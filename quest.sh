#!/bin/bash
# daily_job_quest.sh
# 運行範例: sudo bash daily_job_quest.sh
# 此腳本專門處理 'quest' 類型，且只支持 'mode: 4' (一次性運行後刪除) 的容器。

BASE_DIR="/opt"
TARGET_TYPE="quest"    # <--- 此腳本固定處理 'quest' 類型的容器

# 檢查 GITHUB_TOKEN 是否設定
if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "錯誤: GITHUB_TOKEN 環境變數未設定。請設定 GitHub 個人存取權杖。"
    exit 1
fi

echo "此腳本處理的容器類別 (TARGET_TYPE): $TARGET_TYPE"

# GitHub API 設定
GITHUB_REPO="78chicken/config"
GITHUB_API="https://api.github.com/repos/${GITHUB_REPO}/contents"

# containers.yaml 的 URL 位於 GitHub 倉庫的根目錄
CONTAINERS_CONFIG_URL="$GITHUB_API/machine/containers.yaml" # <-- 共用 containers.yaml

# 確保基礎目錄存在
sudo mkdir -p "${BASE_DIR}/daily_job"
sudo mkdir -p "${BASE_DIR}/runner" # 確保 runner 腳本的本地目錄存在

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

# --- 下載共用的 run.sh 腳本 (針對 'quest' 類型) ---
RUN_SH_GITHUB_URL="$GITHUB_API/$TARGET_TYPE/run.sh" # 共用的 run.sh 路徑: config/quest/run.sh
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
    PROJECT_NAME=$(yq ".containers[$i].project_name" "$CONTAINERS_CONFIG_PATH")
    IMAGE_NAME=$(yq ".containers[$i].image_name // \"\"" "$CONTAINERS_CONFIG_PATH")
    ACCOUNT_FILE_NAME=$(yq ".containers[$i].account_file // \"null\"" "$CONTAINERS_CONFIG_PATH") # 從 account_file 欄位獲取
    MODE=$(yq ".containers[$i].mode // 0" "$CONTAINERS_CONFIG_PATH")
    MAX_MEMORY=$(yq ".containers[$i].max_memory // \"50M\"" "$CONTAINERS_CONFIG_PATH")
    CONTAINER_SLEEP_TIME=$(yq ".containers[$i].sleep_time // \"10s\"" "$CONTAINERS_CONFIG_PATH")

    echo "" # 空行分隔每個容器的日誌
    echo "--- 處理容器: $CONTAINER_NAME (專案: $PROJECT_NAME, 類型: $TARGET_TYPE) ---"
    echo "  設定: 模式=$MODE, 最大記憶體=$MAX_MEMORY, 映像檔名稱=$IMAGE_NAME, 帳號檔案名稱=$ACCOUNT_FILE_NAME"
    echo "  容器運行持續時間 (CONTAINER_SLEEP_TIME): $CONTAINER_SLEEP_TIME"

    LOCAL_ACCOUNT_FILE_PATH=""
    # 下載帳號檔案 (如果 ACCOUNT_FILE_NAME 不為空且不為 "null")
    if [[ -n "$ACCOUNT_FILE_NAME" && "$ACCOUNT_FILE_NAME" != "null" ]]; then
        # 假設 ACCOUNT_FILE_NAME 包含 'user/filename' 部分，例如 'user/my_account.json'
        # 構建正確的 GitHub URL: config/quest/PROJECT_NAME/user/filename
        ACCOUNT_FILE_URL="$GITHUB_API/$TARGET_TYPE/${PROJECT_NAME}/$ACCOUNT_FILE_NAME"
        
        # 確保本地路徑也包含 user 子目錄，例如 /opt/PROJECT_NAME/user/filename
        LOCAL_ACCOUNT_FILE_PATH="${BASE_DIR}/${PROJECT_NAME}/${ACCOUNT_FILE_NAME}"
        sudo mkdir -p "$(dirname "$LOCAL_ACCOUNT_FILE_PATH")"
                                
        echo "[$CONTAINER_NAME] 下載帳號檔案: ${ACCOUNT_FILE_NAME} 從 ${ACCOUNT_FILE_URL}"
        if ! sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "$LOCAL_ACCOUNT_FILE_PATH" "$ACCOUNT_FILE_URL"; then
            echo "[$CONTAINER_NAME] 錯誤: 無法下載帳號檔案 ${ACCOUNT_FILE_NAME}。請檢查路徑或權杖。"
            continue
        fi
        
    else
        echo "[$CONTAINER_NAME] 未指定帳號檔案名稱，或指定為 null/空，將不傳遞額外帳號檔案。"
    fi

    case $MODE in
        4)  # mode 4: 啟動容器，執行 N 秒後停止並刪除
            echo "[$CONTAINER_NAME] 模式 4: 啟動容器，執行 $CONTAINER_SLEEP_TIME 後停止並刪除..."
            
            # 執行共用的 run.sh 腳本來啟動容器
            # 將 LOCAL_ACCOUNT_FILE_PATH 作為第六個參數傳遞
            sudo bash "$LOCAL_RUN_SH_PATH" "$CONTAINER_NAME" "$PROJECT_NAME" "$MAX_MEMORY" "$IMAGE_NAME" "$LOCAL_ACCOUNT_FILE_PATH"

            # 檢查容器是否確實啟動（給容器一點時間啟動）
            sleep 5

            # 驗證容器是否正在運行，才執行等待和刪除
            if sudo podman container inspect "$CONTAINER_NAME" &>/dev/null && \
               sudo podman container inspect -f '{{.State.Running}}' "$CONTAINER_NAME" | grep -q "true"; then
                echo "[$CONTAINER_NAME] 容器已啟動。將運行 $CONTAINER_SLEEP_TIME 後停止並刪除..."
                sleep "$CONTAINER_SLEEP_TIME"
                
                echo "[$CONTAINER_NAME] 時間到，停止並刪除容器..."
                sudo podman stop "$CONTAINER_NAME"
                sudo podman rm "$CONTAINER_NAME"
                echo "[$CONTAINER_NAME] 容器已停止並刪除。"
            else
                echo "[$CONTAINER_NAME] 警告: 容器可能未成功啟動，跳過停止和刪除操作。"
            fi
            ;;
        *)  # 其他未定義的 mode
            echo "[$CONTAINER_NAME] 錯誤: 對於 '$TARGET_TYPE' 類型，只支持模式 4。當前模式為 ($MODE)，跳過此容器。"
            ;;
    esac
done

echo "--- 所有類型為 '$TARGET_TYPE' 的容器處理完成 ---"
