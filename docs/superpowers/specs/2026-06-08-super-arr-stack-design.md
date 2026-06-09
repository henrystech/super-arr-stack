# Super Arr Stack Design

## Goal

Super Arr Stack is a guided Ubuntu installer for a media automation stack that keeps qBittorrent locked behind a Private Internet Access VPN while leaving the Arr apps reachable on the local network.

## Promises

- qBittorrent traffic only exits through the VPN gateway.
- If the VPN is down, qBittorrent has no direct internet path.
- Users can choose PIA WireGuard or OpenVPN.
- Users can pick preferred PIA regions, including Europe-focused choices.
- Users can mount storage directly through NFS or use an already mounted Proxmox/VirtioFS path.
- The stack is easy to inspect, backup, migrate, and modify.
- No VPN credentials, API keys, or generated passwords are committed to Git.

## Default Apps

- Gluetun
- qBittorrent
- Prowlarr
- Sonarr
- Radarr
- Lidarr
- File Browser

## Optional Apps

- SABnzbd
- Bazarr
- Readarr
- FlareSolverr
- Unpackerr
- Dozzle Agent

## Architecture

The installer creates a Docker Compose project under a user-selected app root, usually `/opt/super-arr-stack`. Gluetun exposes qBittorrent's Web UI and torrent ports to the LAN, while qBittorrent uses `network_mode: service:gluetun`. The Arr apps use normal Docker networking so they can talk to LAN services, indexers, metadata providers, and qBittorrent through the Gluetun container.

Storage is mounted at a stable data path, usually `/data`. The installer can create an NFS mount, or it can use an existing path that Proxmox already passed through to the VM.

## VPN Region Strategy

The stack accepts comma-separated PIA regions. It includes a helper script that rotates to the next region and restarts Gluetun. A future version can benchmark regions by latency, VPN health, forwarded port availability, and optional speed tests.

WireGuard is the recommended default because it is usually faster and lighter. OpenVPN remains available as a fallback for networks where WireGuard is unreliable.

## Generated Layout

```text
/opt/super-arr-stack
  .env
  docker-compose.yml
  data/
    prowlarr/
    sonarr/
    radarr/
    lidarr/
    qbittorrent/
    gluetun/
    filebrowser/
  backups/
  logs/
```

## Initial User Flow

1. User clones the repository.
2. User runs `sudo ./install.sh`.
3. The installer asks for paths, VPN settings, app choices, and storage mode.
4. The installer writes `.env` and `docker-compose.yml`.
5. The installer optionally installs Docker.
6. The installer starts the stack.
7. The README guides the user through first login and Arr app connection steps.

## Non-Goals For First Release

- Fully automated Arr app API configuration.
- Fully automated indexer setup.
- A web UI installer.
- Supporting every VPN provider.
- Managing Proxmox VM creation.
