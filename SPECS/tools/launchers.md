# Launchers (rofi, tofi, fuzzel)

Three launchers, each with a distinct job. They are not interchangeable and
none is dead weight.

| Launcher | Bind / caller | Config | Job |
|---|---|---|---|
| rofi | `Super+D` | `.config/rofi/{config,drun,wallpaper}.rasi` | Application menu (drun) and wallpaper picker. |
| tofi | `Super+Shift+A` | `.config/tofi/configA`, `configV` | Fast drun launcher (`tofi-drun`). |
| fuzzel | clipboard + `pass` | `.config/fuzzel/fuzzel.ini` | `scripts/clipboard` and the password picker only. |

## Dependencies

`rofi`, `tofi`, `fuzzel`, `papirus-icon-theme` (fuzzel icons), a Nerd Font.

## Commands

```bash
rofi -show drun -config ~/.config/rofi/drun.rasi     # from P.menu
tofi-drun -c ~/.config/tofi/configA --drun-launch=true
scripts/clipboard                                     # fuzzel
scripts/clipboard pass                                # fuzzel + pass
```

## Design decisions

- **rofi is the default menu** because it supports the drun + wallpaper themes;
  tofi is the fast path people reach for with `Super+Shift+A`.
- **fuzzel is intentionally narrow.** It is not a general launcher here; it is
  the UI for clipboard history and `pass`. Deleting `.config/fuzzel` breaks
  both (INV-7).
- **Wallpaper picker** is `rofi` with `wallpaper.rasi`, driven by
  `scripts/wallpaper_select`; the theme also lives in `.config/rofi`.

## Gotchas

- tofi uses a full-screen overlay (`width/height = 100%`), not a small centred
  box; `configA` is the drun launcher and `configV` a variant with a different
  font. Changing one does not change the other.
- fuzzel sets `layer = overlay` so it draws above fullscreen windows.
- Changing the rofi theme means editing three `.rasi` files or the shared
  `config.rasi` import — check which one the bind actually uses.
- `.config/rofi/screenshots/` holds documentation images; it is tracked and not
  used at runtime.
