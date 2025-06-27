#!/bin/bash
# daily_job.sh
# 運行範例: sudo bash daily_job.sh 30s 100 bot

BASE_DIR="/opt"
SLEEP_TIME=${1:-30s}  # 預設值為 30 秒，現在是第一個參數
CUSTOM_IP_OCTET=${2}  # 第二個參數作為最後一段 IP
TYPE=${3:-bot}       # 第三個參數作為類別，預設為 bot

# 檢查 GITHUB_TOKEN 是否設定
if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "錯誤: GITHUB_TOKEN 環境變數未設定。請設定 GitHub 個人存取權杖。"
    exit 1
fi

# 嘗試獲取本機 IP 最後一組數字
if [[ -n "$CUSTOM_IP_OCTET" ]]; then
    LAST_IP_OCTET="$CUSTOM_IP_OCTET"
else
    LAST_IP_OCTET=$(hostname -I 2>/dev/null | awk '{split($1, ip, "."); print ip[4]}')
    if [[ -z "$LAST_IP_OCTET" ]]; then
        echo "警告: 無法從 'hostname -I' 獲取 IP。請手動提供 IP 最後一段數字或檢查網路配置。"
        exit 1
    fi
fi

echo "本機 IP 最後一組數字: $LAST_IP_OCTET"
echo "本次處理的容器類別 (TYPE): $TYPE"
echo "容器操作間隔 (SLEEP_TIME): $SLEEP_TIME" # 顯示 SLEEP_TIME

# GitHub API 設定
GITHUB_REPO="78chicken/config"
GITHUB_API="https://api.github.com/repos/${GITHUB_REPO}/contents"

# containers.yaml 的 URL 位於 machine/ 下
KEY_FILE_URL="$GITHUB_API/machine/${LAST_IP_OCTET}/key.txt"
CONTAINERS_CONFIG_URL="$GITHUB_API/machine/containers.yaml" # 配置檔 URL 位於 machine 資料夾內，不包含 IP

# run.sh 的 GitHub 遠端路徑
RUN_SH_GITHUB_URL="$GITHUB_API/$TYPE/run.sh" 

# 確保基礎目錄存在
sudo mkdir -p "${BASE_DIR}/daily_job"

# --- 下載 key.txt ---
KEY_FILE_PATH="${BASE_DIR}/daily_job/key.txt"
echo "從 GitHub 下載 key.txt ... ${KEY_FILE_URL}"
if ! sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "$KEY_FILE_PATH" "$KEY_FILE_URL"; then
    echo "錯誤: 無法下載 key.txt。請檢查網路連線或權杖設定。"
    exit 1
fi

# 確認 key.txt 是否成功下載且非空
if [[ ! -f "$KEY_FILE_PATH" || ! -s "$KEY_FILE_PATH" ]]; then
    echo "錯誤: key.txt 不存在或為空。請確認 GitHub 倉庫中 'machine/${LAST_IP_OCTET}/key.txt' 檔案。"
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

echo "--- 讀取到的容器帳號對應關係 ---"
for key in "${!CONTAINER_ACCOUNTS[@]}"; do
    echo "$key -> ${CONTAINER_ACCOUNTS[$key]}"
done
echo "------------------------------"

# --- 下載 containers.yaml ---
CONTAINERS_CONFIG_PATH="${BASE_DIR}/daily_job/containers.yaml"
echo "從 GitHub 下載 containers.yaml ... ${CONTAINERS_CONFIG_URL}"
if ! sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "$CONTAINERS_CONFIG_PATH" "$CONTAINERS_CONFIG_URL"; then
    echo "錯誤: 無法下載 containers.yaml。請檢查網路連線或權杖設定。"
    exit 1
fi

# 確認 containers.yaml 是否成功下載且非空
if [[ ! -f "$CONTAINERS_CONFIG_PATH" || ! -s "$CONTAINERS_CONFIG_PATH" ]]; then
    echo "錯誤: containers.yaml 不存在或為空。請確認 GitHub 倉庫中 'machine/containers.yaml' 檔案。"
    exit 1
fi

# 檢查是否安裝了 yq (用於解析 YAML)
if ! command -v yq &> /dev/null; then
    echo "錯誤: yq 工具未安裝。請執行 'sudo dnf install yq -y' 或手動安裝。"
    exit 1
fi

# --- 下載通用 runner 腳本 (在 for 迴圈之外，只下載一次) ---
# 將 runner 腳本下載到指定的 BASE_DIR/runner/ 目錄下，並以 TYPE 命名
UNIVERSAL_RUN_SH_PATH="${BASE_DIR}/runner/${TYPE}.sh" 
echo "準備下載通用 ${TYPE}.sh 腳本到 ${UNIVERSAL_RUN_SH_PATH} ..."

# 檢查並建立目標目錄
sudo mkdir -p "$(dirname "$UNIVERSAL_RUN_SH_PATH")" 

echo "嘗試從 GitHub 下載 ${TYPE}.sh: ${RUN_SH_GITHUB_URL}"
if ! sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "$UNIVERSAL_RUN_SH_PATH" "$RUN_SH_GITHUB_URL"; then
    echo "錯誤: 無法下載通用 ${TYPE}.sh 腳本。請檢查 GitHub 倉庫中 'runner/${TYPE}.sh' 是否存在。"
    exit 1 # 如果通用腳本都無法下載，則整個流程無法進行
fi
sudo chmod +x "$UNIVERSAL_RUN_SH_PATH"
echo "通用 ${TYPE}.sh 腳本下載完成並已賦予執行權限。"


