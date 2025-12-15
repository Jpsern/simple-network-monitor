# Simple Network Monitor

## 基本的な使い方
1. `.env.example` をコピーして `.env` を作成し、必須の `SERVICE_HOST` を設定します。
   ```bash
   cp .env.example .env
   echo "SERVICE_HOST=example.com" >> .env  # 監視対象ホストを指定
   ```
2. スクリプトに実行権限がない場合は付与します（初回のみ）。
   ```bash
   chmod +x ./main.sh
   ```
3. 実行します。
   ```bash
   ./main.sh
   ```
4. ログ出力先はデフォルトで `log/error.log` です。必要に応じて `.env` で `LOG_DIR` や `LOG_FILE` を変更できます。

## 応用
### cronで定期実行
1. リポジトリの絶対パスを確認します（例: `/Users/you/simple-network-monitor`）。  
   `.env` も同ディレクトリに置いておきます。
2. `crontab -e` でジョブを追加します。月曜から金曜の9時から18時まで5分ごとに実行する例:
    ```bash
    */5 9-18 * * 1-5 sh /Users/you/simple-network-monitor/main.sh > /dev/null 2>&1
    ```
