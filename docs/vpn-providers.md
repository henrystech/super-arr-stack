# VPN Providers

Super Arr Stack uses Gluetun as the VPN gateway, so provider support follows Gluetun's native provider support.

## Native Provider Docs

The official Gluetun wiki currently includes provider pages for:

- AirVPN
- CyberGhost
- ExpressVPN
- FastestVPN
- Giganews
- HideMyAss
- IPVanish
- IVPN
- Mullvad
- NordVPN
- Perfect Privacy
- Privado
- Private Internet Access
- PrivateVPN
- ProtonVPN
- PureVPN
- SlickVPN
- Surfshark
- TorGuard
- VPN Secure
- VPN Unlimited
- VyprVPN
- Windscribe
- Custom providers

## Recommended Defaults

For qBittorrent, use a VPN provider that supports port forwarding. Port forwarding usually improves torrent connectivity because peers can initiate connections to your client.

Good first choices:

- Private Internet Access
- ProtonVPN paid plans
- AirVPN
- TorGuard
- PrivateVPN

Privacy-focused choices people often like:

- Mullvad
- IVPN
- ProtonVPN
- AirVPN

Fast commercial choices people often already own:

- NordVPN
- Surfshark
- ExpressVPN
- CyberGhost
- IPVanish

## Important Notes

Provider setup is not identical across VPNs. Some providers use username/password with OpenVPN. Some WireGuard setups need private keys, addresses, or a custom config file.

The first Super Arr Stack installer path supports the common username/password workflow. If your provider needs generated WireGuard keys, use OpenVPN first or adapt the Gluetun environment variables from that provider's official Gluetun page.

Do not commit VPN credentials, WireGuard keys, API keys, or generated config files.
