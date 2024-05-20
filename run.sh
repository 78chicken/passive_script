#!/bin/bash

# 保存到/opt/daily_job/restart.sh
export restart_path=/opt/daily_job
curl -s -o $restart_path/restart.sh https://raw.githubusercontent.com/78chicken/passive_script/main/restart.sh

# 確保脚本是可執行的
chmod +x $restart_path/restart.sh

# 執行腳本
$restart_path/restart.sh
