-- shortcut.luau — Control Center tile for Now Play
local track=""
local active=false
local isPlaying=false
local function baseName(p) return p:match("([^/\\]+)$") or p end
local function render()
  shortcut.setLabel(active and (isPlaying and ("▶ " .. baseName(track)) or ("⏸ " .. baseName(track))) or "Now Play")
  shortcut.setIcon(active and "music" or "music-off")
  shortcut.setActive(active and isPlaying)
end
noctalia.state.watch("nowplay:track", function(v) if type(v)=="string" then track=v end; render() end)
noctalia.state.watch("nowplay:active", function(v) active=v==true; render() end)
noctalia.state.watch("nowplay:isPlaying", function(v) isPlaying=v==true; render() end)
track = noctalia.state.get("nowplay:track") or ""
active = noctalia.state.get("nowplay:active")==true
isPlaying = noctalia.state.get("nowplay:isPlaying")==true
render()
function onClick() noctalia.runAsync("noctalia msg plugin hadi/nowplay:service all toggle ''") end
