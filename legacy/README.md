# legacy/

Configurations that are archived, not deleted, because they still document
decisions or may be revived.

| Path | What | Status |
|---|---|---|
| `noctalia/` | Noctalia (Quickshell shell) config + the `hadi-ambient` plugin | Not part of the session. Installable with `./deploy noctalia`. |
| `swayosd/` | Volume/brightness OSD | Replaced by swaync notifications. `./deploy swayosd`. |
| `packages.system.pkglist` | Old whole-machine `pacman -Qqe` dump (419 entries) | Reference only. Superseded by `bootstrap/packages/`. |
| `aur.system.pkglist` | Old AUR dump | Reference only. Superseded by `bootstrap/packages/aur.txt`. |

Rules:

- Nothing in here is linked by `./deploy all`.
- Do not add new files here. New work belongs in `.config/`; only move a config
  here when it is retired, and add a row to this table in the same commit.
- Do not delete this directory without an explicit decision from the owner.
