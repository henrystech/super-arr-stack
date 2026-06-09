# Super Arr Stack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a first public release scaffold for Super Arr Stack, a guided Ubuntu installer for a VPN-protected qBittorrent and Arr media stack.

**Architecture:** The project uses Bash scripts and Docker Compose templates. The installer collects user choices, writes a `.env`, renders `docker-compose.yml`, optionally configures NFS, and starts the stack. Helper scripts provide VPN health checks, VPN region rotation, qBittorrent port sync guidance, and backups.

**Tech Stack:** Bash, Docker Compose, Gluetun, linuxserver.io media containers, systemd timers.

---

### Task 1: Project Documentation

**Files:**
- Create: `README.md`
- Create: `LICENSE`
- Create: `.gitignore`
- Create: `.env.example`

- [x] **Step 1: Write public-facing README**

Explain the project design goals, included apps, storage choices, VPN behavior, install command, and first-run notes.

- [x] **Step 2: Add license and ignore rules**

Use MIT license and ignore generated `.env`, rendered compose files, logs, and backups.

- [x] **Step 3: Add `.env.example`**

Include every variable used by templates without real credentials.

### Task 2: Installer

**Files:**
- Create: `install.sh`

- [x] **Step 1: Add interactive prompts**

Collect app root, data root, timezone, PUID/PGID, VPN provider, VPN credentials, protocol, VPN regions, storage mode, NFS values, and optional app selections.

- [x] **Step 2: Add Docker check**

Detect Docker and Docker Compose, offer to install Docker through the official convenience script on Ubuntu/Debian, and exit clearly on unsupported systems.

- [x] **Step 3: Render files**

Write `.env`, copy `compose/docker-compose.yml`, optionally configure NFS, and start Docker Compose.

### Task 3: Compose Template

**Files:**
- Create: `compose/docker-compose.yml`

- [x] **Step 1: Add core services**

Define Gluetun, qBittorrent, Prowlarr, Sonarr, Radarr, Lidarr, and File Browser.

- [x] **Step 2: Add optional services through profiles**

Define SABnzbd, Bazarr, Readarr, FlareSolverr, Unpackerr, and Dozzle Agent with Docker Compose profiles.

### Task 4: Helper Scripts

**Files:**
- Create: `scripts/vpn-healthcheck.sh`
- Create: `scripts/rotate-vpn-region.sh`
- Create: `scripts/sync-qbit-port.sh`
- Create: `scripts/backup-configs.sh`
- Create: `scripts/benchmark-pia-regions.sh`
- Create: `scripts/list-vpn-servers.sh`

- [x] **Step 1: Add health check**

Check Gluetun health endpoint and public IP through the VPN container.

- [x] **Step 2: Add region rotation**

Rotate through configured VPN regions and restart Gluetun.

- [x] **Step 3: Add port sync helper**

Read Gluetun's forwarded port file and tell qBittorrent to use it through the qBittorrent Web API.

- [x] **Step 4: Add backup helper**

Archive `.env`, compose file, and app data into `backups/`.

- [x] **Step 5: Add simple benchmark helper**

Measure approximate latency for configured regions by timing Gluetun reconnects and health recovery.

- [x] **Step 6: Add server-list helper**

Use Gluetun's `format-servers` command to print or save the current provider server list.

### Task 5: Systemd Templates

**Files:**
- Create: `systemd/super-arr-stack-vpn-health.service`
- Create: `systemd/super-arr-stack-vpn-health.timer`
- Create: `systemd/super-arr-stack-region-rotate.service`
- Create: `systemd/super-arr-stack-region-rotate.timer`

- [x] **Step 1: Add health timer**

Run VPN health checks every 10 minutes.

- [x] **Step 2: Add monthly rotation timer**

Run region rotation monthly.

### Task 6: Verification

**Files:**
- Modify: executable bits for shell scripts.

- [ ] **Step 1: Run Bash syntax checks**

Run `bash -n install.sh scripts/*.sh`.

- [ ] **Step 2: Run Docker Compose config check**

Run `docker compose -f compose/docker-compose.yml --env-file .env.example config`.

- [ ] **Step 3: Initialize Git and commit**

Run `git init`, `git add`, and `git commit`.

- [ ] **Step 4: Publish public repository**

Run `gh repo create henrystech/super-arr-stack --public --source . --remote origin --push`.
