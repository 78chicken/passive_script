sudo podman run --privileged -d -m 256m -p 9000:9000 --name portainer --restart=always -v /run/podman/podman.sock -v portainer_data:/data portainer/portainer-ce
