sudo dnf install -y cockpit
sudo systemctl enable --now cockpit.socket
sudo firewall-cmd --add-service=cockpit --permanent
sudo firewall-cmd --reload
sudo systemctl daemon-reload
sudo systemctl restart cockpit.socket
sudo dnf install -y cockpit-podman
