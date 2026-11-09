-- Boot loader for a bare `Hyprland` or `start-hyprland` start.
--
-- Those commands read ~/.config/hypr/hyprland.lua. The real config lives in
-- ~/dotfiles (single source of truth). Hyprland resolves require() from the
-- directory of the file it was given, so point package.path at the dotfiles
-- tree before loading it.
local dir = os.getenv("HOME") .. "/dotfiles/.config/hypr"
package.path = dir .. "/?.lua;" .. package.path
dofile(dir .. "/hyprland.lua")
