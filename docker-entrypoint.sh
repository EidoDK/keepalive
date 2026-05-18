#!/usr/bin/env sh
set -eu

: "${TARGET:?TARGET is required}"
: "${LOGFILE:=/logs/heartbeat.log}"
: "${INTERVAL:=21600}"

mkdir -p "$(dirname "$LOGFILE")"
chmod 0777 "$(dirname "$LOGFILE")" 2>/dev/null || true

while :; do
    /usr/local/bin/keepalive.sh -t "$TARGET" -l "$LOGFILE"
    sleep "$INTERVAL"
done
