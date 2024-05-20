在github放置排程設定檔,統一管理就不用每台手動改了
1.取得腳本,並設定權限
curl -s -o ./fetch_and_run.sh https://raw.githubusercontent.com/78chicken/passive_script/main/run.sh
chmod 775 fetch_and_run.sh
2.設定排程 : sudo crontab -e
  5 3 * * * /opt/daily_job/fetch_and_run.sh  