# --- 處理每個容器 ---
echo "--- 開始處理容器 ---"

# 使用 yq 解析 YAML 並根據 TYPE 篩選容器
mapfile -t CONTAINER_INDICES < <(yq '.containers | to_entries | .[] | select(.value.type == "'"$TYPE"'") | .key' "$CONTAINERS_CONFIG_PATH")

if [ ${#CONTAINER_INDICES[@]} -eq 0 ]; then
    echo "沒有找到類型為 '$TYPE' 的容器。結束處理。"
    exit 0
fi

for i in "${CONTAINER_INDICES[@]}"; do
    # 使用索引來獲取完整的容器資訊
    CONTAINER_NAME=$(yq ".containers[$i].name" "$CONTAINERS_CONFIG_PATH")
    PROJECT_NAME=$(yq ".containers[$i].project_name" "$CONTAINERS_CONFIG_PATH")
    ACCOUNT_FILE=$(yq ".containers[$i].account_file // \"null\"" "$CONTAINERS_CONFIG_PATH") # 如果 account_file 不存在，設為 "null"
    # 讀取 mode，預設為 0
    MODE=$(yq ".containers[$i].mode // 0" "$CONTAINERS_CONFIG_PATH")
    # 讀取 max_memory，預設為 50M
    MAX_MEMORY=$(yq ".containers[$i].max_memory // \"50M\"" "$CONTAINERS_CONFIG_PATH")

    # 從 key.txt 獲取帳號識別碼 (例如 jyhfengli)，如果不存在則為空
    DYNAMIC_ACCOUNT_IDENTIFIER="${CONTAINER_ACCOUNTS[$PROJECT_NAME]}"

    echo "" # 空行分隔每個容器的日誌
    echo "--- 處理容器: $CONTAINER_NAME (專案: $PROJECT_NAME, 類型: $TYPE) ---"
    echo "  設定: 模式=$MODE, 最大記憶體=$MAX_MEMORY"

    case $MODE in
        0)  # mode 0: 每次拉取新的 image 並啟動
            echo "[$CONTAINER_NAME] 模式 0: 自動更新並啟動容器..."
            
            # 下載帳號設定檔 (如果 ACCOUNT_FILE 不為空且不為 "null")
            if [[ "$ACCOUNT_FILE" != "" && "$ACCOUNT_FILE" != "null" ]]; then
                if [[ -z "$DYNAMIC_ACCOUNT_IDENTIFIER" ]]; then
                    echo "[$CONTAINER_NAME] 警告: 指定了 account_file 但沒有對應的帳號識別碼，無法下載 ${ACCOUNT_FILE}。請檢查 key.txt 或 containers.yaml。"
                    continue
                else
                    ACCOUNT_FILE_URL="$GITHUB_API/${TYPE}/${PROJECT_NAME}/${DYNAMIC_ACCOUNT_IDENTIFIER}/$ACCOUNT_FILE"
                    ACCOUNT_FILE_LOCAL_PATH="${BASE_DIR}/${PROJECT_NAME}/${DYNAMIC_ACCOUNT_IDENTIFIER}/$ACCOUNT_FILE"
                    
                    sudo mkdir -p "$(dirname "$ACCOUNT_FILE_LOCAL_PATH")" 

                    echo "[$CONTAINER_NAME] 下載設定檔: ${ACCOUNT_FILE} 從 ${ACCOUNT_FILE_URL}"
                    if ! sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "$ACCOUNT_FILE_LOCAL_PATH" "$ACCOUNT_FILE_URL"; then
                        echo "[$CONTAINER_NAME] 錯誤: 無法下載設定檔 ${ACCOUNT_FILE}。"
                        continue
                    fi
                fi
            fi

            echo "[$CONTAINER_NAME] 執行 runner 腳本: $UNIVERSAL_RUN_SH_PATH"
            # 參數順序: $1=CONTAINER_NAME, $2=PROJECT_NAME, $3=DYNAMIC_ACCOUNT_IDENTIFIER, $4=MAX_MEMORY, $5=ACCOUNT_FILE
            # 在 mode 0 下，CURRENT_ACTION 邏輯上就是 START
            sudo bash "$UNIVERSAL_RUN_SH_PATH" "$CONTAINER_NAME" "$PROJECT_NAME" "$DYNAMIC_ACCOUNT_IDENTIFIER" "$MAX_MEMORY" "$ACCOUNT_FILE"
            #sleep "$SLEEP_TIME"
            ;;
        1)  # mode 1: 手動模式, 忽略此容器
            echo "[$CONTAINER_NAME] 模式 1: 手動管理容器，跳過此容器操作。"
            ;;
        2)  # mode 2: 如果容器正在運行，中止它；未運行的則跳過
            echo "[$CONTAINER_NAME] 模式 2: 檢查容器運行狀態並中止..."
            if sudo podman container inspect "$CONTAINER_NAME" &>/dev/null && \
               sudo podman container inspect -f '{{.State.Running}}' "$CONTAINER_NAME" | grep -q "true"; then
                echo "[$CONTAINER_NAME] 容器正在運行，執行停止操作。"
                sudo podman container stop "$CONTAINER_NAME"
                sleep "$SLEEP_TIME"
            else
                echo "[$CONTAINER_NAME] 容器未運行，跳過停止操作。"
            fi
            ;;
        *)  # 其他未定義的 mode
            echo "[$CONTAINER_NAME] 錯誤: 未知或未定義的模式 ($MODE)，跳過此容器。"
            ;;
    esac
done

echo "--- 所有容器處理完成 ---"
