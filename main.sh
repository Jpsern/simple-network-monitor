#!/bin/bash

# 未定義変数アクセスは即エラー
set -u

SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
ENV_FILE="$SCRIPT_DIR/.env"

# .envの内容を環境変数として読み込む
load_env() {
    if [ -f "$ENV_FILE" ]; then
        set -a
        . "$ENV_FILE"
        set +a
    fi
}

load_env

LOG_DIR="${LOG_DIR:-"$SCRIPT_DIR/log"}"
LOG_FILE="${LOG_FILE:-"$LOG_DIR/error.log"}"
PING_BIN="${PING_BIN:-/sbin/ping}"
NETWORK_CHECK_TARGET="${NETWORK_CHECK_TARGET:-8.8.8.8}"
SERVICE_HOST="${SERVICE_HOST:-}"
PING_COUNT="${PING_COUNT:-1}"
PING_TIMEOUT="${PING_TIMEOUT:-1}"
RETRY_COUNT="${RETRY_COUNT:-3}"
RETRY_INTERVAL="${RETRY_INTERVAL:-5}"

# SERVICE_HOSTが未設定なら即終了
require_service_host() {
    if [ -z "$SERVICE_HOST" ]; then
        echo "SERVICE_HOSTが設定されていません。.envまたは環境変数で指定してください。" >&2
        exit 1
    fi
}

# 通信エラー通知
notify_disconnect() {
    /usr/bin/osascript -e \
        'display notification "インターネット接続が切れてませんか？ネットワークを確認してください。" with title "通信エラーです"'
}

# ログファイルへメッセージを記録
log() {
    mkdir -p "$LOG_DIR"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# 指定ホストへ1回だけpingを打つ
ping_once() {
    local target_host=$1
    "$PING_BIN" -c "$PING_COUNT" -t "$PING_TIMEOUT" "$target_host" >/dev/null 2>&1
}

# インターネット疎通確認
check_network_reachable() {
    if ping_once "$NETWORK_CHECK_TARGET"; then
        return 0
    fi

    log "ネットワークにアクセスできません"
    return 1
}

# 監視対象ホストへの再試行付きping
check_service_with_retry() {
    local attempt=1

    while [ "$attempt" -le "$RETRY_COUNT" ]; do
        if ping_once "$SERVICE_HOST"; then
            return 0
        fi

        if [ "$attempt" -lt "$RETRY_COUNT" ]; then
            sleep "$RETRY_INTERVAL"
        fi

        attempt=$((attempt + 1))
    done

    return 1
}

# エントリーポイント
main() {
    require_service_host

    if ! check_network_reachable; then
        exit 0
    fi

    if check_service_with_retry; then
        exit 0
    fi

    log "再試行しましたが通信に失敗しました"
    notify_disconnect
}

main "$@"
