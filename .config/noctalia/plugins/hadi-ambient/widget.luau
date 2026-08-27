-- widget.luau — Rain & Cloudy Ocean minimal
local GLYPHS = { ["rain"]="cloud-rain", ["ocean"]="cloud" }
local active=false
local sound="rain"
local volume=0.32
local function render()
  local g = GLYPHS[sound] or "cloud-rain"
  local volPct = math.floor(volume*100+0.5)
  barWidget.setGlyph(g)
  if active then
    barWidget.setText(sound .. " " .. tostring(volPct) .. "%")
    barWidget.setTooltip(noctalia.tr("widget.tooltip.playing") .. " — " .. sound)
  else
    barWidget.setText("ambient")
    barWidget.setTooltip(noctalia.tr("widget.tooltip.stopped"))
  end
end
noctalia.state.watch("ambient:active", function(v) active=v==true; render() end)
noctalia.state.watch("ambient:sound", function(v) if type(v)=="string" then sound=v end; render() end)
noctalia.state.watch("ambient:volume", function(v) if type(v)=="number" then volume=v end; render() end)
active = noctalia.state.get("ambient:active")==true
local s=noctalia.state.get("ambient:sound"); if type(s)=="string" then sound=s end
local vol=noctalia.state.get("ambient:volume"); if type(vol)=="number" then volume=vol end
render()
noctalia.setUpdateInterval(3000)
function update() render() end
function onClick() noctalia.runAsync("noctalia msg plugin hadi/ambient:service all cycle ''") end
function onRightClick() noctalia.runAsync("noctalia msg plugin hadi/ambient:service all toggle ''") end
function onMiddleClick() noctalia.togglePanel("hadi/ambient:ambient-panel") end
function onScroll(axis, steps)
  if axis~="vertical" then return end
  volume = math.clamp(volume - steps*0.05, 0, 1)
  noctalia.runAsync("noctalia msg plugin hadi/ambient:service all volume " .. tostring(volume))
  render()
end
