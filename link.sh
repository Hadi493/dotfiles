#!/bin/bash

# Get the absolute path of the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

link_emacs() {
    echo "Linking Emacs configuration..."
    # List of files/dirs in emacs.conf to link to $HOME
    FILES=(
        ".emacs"
        ".emacs.custom.el"
        ".emacs.local"
        ".emacs.rc"
        ".emacs.snippets"
    )

    for file in "${FILES[@]}"; do
        if [ -e "$DOTFILES_DIR/emacs.conf/$file" ]; then
            ln -snfv "$DOTFILES_DIR/emacs.conf/$file" "$HOME/$file"
        fi
    done
}

case "$1" in
    emacs)
        link_emacs
        ;;
    *)
        echo "Usage: $0 {emacs}"
        exit 1
        ;;
esac
