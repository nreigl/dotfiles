# Raycast

Raycast replaced Alfred on 2026-08-14. Raycast keeps its own settings in
`~/Library/Application Support/com.raycast.macos/`. That database is not
stowable, so this package holds only the parts that live in the repository.

## Contents

- `scripts/` — script commands that no store extension covers
- `install-extensions.sh` — opens each store page so you can install it

## Setup

Raycast settings are not files. You must set these once through the user
interface.

1. Quit Alfred. Alfred holds Cmd-Space.
2. Open Raycast. Set the hotkey to Cmd-Space.
3. Open Settings, then Extensions, then the plus button.
4. Choose "Add Script Directory" and select `~/dotfiles/raycast/scripts`.
5. Run `./install-extensions.sh` and install each page.

## Script commands

| Command | Input | Result |
| --- | --- | --- |
| Wind Convert | `18 kn`, `9 m/s`, `35 km/h`, `5 bft` | all units plus Beaufort |
| Windguru | spot name, spot id, or empty | opens the forecast |

`Wind Convert` assumes knots when you give no unit.

`Windguru` reads a spot list at the top of `scripts/windguru.sh`. The ids are
empty. To fill one, open the spot on windguru.cz and copy the number from the
URL. For example `https://www.windguru.cz/48651` has the id `48651`. Without an
id the script opens a Windguru search instead.

`Windguru` only opens a browser tab. It does not read forecast data. Windguru
sells API access as a Pro feature, so no extension can show the numbers inside
Raycast. `comoser/surfs-up` is on trial as the alternative. It reads a free
source and shows wind and wave conditions in Raycast directly.

## AI assistants

The store extensions for Claude and ChatGPT call the vendor APIs. They bill per
token and ignore a Claude Pro or ChatGPT Plus subscription. Both are left out of
`install-extensions.sh` for that reason.

Use the desktop apps instead. Raycast launches them by name, and they use the
subscription you already pay for.

- `Claude.app`, bundle `com.anthropic.claudefordesktop`, scheme `claude://`
- `ChatGPT Classic.app`, bundle `com.openai.chat`, scheme `openai://`

## Surf and wind data

`comoser/surfs-up` scrapes Windguru through the `wind-scrape` package, so its
spot ids are Windguru spot ids. Spot 341 is Tallinn in both.

The spot list is compiled into the extension as `src/data/spots.json`. It holds
361 spots and one Estonian entry, Tallinn. There is no preference to add more.
To add a spot you must fork the extension and run a local build. The extension
was last updated in May 2024.

## Free plan limits

Raycast free covers clipboard history, snippets, quicklinks, window management,
and script commands. It does not sync settings between machines. Keep anything
you want to keep in this repository.
