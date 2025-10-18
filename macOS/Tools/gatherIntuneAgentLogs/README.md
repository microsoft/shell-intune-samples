# gatherIntuneAgentLogs

## Overview
- Captures targeted diagnostics for the Microsoft Intune agents on macOS: `IntuneMdmDaemon` (root) and `IntuneMdmAgent` (user session).
- Automates thread samples, spindumps, file system tracing, memory maps, open file snapshots, and recent unified logs for each process.
- Copies Microsoft Intune agent logs from `/Library/Logs/Microsoft/Intune` and produces a compressed bundle ready for escalation.

## Prerequisites
- macOS host with Microsoft Intune Company Portal agents installed and running.
- Shell capable of executing zsh scripts (macOS default `/bin/zsh`).
- Run the script with sudo/root privileges; it validates this requirement and exits if not executed as root.

## Usage
1. Open Terminal and change to the tool directory:
   ```zsh
   cd macOS/Tools/gatherIntuneAgentLogs
   ```
2. Run the collector (sudo is mandatory; the script exits immediately if not run as root):
   ```zsh
   sudo ./gatherIntuneAgentLogs.zsh
   ```
3. On completion, the script prints the location of the output bundle: `IntuneDiagnostics_<timestamp>.zip`.

### Adjustable settings
Override the defaults by exporting environment variables before running the script:
- `SAMPLE_SEC` – duration passed to `sample` (default `10`).
- `SPIN_SEC` – duration passed to `spindump` (default `10`).
- `FS_SEC` – seconds to observe file activity with `fs_usage` (default `10`).
- `FS_USAGE_FILTER` – regex filter applied to `fs_usage` output (default `read|write|pread|pwrite|open|close|stat|fstat|pipe`).
- `FS_USAGE_MAX_LINES` – maximum `fs_usage` lines retained before compression (default `10000`).
- `LOG_WINDOW` – unified log lookback window (default `20m`).

Example: `SAMPLE_SEC=30 LOG_WINDOW=2h sudo ./gatherIntuneAgentLogs.zsh`

## Output structure
Each execution creates `IntuneDiagnostics_<YYYYMMDD>_<HHMMSS>/` and a matching zip archive. Within the directory:
- `collection.log` – session transcript describing every capture step.
- `IntuneMdmDaemon_pid<id>_<owner>/` and `IntuneMdmAgent_pid<id>_<owner>/` – per-process artifacts:
  - `sample.txt` – stack samples (`sample` output).
  - `spindump.txt` – short-duration `spindump` capture.
  - `fs_usage.txt.gz` + `fs_usage_summary.txt` – compressed raw file activity and a top-level summary.
  - `vmmap.txt` – `vmmap -summary` output.
  - `lsof.txt` – open file descriptor list.
  - `unified_logs*.txt` – unified logging extracts by process name and PID.
  - `ps_context.txt` – lightweight `ps` snapshot recording PPID, CPU, and memory.
- `Microsoft_Intune_Logs/` – copy of `/Library/Logs/Microsoft/Intune` with a `logs_manifest.txt` inventory.

## Tool reference
- **sample** – Captures thread backtraces at a configurable interval to reveal current stack states. Docs: run `man sample` on macOS.
- **spindump** – Records call stacks and scheduling delays for diagnosing hangs or beachballs. Docs: run `man spindump`.
- **fs_usage** – Streams file system operations for the selected PID, helpful for spotting heavy I/O, permission issues, or path access patterns. Docs: run `man fs_usage`.
- **vmmap** – Summarises virtual memory regions and allocations for the process. Docs: run `man vmmap`.
- **lsof** – Lists open files and sockets, allowing you to confirm network and file handles in use. Docs: run `man lsof`.
- **log show** – Queries the unified logging subsystem so you can correlate Intune events across the configured time window. Docs: run `man log` or see the unified logging section in Apple Developer documentation.
- **ps** – Provides a quick snapshot of parent PID, CPU, and memory usage for each targeted process. Docs: run `man ps`.

## Tips
- If `fs_usage_summary.txt` reports no matching records, increase `FS_SEC` or relax `FS_USAGE_FILTER` to capture quieter intervals.
- When troubleshooting intermittent spikes, run the script multiple times or expand `LOG_WINDOW` to ensure the relevant entries fall inside the lookback window.
- Share only the generated zip bundle with support to keep the working directory clean.
- When invoked via `sudo`, the script resets ownership of the output folder and zip bundle to the original caller so the artifacts remain readable without elevated rights.
