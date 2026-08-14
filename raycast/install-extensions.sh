#!/usr/bin/env bash
# Open each Raycast store page in turn so you can install it.
# Press Enter in Raycast to install, then come back here and press Enter again.

set -uo pipefail

EXTENSIONS=(
  # must have
  "fernando_barrios/shottr        Shottr screenshot control"
  "vlades/herdr                   Herdr workspaces and agents"
  "devahschaefers/fantastical     Fantastical natural language events"
  "thomas/google-calendar         Google Calendar"
  "nhojb/brew                     Homebrew search and install"
  "samuelkraft/workouts           Strava workouts and routes"
  "comoser/surfs-up               Wind and wave conditions, on trial"

  # replaces an Alfred workflow you had
  "moored/git-repos               Git Repos"
  "rolandleth/kill-process        Kill Process, replaces ProcessControl"
  "thomas/color-picker            Color Picker"
  "reckoning-dev/zotero           Search Zotero, replaces ZotHero"
  "leandro.maia/google-scholar    Google Scholar"
  "xilopaint/pdf-tools            PDF Tools, replaces Alfred PDF Tools"
  "koayon/arxiv                   ArXiv Search"
  "gebeto/translate               Google Translate"
  "tumtum/apple-notes             Apple Notes"
  "erics118/brew-services          Manage brew services"
)

# Timed mode. Run "./install-extensions.sh 8" to advance every 8 seconds
# instead of waiting for a key press. Use this when the terminal is not
# interactive.
#
# Retry mode. Pass one or more slugs to reopen only those pages, for example
# "./install-extensions.sh 8 vlades/herdr thomas/color-picker".
DELAY="${1:-}"
shift || true

if [[ $# -gt 0 ]]; then
  EXTENSIONS=("$@")
fi

echo "Raycast extension install helper"
if [[ -n "$DELAY" ]]; then
  echo "Each page opens for $DELAY seconds. Press Enter in Raycast to install."
else
  echo "Install each page with Enter inside Raycast, then press Enter here."
fi
echo

for entry in "${EXTENSIONS[@]}"; do
  slug="${entry%% *}"
  label="${entry#"$slug"}"
  label="$(printf '%s' "$label" | sed 's/^ *//')"
  printf '  %-34s %s\n' "$slug" "$label"
  open "raycast://extensions/$slug"
  if [[ -n "$DELAY" ]]; then
    sleep "$DELAY"
  else
    read -r -p "    installed? press Enter for the next one " _
  fi
done

echo
echo "Done. Run 'raycast://extensions' to review what is installed."
