sudo podman run -d --rm --restart always --replace -m 50m -v /opt/build_image/unich/tokens.txt:/opt/unich/tokens.txt --name Unich docker.io/78chicken/unich:latest
sleep 15s 
