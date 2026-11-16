# SPECS index

Modular specifications for the dotfiles repo. Read
[`architecture.md`](architecture.md) first, then
[`invariants.md`](invariants.md) before changing anything.

## Core

| Spec | Covers |
|---|---|
| [`architecture.md`](architecture.md) | Repo layout, `deploy`, Hyprland boot chain, packages, adding a tool. |
| [`invariants.md`](invariants.md) | The 12 rules that must not break, each with a check. |

## Tools

| Spec | Covers |
|---|---|
| [`tools/hyprland.md`](tools/hyprland.md) | Compositor, Lua tree, loader, monitors, binds. |
| [`tools/waybar.md`](tools/waybar.md) | Bar modules, scripts, startup delay. |
| [`tools/swaync.md`](tools/swaync.md) | Notifications, OSD, systemd unit. |
| [`tools/kitty.md`](tools/kitty.md) | Terminal config layering and keymaps. |
| [`tools/fish.md`](tools/fish.md) | Shell load order, PATH, colours, prompts. |
| [`tools/nvim.md`](tools/nvim.md) | vim-plug layout, leader, editing rules. |
| [`tools/emacs.md`](tools/emacs.md) | Modular RC tree, input methods, autocommit hazard. |
| [`tools/launchers.md`](tools/launchers.md) | rofi, tofi and fuzzel: who owns what. |
| [`tools/clipboard.md`](tools/clipboard.md) | cliphist, thumbnails, `pass`, performance rules. |
| [`tools/st.md`](tools/st.md) | Building suckless st with the alpha patch. |

## Convention

A tool spec answers, in this order:

1. **Purpose** — one paragraph, why it exists.
2. **Files** — table of path → role.
3. **Dependencies** — packages and services.
4. **Behaviour** — keybindings, modes, lifecycle.
5. **Design decisions** — the non-obvious choices and why.
6. **Gotchas** — what breaks and how to check it.

Write facts you verified, not intentions. If a claim is a convention rather than
a guarantee, say so. Keep each spec under ~80 lines; split when it grows.
