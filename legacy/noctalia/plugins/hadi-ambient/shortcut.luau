-- shortcut.luau — control-center tile
local active=false
local sound="rain"
local function render()
  shortcut.setLabel(active and ("Ambient: " .. sound) or "Ambient")
  shortcut.setIcon(active and "wave-sine" or "wave-sine")
  shortcut.setActive(active)
end
noctalia.state.watch("ambient:active", function(v) active=v==true; render() end)
noctalia.state.watch("ambient:sound", function(v) if type(v)=="string" then sound=v end; render() end)
-- initial
active = noctalia.state.get("ambient:active")==true
local s=noctalia.state.get("ambient:sound"); if type(s)=="string" then sound=s end
render()

function onClick()
  noctalia.runAsync("noctalia msg plugin hadi/ambient:service all toggle ''")
end
