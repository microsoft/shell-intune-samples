#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# betaTokens.sh
#
# This script automates the process of obtaining and extracting Apple MDM
# server tokens (*.p7m) for beta OS enrollment via Apple Business Manager (ABM).
#
# Features:
#   - Generates a private key and self-signed certificate if needed.
#   - Watches for new *.p7m tokens in your Downloads folder.
#   - Decrypts and extracts OAuth credentials from the server token.
#   - Authenticates to Apple's MDM service and fetches available beta enrollment tokens.
#   - Displays all available beta tokens in a readable table, grouped and sorted by OS.
#
# Requirements:
#   - openssl, jq, curl, python3 (for URL encoding)
#
# Usage:
#   Run this script in a directory where you want to manage your ABM tokens.
#   The script will guide you through the process if no valid tokens are found.
#
# neiljohn@microsoft.com
#
###############################################################################

# --- Dependency Checks -------------------------------------------------------
REQUIRED_BINS=(openssl jq curl perl)  # perl required for urlenc
for bin in "${REQUIRED_BINS[@]}"; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "[ERROR] Required dependency '$bin' is not installed or not in PATH." >&2
    exit 1
  fi
done
# -----------------------------------------------------------------------------

# --- Configuration -----------------------------------------------------------
WORKDIR="./abm_auth"      # Directory to store keys, certs, and tokens
POLL_INTERVAL=5           # Seconds between checks for new tokens in Downloads
# -----------------------------------------------------------------------------

mkdir -p "$WORKDIR"
cd "$WORKDIR"

# --- 1) Find or generate your .p7m server token ------------------------------
# If all required files exist, use them immediately (no prompting)
if [[ -f mdm_private.key && -f mdm_public_cert.pem && -f *.p7m ]]; then
  shopt -s nullglob
  tokens=( *.p7m )
  P7M_FILE="${tokens[-1]}"
  echo "[INFO] Using existing certs and token: $P7M_FILE"
else
  # Look for any existing .p7m tokens first (use the first one found, no prompt)
  shopt -s nullglob
  for cand in *.p7m; do
    echo "[INFO] Found existing token: $cand"
    P7M_FILE="$cand"
    break
  done

  # If no token found, generate key/cert and wait for user to upload/download
  if [[ -z "${P7M_FILE-}" ]]; then
    echo "[INFO] No .p7m found in $WORKDIR."
    echo "[ACTION] A certificate will be generated – upload the PEM to ABM, then"
    echo "         download the issued *.p7m token (it usually lands in ~/Downloads)."
    # Generate private key, CSR, and self-signed certificate
    echo "[INFO] No .p7m found: generating key + self-signed cert…"
    openssl genrsa -out mdm_private.key 2048
    openssl req -new -key mdm_private.key -out mdm_request.csr \
      -subj "/CN=Your MDM Server"
    openssl x509 -req -days 365 -in mdm_request.csr \
      -signkey mdm_private.key -out mdm_public_cert.pem

    cat <<EOF

[ACTION] Upload this PEM to Apple Business Manager (Settings → MDM Servers)

────────────────────────────────────────────────────────────────
$(cat mdm_public_cert.pem)
────────────────────────────────────────────────────────────────

After ABM issues you a *.p7m server token, drop it into this directory.

