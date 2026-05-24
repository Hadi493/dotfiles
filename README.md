# dotfiles #

Just config files for some programs that I actively use.

# Requirements #

* i3wm / Polybar / Rofi / Picom
* Kitty / Fish / Nushell / Bash
* Emacs / Neovim / Helix / Vim
* Dunst / Twmn / Flameshot
* Cava / Fastfetch / Mpv
* Git
* Any Linux distribution (i use arch)

# Deployment #

Clone the repo somewhere and run `./deploy -h`.

The script handles symlinking your configurations and binaries:

* `all`: Links everything (default).
* `config`: Links all `.config` directories.
* `bin`: Links custom binaries to `/usr/bin/`.
* `fonts`: Links fonts to `~/.local/share/fonts`.
* Individual components: Link specific configs (e.g., `./deploy i3`, `./deploy fish`).

# License #

This project is licensed under the [MIT License](LICENSE).
