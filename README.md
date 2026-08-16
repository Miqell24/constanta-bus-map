# Constanța Public Transport — interactive map

Interactive, poster-grade map of the public transport network of
**Constanța**: CT BUS S.A. Constanța's buses — 20 lines drawn along the
real street geometry.

## Live

Not published — this map is built and reviewed locally.

One feed covers everything, split by `route_type` at build time:

| mode | route_type | lines | graph |
|---|---|---|---|
| buses | 3 | city lines, the E express pair, the summer 100M/43M services and the CiTy Tour | OSM roadways |

Constanța has **no metro**, so the engine's metro treatment stays unused.

Build quirks worth knowing:

* **Buses only.** Constanța runs no trams and no trolleybuses, so this map has a single cfg and the frontend drops the tram toggle; `--tram` is accepted and ignored rather than building an empty rail mode.
* **Line numbers are unique across the modes**, so the line keys are the bare
  numbers printed on the vehicles — none of the mode prefixes the Sofia sibling
  needs. Re-check on every feed refresh.
* **Romanian is written in the Latin alphabet**, so this map runs without the
  second, transliterated label line its Greek, Bulgarian and Serbian siblings
  carry, and the stop names arrive properly cased and accented from the
  operator.
* **The feed's own `route_color` is ignored**, as everywhere in this family:
  colour means the MODE — navy bus, green trolleybus, red tram.

## Pipeline

`npm run download` fetches the GTFS, the OSM roadways and
MapLibre GL. `npm run build` map-matches every line (HMM/Viterbi on the OSM
graphs) and writes GeoJSON to `data/out/`. `npm run serve` hosts the map at
http://localhost:8146.

Data: CT BUS S.A. Constanța · base map © OpenFreeMap / OpenMapTiles / OpenStreetMap
contributors.
