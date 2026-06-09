# Private Internet Access Regions

Private Internet Access is the default VPN provider for Super Arr Stack. This page gives people a quick way to choose useful `VPN_REGIONS` values without guessing.

PIA locations change over time, and Gluetun keeps its own provider server database. For the current list supported by your installed Gluetun image, run:

```bash
./scripts/list-vpn-servers.sh private-internet-access
```

To save the current list to a file:

```bash
./scripts/list-vpn-servers.sh private-internet-access docs/pia-current-servers.md
```

Gluetun's official server-list docs use this same `format-servers` command.

## Good Starter Sets

Balanced Americas and Europe:

```env
VPN_REGIONS=Mexico,Panama,US Florida,US Atlanta,CA Toronto,Netherlands
```

Europe-focused:

```env
VPN_REGIONS=Netherlands,Switzerland,Sweden,Germany,UK London
```

United States-focused:

```env
VPN_REGIONS=US Florida,US Atlanta,US Texas,US California,US New York
```

Privacy-leaning Europe:

```env
VPN_REGIONS=Switzerland,Sweden,Netherlands
```

## Common PIA Regions To Try

These are convenient human-facing region names that are commonly useful with Gluetun and PIA. If one does not work, generate the live list with `scripts/list-vpn-servers.sh`.

### North America

```text
CA Montreal
CA Ontario
CA Toronto
CA Vancouver
Mexico
Panama
US Atlanta
US California
US Chicago
US Dallas
US Denver
US East
US Florida
US Houston
US Las Vegas
US New York
US Seattle
US Silicon Valley
US Texas
US Washington DC
```

### Europe

```text
Austria
Belgium
Czech Republic
Denmark
France
Germany
Ireland
Italy
Netherlands
Norway
Poland
Portugal
Romania
Spain
Sweden
Switzerland
UK London
UK Manchester
```

### Asia Pacific

```text
Australia
AU Melbourne
AU Sydney
Hong Kong
India
Japan
Singapore
South Korea
Taiwan
New Zealand
```

### Other Regions

```text
Brazil
Israel
South Africa
United Arab Emirates
```

## How Region Rotation Uses This

Set `VPN_REGIONS` in `.env` to a comma-separated list:

```env
VPN_REGIONS=Mexico,Panama,Netherlands,Switzerland
```

Then run:

```bash
./scripts/rotate-vpn-region.sh
```

The script rewrites `VPN_REGIONS` to the next single region and restarts Gluetun. This is simple on purpose: it makes the active exit point obvious when someone looks at `.env`.

## Notes

- Prefer nearby regions when speed matters.
- Prefer regions with port forwarding support when torrent performance matters.
- If a region stops working, run the live list script and update `.env`.
- Some PIA locations are virtual/geolocated. Check PIA's own server information if the physical host location matters to you.
