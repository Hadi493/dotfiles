clear
# fastfetch
# nitchrevived

export HELIX_RUNTIME=$HOME/.config/helix/runtime
# exports
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=kvantum
# ===============================================
# FISH SHELL ENHANCED CONFIGURATION
# ===============================================

# Enable all Fish features
set -g fish_greeting ''

# ===============================================
# FISH AUTOCOMPLETION & SYNTAX HIGHLIGHTING
# ===============================================

# Pager colors
set -g fish_pager_color_completion ffdd33
set -g fish_pager_color_description B3A06D 73c936
set -g fish_pager_color_prefix white --bold --underline
set -g fish_pager_color_progress brwhite --background=181818

# ===============================================
# AUTOCOMPLETION SETTINGS
# ===============================================

# Enable case-insensitive autocompletion
set -g fish_complete_case_insensitive 1

# Enable autosuggestions from history
set -g fish_autosuggestion_enabled 1


set -Ux CHROME_EXECUTABLE /bin/chromium
export CHROME_EXECUTABLE

set -Ux ANDROID_HOME ~/Android/Sdk                                                                                        ⏱ {2.354}s 00:13:
set -Ux ANDROID_SDK_ROOT ~/Android/Sdk
set -Ux PATH $PATH $ANDROID_HOME/cmdline-tools/latest/bin $ANDROID_HOME/platform-tools
set -Ux VIRTUAL_ENV_DISABLE_PROMPT 1

# ===============================================
# HISTORY SETTINGS
# ===============================================

# Set history size
set -g fish_history_max 10000

# Save timestamp in history
set -g fish_save_timestamp 1

# Vi mode (optional - uncomment if you prefer vi keybindings)
# fish_vi_key_bindings

fish_default_key_bindings

