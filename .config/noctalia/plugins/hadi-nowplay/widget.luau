-- widget.luau — Now Play bar widget
local track=""
local active=false
local isPlaying=false
local volume=0.45
local function baseName(p) return p:match("([^/\\]+)$") or p end
local function render()
  if active and track~="" then
    local name = baseName(track)
    if #name>28 then name=name:sub(1,26)..".." end
    barWidget.setGlyph(isPlaying and "player-play" or "player-pause")
    barWidget.setText(name)
    barWidget.setTooltip((isPlaying and "▶ " or "⏸ ") .. baseName(track))
  else
    barWidget.setGlyph("music")
    barWidget.setText("now play")
    barWidget.setTooltip(noctalia.tr("widget.tooltip.stopped"))
  end
end
noctalia.state.watch("nowplay:track", function(v) if type(v)=="string" then track=v end; render() end)
noctalia.state.watch("nowplay:active", function(v) active=v==true; render() end)
noctalia.state.watch("nowplay:isPlaying", function(v) isPlaying=v==true; render() end)
noctalia.state.watch("nowplay:volume", function(v) if type(v)=="number" then volume=v end; render() end)
track = noctalia.state.get("nowplay:track") or ""
active = noctalia.state.get("nowplay:active")==true
isPlaying = noctalia.state.get("nowplay:isPlaying")==true
local vol = noctalia.state.get("nowplay:volume"); if type(vol)=="number" then volume=vol end
render()
noctalia.setUpdateInterval(2000)
function update() render() end
function onClick() noctalia.togglePanel("hadi/nowplay:nowplay-panel") end
function onRightClick() noctalia.runAsync("noctalia msg plugin hadi/nowplay:service all toggle ''") end
function onMiddleClick() noctalia.runAsync("noctalia msg plugin hadi/nowplay:service all next ''") end
function onScroll(axis, steps)
  if axis~="vertical" then return end
  if steps<0 then
    noctalia.runAsync("noctalia msg plugin hadi/nowplay:service all next ''")
  else
    noctalia.runAsync("noctalia msg plugin hadi/nowplay:service all prev ''")
  end
end
