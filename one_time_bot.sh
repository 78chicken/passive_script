BASE_DIR="/opt/build_image"
GITHUB_REPO="78chicken/config"
GITHUB_API="https://api.github.com/repos/${GITHUB_REPO}/contents"

sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${BASE_DIR}/unich/tokens.txt" "$GITHUB_API/unich/all/tokens.txt"
echo "download $GITHUB_API/unich/all/tokens.txt to ${BASE_DIR}/unich/tokens.txt"
sudo podman run -d --rm --replace -m 40m -v ${BASE_DIR}/unich/tokens.txt:/app/unich/tokens.txt:Z --name Unich docker.io/78chicken/unich:latest
sleep 30s 
sudo podman stop Unich

sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${BASE_DIR}/hahawallet/jyhfengli/accounts.json" "$GITHUB_API/hahawallet/jyhfengli/accounts.json"
echo "download $GITHUB_API/hahawallet/jyhfengli/accounts.json to ${BASE_DIR}/hahawallet/jyhfengli/accounts.json"
sudo podman run -d --rm --replace -m 40m -v ${BASE_DIR}/hahawallet/accounts.json:/app/hahawallet/accounts.json:Z --name HahaWallet docker.io/78chicken/hahawallet:latest
sleep 30s 
sudo podman stop HahaWallet