# Enhanced navigation
bind \e\[1\;5C forward-word # Ctrl+Right
bind \e\[1\;5D backward-word # Ctrl+Left
bind \cH backward-kill-word # Ctrl+Backspace
bind \e\[3\;5~ kill-word # Ctrl+Delete

# History search with arrow keys
bind \e\[A history-search-backward # Up arrow
bind \e\[B history-search-forward # Down arrow

# Enhanced ls with colors
function ls --wraps=ls --description="Enhanced ls with colors"
    command ls --color=auto $argv
end

# Better grep with colors
function grep --wraps=grep --description="Enhanced grep with colors"
    command grep --color=auto $argv
end

# Enhanced tree command if available
if command -q tree
    function tree --wraps=tree --description="Enhanced tree with colors"
        command tree -C $argv
    end
end

# Smart cd that lists contents
function cd --wraps=cd --description="cd with auto-ls"
    builtin cd $argv
    and l
end

# Extract function for various archive formats
function extract --description="Extract various archive formats"
    if test (count $argv) -ne 1
        echo "Usage: extract <archive>"
        return 1
    end

    set -l file $argv[1]

    if not test -f $file
        echo "Error: '$file' is not a valid file"
        return 1
    end

    switch $file
        case '*.tar.bz2'
            tar xjf $file
        case '*.tar.gz'
            tar xzf $file
        case '*.bz2'
            bunzip2 $file
        case '*.rar'
            unrar x $file
        case '*.gz'
            gunzip $file
        case '*.tar'
            tar xf $file
        case '*.tbz2'
            tar xjf $file
        case '*.tgz'
            tar xzf $file
        case '*.zip'
            unzip $file
        case '*.Z'
            uncompress $file
        case '*.7z'
            7z x $file
        case '*'
            echo "Error: '$file' cannot be extracted via extract()"
            return 1
    end
end

# Quick file finder
function ff --description="Find files quickly"
    find . -name "*$argv*" 2>/dev/null
end

# Process finder
function psg --description="Grep running processes"
    ps aux | grep -v grep | grep -i $argv
end

# Weather function (requires curl)
function weather --description="Get weather info"
    if test (count $argv) -eq 0
        curl -s "wttr.in?format=3"
    else
        curl -s "wttr.in/$argv[1]?format=3"
    end
end

# Theme Environment Variables
set -x QT_QPA_PLATFORMTHEME qt5ct
set -x QT_STYLE_OVERRIDE Adwaita-Dark
set -x GTK_THEME Adwaita:dark

# Add ~/.local/bin to PATH
set -gx PATH $HOME/.local/bin $PATH

# source fish config
alias sfc="source ~/.config/fish/config.fish"

# Basic file operations
alias l="eza --long --header --git --icons --group-directories-first"
alias ls="ls -a"
alias c="clear"
alias toc="touch"
alias md="mkdir -pv"
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"
alias cat="bat"
alias dsk="dysk --all"
alias cl="c ;; l"

# yay
alias yayf="yay -Slq | fzf --multi --preview 'yay -Sii {1}' --preview-window=down:75% | xargs -ro yay -S"

#play
alias playurl="~/.config/waybar/scripts/play-song.sh"

# configs
alias fconf="nv ~/.config/fish/config.fish"
alias niri-config="nv ~/.config/niri/config.kdl"
alias hyprconf="nv ~/.config/hypr/hyprland.conf"
alias whconf="nv ~/.config/hypr/scripts/wallpaper_changer.sh"
alias cdwm="nv ~/cg-dwm/config.h"
alias mdwm="cd ~/cg-dwm; sudo make clean install; cd -"


alias jrnl="nv ~/jrnls/jrnl.daily.md"
alias bjrnl="nv ~/jrnls/bjrnl.md"
alias ht="nv ~/jrnls/ht.daily.md"

# Logout from i3
alias logout="hyprctl dispatch exit"

# Restart i3 (without logging out)
alias i3-restart="i3-msg restart"

# Reload i3 config
alias i3-reload="i3-msg reload"

# yt-dlp
alias dv="yt-dlp --no-playlist -f \"bestvideo+bestaudio\" --cookies-from-browser firefox"

# check video quality
alias vqc="ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0"

# # boomer for zoomer
# alias boomer="~/.config/boomer/boomer"

# Editor aliases
alias nv="nvim"
alias hx="helix"
alias v="vim"
alias emnw="emacs -nw"

# poetry
alias pv="v ~/Documents/poetry/poetry.md"
alias pnv="nv ~/Documents/poetry/poetry.md"
alias ph="hx ~/Documents/poetry/poetry.md"

# Git aliases
alias g="git"
alias ga="git add"
alias gc="git commit -m"
alias gb="git branch"
alias gp="git push -v"
alias gpl="git pull"
alias gs="git status"
alias gd="git diff"
alias gco="git checkout"
alias gacp='git add . && git commit -m "..." && git push'
alias done="gacp"

alias git_graph="git log --graph --oneline --decorate --all"
alias g_graph="git log --graph --pretty=format:'%C(auto)%h%d %s %C(blue)</%an>' --all"
alias gb_graph="git log --graph --abbrev-commit --decorate --all --format=format:'%C(bold blue)%h%C(reset) - %C(dim white)%an%C(reset) %C(bold yellow)%d%C(reset)%n''%C(white)%s%C(reset)' --date=short"

# System monitoring
alias df="df -h" # Human readable disk usage
alias du="du -h" # Human readable directory usage
alias free="free -h" # Human readable memory usage
alias ps="ps auxf" # Full process list

# Network
alias ping="ping -c 5" # Ping 5 times by default
alias wget="wget -c" # Continue partial downloads

# Safety aliases
alias chown="chown --preserve-root"
alias chmod="chmod --preserve-root"
alias chgrp="chgrp --preserve-root"

# Custom Aliases

# ----- if can't install directly ------ #
# tmux -> (Zellij)
# alias Zellij="bash (curl -L zellij.dev/launch | psub) "

# set wallpaper
alias set-wallpaper="feh --bg-fill"


alias sys-upgrade='sudo timeshift --create --comments "Before Upgrade" --tags D && sudo pacman -Syu'

# clean caches
alias callc="~/.config/hypr/scripts/clean_arch.sh"

# uptime
alias uptime="uptime -p | bat -l asm"

alias grep-rec="grep -Ri"

# Search for a string in a single file (with line numbers)
alias grep-l="grep -n"

# Search and highlight the match in color
alias grep-color="grep --color=auto"

# Search only for whole words
alias grep-word="grep -w"

# Count the number of matches
alias grep-count="grep -c"

# Show lines before/after match (context)
alias grep-context="grep -C 3"

# Combine recursive + color + line numbers
alias grep-all="grep -Rin --color=auto"

set -g os_name (string replace 'NAME=' '' (grep '^NAME=' /etc/os-release) | string trim --chars='"')

# ===============================================
# ENHANCED PROMPTS
# ===============================================

# fish prompt (left prompt)
function fish_prompt
    set -l last_status $status
    # set_color 00ffaf
    set_color 73c936
    echo -n "╭──("
    # set_color 00ff87
    set_color 73c936
    echo -n "$USER"
    # set_color 00ff8f
    set_color 73c936
    echo -n "@"
    # echo -n "[]"
    # set_color 00ff87
    set_color 73c936
    echo -n "$os_name"
    # set_color 00ffaf
    set_color 73c936
    echo -n ")"

     # Virtual env
    if set -q VIRTUAL_ENV
		set_color ffdd33
        echo -n "-("(basename $VIRTUAL_ENV)")"
    end

    # set_color 00ffaf
    set_color 73c936
    echo -n "-["
    # set_color 00ffaf
    set_color 73c936
    # set_color 73c936
    echo -n (prompt_pwd)
    # set_color 00ffaf
    set_color 73c936
    echo -n "]"



    # git branch with status
    if git rev-parse --git-dir >/dev/null 2>&1
        set -l git_branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
        set -l git_status (git status --porcelain 2>/dev/null)
        set_color ffdd33
        echo -n "  $git_branch"

        # Show git status indicators
        if test -n "$git_status"
            set_color ffdd33
            echo -n "*"
        end
        set_color ff87d7
        echo -n ""
    end

    # Show exit status if non-zero
    if test $last_status -ne 0
        set_color ffdd45
        echo -n " [$last_status]"
    end

    echo
    # set_color 00ffaf
    set_color 73c936
    echo -n "╰─"
    # set_color 00ffaf
    set_color 73c936
    # echo -n " ❯❯ "
	echo -n "\$ "
    set_color 73c936
end


# function fish_prompt
#     set -l last_status $status
#     set_color 00ffaf
#     echo -n ""
#     set_color 00ff87
#     echo -n "$USER"
# 	set_color 1793D1
#     echo -n "   "
#     set_color 00ff87
#     echo -n "$os_name"
#     set_color 00ffaf
#     echo -n ""
#
#      # Virtual env
#     if set -q VIRTUAL_ENV
#         set_color ff5fff
#         echo -n " "(basename $VIRTUAL_ENV)""
#     end
#
#     set_color 00ffaf
#     echo -n " "
#     set_color 00ffaf
#     echo -n (prompt_pwd)
#     set_color 00ffaf
#     echo -n " "
#
#
#
#     # git branch with status
#     if git rev-parse --git-dir >/dev/null 2>&1
#         set -l git_branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
#         set -l git_status (git status --porcelain 2>/dev/null)
#         set_color ff87d7
#         echo -n " $git_branch"
#
#         # Show git status indicators
#         if test -n "$git_status"
#             set_color yellow
#             echo -n "*"
#         end
#         set_color ff87d7
#         echo -n ""
#     end
#
#     # Show exit status if non-zero
#     if test $last_status -ne 0
#         set_color red
#         echo -n " $last_status"
#     end
#
#     echo
#     set_color 00ffaf
#     echo -n ""
#     set_color 00ffaf
#     # echo -n " ❯❯ "
# 	echo -n "\$ "
#     set_color normal
# end

# Right prompt with time and additional info
function fish_right_prompt
    set_color 73c936
    set -l cmd_duration $CMD_DURATION
    set_color 73c936
    set -l timestamp (date "+%H:%M:%S")

    # Show command duration if > 2 seconds
    if test $cmd_duration -gt 2000
        set -l duration_seconds (math "$cmd_duration / 1000")
        set_color 73c936
        echo -n "⏱ {$duration_seconds}s "
    end

    # Show current time
    set_color 666666
    echo -n "$timestamp"
    set_color 73c936
end

# Title function to set terminal title
function fish_title
    echo (status current-command) " " (prompt_pwd)
end

if not contains /usr/bin $PATH
    set -x PATH /usr/local/bin /usr/bin /bin /usr/local/sbin /usr/sbin /sbin $PATH
end
