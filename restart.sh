#1. Traffmonetizer
sudo podman container stop Traffmonetizer
sleep 30s
sudo podman container start Traffmonetizer

#2. Traffmonetizer2
sudo podman container stop Traffmonetizer2
sleep 30s
sudo podman container start Traffmonetizer2

#3. Repocket
sudo podman container stop Repocket
sleep 30s
sudo podman container start Repocket

#4. Repocket2
sudo podman container stop Repocket2
sleep 30s
sudo podman container start Repocket2

#5. Honeygain
sudo podman container stop HoneyGain
sleep 120s
sudo podman container start HoneyGain

#6. PacketStream
sudo podman container stop PacketStream
sleep 180s
sudo podman container start PacketStream

#7. EarnApp
sudo podman container stop EarnApp
sleep 30s
sudo podman container start EarnApp

#8. EarnFm
sudo podman container stop EarnFm
sleep 30s
sudo podman container start EarnFm

#9. IPRoyal
sudo podman container stop IPRoyal
sleep 90s
sudo podman container start IPRoyal

#10. Grass
sudo podman container stop Grass
sleep 30s
sudo podman container start Grass

#11. ProxyRack
sudo podman container stop ProxyRack
sleep 30s
sudo podman container start ProxyRack

#12. NodePay
sudo podman container stop NodePay
sleep 30s
sudo podman container start NodePay

#13. BlockMesh
sudo podman container stop BlockMesh
sleep 30s
sudo podman container start BlockMesh

#14 Titan
sudo podman container stop Titan
sleep 30s
sudo podman container start Titan

#15 OpenLoop
sudo podman container stop OpenLoop
sleep 30s
sudo podman container start OpenLoop

#16 Teneo
sudo podman container stop Teneo
sleep 30s
sudo podman container start Teneo

#17 Gaea
sudo podman container stop Gaea
sleep 30s
sudo podman container start Gaea

#18 DistributeAi
sudo podman container stop DistributeAi
sleep 30s
sudo podman container start DistributeAi

#19 DePINed
sudo podman container stop DePINed
sleep 30s
sudo podman container start DePINed

#20 Bless
sudo podman container stop Bless
sleep 30s
sudo podman container start Bless

#14. PipeNetwork
#sudo podman container stop PipeNetwork
#sleep 30s
#sudo podman container start PipeNetwork


#100 刪除沒有tag的image
sudo podman images -f "dangling=true" -q | xargs sudo podman rmi

#101 刪除沒有使用的image
sudo podman image prune -a -f

#restart
#sleep 10s
#sudo reboot
