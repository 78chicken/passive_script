BASE_DIR="/opt/build_image"
GITHUB_REPO="78chicken/config"
GITHUB_API="https://api.github.com/repos/${GITHUB_REPO}/contents"

sudo curl -s -H "Accept: application/vnd.github.v3.raw" -H "Authorization: token ${GITHUB_TOKEN}" -o "${BASE_DIR}/unich/accounts.json" "$GITHUB_API/unich/all/accounts.json"
sudo podman run -d --rm --replace -m 50m -v /opt/build_image/unich/tokens.txt:/opt/unich/tokens.txt --name Unich docker.io/78chicken/unich:latest
sleep 30s 
sudo podman stop Unich
