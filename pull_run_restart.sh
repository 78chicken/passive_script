#!/bin/bash
# daily_job_third.sh
# 運行範例: sudo bash daily_job_third.sh 30s 100

BASE_DIR="/opt"
SLEEP_TIME=${1:-30s}  # 預設值為 30 秒
CUSTOM_IP_OCTET=${2}  # 第二個參數作為最後一段 IP
TARGET_TYPE="third"  # <--- 此腳本固定處理 'third' 類型的容器

# 檢查 GITHUB_TOKEN 是否設定
if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "錯誤: GITHUB_TOKEN 環境變數未設定。請設定 GitHub 個人存取權杖。"
    exit 1
fi

# 嘗試獲取本機 IP 最後一組數字
if [[ -n "$CUSTOM_IP_OCTET" ]]; then
    LAST_IP_OCTET="$CUSTOM_IP_OCTET" # 使用傳入的參數作為最後一段 IP
else
    LAST_IP_OCTET=$(hostname -I 2>/dev/null | awk '{split($1, ip, "."); print ip[4]}')
    if [[ -z "$LAST_IP_OCTET" ]]; then
        echo "警告: 無法從 'hostname -I' 獲取 IP。請手動提供 IP 最後一段數字或檢查網路配置。"
        exit 1
    fi
fi

echo "本機 IP 最後一組數字: $LAST_IP_OCTET"
echo "此腳本處理的容器類別 (TARGET_TYPE): $TARGET_TYPE"
echo "容器操作間隔 (SLEEP_TIME): $SLEEP_TIME"

# GitHub API 設定
GITHUB_REPO="78chicken/config"
GITHUB_API="https://api.github.com/repos/${GITHUB_REPO}/contents"

# key.txt 的 URL 位於 machine/ 下
KEY_FILE_URL="$GITHUB_API/machine/${LAST_IP_OCTET}/key.txt"

# containers.yaml 的 URL 位於 GitHub 倉庫的根目錄
CONTAINERS_CONFIG_URL="$GITHUB_API/machine/containers.yaml" # <-- 共用 containers.yaml

# 確保基礎目錄存在
sudo mkdir -p "${BASE_DIR}/daily_job"
sudo mkdir -p "${BASE_DIR}/runner" # 確保 runner 腳本的本地目錄存在

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
    echo "錯誤: containers.yaml 不存在或為空。請確認 GitHub 倉庫中 'containers.yaml' 檔案。"
    exit 1
fi

# 檢查是否安裝了 yq (用於解析 YAML)
if ! command -v yq &> /dev/null; then
    echo "錯誤: yq 工具未安裝。請執行 'sudo dnf install yq -y' 或手動安裝。"
    exit 1
fi

# --- 下載共用的 run.sh 腳本 (針對 'third' 類型) ---
RUN_SH_GITHUB_URL="$GITHUB_API/$TARGET_TYPE/run.sh" # 共用的 run.sh 路徑: config/third/run.sh
LOCAL_RUN_SH_PATH="${BASE_DIR}/runner/${TARGET_TYPE}_run.sh"
echo "嘗試從 GitHub 下載共用 run.sh: ${RUN_SH_GITHUB_URL}"
if ! sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "$LOCAL_RUN_SH_PATH" "$RUN_SH_GITHUB_URL"; then
    echo "錯誤: 無法下載共用 run.sh 腳本。請檢查 GitHub 倉庫中 '${TARGET_TYPE}/run.sh' 是否存在。"
    exit 1
fi
sudo chmod +x "$LOCAL_RUN_SH_PATH"
echo "共用 run.sh 腳本下載完成並已賦予執行權限。"

# --- 處理每個容器 ---
echo "--- 開始處理容器 (類型: $TARGET_TYPE) ---"

# 使用 yq 解析 YAML 並根據 TARGET_TYPE 篩選容器
mapfile -t CONTAINER_INDICES < <(yq '.containers | to_entries | .[] | select(.value.type == "'"$TARGET_TYPE"'") | .key' "$CONTAINERS_CONFIG_PATH")

