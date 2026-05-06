export HISTSIZE=10000
export HISTFILESIZE=10000

export HISTCONTROL=ignoredups

export EDITOR='vim'

alias l='ls'
alias ll='ls -la'
alias v='vim'
alias nv='nvim'
alias c=clear
alias i='sudo pacman -S'
alias s='sudo pacman -Ss'
alias update='sudo pacman -Syyu'

# yt-dlp
alias dv="yt-dlp --no-playlist -f \"bestvideo+bestaudio\" --cookies-from-browser firefox"

# Git aliases
alias gb='git branch'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'


parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[0;31m\]\$(parse_git_branch)\[\033[00m\]\\n$ "
