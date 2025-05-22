BASE_DIR="/opt/build_image"
QUEST_DIR="${BASE_DIR}/quest"
GITHUB_REPO="78chicken/config"
GITHUB_API="https://api.github.com/repos/${GITHUB_REPO}/contents"

#Assisterr
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/assisterr/accounts.txt" "$GITHUB_API/assisterr/all/accounts.txt"
echo "download $GITHUB_API/assisterr/all/accounts.txt to ${QUEST_DIR}/assisterr/accounts.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/assisterr/accounts.txt:/app/assisterr/accounts.txt:Z --name Assisterr docker.io/78chicken/assisterr:latest
sleep 60s 
sudo podman stop Assisterr

#Billions
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/billions/cookies.txt" "$GITHUB_API/billions/all/cookies.txt"
echo "download $GITHUB_API/billions/all/cookies.txt to ${QUEST_DIR}/billions/cookies.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/billions/cookies.txt:/app/billions/cookies.txt:Z --name Billions docker.io/78chicken/billions:latest
sleep 60s 
sudo podman stop Billions

#NexyAi
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/nexyai/tokens.txt" "$GITHUB_API/nexyai/all/tokens.txt"
echo "download $GITHUB_API/nexyai/all/tokens.txt to ${QUEST_DIR}/nexyai/tokens.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/nexyai/tokens.txt:/app/nexyai/tokens.txt:Z --name NexyAi docker.io/78chicken/nexyai:latest
sleep 120s 
sudo podman stop NexyAi

#openverse
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/openverse/accounts.txt" "$GITHUB_API/openverse/jyhfengli/accounts.txt"
echo "download $GITHUB_API/openverse/all/accounts.txt to ${QUEST_DIR}/openverse/accounts.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/openverse/accounts.txt:/app/openverse/accounts.txt:Z --name Openverse docker.io/78chicken/openverse:latest
sleep 60s 
sudo podman stop Openverse

#stobix
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/stobix/accounts.txt" "$GITHUB_API/stobix/all/accounts.txt"
echo "download $GITHUB_API/stobix/all/accounts.txt to ${QUEST_DIR}/stobix/accounts.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/stobix/accounts.txt:/app/stobix/accounts.txt:Z --name Stobix docker.io/78chicken/stobix:latest
sleep 150s 
sudo podman stop Stobix

#zeroswallet
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/zeroswallet/accounts.txt" "$GITHUB_API/zeroswallet/all/accounts.txt"
echo "download $GITHUB_API/zeroswallet/all/accounts.txt to ${QUEST_DIR}/zeroswallet/accounts.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/zeroswallet/accounts.txt:/app/zeroswallet/accounts.txt:Z --name ZerosWallet docker.io/78chicken/zeroswallet:latest
sleep 120s 
sudo podman stop ZerosWallet

#Unich
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/unich/tokens.txt" "$GITHUB_API/unich/all/tokens.txt"
echo "download $GITHUB_API/unich/all/tokens.txt to ${QUEST_DIR}/unich/tokens.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/unich/tokens.txt:/app/unich/tokens.txt:Z --name Unich docker.io/78chicken/unich:latest
sleep 120s 
sudo podman stop Unich

#TakerProtocol
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/takerprotocol/accounts.txt" "$GITHUB_API/takerprotocol/all/accounts.txt"
echo "download $GITHUB_API/takerprotocol/all/accounts.txt to ${QUEST_DIR}/takerprotocol/accounts.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/takerprotocol/accounts.txt:/app/takerprotocol/accounts.txt:Z --name TakerProtocol docker.io/78chicken/takerprotocol:latest
sleep 60s 
sudo podman stop TakerProtocol 

#MonadScore
#sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/monadscore/query.txt" "$GITHUB_API/monadscore/all/query.txt"
#echo "download $GITHUB_API/monadscore/all/query.txt to ${QUEST_DIR}/monadscore/query.txt"
#sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/monadscore/query.txt:/app/monadscore/query.txt:Z --name MonadScore docker.io/78chicken/monadscore:latest
#sleep 180s 
#sudo podman stop MonadScore

#GpuNet
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/gpunet/accounts.txt" "$GITHUB_API/gpunet/all/accounts.txt"
echo "download $GITHUB_API/gpunet/all/accounts.txt to ${QUEST_DIR}/gpunet/accounts.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/gpunet/accounts.txt:/app/gpunet/accounts.txt:Z --name GpuNet docker.io/78chicken/gpunet:latest
sleep 120s 
sudo podman stop GpuNet

#ByteNova
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/bytenova/accounts.txt" "$GITHUB_API/bytenova/all/accounts.txt"
echo "download $GITHUB_API/bytenova/all/accounts.txt to ${QUEST_DIR}/bytenova/accounts.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/bytenova/accounts.txt:/app/bytenova/accounts.txt:Z --name ByteNova docker.io/78chicken/bytenova:latest
sleep 60s 
sudo podman stop ByteNova

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

#Coresky
sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${QUEST_DIR}/coresky/accounts.txt" "$GITHUB_API/coresky/all/accounts.txt"
echo "download $GITHUB_API/coresky/all/accounts.txt to ${QUEST_DIR}/coresky/accounts.txt"
sudo podman run -d --rm --replace -m 50m -v ${QUEST_DIR}/coresky/accounts.txt:/app/coresky/accounts.txt:Z --name Coresky docker.io/78chicken/coresky:latest
sleep 60s 
sudo podman stop Coresky

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


