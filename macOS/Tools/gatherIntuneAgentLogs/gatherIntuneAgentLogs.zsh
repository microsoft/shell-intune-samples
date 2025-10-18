#!/bin/zsh
# Collect diagnostics for IntuneMdmDaemon (root) and IntuneMdmAgent (user)

set -e
set -u
set -o pipefail

: "${SAMPLE_SEC:=10}"
: "${SPIN_SEC:=10}"
: "${FS_SEC:=10}"
: "${FS_USAGE_FILTER:=read|write|pread|pwrite|open|close|stat|fstat|pipe}"
: "${FS_USAGE_MAX_LINES:=10000}"
: "${LOG_WINDOW:=20m}"
timestamp() { date +"%Y%m%d_%H%M%S"; }

if (( $EUID != 0 )); then
  echo "[ERROR] This collector must be run with sudo/root privileges." >&2
  exit 1
fi

SUDO=""

ROOTDIR="$(pwd)/IntuneDiagnostics_$(timestamp)"
mkdir -p "$ROOTDIR"

RUN_LOG="$ROOTDIR/collection.log"
exec > >(tee -a "$RUN_LOG") 2>&1
echo "[INFO] Session log: $RUN_LOG"

PROCS=("IntuneMdmDaemon" "IntuneMdmAgent")

echo "[INFO] Starting collection..."
echo "[INFO] Output directory: $ROOTDIR"

for PROC in $PROCS; do
  PID=$(pgrep -x "$PROC" 2>/dev/null || true)
  if [[ -z "$PID" ]]; then
    echo "[WARN] Process $PROC not found — skipping."
    continue
  fi

  OWNER=$(ps -o user= -p $PID | awk '{print $1}')
  CPU=$(ps -o %cpu= -p $PID | awk '{print $1}')
  SUB="$ROOTDIR/${PROC}_pid${PID}_${OWNER}"
  mkdir -p "$SUB"

  echo ""
  echo "[INFO] >>> Capturing for $PROC (PID=$PID, owner=$OWNER, CPU=${CPU:-?}%)"

  # 1. Thread sample
  sample $PID $SAMPLE_SEC -file "$SUB/sample.txt" || true

  # 2. Spindump
  ${SUDO}spindump $PID $SPIN_SEC -file "$SUB/spindump.txt" || true

  # 3. File I/O trace (trimmed and filtered for concise capture)
  echo "[INFO] Running fs_usage for ${FS_SEC}s (filtering: ${FS_USAGE_FILTER})..."
  FS_USAGE_PATH="${SUB}/fs_usage.txt"
  FS_USAGE_ARCHIVE="${FS_USAGE_PATH}.gz"
  ${SUDO}fs_usage -w -f filesys -t ${FS_SEC} ${PID} | grep -E "${FS_USAGE_FILTER}" | head -n "${FS_USAGE_MAX_LINES}" > "${FS_USAGE_PATH}" 2>&1 || true
  
  # 3b. Create fs_usage summary for quick analysis
  echo "[INFO] Creating fs_usage summary..."
  {
    echo "=== FS_USAGE SUMMARY for PID $PID ==="
    echo "Collection time: ${FS_SEC} seconds"
    echo "Generated: $(date)"
    echo "Filter: ${FS_USAGE_FILTER}"
    echo "Line cap: ${FS_USAGE_MAX_LINES}"
    echo ""
    if [[ -f "${FS_USAGE_PATH}" && -s "${FS_USAGE_PATH}" ]]; then
      echo "Operation counts:"
      grep -o -E '^[0-9:.]+ +[a-zA-Z_]+' "${FS_USAGE_PATH}" | awk '{print $2}' | sort | uniq -c | sort -nr | head -10
      echo ""
      echo "File descriptor activity (top 10):"
      grep -o 'F=[0-9]+' "${FS_USAGE_PATH}" | sort | uniq -c | sort -nr | head -10
      echo ""
      echo "Sample entries (first 20 lines):"
      head -20 "${FS_USAGE_PATH}"
    else
      echo "No fs_usage records matched the filter '${FS_USAGE_FILTER}'."
      echo "Consider relaxing FS_USAGE_FILTER or increasing FS_SEC if more detail is needed."
    fi
  } > "${SUB}/fs_usage_summary.txt" 2>&1 || true

  if [[ -f "${FS_USAGE_PATH}" ]]; then
    gzip -9 -f "${FS_USAGE_PATH}" 2>/dev/null || true
    if [[ -f "${FS_USAGE_ARCHIVE}" ]]; then
      echo "Raw fs_usage data stored as $(basename "${FS_USAGE_ARCHIVE}")" >> "${SUB}/fs_usage_summary.txt"
    fi
  fi

  # 4. Memory map summary
  vmmap -summary $PID > "$SUB/vmmap.txt" 2>&1 || true

  # 5. Open files
  lsof -p $PID > "$SUB/lsof.txt" 2>&1 || true

  # 6. Unified logs (explicit path to avoid zsh’s built-in ‘log’)
  /usr/bin/log show --process "$PROC" --last "$LOG_WINDOW" > "$SUB/unified_logs.txt" 2>&1 || true
  /usr/bin/log show --predicate "processID == $PID" --last "$LOG_WINDOW" > "$SUB/unified_logs_by_pid.txt" 2>&1 || true

  # 7. Process context snapshot
  {
    echo "PPID   PID  %CPU %MEM COMMAND"
    ps -o ppid,pid,pcpu,pmem,command -p $PID 2>/dev/null || true
  } > "$SUB/ps_context.txt" || true
