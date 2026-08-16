#!/usr/bin/env bash
# Downloads input data: Constanța GTFS, OSM networks (Overpass), MapLibre GL.
# Everything is cached — re-running only fetches what is missing.
#
# ONE feed covers the whole network: CT BUS S.A. Constanța's
# buses, split by route_type at build time.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p data/gtfs data/osm web/vendor

BB=44.10,28.54,44.30,28.70

# 1) GTFS
if [ ! -f data/gtfs/routes.txt ]; then
  echo "== CT BUS GTFS (Constanța) =="
  curl -fL --retry 3 --max-time 600 -o data/constanta-gtfs.zip \
    "https://external.gtfs.ro/constanta/CONSTANTA.zip"
  unzip -o data/constanta-gtfs.zip -d data/gtfs
fi

# 2) OSM — roadways over the feed's extent plus margin.
if [ ! -f data/osm/constanta.json ]; then
  echo "== Overpass (roads) =="
  QR="[out:json][timeout:900];way($BB)[\"highway\"~\"^(motorway|trunk|primary|secondary|tertiary|unclassified|residential|living_street|service|busway|construction|motorway_link|trunk_link|primary_link|secondary_link|tertiary_link)$\"];out geom;"
  ok=0
  # overpass-api.de first: the lighter mirrors have been caught serving a stale
  # database (Naples, 16.08.2026 — a line opened in 2025 was missing)
  for EP in "https://overpass-api.de/api/interpreter" \
            "https://maps.mail.ru/osm/tools/overpass/api/interpreter" \
            "https://overpass.kumi.systems/api/interpreter"; do
    echo "-- $EP"
    if curl -fsS --max-time 900 -o data/osm/constanta.json --data-urlencode "data=$QR" "$EP" \
       && grep -q '"elements"' data/osm/constanta.json; then
      ok=1; break
    fi
    sleep 5
  done
  [ "$ok" = 1 ] || { echo "Overpass (roads): all mirrors failed" >&2; exit 1; }
fi

# 3) MapLibre GL (vendored, no CDN at runtime)
if [ ! -f web/vendor/maplibre-gl.js ]; then
  echo "== MapLibre GL =="
  curl -fL --retry 3 -o web/vendor/maplibre-gl.js  https://unpkg.com/maplibre-gl@5.6.1/dist/maplibre-gl.js
  curl -fL --retry 3 -o web/vendor/maplibre-gl.css https://unpkg.com/maplibre-gl@5.6.1/dist/maplibre-gl.css
fi

echo "OK — data ready:"
du -sh data/constanta-gtfs.zip data/osm/constanta*.json 2>/dev/null || true
