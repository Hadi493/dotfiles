# config.nu
#
# Installed by:
# version = "0.112.2"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

alias l = ls
alias ll = ls -la
alias .. = cd ..
alias grep = grep --color=auto
alias v = vim
alias nv = nvim
alias emnw = emacs -nw
alias c = clear
alias i = sudo pacman -S
alias s = sudo pacman -Ss
alias update = sudo pacman -Syyu

alias gs = git status
alias ga = git add
alias gc = git commit
alias gp = git push -v

alias vqc = ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0

def dv [url: string] {
    yt-dlp --no-playlist -f "bestvideo+bestaudio" --cookies-from-browser firefox $url
}

# Custom Prompt:
$env.PROMPT_COMMAND = { ||
    let username = (whoami)
    let hostname = (sys host | get hostname)
    let current_dir = (
      if ($env.PWD | str starts-with $env.HOME) {
          let rel = ($env.PWD | path relative-to $env.HOME)
          if ($rel | is-empty) { "~" } else { $"~/($rel)" }
      } else {
          $env.PWD
      }
    )
    
    let primary_color = (ansi -e { fg: '#00ffaf' })
    let reset = (ansi reset)

    $"($primary_color)($username)@($hostname):($current_dir)($reset)\n"
}

$env.PROMPT_COMMAND_RIGHT = { || "" }
$env.PROMPT_MULTILINE_INDICATOR = { || "" }
