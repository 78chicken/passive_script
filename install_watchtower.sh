sudo podman run --privileged -d --restart --name watchtower -v /run/podman/podman.sock:/var/run/docker.sock containrrr/watchtower --cleanup --interval 21600
