#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
LOG_FILE="$SCRIPT_DIR/log/error.log"

notify_disconnect() {
    /usr/bin/osascript -e \
        'display notification "インターネット接続が切れてませんか？ネットワークを確認してください。" with title "通信エラーです"'
}

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# ネットワーク有無のみの確認
if ! /sbin/ping -c1 -t1 8.8.8.8 >/dev/null 2>&1; then
  log "ネットワークにアクセスできません"
  exit 0
fi

# 
for i in 1 2 3; do
  /sbin/ping -c1 -t1 jpsern.com >/dev/null 2>&1 && exit 0
  sleep 5
done

log "再試行しましたが通信に失敗しました"
notify_disconnect

