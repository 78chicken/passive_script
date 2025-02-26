#!/bin/bash

BASE_DIR="/opt"
SLEEP_TIME=${1:-30s}  # 預設值為 30 秒
ACTION=${2:-START}    # 預設為 START

# 讀取 /opt/key.txt
KEY_FILE="${BASE_DIR}/daily_job/key.txt"
if [[ ! -f "$KEY_FILE" ]]; then
    echo "錯誤: 找不到 $KEY_FILE"
    exit 1
fi

# 讀取 GitHub Token
GITHUB_TOKEN=$(sed -n '1p' "$KEY_FILE" | tr -d '[:space:]')
if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "錯誤: key.txt 內容格式錯誤，請確保第一行是 GitHub Token"
    exit 1
fi

# 讀取 name/value 配對
declare -A CONTAINER_ACCOUNTS
while IFS=: read -r name value; do
    name=$(echo "$name" | tr -d '[:space:]')
    value=$(echo "$value" | tr -d '[:space:]')
    if [[ -n "$name" && -n "$value" ]]; then
        CONTAINER_ACCOUNTS["$name"]="$value"
    fi
done < <(tail -n +2 "$KEY_FILE")
# 印出 CONTAINER_ACCOUNTS 內容
echo "讀取到的容器帳號對應關係:"
for key in "${!CONTAINER_ACCOUNTS[@]}"; do
    echo "$key -> ${CONTAINER_ACCOUNTS[$key]}"
done
# GitHub API 設定
GITHUB_REPO="78chicken/config"
GITHUB_API="https://api.github.com/repos/${GITHUB_REPO}/contents"

# 設定每個容器是否需要從 GitHub 下載更新 (Y=下載，N=本地方式)
UPDATE_HoneyGain="Y"
UPDATE_Traffmonetizer="N"
UPDATE_Traffmonetizer2="N"
UPDATE_EarnApp="N"
UPDATE_Repocket="N"
UPDATE_PacketStream="N"
UPDATE_EarnFm="N"
UPDATE_IPRoyal="N"
UPDATE_Grass="N"
UPDATE_ProxyRack="N"
UPDATE_BlockMesh="N"
UPDATE_Titan="N"
#目前無法賺錢的
#Grass / Dawn / BlockMesh / DistributeAi


# 下載並執行腳本
process_container() {
    local container_name=$1
    local update_flag=$2
    local project_name=$3    
    local action_flag=$4

    if [[ "$update_flag" == "Y" ]]; then      
        
        echo "[$container_name] 下載 設定 ...$GITHUB_API/${project_name}/${CONTAINER_ACCOUNTS[$project_name]}/${CONTAINER_ACCOUNTS[$project_name]}/run.sh"
        sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${BASE_DIR}/$project_name/run.sh" "$GITHUB_API/${project_name}/${CONTAINER_ACCOUNTS[$project_name]}/run.sh"
        
        sudo bash ${BASE_DIR}/$project_name/run.sh 
    else
        echo "[$container_name] 使用 Podman 重新啟動容器..."
        sudo podman container stop "$container_name"      
        if [[ "$action_flag" == "START" ]]; then
            sleep "$sleep_time"
            sudo podman container start "$container_name"    
        else
            echo "[$container_name] 動作為 STOP，跳過啟動"
        fi
    fi
}

# 依據設定執行不同的更新方式

process_container "HoneyGain" "$UPDATE_HoneyGain" "honeygain" "$ACTION"


# 清理沒有 tag 的 images
echo "清理未標記的 images..."
#sudo podman images -f "dangling=true" -q | xargs sudo podman rmi -f

# 清理未使用的 images
echo "清理未使用的 images..."
#sudo podman image prune -a -f
