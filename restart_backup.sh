#!/bin/bash
BASE_DIR="/opt"
SLEEP_TIME=${1:-30s}  # 預設值為 30 秒
ACTION=${2:-START}    # 預設為 START

# 取得 ens192 的 IPv4 最後一組數字
LAST_IP_OCTET=$(ip -4 a show ens192 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | awk -F. '{print $4}')
echo "本機 IP 最後一組數字: $LAST_IP_OCTET"

# GitHub API 設定
GITHUB_REPO="78chicken/config"
GITHUB_API="https://api.github.com/repos/${GITHUB_REPO}/contents"
KEY_FILE_URL="$GITHUB_API/machine/${LAST_IP_OCTET}/key.txt"
# 下載 key.txt
KEY_FILE_PATH="${BASE_DIR}/daily_job/key.txt"
echo "從 GitHub下載 key.txt ...${KEY_FILE_URL}"
echo "${GITHUB_TOKEN}"
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "$KEY_FILE_PATH" "$KEY_FILE_URL"

# 確認 key.txt 是否成功下載
if [[ ! -f "$KEY_FILE_PATH" || ! -s "$KEY_FILE_PATH" ]]; then
    echo "錯誤: 無法下載或 key.txt 為空"
    exit 1
fi

# 讀取 key/value 配對
declare -A CONTAINER_ACCOUNTS
while IFS=: read -r name value; do
    name=$(echo "$name" | tr -d '[:space:]')
    value=$(echo "$value" | tr -d '[:space:]')
    if [[ -n "$name" && -n "$value" ]]; then
        CONTAINER_ACCOUNTS["$name"]="$value"
    fi
done < "$KEY_FILE_PATH"

# 印出 CONTAINER_ACCOUNTS 內容
echo "讀取到的容器帳號對應關係:"
for key in "${!CONTAINER_ACCOUNTS[@]}"; do
    echo "$key -> ${CONTAINER_ACCOUNTS[$key]}"
done

# 設定每個容器是否需要從 GitHub 下載更新 (Y=下載，N=本地方式)
UPDATE_HoneyGain="N"
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
    local sleep_time=$4
    local action_flag=$5

    if [[ "$update_flag" == "Y" ]]; then      
        
        echo "[$container_name] 下載 設定 ...$GITHUB_API/${project_name}/${CONTAINER_ACCOUNTS[$project_name]}/run.sh"
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

process_container "HoneyGain" "$UPDATE_HoneyGain" "honeygain" "$SLEEP_TIME" "$ACTION"
process_container "Traffmonetizer" "$UPDATE_Traffmonetizer" "traffmonetizer" "$SLEEP_TIME" "$ACTION"
process_container "Earnapp" "$UPDATE_Earnapp" "earnapp" "$SLEEP_TIME" "$ACTION"

# 清理沒有 tag 的 images
echo "清理未標記的 images..."
#sudo podman images -f "dangling=true" -q | xargs sudo podman rmi -f

# 清理未使用的 images
echo "清理未使用的 images..."
#sudo podman image prune -a -f
