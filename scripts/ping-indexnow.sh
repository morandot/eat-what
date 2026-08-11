#!/usr/bin/env bash
# Ping IndexNow (Bing / Yandex) after deploy so new content is discovered quickly.
# Usage: scripts/ping-indexnow.sh
set -euo pipefail

KEY_FILE=$(find public -maxdepth 1 -name "*.txt" ! -name "llms.txt" ! -name "robots.txt" | head -1)
HOST="https://eatwhat.nopress.net"

if [[ -z "$KEY_FILE" ]]; then
  echo "error: no IndexNow key file found in public/" >&2
  exit 1
fi

KEY=$(basename "$KEY_FILE" .txt)

curl -s -o /dev/null -w "ping indexnow: %{http_code}\n" \
  "https://api.indexnow.org/indexnow" \
  -H "Content-Type: application/json" \
  --data "{\"host\":\"${HOST#https://}\",\"key\":\"$KEY\",\"keyLocation\":\"$HOST/$KEY.txt\",\"urlList\":[\"$HOST/\"]}"
