#!/usr/bin/env bash
# Notify IndexNow (Bing / Yandex / Seznam / Naver) that URLs changed, so they get
# crawled and indexed quickly instead of waiting for the next scheduled crawl.
#
# Usage:
#   scripts/ping-indexnow.sh              # submit every <loc> in public/sitemap.xml
#   scripts/ping-indexnow.sh <url> [...]  # submit only the given URLs
#
# Env overrides:
#   SITE_ORIGIN   canonical origin, e.g. https://eatwhat.nopress.net
#   SITEMAP_FILE  sitemap to read URLs from (default: public/sitemap.xml)
#   INDEXNOW_ENDPOINT  override the API endpoint
#
# Exit codes: 0 = accepted by every endpoint, 1 = config/preflight error,
#             2 = the API rejected the submission.
set -euo pipefail

cd "$(dirname "$0")/.."

SITE_ORIGIN="${SITE_ORIGIN:-https://eatwhat.nopress.net}"
SITEMAP_FILE="${SITEMAP_FILE:-public/sitemap.xml}"
ENDPOINTS=("${INDEXNOW_ENDPOINT:-https://api.indexnow.org/indexnow}")

# --- Locate the IndexNow key file -------------------------------------------------
# The key is the filename stem of a <key>.txt file served from the site root.
KEY_FILE="$(find public -maxdepth 1 -name '*.txt' ! -name 'llms.txt' ! -name 'robots.txt' | head -1)"
if [[ -z "$KEY_FILE" ]]; then
  echo "error: no IndexNow key file found in public/ (expected <32+ hex chars>.txt)" >&2
  exit 1
fi
KEY="$(basename "$KEY_FILE" .txt)"

if [[ ! "$KEY" =~ ^[a-fA-F0-9]{8,128}$ ]]; then
  echo "error: IndexNow key '$KEY' does not look like a hex key" >&2
  exit 1
fi

KEY_URL="$SITE_ORIGIN/$KEY.txt"

# --- Collect URLs -----------------------------------------------------------------
if [[ $# -gt 0 ]]; then
  URLS=("$@")
else
  if [[ ! -f "$SITEMAP_FILE" ]]; then
    echo "error: sitemap not found at $SITEMAP_FILE" >&2
    exit 1
  fi
  # One <loc> per line, trimmed.
  URLS=()
  while IFS= read -r loc; do
    [[ -n "$loc" ]] && URLS+=("$loc")
  done < <(grep -o '<loc>[^<]*</loc>' "$SITEMAP_FILE" | sed -e 's|<loc>||' -e 's|</loc>||' -e 's|^[[:space:]]*||' -e 's|[[:space:]]*$||')
fi

if [[ ${#URLS[@]} -eq 0 ]]; then
  echo "error: no URLs to submit" >&2
  exit 1
fi

HOST="${SITE_ORIGIN#*://}"
HOST="${HOST%%/*}"

# --- Preflight: the key file must be publicly reachable ---------------------------
echo "==> IndexNow key: $KEY"
echo "==> key location: $KEY_URL"
KEY_STATUS="$(curl -s -o /dev/null -w '%{http_code}' -L "$KEY_URL" || echo 000)"
if [[ "$KEY_STATUS" != "200" ]]; then
  echo "error: key file not reachable (HTTP $KEY_STATUS): $KEY_URL" >&2
  echo "       deploy the site first — IndexNow validates the key before indexing." >&2
  exit 1
fi
SERVED_KEY="$(curl -s -L "$KEY_URL" | tr -d '[:space:]')"
if [[ "$SERVED_KEY" != "$KEY" ]]; then
  echo "error: served key file does not match its filename" >&2
  echo "       expected: $KEY" >&2
  echo "       served:   $SERVED_KEY" >&2
  exit 1
fi

# --- Build the JSON body ----------------------------------------------------------
URL_JSON="$(printf '%s\n' "${URLS[@]}" | sed 's/\\/\\\\/g; s/"/\\"/g' | paste -sd, - | sed 's/,/","/g')"
BODY="{\"host\":\"$HOST\",\"key\":\"$KEY\",\"keyLocation\":\"$KEY_URL\",\"urlList\":[\"$URL_JSON\"]}"

echo "==> submitting ${#URLS[@]} URL(s) for $HOST"
printf '    %s\n' "${URLS[@]}"

# --- Submit -----------------------------------------------------------------------
FAILED=0
for endpoint in "${ENDPOINTS[@]}"; do
  STATUS="$(curl -s -o /tmp/indexnow-response.$$ -w '%{http_code}' \
    -X POST "$endpoint" \
    -H 'Content-Type: application/json; charset=utf-8' \
    --data "$BODY" || echo 000)"

  case "$STATUS" in
    200) NOTE="OK - URLs submitted" ;;
    202) NOTE="Accepted - key validation pending" ;;
    400) NOTE="Bad request - invalid URL format" ;;
    403) NOTE="Forbidden - key not valid / not found" ;;
    422) NOTE="Unprocessable - URLs do not belong to host, or key mismatch" ;;
    429) NOTE="Too many requests - rate limited, retry later" ;;
    000) NOTE="No response - network error" ;;
    *)   NOTE="Unexpected status" ;;
  esac

  echo "==> $endpoint -> HTTP $STATUS ($NOTE)"
  if [[ "$STATUS" != "200" && "$STATUS" != "202" ]]; then
    FAILED=1
    [[ -s /tmp/indexnow-response.$$ ]] && sed 's/^/    /' /tmp/indexnow-response.$$
  fi
  rm -f /tmp/indexnow-response.$$
done

if [[ "$FAILED" -ne 0 ]]; then
  echo "error: IndexNow submission was rejected" >&2
  exit 2
fi

echo "==> done"
