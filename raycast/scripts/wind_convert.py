#!/usr/bin/env python3
"""Convert a wind speed between knots, m/s, km/h, mph and Beaufort.

Accepts input such as "18 kn", "9m/s", "35 kmh", "5 bft". If no unit is
given, knots are assumed.
"""

import re
import sys

# Multipliers that convert one unit into metres per second.
TO_MS = {
    "kn": 0.514444,
    "ms": 1.0,
    "kmh": 0.277778,
    "mph": 0.44704,
}

# Spellings accepted for each canonical unit.
ALIASES = {
    "kn": ("kn", "kt", "kts", "knot", "knots"),
    "ms": ("ms", "m/s", "mps", "meterspersecond"),
    "kmh": ("kmh", "km/h", "kph", "kmph"),
    "mph": ("mph", "mi/h"),
    "bft": ("bft", "b", "beaufort", "bf"),
}

# Upper bound in metres per second for each Beaufort force, 0 to 11.
BEAUFORT_MAX = [0.5, 1.5, 3.3, 5.4, 7.9, 10.7, 13.8, 17.1, 20.7, 24.4, 28.4, 32.6]

# Representative metres per second for each Beaufort force, 0 to 12.
BEAUFORT_MID = [0.2, 1.0, 2.4, 4.4, 6.7, 9.3, 12.3, 15.5, 18.9, 22.6, 26.4, 30.5, 34.0]

DESCRIPTION = [
    "Calm",
    "Light air",
    "Light breeze",
    "Gentle breeze",
    "Moderate breeze",
    "Fresh breeze",
    "Strong breeze",
    "Near gale",
    "Gale",
    "Strong gale",
    "Storm",
    "Violent storm",
    "Hurricane",
]


def canonical(raw):
    """Return the canonical unit name, or None if the unit is unknown."""
    cleaned = raw.strip().lower().replace(" ", "")
    for unit, spellings in ALIASES.items():
        if cleaned in spellings:
            return unit
    return None


def beaufort(ms):
    """Return the Beaufort force for a speed in metres per second."""
    for force, limit in enumerate(BEAUFORT_MAX):
        if ms < limit:
            return force
    return 12


def main():
    text = " ".join(sys.argv[1:]).strip()
    if not text:
        print("Enter a wind speed, for example 18 kn")
        return 1

    match = re.match(r"^\s*([0-9]+(?:[.,][0-9]+)?)\s*(.*)$", text)
    if not match:
        print("Cannot read '%s'. Use a form such as 18 kn." % text)
        return 1

    value = float(match.group(1).replace(",", "."))
    unit_text = match.group(2)
    unit = canonical(unit_text) if unit_text else "kn"

    if unit is None:
        print("Unknown unit '%s'. Use kn, m/s, km/h, mph or bft." % unit_text.strip())
        return 1

    if unit == "bft":
        force = int(round(value))
        if force < 0 or force > 12:
            print("Beaufort force must be between 0 and 12.")
            return 1
        ms = BEAUFORT_MID[force]
    else:
        ms = value * TO_MS[unit]

    force = beaufort(ms)
    print(
        "%.1f kn | %.1f m/s | %.1f km/h | %.1f mph | %d Bft %s"
        % (
            ms / TO_MS["kn"],
            ms,
            ms / TO_MS["kmh"],
            ms / TO_MS["mph"],
            force,
            DESCRIPTION[force],
        )
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
