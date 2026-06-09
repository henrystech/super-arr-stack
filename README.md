# Super Arr Stack

Super Arr Stack is a guided Ubuntu installer for a media automation stack with qBittorrent locked behind a Gluetun-supported VPN.

The goal is simple: make a strong, understandable Arr stack that normal homelab users can run, inspect, backup, migrate, and improve.

## What It Promises

- qBittorrent uses the VPN only.
- If the VPN drops, qBittorrent has no direct internet route.
- The Arr apps stay reachable on your LAN.
- Private Internet Access is the default, but other Gluetun-supported VPN providers can be used.
- Users can choose preferred VPN regions, including European locations.
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
qBittorrent -> Gluetun -> VPN provider -> Internet
```

Only qBittorrent is forced through the VPN. This keeps the dangerous traffic isolated without making Sonarr, Radarr, Lidarr, Prowlarr, and File Browser harder to reach.

## VPN Providers

Private Internet Access is the default because it supports port forwarding and works well for torrenting, but Gluetun supports many native providers.

Common Gluetun provider names include:

```text
private internet access
mullvad
nordvpn
protonvpn
surfshark
expressvpn
cyberghost
ipvanish
airvpn
torguard
windscribe
purevpn
vyprvpn
privado
privatevpn
perfect privacy
```

Some providers need normal username/password credentials. Some WireGuard setups need provider-specific keys or custom config values. If your provider needs WireGuard keys instead of username/password, start with OpenVPN or check that provider's Gluetun page.

Port forwarding is provider-specific. PIA, ProtonVPN, PrivateVPN, and Perfect Privacy have Gluetun port-forwarding support documented, but not every VPN provider supports incoming torrent ports.

## VPN Regions

The installer accepts a comma-separated list of VPN regions.

Balanced example:

```text
Mexico,Panama,US Florida,US Atlanta,CA Toronto,Netherlands
```

Europe-focused example:

```text
Netherlands,Switzerland,Sweden,Germany,UK London
```

The exact region names depend on what your provider and Gluetun currently support. If a region fails, remove it from `.env` or rotate to another one. Gluetun typically uses display-style names such as `Netherlands` or `US Florida`.

For Private Internet Access examples, see:

- [Private Internet Access region guide](docs/private-internet-access-regions.md)
- [Private Internet Access plain text quick list](docs/private-internet-access-regions.txt)

To ask Gluetun for the current provider server list:

```bash
./scripts/list-vpn-servers.sh private-internet-access
```

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
- VPN provider
- VPN username and password
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
./scripts/list-vpn-servers.sh
```

## Notes

This project does not download content, provide indexers, or bypass copyright laws. It only installs and organizes self-hosted media management tools.

Use it responsibly and follow the laws in your location.
