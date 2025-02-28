#!/bin/bash
BASE_DIR="/opt"
SLEEP_TIME=${1:-30s}  # 預設值為 30 秒
ACTION=${2:-START}    # 預設為 START

# 取得 ens192 的 IPv4 最後一組數字
LAST_IP_OCTET=$(hostname -I | awk '{split($1, ip, "."); print ip[4]}')
echo "本機 IP 最後一組數字: $LAST_IP_OCTET"

# GitHub API 設定
GITHUB_REPO="78chicken/config"
GITHUB_API="https://api.github.com/repos/${GITHUB_REPO}/contents"
KEY_FILE_URL="$GITHUB_API/machine/${LAST_IP_OCTET}/key.txt"
# 下載 key.txt
KEY_FILE_PATH="${BASE_DIR}/daily_job/key.txt"
echo "從 GitHub下載 key.txt ...${KEY_FILE_URL}"
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
UPDATE_Traffmonetizer="Y"
UPDATE_EarnApp="Y"
UPDATE_IPRoyal="Y"
UPDATE_PacketStream="Y"
UPDATE_EarnFm="Y"
UPDATE_ProxyRack="Y"
UPDATE_Repocket="Y"
UPDATE_Titan="Y"

#以下目前無法賺錢的
UPDATE_Traffmonetizer2="N"
UPDATE_Grass="N"
UPDATE_BlockMesh="N"

# 下載並執行腳本
process_container() {
    local container_name=$1
    local update_flag=$2
    local project_name=$3
    local sleep_time=$4
    local action_flag=$5

    if [[ -z "${CONTAINER_ACCOUNTS[$project_name]}" ]]; then
        echo "[$container_name] 錯誤: 找不到對應的帳號，跳過此容器"
        return
    fi

    if [[ "$update_flag" == "Y" ]]; then      
         # 確保目標目錄存在
        sudo mkdir -p "${BASE_DIR}/$project_name"
        
        echo "[$container_name] 下載 設定 ...$GITHUB_API/${project_name}/${CONTAINER_ACCOUNTS[$project_name]}/run.sh"
        sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${BASE_DIR}/$project_name/run.sh" "$GITHUB_API/${project_name}/${CONTAINER_ACCOUNTS[$project_name]}/run.sh"
        
        sudo bash -x ${BASE_DIR}/$project_name/run.sh 
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
process_container "EarnApp" "$UPDATE_EarnApp" "earnapp" "$SLEEP_TIME" "$ACTION"
process_container "IPRoyal" "$UPDATE_IPRoyal" "iproyal" "$SLEEP_TIME" "$ACTION"
process_container "PacketStream" "$UPDATE_PacketStream" "packetstream" "$SLEEP_TIME" "$ACTION"
process_container "EarnFm" "$UPDATE_EarnFm" "earnfm" "$SLEEP_TIME" "$ACTION"
process_container "ProxyRack" "$UPDATE_ProxyRack" "proxyrack" "$SLEEP_TIME" "$ACTION"
process_container "Repocket" "$UPDATE_Repocket" "repocket" "$SLEEP_TIME" "$ACTION"
process_container "Titan" "$UPDATE_Titan" "titan" "$SLEEP_TIME" "$ACTION"

# 清理沒有 tag 的 images
echo "清理未標記的 images..."
#sudo podman images -f "dangling=true" -q | xargs sudo podman rmi -f

# 清理未使用的 images
echo "清理未使用的 images..."
#sudo podman image prune -a -f
