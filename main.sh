#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
LOG_FILE="$SCRIPT_DIR/log/error.log"

notify_disconnect() {
    osascript -e 'display notification "インターネット接続が切れてませんか？ネットワークを確認してください。" with title "通信エラーです"'
}

log() {
    local message="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - ${message}" >> "$LOG_FILE"
}

PING_OUTPUT=$(/sbin/ping -c1 www.google.com 2>&1)
PING_EXIT_CODE=$?
if [ $PING_EXIT_CODE -ne 0 ]; then
    log "ping failed with exit code $PING_EXIT_CODE"
    log "$PING_OUTPUT"
    notify_disconnect
fi


