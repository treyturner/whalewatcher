# whalewatcher

Recreate a Docker container if a container it depends upon is recreated.

That's a word salad, so here's at least one use case (mine):

You have a containerized app that routes traffic through a containerized VPN client, but when watchtower recreates the VPN client container due to an image update, your app container stops routing traffic until it is removed and recreated.

This small Dockerfile and shell script will monitor the state of containers in these dependent relationships and restart the dependent container as needed.

## Environment variables

The following environment variables must be set; no defaults are provided.

| Name                   | Description                         | Example value |
|------------------------|-------------------------------------|---------------|
| `DEPENDENT_CONTAINER`  | The container with the dependency   | `rtorrent`    |
| `DEPENDENCY_CONTAINER` | The container that is depended upon | `vpn-dal`     |
| `COMPOSE_PROJECT_NAME` | The name of the compose project     | `rtorrent`    |

The examples above suggest an rtorrent/docker-compose.yml that looks something like this:

```
version: "3.2"

services:
  rtorrent:
    image: crazymax/rtorrent-rutorrent
    container_name: rtorrent
    network_mode: container:vpn-dal
    # whatever environment variables and volumes you need

  watcher:
    image: whalewatcher
    container_name: rtorrent_watcher
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      # YOU MUST MODIFY THE HOST PATH TO CORRECTLY MOUNT YOUR docker-compose.yml INSIDE THE CONTAINER 
      - /mnt/cache/appdata/portainer_data/compose/28/docker-compose.yml:/root/docker-compose.yml
    restart: unless-stopped
    labels:
      - com.centurylinklabs.watchtower.enable=false
    environment:
      - DEPENDENT_CONTAINER=rtorrent
      - DEPENDENCY_CONTAINER=vpn-dal
      - COMPOSE_PROJECT_NAME=rtorrent
```
