# 清理沒有 tag 的 images
echo "清理未標記的 images..."
sudo podman images -f "dangling=true" -q | xargs sudo podman rmi -f

# 清理未使用的 images
echo "清理未使用的 images..."
sudo podman image prune -a -f
# 清理未使用的 volume
sudo podman volume prune -f
