echo "start to do Haha Wallet job..."
CID=$(sudo podman run -d --rm -m 50M -e TZ=Asia/Taipei --log-opt max-size=1m --log-opt max-file=1  --name HahaWallet -v /opt/build_image/hahawallet/accounts.json:/app/hahawallet/accounts.json 78chicken/hahawallet:latest)
sleep 15 && sudo podman stop $CID