done

# 8. Collect Microsoft Intune logs from /Library/Logs/Microsoft/Intune
echo ""
echo "[INFO] >>> Collecting Microsoft Intune logs from /Library/Logs/Microsoft/Intune"
INTUNE_LOGS_DIR="/Library/Logs/Microsoft/Intune"
LOGS_SUB="$ROOTDIR/Microsoft_Intune_Logs"

if [[ -d "$INTUNE_LOGS_DIR" ]]; then
  mkdir -p "$LOGS_SUB"
  
  # Copy all log files from the Intune logs directory
  echo "[INFO] Copying log files from $INTUNE_LOGS_DIR..."
  ${SUDO}cp -R "$INTUNE_LOGS_DIR"/* "$LOGS_SUB/" 2>/dev/null || {
    echo "[WARN] Failed to copy some files from $INTUNE_LOGS_DIR (may require elevated privileges)"
    # Try to copy individual files that are readable
    find "$INTUNE_LOGS_DIR" -type f -readable -exec cp {} "$LOGS_SUB/" \; 2>/dev/null || true
  }
  
  # Create a manifest of all files in the logs directory
  echo "[INFO] Creating log files manifest..."
  {
    echo "=== Microsoft Intune Logs Directory Manifest ==="
    echo "Directory: $INTUNE_LOGS_DIR"
    echo "Collected at: $(date)"
    echo ""
    ${SUDO}find "$INTUNE_LOGS_DIR" -type f -exec ls -la {} \; 2>/dev/null || find "$INTUNE_LOGS_DIR" -type f -exec ls -la {} \; 2>/dev/null || true
  } > "$LOGS_SUB/logs_manifest.txt" || true
  
  echo "[INFO] Microsoft Intune logs collected successfully"
else
  echo "[WARN] Microsoft Intune logs directory not found: $INTUNE_LOGS_DIR"
fi

echo ""
echo "[INFO] Creating zip bundle..."
( cd "$ROOTDIR/.." && zip -r "${ROOTDIR}.zip" "$(basename "$ROOTDIR")" >/dev/null )

echo "[DONE] Logs collected for both processes:"
echo "       ${ROOTDIR}.zip"

CURRENT_USER="${SUDO_USER:-$(id -un)}"
CURRENT_GROUP="$(id -gn "$CURRENT_USER" 2>/dev/null || id -gn 2>/dev/null)"

if id -u "$CURRENT_USER" >/dev/null 2>&1; then
  echo "[INFO] Resetting ownership and permissions for collected artifacts"
  chown -R "$CURRENT_USER":"$CURRENT_GROUP" "$ROOTDIR" 2>/dev/null || echo "[WARN] Failed to update ownership on $ROOTDIR"
  chown "$CURRENT_USER":"$CURRENT_GROUP" "${ROOTDIR}.zip" 2>/dev/null || echo "[WARN] Failed to update ownership on ${ROOTDIR}.zip"
  chmod -R u+rwX "$ROOTDIR" 2>/dev/null || echo "[WARN] Failed to adjust permissions on $ROOTDIR"
  chmod u+rw "${ROOTDIR}.zip" 2>/dev/null || echo "[WARN] Failed to adjust permissions on ${ROOTDIR}.zip"
else
  echo "[WARN] Unable to resolve a non-root owner; artifacts remain with their existing permissions."
fi