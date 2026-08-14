#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Wind Convert
# @raycast.mode inline
# @raycast.packageName Wind

# @raycast.icon 💨
# @raycast.argument1 { "type": "text", "placeholder": "18 kn", "percentEncoded": false }

# @raycast.description Convert a wind speed between knots, m/s, km/h, mph and Beaufort.
# @raycast.author Nicolas Reigl

exec /usr/bin/python3 "$(dirname "$0")/wind_convert.py" "$1"
