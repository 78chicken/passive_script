在github放置設定檔,統一管理就不用每台手動改;以下視需要個別安裝 
1.安裝cockpit  
curl -s -o ./fetch_and_run.sh https://raw.githubusercontent.com/78chicken/passive_script/main/install_cockpit.sh    
chmod 775 install_cockpit.sh    
./install_cockpit.sh  
2.取得腳本,並設定權限  
curl -s -o ./fetch_and_run.sh https://raw.githubusercontent.com/78chicken/passive_script/main/run.sh  
chmod 775 fetch_and_run.sh  
3.設定排程 : sudo crontab -e  
  5 3 * * * /opt/daily_job/fetch_and_run.sh    
