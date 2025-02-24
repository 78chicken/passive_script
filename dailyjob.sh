echo "start to do HahaWallet job..."
CID=$(sudo podman run -d --rm -m 50M -e TZ=Asia/Taipei --log-opt max-size=1m --log-opt max-file=1 --name HahaWallet -v /opt/build_image/hahawallet/accounts.json:/app/hahawallet/accounts.json 78chicken/hahawallet:latest)
echo "HahaWallet CID is ${CID}, will be killed after 15s."
sleep 15s && sudo podman stop ${CID}