EOF

    # Watch Downloads for new *.p7m tokens and copy them to WORKDIR
    DOWNLOADS="${HOME}/Downloads"
    echo "[INFO] Watching $DOWNLOADS for NEW *.p7m files (every ${POLL_INTERVAL}s)…"
    shopt -s nullglob
    SEEN_FILES=()
    for f in "${DOWNLOADS}"/*.p7m; do SEEN_FILES+=("$f"); done

    # Helper: returns 0 if file is already in SEEN_FILES, 1 otherwise
    file_seen() {
      local p
      for p in "${SEEN_FILES[@]:-}"; do
        [[ "$p" == "$1" ]] && return 0
      done
      return 1
    }

    while true; do
      # Copy any new *.p7m from Downloads to WORKDIR
      for dl in "${DOWNLOADS}"/*.p7m; do
        [[ -e "$dl" ]] || continue
        if ! file_seen "$dl"; then
          SEEN_FILES+=("$dl")
          echo "[INFO] New token detected in Downloads: $(basename "$dl")"
          cp "$dl" .   # Already inside $WORKDIR
        fi
      done

      # If at least one token exists, use the newest one immediately
      shopt -s nullglob
      tokens=( *.p7m )
      if (( ${#tokens[@]} )); then
        newest=$(ls -1tr *.p7m | tail -n1)
        echo "[INFO] Using token: $newest"
        P7M_FILE="$newest"
        break
      fi

      sleep "$POLL_INTERVAL"
    done
  fi
fi

echo "[INFO] Using server token file: $P7M_FILE"

# --- 2) Strip S/MIME envelope to plain JSON -----------------------------------
echo "[INFO] Stripping S/MIME wrapper…"
# Remove S/MIME headers (first 5 lines)
tail -n +6 "$P7M_FILE" > raw.base64
# Base64-decode to DER format
base64 -D -i raw.base64 -o token.der
# Decrypt with private key/cert to extract the JSON payload
openssl smime -decrypt \
  -inform DER \
  -in token.der \
  -recip mdm_public_cert.pem \
  -inkey mdm_private.key \
  -out server_token.json || {
    echo "[ERROR] Failed to decrypt .p7m – does it match the generated PEM uploaded to ABM?" >&2
    exit 1
}

# Extract JSON from message block (handles JSON on same line as BEGIN)
grep -o '{.*}' server_token.json > token.json

# --- 3) Parse the JSON fields -------------------------------------------------
CONSUMER_KEY=$(jq -r .consumer_key    token.json)
CONSUMER_SECRET=$(jq -r .consumer_secret token.json)
ACCESS_TOKEN=$(jq -r .access_token     token.json)
ACCESS_SECRET=$(jq -r .access_secret    token.json)

echo "[INFO] Got credentials:"
echo "  consumer_key:    $CONSUMER_KEY"
echo "  consumer_secret: $CONSUMER_SECRET"
echo "  access_token:    $ACCESS_TOKEN"
echo "  access_secret:   $ACCESS_SECRET"
echo "  access_expires:  $(jq -r .access_token_expiry token.json)"

# --- 4) Build OAuth-1.0a header for /session ----------------------------------
echo "[INFO] Building OAuth header for session request…"
METHOD="GET"
SESSION_ENDPOINT="https://mdmenrollment.apple.com/session"
SIG_M="HMAC-SHA1"                     # Apple spec
TIMESTAMP=$(date +%s)
NONCE=$(openssl rand -hex 8)
OAUTH_V="1.0"

# Helper: URL-encode for OAuth (RFC 3986)
urlenc() {
  perl -MURI::Escape -ne 'chomp;print uri_escape($_,"^-._~A-Za-z0-9")'
}

# Prepare OAuth parameters
PARAM_KVS=(
  "oauth_consumer_key=$CONSUMER_KEY"
  "oauth_nonce=$NONCE"
  "oauth_signature_method=$SIG_M"
  "oauth_timestamp=$TIMESTAMP"
  "oauth_token=$ACCESS_TOKEN"
  "oauth_version=$OAUTH_V"
)

# Build parameter string (sorted, URL-encoded)
PARAM_STRING=$(
  printf '%s\n' "${PARAM_KVS[@]}" \
  | while IFS='=' read -r k v; do
      printf '%s=%s\n' "$(printf '%s' "$k" | urlenc)" "$(printf '%s' "$v" | urlenc)"
    done \
  | LC_ALL=C sort | paste -sd '&' -
)

# Build OAuth base string and signature
BASE_STRING=$(printf '%s&%s&%s' \
  "$(printf '%s' "$METHOD" | urlenc)" \
  "$(printf '%s' "$SESSION_ENDPOINT" | urlenc)" \
  "$(printf '%s' "$PARAM_STRING" | urlenc)"
)
SIGN_KEY="$(printf '%s&%s' "$(printf '%s' "$CONSUMER_SECRET" | urlenc)" "$(printf '%s' "$ACCESS_SECRET" | urlenc)")"
OAUTH_SIG=$(printf '%s' "$BASE_STRING" | openssl dgst -binary -sha1 -hmac "$SIGN_KEY" | base64 | urlenc)

REALM="ADM"

# Compose OAuth header
OAUTH_HEADER="OAuth realm=\"${REALM}\","
for kv in "${PARAM_KVS[@]}"; do
  IFS='=' read -r k v <<<"$kv"
  OAUTH_HEADER+="$k=\"$(printf '%s' "$v" | urlenc)\","
done
OAUTH_HEADER+="oauth_signature=\"$OAUTH_SIG\""

# --- 5) Fetch the auth_session_token ------------------------------------------
echo "[INFO] Requesting session token…"
SESSION_JSON_AND_CODE=$(curl -sS -w '\n%{http_code}' -X GET  "$SESSION_ENDPOINT" \
                         -H "Authorization: $OAUTH_HEADER" \
                         -H "Accept: application/json")

SESSION_JSON=${SESSION_JSON_AND_CODE%$'\n'*}
HTTP_CODE=${SESSION_JSON_AND_CODE##*$'\n'}

if [[ "$HTTP_CODE" != "200" ]]; then
  echo "[ERROR] Session request failed (HTTP $HTTP_CODE)"; exit 1
fi

AUTH_SESSION_TOKEN=$(printf '%s' "$SESSION_JSON" \
                     | jq -r 'try .auth_session_token // empty' 2>/dev/null)

if [[ -z "$AUTH_SESSION_TOKEN" ]]; then
  echo "[ERROR] auth_session_token missing in response"; exit 1
fi
echo "[INFO] Got session token."

# --- 6) Call the beta-enrollment tokens endpoint ------------------------------
TOKENS_ENDPOINT="https://mdmenrollment.apple.com/os-beta-enrollment/tokens"
echo "[INFO] Fetching beta-enrollment tokens…"

TOKENS_JSON_AND_CODE=$(curl -sS -w '\n%{http_code}' -X GET "$TOKENS_ENDPOINT" \
  -H "X-ADM-Auth-Session: $AUTH_SESSION_TOKEN" \
  -H "X-Server-Protocol-Version: 1" \
  -H "Accept: application/json")

TOKENS_JSON=${TOKENS_JSON_AND_CODE%$'\n'*}
TOKENS_HTTP=${TOKENS_JSON_AND_CODE##*$'\n'}

if [[ "$TOKENS_HTTP" != "200" ]]; then
  echo "[ERROR] Tokens request failed (HTTP $TOKENS_HTTP)"; exit 1
fi

echo "[INFO] Available beta programs:"

# Find max widths for each column (scan all tokens, not grouped)
max_title=5
max_os=2
max_token=5
while IFS=$'\t' read -r title os token; do
  (( ${#title} > max_title )) && max_title=${#title}
  (( ${#os} > max_os )) && max_os=${#os}
  (( ${#token} > max_token )) && max_token=${#token}
done < <(echo "$TOKENS_JSON" | jq -r '.betaEnrollmentTokens[] | [.title, .os, .token] | @tsv')
((max_title+=2))
((max_os+=2))
((max_token+=2))

# Print table header
printf "┌-%-${max_title}s-┬-%-${max_os}s-┬-%-${max_token}s-┐\n" "$(printf '─%.0s' $(seq 1 $max_title))" "$(printf '─%.0s' $(seq 1 $max_os))" "$(printf '─%.0s' $(seq 1 $max_token))"
printf "│ %-${max_title}s │ %-${max_os}s │ %-${max_token}s │\n" "Title" "OS" "Token"
printf "├-%-${max_title}s-┼-%-${max_os}s-┼-%-${max_token}s-┤\n" "$(printf '─%.0s' $(seq 1 $max_title))" "$(printf '─%.0s' $(seq 1 $max_os))" "$(printf '─%.0s' $(seq 1 $max_token))"

# Print sorted tokens by Title (column 1)
tokens_sorted=$(echo "$TOKENS_JSON" | jq -r '.betaEnrollmentTokens[] | [.title, .os, .token] | @tsv' | sort -k1,1)
line_count=$(echo "$tokens_sorted" | wc -l | tr -d ' ')
line_num=0
echo "$tokens_sorted" | while IFS=$'\t' read -r title os token; do
  line_num=$((line_num+1))
  printf "│ %-${max_title}s │ %-${max_os}s │ %-${max_token}s │\n" "$title" "$os" "$token"
  if [[ $line_num -lt $line_count ]]; then
    printf "├-%-${max_title}s-┼-%-${max_os}s-┼-%-${max_token}s-┤\n" "$(printf '─%.0s' $(seq 1 $max_title))" "$(printf '─%.0s' $(seq 1 $max_os))" "$(printf '─%.0s' $(seq 1 $max_token))"
  fi
done

# Print table footer
printf "└-%-${max_title}s-┴-%-${max_os}s-┴-%-${max_token}s-┘\n" "$(printf '─%.0s' $(seq 1 $max_title))" "$(printf '─%.0s' $(seq 1 $max_os))" "$(printf '─%.0s' $(seq 1 $max_token))"