if [ ${#CONTAINER_INDICES[@]} -eq 0 ]; then
    echo "沒有找到類型為 '$TARGET_TYPE' 的容器。結束處理。"
    exit 0
fi

for i in "${CONTAINER_INDICES[@]}"; do
    # 使用索引來獲取完整的容器資訊
    CONTAINER_NAME=$(yq ".containers[$i].name" "$CONTAINERS_CONFIG_PATH")
    PROJECT_NAME=$(yq ".containers[$i].project_name" "$CONTAINERS_CONFIG_PATH") # <-- 這是資料夾名稱
    IMAGE_NAME=$(yq ".containers[$i].image_name // \"\"" "$CONTAINERS_CONFIG_PATH") # <--- NEW: 讀取實際映像檔名稱
    PARAM_FILE_NAME=$(yq ".containers[$i].param_file // \"null\"" "$CONTAINERS_CONFIG_PATH")
    MODE=$(yq ".containers[$i].mode // 0" "$CONTAINERS_CONFIG_PATH")
    MAX_MEMORY=$(yq ".containers[$i].max_memory // \"50M\"" "$CONTAINERS_CONFIG_PATH")
    CONTAINER_SLEEP_TIME=$(yq ".containers[$i].sleep_time // \"10s\"" "$CONTAINERS_CONFIG_PATH")

    # 從 key.txt 獲取帳號識別碼 (例如 jyhfengli)
    DYNAMIC_ACCOUNT_IDENTIFIER="${CONTAINER_ACCOUNTS[$PROJECT_NAME]}"

    echo "" # 空行分隔每個容器的日誌
    echo "--- 處理容器: $CONTAINER_NAME (專案: $PROJECT_NAME, 類型: $TARGET_TYPE) ---"
    echo "  設定: 模式=$MODE, 最大記憶體=$MAX_MEMORY, 映像檔名稱=$IMAGE_NAME, 參數檔案名稱=$PARAM_FILE_NAME"
    echo "  容器專屬睡眠時間 (CONTAINER_SLEEP_TIME): $CONTAINER_SLEEP_TIME"

    case $MODE in
        0)  # mode 0: 每次拉取新的 image 並啟動
            echo "[$CONTAINER_NAME] 模式 0: 自動更新並啟動容器..."
            
            # 檢查 DYNAMIC_ACCOUNT_IDENTIFIER 是否存在
            if [[ -z "$DYNAMIC_ACCOUNT_IDENTIFIER" ]]; then
                echo "[$CONTAINER_NAME] 錯誤: 'type: $TARGET_TYPE' 容器需要對應的帳號識別碼，但 'project_name: $PROJECT_NAME' 在 key.txt 中無對應值，無法啟動容器。"
                continue # 跳過此容器，繼續處理下一個
            fi

            LOCAL_PARAM_FILE_PATH=""
            # 下載參數檔案 (如果 PARAM_FILE_NAME 不為空且不為 "null")
            if [[ -n "$PARAM_FILE_NAME" && "$PARAM_FILE_NAME" != "null" ]]; then
                PARAM_FILE_URL="$GITHUB_API/$TARGET_TYPE/${PROJECT_NAME}/${DYNAMIC_ACCOUNT_IDENTIFIER}/$PARAM_FILE_NAME"
                LOCAL_PARAM_FILE_PATH="${BASE_DIR}/${PROJECT_NAME}/${DYNAMIC_ACCOUNT_IDENTIFIER}/$PARAM_FILE_NAME"
                sudo mkdir -p "$(dirname "$LOCAL_PARAM_FILE_PATH")"
                                
                echo "[$CONTAINER_NAME] 下載設定檔: ${PARAM_FILE_NAME} 從 ${PARAM_FILE_URL}"
                if ! sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "$LOCAL_PARAM_FILE_PATH" "$PARAM_FILE_URL"; then
                    echo "[$CONTAINER_NAME] 錯誤: 無法下載設定檔 ${PARAM_FILE_NAME}。"
                    continue
                fi
                
            else
                echo "[$CONTAINER_NAME] 未指定參數檔案名稱，或指定為 null/空，將不傳遞額外參數檔案。"
                # 這裡不需要 `continue`，因為即使沒有參數檔案，我們還是希望嘗試啟動容器。
                # run.sh 會處理 LOCAL_PARAM_FILE_PATH 為空字串的情況。
            fi
            
            # 執行共用的 run.sh 腳本，並傳遞所有必要參數
            # 參數順序: $1=CONTAINER_NAME, $2=PROJECT_NAME, $3=MAX_MEMORY, $4=IMAGE_NAME, $5=LOCAL_PARAM_FILE_PATH
            sudo bash "$LOCAL_RUN_SH_PATH" "$CONTAINER_NAME" "$PROJECT_NAME" "$MAX_MEMORY" "$IMAGE_NAME" "$LOCAL_PARAM_FILE_PATH"
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
                sleep "$CONTAINER_SLEEP_TIME" # 使用容器專屬的 sleep_time
            else
                echo "[$CONTAINER_NAME] 容器未運行，跳過停止操作。"
            fi
            ;;
        3)  # mode 3: 如果容器未運行，則啟動它；正在運行的則終止,並等待SLEEP_TIME後重啟動
            echo "[$CONTAINER_NAME] 模式 3: 確保容器運行，如果已運行則終止並重啟..."
            # 檢查容器是否運行
            if sudo podman container inspect "$CONTAINER_NAME" &>/dev/null && \
               sudo podman container inspect -f '{{.State.Running}}' "$CONTAINER_NAME" | grep -q "true"; then
                echo "[$CONTAINER_NAME] 容器正在運行，將終止並重啟。"
                sudo podman container stop "$CONTAINER_NAME"
                echo "[$CONTAINER_NAME] 等待 $CONTAINER_SLEEP_TIME 後重啟..."
                sleep "$CONTAINER_SLEEP_TIME" # 使用容器專屬的 sleep_time
            else
                echo "[$CONTAINER_NAME] 容器未運行，執行啟動操作。"
            fi
            
            # 不論是停止後重啟還是直接啟動，都執行啟動邏輯
            # 啟動邏輯與 mode 0 相同，因為 run.sh 會處理拉取和啟動細節
            # 檢查 DYNAMIC_ACCOUNT_IDENTIFIER 是否存在
            if [[ -z "$DYNAMIC_ACCOUNT_IDENTIFIER" ]]; then
                echo "[$CONTAINER_NAME] 錯誤: 'type: $TARGET_TYPE' 容器需要對應的帳號識別碼，但 'project_name: $PROJECT_NAME' 在 key.txt 中無對應值，無法啟動容器。"
                continue # 跳過此容器，繼續處理下一個
            fi

            LOCAL_PARAM_FILE_PATH=""
            # 下載參數檔案 (如果 PARAM_FILE_NAME 不為空且不為 "null")
            if [[ -n "$PARAM_FILE_NAME" && "$PARAM_FILE_NAME" != "null" ]]; then
                PARAM_FILE_URL="$GITHUB_API/$TARGET_TYPE/${PROJECT_NAME}/${DYNAMIC_ACCOUNT_IDENTIFIER}/$PARAM_FILE_NAME"
                LOCAL_PARAM_FILE_PATH="${BASE_DIR}/${PROJECT_NAME}/${DYNAMIC_ACCOUNT_IDENTIFIER}/$PARAM_FILE_NAME"
                sudo mkdir -p "$(dirname "$LOCAL_PARAM_FILE_PATH")"
                                
                echo "[$CONTAINER_NAME] (啟動/重啟) 下載設定檔: ${PARAM_FILE_NAME} 從 ${PARAM_FILE_URL}"
                if ! sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "$LOCAL_PARAM_FILE_PATH" "$PARAM_FILE_URL"; then
                    echo "[$CONTAINER_NAME] (啟動/重啟) 錯誤: 無法下載設定檔 ${PARAM_FILE_NAME}。"
                    continue
                fi
                
            else
                echo "[$CONTAINER_NAME] (啟動/重啟) 未指定參數檔案名稱，或指定為 null/空，將不傳遞額外參數檔案。"
                # 這裡不需要 `continue`，因為即使沒有參數檔案，我們還是希望嘗試啟動容器。
                # run.sh 會處理 LOCAL_PARAM_FILE_PATH 為空字串的情況。
            fi
            
            # 執行共用的 run.sh 腳本，並傳遞所有必要參數
            sudo bash "$LOCAL_RUN_SH_PATH" "$CONTAINER_NAME" "$PROJECT_NAME" "$MAX_MEMORY" "$IMAGE_NAME" "$LOCAL_PARAM_FILE_PATH"
            ;;
        *)  # 其他未定義的 mode
            echo "[$CONTAINER_NAME] 錯誤: 未知或未定義的模式 ($MODE)，跳過此容器。"
            ;;
    esac
done

echo "--- 所有類型為 '$TARGET_TYPE' 的容器處理完成 ---"
