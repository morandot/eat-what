#!/usr/bin/env bash
# Notify IndexNow (Bing / Yandex / Seznam / Naver) that URLs changed, so they get
# crawled and indexed quickly instead of waiting for the next scheduled crawl.
#
# Usage:
#   scripts/ping-indexnow.sh              # submit every <loc> in public/sitemap.xml
#   scripts/ping-indexnow.sh <url> [...]  # submit only the given URLs
#
# Env overrides:
#   SITE_ORIGIN        canonical origin, e.g. https://eatwhat.nopress.net
#   SITEMAP_FILE       sitemap to read URLs from (default: public/sitemap.xml)
#   INDEXNOW_ENDPOINT  override the API endpoint
#
# Exit codes: 0 = accepted (an HTTP 429 rate-limit is logged but not fatal — the
#             next deploy retries), 1 = config/preflight error, 2 = API rejection.
set -euo pipefail

cd "$(dirname "$0")/.."

SITE_ORIGIN="${SITE_ORIGIN:-https://eatwhat.nopress.net}"
SITEMAP_FILE="${SITEMAP_FILE:-public/sitemap.xml}"
ENDPOINTS=("${INDEXNOW_ENDPOINT:-https://api.indexnow.org/indexnow}")

# --- Locate the IndexNow key file -------------------------------------------------
# The key is a hex string; public/<key>.txt must contain the key itself and is
# served from the site root. Match on the filename pattern so unrelated .txt
# files (llms.txt, robots.txt, ads.txt, security.txt, ...) can never be mistaken
# for the key. 32 hex chars is what this repo deploys; 64 is the other convention.
KEY_FILE=""
hex_re="^([0-9a-fA-F]{32}|[0-9a-fA-F]{64})$"
for f in public/*.txt; do
  [[ -f "$f" ]] || continue
  stem="$(basename "$f" .txt)"
  if [[ "$stem" =~ $hex_re ]]; then
    KEY_FILE="$f"
    KEY="$stem"
    break
  fi
done
if [[ -z "$KEY_FILE" ]]; then
  echo "error: no IndexNow key file in public/ (expected <32-hex>.txt)" >&2
  found="$(ls public/*.txt 2>/dev/null || true)"
  if [[ -n "$found" ]]; then
    echo "       found: $(printf '%s' "$found" | tr '\n' ' ')" >&2
  else
    echo "       (no .txt files in public/ at all)" >&2
  fi
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

# This guard MUST stay above every "${URLS[@]}" expansion: on bash < 4.4 (macOS
# still ships 3.2) expanding a declared-but-empty array under set -u is fatal.
if [[ ${#URLS[@]} -eq 0 ]]; then
  echo "error: no URLs to submit" >&2
  exit 1
fi

HOST="${SITE_ORIGIN#*://}"
HOST="${HOST%%/*}"

# --- Preflight: the key file must be publicly reachable and match its filename ----
# One fetch for status + body (no TOCTOU between two GETs). On any curl failure
# the status collapses to a clean 000 instead of a polluted capture.
echo "==> IndexNow key: $KEY"
echo "==> key location: $KEY_URL"
NL=$'\n'
RESP="$(curl -sS -L -w $'\n%{http_code}' "$KEY_URL")" || RESP="$NL"000
KEY_STATUS="${RESP##*"$NL"}"
KEY_BODY="${RESP%"$NL"*}"
if [[ "$KEY_STATUS" != "200" ]]; then
  echo "error: key file not reachable (HTTP $KEY_STATUS): $KEY_URL" >&2
  echo "       deploy the site first — IndexNow validates the key before indexing." >&2
  exit 1
fi
SERVED_KEY="$(printf '%s' "$KEY_BODY" | tr -d '[:space:]')"
if [[ "$SERVED_KEY" != "$KEY" ]]; then
  echo "error: served key file does not match its filename" >&2
  echo "       expected: $KEY" >&2
  echo "       served:   $SERVED_KEY" >&2
  exit 1
fi

# --- Build the JSON body ----------------------------------------------------------
# Pure-bash escaping and explicit per-entry quoting: immune to commas inside URLs
# (a sed/paste join silently split "a,b" into two entries) and needs no jq/node.
URL_JSON=""
for u in "${URLS[@]}"; do
  esc="${u//\\/\\\\}"    # escape backslash first...
  esc="${esc//\"/\\\"}"  # ...then double quotes
  URL_JSON+="\"$esc\"",
done
URL_JSON="${URL_JSON%,}"
BODY="{\"host\":\"$HOST\",\"key\":\"$KEY\",\"keyLocation\":\"$KEY_URL\",\"urlList\":[$URL_JSON]}"

echo "==> submitting ${#URLS[@]} URL(s) for $HOST"
printf '    %s\n' "${URLS[@]}"

# --- Submit -----------------------------------------------------------------------
FAILED=0
RATE_LIMITED=0
for endpoint in "${ENDPOINTS[@]}"; do
  TMP_FILE="$(mktemp)"
  STATUS="$(curl -sS -o "$TMP_FILE" -w '%{http_code}' \
    -X POST "$endpoint" \
    -H 'Content-Type: application/json; charset=utf-8' \
    --data "$BODY")" || STATUS=000

  case "$STATUS" in
    200) NOTE='OK - URLs submitted' ;;
    202) NOTE='Accepted - key validation pending' ;;
    400) NOTE='Bad request - invalid URL format' ;;
    403) NOTE='Forbidden - key not valid / key file unreachable' ;;
    422) NOTE='Unprocessable - URLs do not belong to host, or key mismatch' ;;
    429) NOTE='Rate limited - retried on the next deploy' ;;
    000) NOTE='No response - network error' ;;
    *)   NOTE='Unexpected status' ;;
  esac

  echo "==> $endpoint -> HTTP $STATUS ($NOTE)"

  if [[ "$STATUS" == "429" ]]; then
    RATE_LIMITED=1   # transient by definition; the next deploy pings again
  elif [[ "$STATUS" != "200" && "$STATUS" != "202" ]]; then
    FAILED=1
    if [[ -s "$TMP_FILE" ]]; then sed 's/^/    /' "$TMP_FILE"; fi
  fi
  rm -f "$TMP_FILE"
done

if [[ "$FAILED" -ne 0 ]]; then
  echo "error: IndexNow submission was rejected" >&2
  exit 2
fi

if [[ "$RATE_LIMITED" -ne 0 ]]; then
  echo "==> done (rate-limited; the next deploy will retry)"
else
  echo "==> done"
fi
