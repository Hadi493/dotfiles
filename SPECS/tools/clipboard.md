# Clipboard

## Purpose

Clipboard history for text and images, plus a password lookup, all keyed from
`Super+V` (`scripts/clipboard`).

## Files

| Path | Role |
|---|---|
| `.config/hypr/scripts/clipboard` | Fuzzel front end. Modes: history, `manage`, `pass`. |
| `.config/hypr/scripts/clipboard-store` | `wl-paste --watch` target: stores the entry, builds the thumbnail. |
| `.config/hypr/scripts/lib/clip-thumb.sh` | Thumbnail helper shared by both. |
| `.config/fuzzel/fuzzel.ini` | Picker UI (required — see INV-7). |

## Dependencies

`cliphist`, `wl-clipboard`, `fuzzel`, `imagemagick` (`magick`), `pass` + `gnupg`
for the password mode.

## Data flow

```
wl-paste --type text  --watch cliphist store            (startup.lua)
wl-paste --type image --watch scripts/clipboard-store   (startup.lua)
                                  │
                                  ├─ cliphist store
                                  └─ 128px PNG in ~/.cache/cliphist-thumbs/<id>
                                          │
Super+V → scripts/clipboard ──────────────┘  rows: URL, Path, Colour, Email,
                                             JSON, Image WxH; pinned (★) first
```

## Behaviour

| Bind | Mode |
|---|---|
| `Super+V` | history; Enter copies |
| `Super+Alt+V` | manage: clear history, delete entries |
| `Super+Shift+V` | `pass` store: searches `~/.password-store`, Enter copies the password |

## Performance rules (do not regress)

The picker must stay instant with ~750 entries:

- Thumbnails are **pre-built** by `clipboard-store`; opening the picker never
  decodes images and never runs `magick identify`.
- Image dimensions come from cliphist's preview line
  (`[[ binary data … png 600x600 ]]`).
- A missing thumbnail shows a generic icon for one open and is backfilled in the
  background.
- Text rows are formatted in-process; a command substitution per row is too slow.
- History is capped by `cliphist -max-items` (750). The database lives in
  `~/.cache/cliphist/db` (~50 MB) and can be trimmed in
  `~/.config/cliphist/config`.

## Gotchas

- `scripts/clipboard-store` must be executable and reachable by absolute path;
  `startup.lua` passes `$HOME/dotfiles/.config/hypr/scripts/clipboard-store`.
- `pass` mode requires `PASSWORD_STORE_DIR` or the default `~/.password-store`.
- Deleting `~/.cache/cliphist-thumbs` only costs one slow open per image; the
  cache is rebuilt automatically.
