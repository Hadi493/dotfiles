-- panel.luau — Minimal Rain & Cloudy Ocean selection (macOS-like)
local SOUNDS = { "rain", "ocean" }
local LABELS = { ["rain"]="Rain — rainy", ["ocean"]="Cloudy Ocean — soft waves" }
local ICONS = { ["rain"]="cloud-rain", ["ocean"]="cloud" }
local DESC = { ["rain"]="Soft rain • clean stereo", ["ocean"]="Cloudy waves • airy echo" }
local active=false; local sound="rain"; local volume=0.32; local mixes={}
local function isMixed(n) for _,v in ipairs(mixes) do if v==n then return true end end return false end
local function render()
  local rows={}
  table.insert(rows, ui.row({ align="center", justify="space_between" }, {
    ui.column({ gap=2 }, {
      ui.label({ text=noctalia.tr("panel.title"), fontSize=17, fontWeight="bold", color="primary" }),
      ui.label({ text=noctalia.tr("panel.subtitle"), fontSize=11, color="on_surface/0.65" }),
    }),
    ui.button({ glyph="x", variant="ghost", onClick="onClose" })
  }))
  table.insert(rows, ui.separator({ spacing=10 }))
  -- Master toggle
  table.insert(rows, ui.row({ align="center", justify="space_between", fill=active and "primary/0.10" or "surface_variant/0.5", radius=0, padding=12 }, {
    ui.column({ gap=2, flexGrow=1 }, {
      ui.label({ text="Background Sounds", fontWeight="bold", fontSize=13 }),
      ui.label({ text= active and ("Playing: " .. (LABELS[sound] or sound)) or "Off — pick Rain or Cloudy Ocean", fontSize=11, color="on_surface/0.7" }),
    }),
    ui.toggle({ checked=active, onChange="onMasterToggle" }),
  }))
  table.insert(rows, ui.label({ text=noctalia.tr("panel.section.macos"), fontSize=11, fontWeight="bold", color="primary" }))
  -- Dropdown (only 2)
  local opts={LABELS["rain"], LABELS["ocean"]}
  table.insert(rows, ui.row({ gap=8, align="center" }, {
    ui.label({ text="Sound", fontSize=12, minWidth=46 }),
    ui.select({ options=opts, selectedIndex= sound=="ocean" and 1 or 0, onChange="onSelect", flexGrow=1 }),
    ui.button({ text= active and "⏸" or "▶", variant= active and "secondary" or "primary", controlSize="sm", onClick="onToggleMaster" }),
  }))
  table.insert(rows, ui.row({ gap=8, align="center" }, {
    ui.label({ text=noctalia.tr("panel.volume"), fontSize=12, minWidth=46 }),
    ui.glyph({ name="volume", size=14, color="on_surface/0.7" }),
    ui.slider({ min=0, max=1, step=0.05, value=volume, onChange="onVolume", onDragEnd="onVolumeEnd", flexGrow=1 }),
    ui.label({ text=tostring(math.floor(volume*100+0.5)).."%", fontSize=12, minWidth=36 }),
  }))
  -- Two big selectable rows
  for _, name in ipairs(SOUNDS) do
    local sel=sound==name; local playing=sel and active; local mixed=isMixed(name)
    table.insert(rows, ui.row({ gap=12, align="center", fill= sel and (playing and "primary/0.14" or "primary/0.07") or "surface_variant/0.0", radius=0, padding=10, border=sel, borderWidth=sel and 1 or 0, onClick=function() onPick(name) end }, {
      ui.glyph({ name=ICONS[name], size=22, color= sel and "primary" or "on_surface/0.7" }),
      ui.column({ flexGrow=1, gap=2 }, {
        ui.label({ text=LABELS[name], fontWeight= sel and "bold" or "regular", color= sel and "primary" or "on_surface" }),
        ui.label({ text=DESC[name], fontSize=10, color="on_surface/0.6" }),
      }),
      ui.glyph({ name= playing and "player-play-filled" or (sel and "circle-dot" or "circle"), size=16, color= playing and "primary" or "on_surface/0.5" }),
    }))
  end
  -- Mix hint
  table.insert(rows, ui.separator({ spacing=8 }))
  table.insert(rows, ui.label({ text=noctalia.tr("panel.hint"), fontSize=10, color="on_surface/0.45" }))
  panel.render(ui.column({ gap=8, padding=16 }, rows))
end
function onOpen()
  active = noctalia.state.get("ambient:active")==true
  local s=noctalia.state.get("ambient:sound"); if type(s)=="string" then sound=s end
  local v=noctalia.state.get("ambient:volume"); if type(v)=="number" then volume=v end
  local m=noctalia.state.get("ambient:mixes"); if type(m)=="table" then mixes=m end
  render()
end
noctalia.state.watch("ambient:active", function(v) active=v==true; render() end)
noctalia.state.watch("ambient:sound", function(v) if type(v)=="string" then sound=v end; render() end)
noctalia.state.watch("ambient:volume", function(v) if type(v)=="number" then volume=v end; render() end)
noctalia.state.watch("ambient:mixes", function(v) if type(v)=="table" then mixes=v end; render() end)
function onMasterToggle(v) local want=v=="true"; if want~=active then noctalia.runAsync("noctalia msg plugin hadi/ambient:service all toggle " .. sound) end end
function onToggleMaster() noctalia.runAsync("noctalia msg plugin hadi/ambient:service all toggle " .. sound) end
function onVolume(val) volume=tonumber(val) or volume; render() end
function onVolumeEnd(val) local v=tonumber(val); if v then noctalia.runAsync("noctalia msg plugin hadi/ambient:service all volume " .. tostring(v)) end end
function onSelect(idxStr) local idx=tonumber(idxStr) or 0; local name= idx==1 and "ocean" or "rain"; sound=name; noctalia.runAsync("noctalia msg plugin hadi/ambient:service all set-sound " .. name); render() end
function onPick(name) sound=name; noctalia.runAsync("noctalia msg plugin hadi/ambient:service all set-sound " .. name); render() end
function onClose() panel.close() end
