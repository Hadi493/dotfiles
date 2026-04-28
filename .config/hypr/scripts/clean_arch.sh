#!/bin/bash

# This script performs cleaning tasks on an Arch Linux system.
# It will use 'sudo' for some commands, so you may be prompted for your password.

echo "--- Starting Arch Linux Cleanup ---"
echo ""

# 1. Clean the package manager cache
echo "--- Cleaning package manager cache... ---"
sudo pacman -Scc --noconfirm
echo "--- Package manager cache cleaned. ---"
echo ""

# 2. Remove orphan packages
echo "--- Removing orphan packages... ---"
if [[ -n "$(pacman -Qtdq)" ]]; then
    sudo pacman -Rns --noconfirm $(pacman -Qtdq)
    echo "--- Orphan packages removed. ---"
else
    echo "--- No orphan packages to remove. ---"
fi
echo ""

# 3. Clean up journald logs
echo "--- Cleaning journald logs (keeping last 3 days)... ---"
sudo journalctl --vacuum-time=3d
echo "--- Journald logs cleaned. ---"
echo ""

# 4. Clean user cache in ~/.cache (use with caution)
# This command is commented out by default because it can be aggressive.
# It removes the cache for many of your applications, which is usually safe,
# but might cause them to run slower the first time you open them afterward.
# If you want to clear the entire user cache, uncomment the two lines below.
# echo "--- Cleaning user cache in ~/.cache... ---"
# rm -rf ~/.cache/*

echo "--- Arch Linux Cleanup Finished ---"
