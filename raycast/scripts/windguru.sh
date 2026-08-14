#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Windguru
# @raycast.mode silent
# @raycast.packageName Wind

# @raycast.icon 🌊
# @raycast.argument1 { "type": "text", "placeholder": "spot name or id", "optional": true }

# @raycast.description Open a Windguru forecast. Give a saved spot name, a numeric spot id, or nothing for your default spot.
# @raycast.author Nicolas Reigl

set -euo pipefail

# Saved spots. Add a line per spot as "name=id".
# To find an id, open the spot on windguru.cz and read the number in the URL,
# for example https://www.windguru.cz/48651 has the id 48651.
SPOTS="
laulasmaa=
vaana=
pirita=
tallinn=341
"

DEFAULT_SPOT="laulasmaa"

query="${1:-$DEFAULT_SPOT}"
key=$(printf '%s' "$query" | tr '[:upper:]' '[:lower:]' | tr -d ' ')

# A plain number is already a spot id.
if [[ "$key" =~ ^[0-9]+$ ]]; then
  open "https://www.windguru.cz/$key"
  echo "Windguru spot $key"
  exit 0
fi

id=$(printf '%s' "$SPOTS" | grep -i "^${key}=" | cut -d= -f2 | head -1)

if [[ -n "$id" ]]; then
  open "https://www.windguru.cz/$id"
  echo "Windguru: $key"
else
  open "https://www.windguru.cz/search.php?sea=$(printf '%s' "$query" | sed 's/ /+/g')"
  echo "Windguru search: $query"
fi
