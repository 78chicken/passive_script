sudo podman run --privileged -d --restart always --name watchtower -v /run/podman/podman.sock:/var/run/docker.sock containrrr/watchtower --cleanup --remove-volumes --interval 3600
