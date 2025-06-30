# 步驟 1: 獲取最新版本的 yq 標籤名稱
YQ_VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep "tag_name" | awk -F '"' '{print $4}')

# 檢查 YQ_VERSION 是否成功獲取
if [ -z "$YQ_VERSION" ]; then
    echo "錯誤: 無法獲取 yq 最新版本號。請檢查網路連線或 GitHub API 存取。"
    exit 1
fi

echo "發現 yq 最新版本: ${YQ_VERSION}"

# 步驟 2: 建立臨時目錄來下載和解壓縮檔案
sudo mkdir -p /tmp/yq_install
cd /tmp/yq_install

# 步驟 3: 下載適合 Linux AMD64 架構的 yq 壓縮包
YQ_DOWNLOAD_URL="https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64.tar.gz"
echo "正在下載 yq 從: ${YQ_DOWNLOAD_URL}"

if ! sudo curl -sL "${YQ_DOWNLOAD_URL}" -o "yq.tar.gz"; then
    echo "錯誤: 無法下載 yq。請檢查下載連結或網路連線。"
    cd - > /dev/null
    sudo rm -rf /tmp/yq_install
    exit 1
fi

# 步驟 4: 解壓縮檔案
echo "解壓縮 yq.tar.gz..."
if ! sudo tar -xzf yq.tar.gz; then
    echo "錯誤: 無法解壓縮 yq.tar.gz。"
    cd - > /dev/null
    sudo rm -rf /tmp/yq_install
    exit 1
fi

# 步驟 5: 將 yq 執行檔移動到 /usr/bin
echo "將 yq 安裝到 /usr/bin..."
if ! sudo mv yq_linux_amd64 /usr/bin/yq; then
    echo "錯誤: 無法移動 yq 執行檔到 /usr/bin/yq。"
    cd - > /dev/null
    sudo rm -rf /tmp/yq_install
    exit 1
fi

# 步驟 6: 賦予執行權限
echo "設定 yq 執行權限..."
sudo chmod +x /usr/bin/yq

# 步驟 7: 清理臨時檔案
echo "清理臨時檔案..."
cd - > /dev/null
sudo rm -rf /tmp/yq_install

# 步驟 8: 驗證安裝
echo "驗證 yq 安裝..."
/usr/bin/yq --version
