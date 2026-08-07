local P = {}

P.terminal = "st"
P.audiosettings = "pavucontrol"
P.codeditor = "emacs"
P.fileManager = "nautilus"
P.menu = "rofi -show drun -config ~/.config/rofi/drun.rasi"
P.tmenu = "tofi-drun -c ~/.config/tofi/configA --drun-launch=true"
P.wallpaper_selector = "~/.config/hypr/scripts/wallpaper_select"
P.camera = "cheese"
P.look_menu = "lookapp"
P.discord_web = "brave-origin --profile-directory=Default --app=https://discord.com/channels/@me"
P.discord = "discord"
P.telegram = "Telegram"
P.reddit = "brave-origin --profile-directory=Default --app=https://reddit.com"
P.facebook = "brave-origin --profile-directory=Default --app=https://facebook.com"
P.facebook2 = "brave-origin --profile-directory=\"Profile 1\" --app=https://facebook.com"
P.whatsapp = "brave-origin --profile-directory=Default --app=https://web.whatsapp.com"
P.yt = "brave-origin --profile-directory=Default --app=https://youtube.com"
P.twitch = "brave-origin --profile-directory=Default --app=https://www.twitch.tv/"
P.toggle_microphone = "pactl set-source-mute @DEFAULT_SOURCE@ toggle"
P.colorPicker = "hyprpicker"
P.fsc = "nbfc set -s 100 || nbfc set -a"
P.setup_workspace = "~/.config/hypr/scripts/workspace-setup"

P.default_wall = "~/.config/hypr/scripts/set_wallpaper ~/Pictures/wall.jpg"

P.web_game_ev = "brave-origin --profile-directory=Default --app=https://ev.io"

P.magnific = "brave-origin --profile-directory=Default --app=https://contributor.magnific.com/catalog/published-files"

return P
