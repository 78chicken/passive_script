BASE_DIR="/opt/build_image"
QUEST_DIR="${BASE_DIR}/quest"
GITHUB_REPO="78chicken/config"
GITHUB_API="https://api.github.com/repos/${GITHUB_REPO}/contents"

#MonadScore
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/monadscore/query.txt" "$GITHUB_API/monadscore/all/query.txt"
echo "download $GITHUB_API/monadscore/all/query.txt to ${QUEST_DIR}/monadscore/query.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/monadscore/query.txt:/app/monadscore/query.txt:Z --name MonadScore docker.io/78chicken/monadscore:latest
sleep 180s 
sudo podman stop MonadScore

#GpuNet
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/gpunet/accounts.txt" "$GITHUB_API/gpunet/all/accounts.txt"
echo "download $GITHUB_API/gpunet/all/accounts.txt to ${QUEST_DIR}/gpunet/accounts.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/gpunet/accounts.txt:/app/gpunet/accounts.txt:Z --name GpuNet docker.io/78chicken/gpunet:latest
sleep 60s 
sudo podman stop GpuNet

#ByteNova
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/bytenova/accounts.txt" "$GITHUB_API/bytenova/all/accounts.txt"
echo "download $GITHUB_API/bytenova/all/accounts.txt to ${QUEST_DIR}/bytenova/accounts.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/bytenova/accounts.txt:/app/bytenova/accounts.txt:Z --name ByteNova docker.io/78chicken/bytenova:latest
sleep 60s 
sudo podman stop ByteNova

#Unich
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/unich/tokens.txt" "$GITHUB_API/unich/all/tokens.txt"
echo "download $GITHUB_API/unich/all/tokens.txt to ${QUEST_DIR}/unich/tokens.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/unich/tokens.txt:/app/unich/tokens.txt:Z --name Unich docker.io/78chicken/unich:latest
sleep 60s 
sudo podman stop Unich

#PuzzleMania
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/puzzlemania/accounts.txt" "$GITHUB_API/puzzlemania/all/accounts.txt"
echo "download $GITHUB_API/puzzlemania/all/accounts.txt to ${QUEST_DIR}/puzzlemania/accounts.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/puzzlemania/accounts.txt:/app/puzzlemania/accounts.txt:Z --name PuzzleMania docker.io/78chicken/puzzlemania:latest
sleep 90s 
sudo podman stop PuzzleMania

#kivanet
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/kivanet/accounts.json" "$GITHUB_API/kivanet/jyhfengli/accounts.json"
echo "download $GITHUB_API/kivanet/jyhfengli/accounts.json to ${QUEST_DIR}/kivanet/accounts.json"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/kivanet/accounts.json:/app/kivanet/accounts.json:Z --name Kivanet docker.io/78chicken/kivanet:latest
sleep 60s 
sudo podman stop Kivanet

#zeroswallet
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/zeroswallet/accounts.txt" "$GITHUB_API/zeroswallet/all/accounts.txt"
echo "download $GITHUB_API/zeroswallet/all/accounts.txt to ${QUEST_DIR}/zeroswallet/accounts.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/zeroswallet/accounts.txt:/app/zeroswallet/accounts.txt:Z --name ZerosWallet docker.io/78chicken/zeroswallet:latest
sleep 120s 
sudo podman stop ZerosWallet

#Coresky
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/coresky/accounts.txt" "$GITHUB_API/coresky/all/accounts.txt"
echo "download $GITHUB_API/coresky/all/accounts.txt to ${QUEST_DIR}/coresky/accounts.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/coresky/accounts.txt:/app/coresky/accounts.txt:Z --name Coresky docker.io/78chicken/coresky:latest
sleep 60s 
sudo podman stop Coresky

#TakerProtocol
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/takerprotocol/accounts.txt" "$GITHUB_API/takerprotocol/all/accounts.txt"
echo "download $GITHUB_API/takerprotocol/all/accounts.txt to ${QUEST_DIR}/takerprotocol/accounts.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/takerprotocol/accounts.txt:/app/takerprotocol/accounts.txt:Z --name TakerProtocol docker.io/78chicken/takerprotocol:latest
sleep 60s 
sudo podman stop TakerProtocol

#ByData
#sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/bydata/accounts.txt" "$GITHUB_API/bydata/all/accounts.txt"
#echo "download $GITHUB_API/bydata/all/accounts.txt to ${QUEST_DIR}/bydata/accounts.txt"
#sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/bydata/accounts.txt:/app/bydata/accounts.txt:Z --name ByData docker.io/78chicken/bydata:latest
#sleep 300s 
#sudo podman stop ByData

#HahaWallet
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/hahawallet/accounts.json" "$GITHUB_API/hahawallet/jyhfengli/accounts.json"
echo "download $GITHUB_API/hahawallet/jyhfengli/accounts.json to ${QUEST_DIR}/hahawallet/accounts.json"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/hahawallet/accounts.json:/app/hahawallet/accounts.json:Z --name HahaWallet docker.io/78chicken/hahawallet:latest
sleep 30s 
sudo podman stop HahaWallet

#DreamerQuests
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/dreamerquests/cookies.txt" "$GITHUB_API/dreamerquests/all/cookies.txt"
echo "download $GITHUB_API/dreamerquests/all/cookies.txt to ${QUEST_DIR}/dreamerquests/cookies.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/dreamerquests/cookies.txt:/app/dreamerquests/cookies.txt:Z --name DreamerQuests docker.io/78chicken/dreamerquests:latest
sleep 30s 
sudo podman stop DreamerQuests


