export HISTSIZE=10000
export HISTFILESIZE=10000

export HISTCONTROL=ignoredups

export EDITOR='vim'

alias l='ls'
alias ll='ls -lha'
alias ..='cd ..'
alias grep='grep --color=auto'
alias v='vim'
alias nv='nvim'
alias c=clear
alias i='sudo pacman -S'
alias s='sudo pacman -Ss'
alias update='sudo pacman -Syyu'
alias sb='source ~/.bashrc'

# yt-dlp
alias dv="yt-dlp --no-playlist -f \"bestvideo+bestaudio\" --cookies-from-browser firefox"

# Git aliases
alias gb='git branch'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push -v'

mkcd () {
    mkdir -p -- "$1" && cd -P -- "$1"
}

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="\[\033[38;2;0;255;175m\]\u@\h\[\033[38;2;0;255;175m\]:\[\033[38;2;0;255;175m\]\w\[\033[38;2;255;135;215m\]\$(parse_git_branch)\[\033[38;2;0;255;175m\]\\n$ "


if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
