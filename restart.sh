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

UPDATE_OpenLoop="Y"
UPDATE_Teneo="Y"
UPDATE_Gaea="N"
UPDATE_Bless="Y"
UPDATE_DePINed="Y"
UPDATE_MinionLab="Y"
UPDATE_NodePay="Y"
UPDATE_DistributeAi="Y"
UPDATE_Nodego="Y"
UPDATE_Sparkchain="Y"
UPDATE_Naoris="Y"
UPDATE_Dawn="N"

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



# 下載並執行腳本
process_container() {
    local container_name=$1
    local update_flag=$2
    local project_name=$3
    local accounts_file=$4
    local sleep_time=$5
    local action_flag=$6

    if [[ "$update_flag" == "Y" ]]; then
        if [[ "$action_flag" == "STOP" ]]; then
            echo "[$container_name] 動作為 STOP，跳過下載與執行"
            return
        fi
        echo "[$container_name] 下載 run.sh ..."
        sudo curl -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${BASE_DIR}/$project_name/run.sh" "$GITHUB_API/${project_name}/run.sh"
        sudo chmod +x "${BASE_DIR}/$project_name/run.sh"

        if [[ -n "$accounts_file" ]]; then
            echo "[$container_name] 下載 設定 ...$GITHUB_API/${project_name}/${CONTAINER_ACCOUNTS[$project_name]}/$accounts_file"
            sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${BASE_DIR}/$project_name/$accounts_file" "$GITHUB_API/${project_name}/${CONTAINER_ACCOUNTS[$project_name]}/$accounts_file"
        fi

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
process_container "Naoris" "$UPDATE_Naoris" "naoris" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "OpenLoop" "$UPDATE_OpenLoop" "openloop" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "Teneo" "$UPDATE_Teneo" "teneo" "tokens.txt" "$SLEEP_TIME" "$ACTION"
process_container "Gaea" "$UPDATE_Gaea" "gaea" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "Bless" "$UPDATE_Bless" "bless" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "DePINed" "$UPDATE_DePINed" "depined" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "MinionLab" "$UPDATE_MinionLab" "minionlab" "accounts.json" "$SLEEP_TIME" "STOP"
process_container "NodePay" "$UPDATE_NodePay" "nodepay" "tokens.txt" "$SLEEP_TIME" "$ACTION"
process_container "DistributeAi" "$UPDATE_DistributeAi" "distributeai" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "Nodego" "$UPDATE_Nodego" "nodego" "tokens.txt" "$SLEEP_TIME" "$ACTION"
process_container "Sparkchain" "$UPDATE_Sparkchain" "sparkchain" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "Dawn" "$UPDATE_Dawn" "dawn" "accounts.json" "$SLEEP_TIME" "STOP"

process_container "Titan" "$UPDATE_Titan" "" "" "$SLEEP_TIME" "$ACTION"
process_container "HoneyGain" "$UPDATE_HoneyGain" "" "" "$SLEEP_TIME" "$ACTION"
process_container "Traffmonetizer" "$UPDATE_Traffmonetizer" "" "" "$SLEEP_TIME" "$ACTION"
process_container "Traffmonetizer2" "$UPDATE_Traffmonetizer2" "" "" "$SLEEP_TIME" "$ACTION"
process_container "EarnApp" "$UPDATE_EarnApp" "" "" "$SLEEP_TIME" "$ACTION"
process_container "Repocket" "$UPDATE_Repocket" "" "" "$SLEEP_TIME" "$ACTION"
process_container "PacketStream" "$UPDATE_PacketStream" "" "" "$SLEEP_TIME" "$ACTION"
process_container "EarnFm" "$UPDATE_EarnFm" "" "" "$SLEEP_TIME" "$ACTION"
process_container "IPRoyal" "$UPDATE_IPRoyal" "" "" "$SLEEP_TIME" "$ACTION"
process_container "Grass" "$UPDATE_Grass" "" "" "$SLEEP_TIME" "STOP"
process_container "ProxyRack" "$UPDATE_ProxyRack" "" "" "$SLEEP_TIME" "$ACTION"
process_container "BlockMesh" "$UPDATE_BlockMesh" "" "" "$SLEEP_TIME" "STOP"


# 清理沒有 tag 的 images
echo "清理未標記的 images..."
#sudo podman images -f "dangling=true" -q | xargs sudo podman rmi -f

# 清理未使用的 images
echo "清理未使用的 images..."
#sudo podman image prune -a -f
