#!/bin/bash
BASE_DIR="/opt"
SLEEP_TIME=${1:-30s}  # 預設值為 30 秒
ACTION=${2:-START}    # 預設為 START
CUSTOM_IP_OCTET=${3}  # 第三個參數作為最後一段 IP

# 如果有提供第三個參數則使用，否則取得 ens192 的 IPv4 最後一組數字
if [[ -n "$CUSTOM_IP_OCTET" ]]; then
    LAST_IP_OCTET="$CUSTOM_IP_OCTET"
else
    LAST_IP_OCTET=$(hostname -I | awk '{split($1, ip, "."); print ip[4]}')
fi

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
UPDATE_Monami="Y"
UPDATE_OpenLoop="Y"
UPDATE_Teneo="Y"
UPDATE_Bless="Y"
UPDATE_DePINed="Y"
UPDATE_MinionLab="Y"
UPDATE_NodePay="Y"
UPDATE_Nodego="N"
UPDATE_Sparkchain="Y"
UPDATE_Naoris="Y"
UPDATE_KiteAi="Y"
UPDATE_3Dos="Y"
UPDATE_Unich="Y"
UPDATE_DistributeAi="Y"
UPDATE_Kivanet="Y"
UPDATE_OptimAi="Y"
UPDATE_ByData="Y"
UPDATE_OpenLedger="N"
UPDATE_Solix="Y"
UPDATE_CryplexAi="Y"
UPDATE_Dawn="Y"
UPDATE_Ddai="Y"
UPDATE_Brilliance="Y"
UPDATE_LayerEdge="Y"
UPDATE_Sixpence="Y"

#以下目前無法賺錢的
UPDATE_Exeos="N"
UPDATE_Meganet="N"


# 下載並執行腳本
process_container() {
    local container_name=$1
    local update_flag=$2
    local project_name=$3
    local accounts_file=$4
    local sleep_time=$5
    local action_flag=$6

    if [[ -z "${CONTAINER_ACCOUNTS[$project_name]}" ]]; then
        echo "[$container_name] 錯誤: 找不到對應的帳號，跳過此容器"
        return
    fi

    if [[ "$update_flag" == "Y" ]]; then
        if [[ "$action_flag" == "STOP" ]]; then
            sudo podman container stop "$container_name" 
            echo "[$container_name] 動作為 STOP，跳過下載與執行"
            return
        fi
        echo "[$container_name] 下載 run.sh ..."
         # 確保目標目錄存在
        sudo mkdir -p "${BASE_DIR}/$project_name"
        
        sudo curl -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${BASE_DIR}/$project_name/run.sh" "$GITHUB_API/${project_name}/run.sh"
        sudo chmod +x "${BASE_DIR}/$project_name/run.sh"

        if [[ -n "$accounts_file" ]]; then
            echo "[$container_name] 下載 設定 ...$GITHUB_API/${project_name}/${CONTAINER_ACCOUNTS[$project_name]}/$accounts_file"
            sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${BASE_DIR}/$project_name/$accounts_file" "$GITHUB_API/${project_name}/${CONTAINER_ACCOUNTS[$project_name]}/$accounts_file"
        fi

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
process_container "Sixpence" "$UPDATE_Sixpence" "sixpence" "accounts.txt" "$SLEEP_TIME" "$ACTION"
process_container "Monami" "$UPDATE_Monami" "monami" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "Brilliance" "$UPDATE_Brilliance" "brilliance" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "LayerEdge" "$UPDATE_LayerEdge" "layeredge" "tokens.txt" "$SLEEP_TIME" "$ACTION"
process_container "CryplexAi" "$UPDATE_CryplexAi" "cryplexai" "tokens.txt" "$SLEEP_TIME" "$ACTION"
process_container "Solix" "$UPDATE_Solix" "solix" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "Meganet" "$UPDATE_Meganet" "meganet" "accounts.txt" "$SLEEP_TIME" "STOP"
process_container "Exeos" "$UPDATE_Exeos" "exeos" "accounts.json" "$SLEEP_TIME" "STOP"
process_container "OptimAi" "$UPDATE_OptimAi" "optimai" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "OpenLedger" "$UPDATE_OpenLedger" "openledger" "accounts.json" "$SLEEP_TIME" "STOP"
process_container "Kivanet" "$UPDATE_Kivanet" "kivanet" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "Flow3" "$UPDATE_Flow3" "flow3" "tokens.txt" "$SLEEP_TIME" "STOP"
process_container "Unich" "$UPDATE_Unich" "unich" "tokens.txt" "$SLEEP_TIME" "$ACTION"
process_container "Ddai" "$UPDATE_Ddai" "ddai" "tokens.json" "$SLEEP_TIME" "$ACTION"
process_container "3Dos" "$UPDATE_3Dos" "3dos" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "KiteAi" "$UPDATE_KiteAi" "kiteai" "accounts.txt" "$SLEEP_TIME" "$ACTION"
process_container "Dawn" "$UPDATE_Dawn" "dawn" "tokens.json" "$SLEEP_TIME" "$ACTION"
process_container "Naoris" "$UPDATE_Naoris" "naoris" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "OpenLoop" "$UPDATE_OpenLoop" "openloop" "tokens.json" "$SLEEP_TIME" "$ACTION"
process_container "Teneo" "$UPDATE_Teneo" "teneo" "tokens.json" "$SLEEP_TIME" "$ACTION"
process_container "Bless" "$UPDATE_Bless" "bless" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "DePINed" "$UPDATE_DePINed" "depined" "tokens.json" "$SLEEP_TIME" "$ACTION"
process_container "MinionLab" "$UPDATE_MinionLab" "minionlab" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "NodePay" "$UPDATE_NodePay" "nodepay" "tokens.json" "$SLEEP_TIME" "$ACTION"
process_container "DistributeAi" "$UPDATE_DistributeAi" "distributeai" "accounts.json" "$SLEEP_TIME" "$ACTION"
process_container "Nodego" "$UPDATE_Nodego" "nodego" "tokens.txt" "$SLEEP_TIME" "STOP"
process_container "Sparkchain" "$UPDATE_Sparkchain" "sparkchain" "tokens.txt" "$SLEEP_TIME" "$ACTION"

