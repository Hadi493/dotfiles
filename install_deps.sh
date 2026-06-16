#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUR_HELPER=""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

msg()  { echo -e "${GREEN}[*]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[x]${NC} $1"; }

check_arch() {
    if [ ! -f /etc/arch-release ]; then
        err "This script is for Arch Linux only."
        exit 1
    fi
}

setup_sudo() {
    if ! command -v sudo &>/dev/null; then
        msg "Installing sudo..."
        pacman -S --needed --noconfirm sudo
    fi
    if ! sudo -v &>/dev/null; then
        warn "Adding $USER to sudoers (wheel group)..."
        su -c "echo '%wheel ALL=(ALL:ALL) ALL' >> /etc/sudoers"
        usermod -aG wheel "$USER"
        msg "You may need to re-login for sudo group to take effect."
    fi
}

update_system() {
    msg "Updating system..."
    sudo pacman -Syu --noconfirm
}

link_aur_helpers() {
    msg "Symlinking AUR helpers from dotfiles/bin..."
    local binaries=(yay paru)
    for bin in "${binaries[@]}"; do
        if [ -f "$ROOT/bin/$bin" ]; then
            sudo ln -sf "$ROOT/bin/$bin" "/usr/bin/$bin"
        fi
    done
}

detect_aur_helper() {
    if command -v paru &>/dev/null; then
        AUR_HELPER="paru"
    elif command -v yay &>/dev/null; then
        AUR_HELPER="yay"
    fi
}

install_official() {
    msg "Checking packages against official repos (AUR fallback if not found)..."
    local candidates=(
        hyprland hyprlock hypridle hyprpicker
        xdg-desktop-portal-hyprland
        waybar rofi swaync tofi
        kitty neovim vim
        fish
        swaybg swayosd wf-recorder
        wl-clipboard cliphist brightnessctl playerctl gammastep
        pavucontrol nautilus flameshot
        pipewire wireplumber pipewire-pulse pipewire-audio
        qt5ct
        mpv mpvpaper feh
        yt-dlp ffmpeg imagemagick
        fastfetch cava bat eza fd ripgrep fzf
        peaclock
        ttf-iosevka-nerd ttf-iosevka ttf-iosevka-ss04
        ttf-nerd-fonts-symbols
        papirus-icon-theme
        base-devel git curl
        networkmanager network-manager-applet
        bluez bluez-utils
        polkit
        s-tui
        wlogout nbfc
    )

    local official=()

    for pkg in "${candidates[@]}"; do
        if pacman -Si "$pkg" &>/dev/null; then
            official+=("$pkg")
        else
            msg "  '$pkg' not in official repos → will install from AUR"
            AUR_FALLBACK+=("$pkg")
        fi
    done

    if [ ${#official[@]} -gt 0 ]; then
        msg "Installing ${#official[@]} packages from official repos..."
        sudo pacman -S --needed --noconfirm "${official[@]}"
    fi
}

AUR_PACKAGES=(
    hyprshot
    python-pywal
    walker elephant elephant-desktopapplications
    brave-origin-bin
    firefox
    coomer
    look-bin
)

install_aur() {
    local all_aur=("$@")

    if [ ${#all_aur[@]} -eq 0 ]; then
        return
    fi

    if [ -n "$AUR_HELPER" ]; then
        msg "Installing ${#all_aur[@]} AUR packages with $AUR_HELPER..."
        if $AUR_HELPER -S --needed --noconfirm "${all_aur[@]}"; then
            return 0
        fi
        warn "$AUR_HELPER failed. Will build yay from source..."
    fi

    warn "Building yay from AUR source..."
    local tmpdir
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (cd "$tmpdir/yay" && makepkg -si --noconfirm)
    AUR_HELPER="yay"
    $AUR_HELPER -S --needed --noconfirm "${all_aur[@]}"
}

install_fonts() {
    if [ -d "$ROOT/fonts" ]; then
        msg "Installing custom fonts from dotfiles..."
        local font_dir="$HOME/.local/share/fonts"
        mkdir -p "$font_dir"
        find "$ROOT/fonts" -type f \( -name "*.ttf" -o -name "*.otf" -o -name "*.ttc" \) \
            -exec ln -sf {} "$font_dir/" \;
        fc-cache -f
    fi
}

create_dirs() {
    msg "Creating essential directories..."
    mkdir -p "$HOME/Pictures/wallpapers"
    mkdir -p "$HOME/Pictures/screenshots"
}

create_missing_scripts() {
    local scripts_dir="$HOME/.config/hypr/scripts"

    if [ ! -f "$scripts_dir/songdetail.sh" ]; then
        msg "Creating stub songdetail.sh (for hyprlock)..."
        cat > "$scripts_dir/songdetail.sh" << 'EOF'
#!/bin/bash
playerctl metadata --format "{{ artist }} - {{ title }}" 2>/dev/null || echo ""
EOF
        chmod +x "$scripts_dir/songdetail.sh"
    fi
}

enable_services() {
    msg "Enabling system services..."
    sudo systemctl enable --now NetworkManager 2>/dev/null || true
    sudo systemctl enable --now bluetooth 2>/dev/null || true
    sudo systemctl enable --now pipewire-pulse 2>/dev/null || true
}

run_deploy() {
    if [ -x "$ROOT/deploy" ]; then
        msg "Linking configurations with deploy script..."
        "$ROOT/deploy" all
        "$ROOT/deploy" bin
    fi
}

post_install_notes() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  All done!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Start Hyprland with 'Hyprland' on tty1 or your DM."
    echo ""
    echo "Custom binaries from dotfiles/bin/ (symlinked):"
    echo "  yay paru cg-timer wayland-boomer wal wlogout toofan"
    echo ""
    echo "After first login, run: wal -i ~/Pictures/wallpapers/<image>"
}

main() {
    check_arch

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Dotfiles bootstrap — Hyprland${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    if [ "$(id -u)" -eq 0 ]; then
        err "Do not run as root. Run as a regular user."
        exit 1
    fi

    setup_sudo
    update_system
    link_aur_helpers
    detect_aur_helper

    AUR_FALLBACK=()
    install_official
    install_aur "${AUR_FALLBACK[@]}" "${AUR_PACKAGES[@]}"

    install_fonts
    create_dirs
    create_missing_scripts
    enable_services
    run_deploy

    post_install_notes
}

main "$@"
