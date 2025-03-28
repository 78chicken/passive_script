BASE_DIR="/opt/build_image"
QUEST_DIR="${BASE_DIR}/quest"
GITHUB_REPO="78chicken/config"
GITHUB_API="https://api.github.com/repos/${GITHUB_REPO}/contents"

#ByData
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/bydata/accounts.txt" "$GITHUB_API/bydata/all/accounts.txt"
echo "download $GITHUB_API/bydata/all/accounts.txt to ${QUEST_DIR}/bydata/accounts.txt"
sudo podman run -d --rm --replace -m 40m -v ${QUEST_DIR}/bydata/accounts.txt:/app/bydata/accounts.txt:Z --name ByData docker.io/78chicken/bydata:latest
sleep 60s 
sudo podman stop ByData

#Unich
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/unich/tokens.txt" "$GITHUB_API/unich/all/tokens.txt"
echo "download $GITHUB_API/unich/all/tokens.txt to ${QUEST_DIR}/unich/tokens.txt"
sudo podman run -d --rm --replace -m 40m -v ${QUEST_DIR}/unich/tokens.txt:/app/unich/tokens.txt:Z --name Unich docker.io/78chicken/unich:latest
sleep 30s 
sudo podman stop Unich

#HahaWallet
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/hahawallet/accounts.json" "$GITHUB_API/hahawallet/jyhfengli/accounts.json"
echo "download $GITHUB_API/hahawallet/jyhfengli/accounts.json to ${QUEST_DIR}/hahawallet/accounts.json"
sudo podman run -d --rm --replace -m 40m -v ${QUEST_DIR}/hahawallet/accounts.json:/app/hahawallet/accounts.json:Z --name HahaWallet docker.io/78chicken/hahawallet:latest
sleep 30s 
sudo podman stop HahaWallet

#DreamerQuests
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/dreamerquests/cookies.txt" "$GITHUB_API/dreamerquests/all/cookies.txt"
echo "download $GITHUB_API/dreamerquests/all/cookies.txt to ${QUEST_DIR}/dreamerquests/cookies.txt"
sudo podman run -d --rm --replace -m 40m -v ${QUEST_DIR}/dreamerquests/cookies.txt:/app/dreamerquests/cookies.txt:Z --name DreamerQuests docker.io/78chicken/dreamerquests:latest
sleep 30s 
sudo podman stop DreamerQuests


