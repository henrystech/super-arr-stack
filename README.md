# Super Arr Stack

Super Arr Stack is a guided Ubuntu installer for a media automation stack with qBittorrent locked behind Private Internet Access.

The goal is simple: make a strong, understandable Arr stack that normal homelab users can run, inspect, backup, migrate, and improve.

## What It Promises

- qBittorrent uses the VPN only.
- If the VPN drops, qBittorrent has no direct internet route.
- The Arr apps stay reachable on your LAN.
- Private Internet Access is supported with WireGuard by default and OpenVPN as a fallback.
- Users can choose preferred PIA regions, including European locations.
- Storage can be direct NFS from a NAS or an existing mount passed from Proxmox.
- Configs live in one predictable folder.
- No secrets are committed to Git.

## Included Apps

Core apps:

- Gluetun
- qBittorrent
- Prowlarr
- Sonarr
- Radarr
- Lidarr
- File Browser

Optional apps:

- SABnzbd
- Bazarr
- Readarr
- FlareSolverr
- Unpackerr
- Dozzle Agent

## Recommended Network Design

```text
Arr apps -> normal Docker/LAN network
qBittorrent -> Gluetun -> PIA VPN -> Internet
```

Only qBittorrent is forced through the VPN. This keeps the dangerous traffic isolated without making Sonarr, Radarr, Lidarr, Prowlarr, and File Browser harder to reach.

## VPN Regions

The installer accepts a comma-separated list of PIA regions.

Balanced example:

```text
Mexico,Panama,US Florida,US Atlanta,CA Toronto,Netherlands
```

Europe-focused example:

```text
Netherlands,Switzerland,Sweden,Germany,UK London
```

The exact region names depend on what PIA and Gluetun currently support. If a region fails, remove it from `.env` or rotate to another one. Gluetun typically uses display-style names such as `Netherlands` or `US Florida`.

## Storage Choices

### Direct NFS

Use this when the Ubuntu VM/server should mount the NAS itself.

```text
NAS -> Ubuntu VM -> Docker containers
```

### Existing Mount

Use this when Proxmox already mounted the NAS and passed the storage into the VM through VirtioFS, 9p, or another shared mount.

```text
NAS -> Proxmox -> Ubuntu VM -> Docker containers
```

For Proxmox homelabs, the existing mount path is usually cleaner because storage stays centralized in Proxmox.

## Quick Start

```bash
git clone https://github.com/henrystech/super-arr-stack.git
cd super-arr-stack
sudo ./install.sh
```

The installer asks for:

- App install folder
- Data/media folder
- Timezone
- PIA username and password
- VPN protocol
- Preferred VPN regions
- Storage mode
- Optional apps

## After Install

Open the web apps on your server IP:

- qBittorrent: `http://SERVER_IP:8090`
- Prowlarr: `http://SERVER_IP:9696`
- Sonarr: `http://SERVER_IP:8989`
- Radarr: `http://SERVER_IP:7878`
- Lidarr: `http://SERVER_IP:8686`
- File Browser: `http://SERVER_IP:9898`

The qBittorrent temporary password may appear in the qBittorrent container logs on first run. Change it after logging in.

## Download Paths

Suggested paths:

```text
/data/torrents/incomplete
/data/torrents/completed/movies
/data/torrents/completed/tv
/data/torrents/completed/anime
/data/torrents/completed/music
/data/usenet/incomplete
/data/usenet/complete
/data/media
```

Suggested qBittorrent categories:

```text
movies
tv
anime
music
software
```

## Helper Scripts

```bash
./scripts/vpn-healthcheck.sh
./scripts/rotate-vpn-region.sh
./scripts/sync-qbit-port.sh
./scripts/backup-configs.sh
./scripts/benchmark-pia-regions.sh
```

## Notes

This project does not download content, provide indexers, or bypass copyright laws. It only installs and organizes self-hosted media management tools.

Use it responsibly and follow the laws in your location.
