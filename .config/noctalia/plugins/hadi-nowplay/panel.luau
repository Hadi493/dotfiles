-- panel.luau — Now Play + Wallpaper: folder pick, playlist, controls, wallpaper follow
local function baseName(p) return p:match("([^/\\]+)$") or p end

local folder="~/Videos"
local playlist={}
local track=""
local index=1
local active=false
local isPlaying=false
local volume=0.45
local shuffle=false
local repeat_=true
local wallpaper=false

local function render()
  local rows={}
  -- Header
  table.insert(rows, ui.row({ align="center", justify="space_between" }, {
    ui.column({ gap=2 }, {
      ui.label({ text=noctalia.tr("panel.title"), fontSize=17, fontWeight="bold", color="primary" }),
      ui.label({ text=noctalia.tr("panel.subtitle"), fontSize=11, color="on_surface/0.65" }),
    }),
    ui.button({ glyph="x", variant="ghost", onClick="onClose" })
  }))
  table.insert(rows, ui.separator({ spacing=8 }))

  -- Folder row + browse
  table.insert(rows, ui.row({ gap=8, align="center", fill="surface_variant/0.5", radius=0, padding=8 }, {
    ui.column({ flexGrow=1, gap=2 }, {
      ui.label({ text=noctalia.tr("panel.folder"), fontSize=11, fontWeight="bold", color="primary" }),
      ui.label({ text=folder, fontSize=11, color="on_surface/0.7" }),
      ui.label({ text= string.format(noctalia.tr("panel.count"), #playlist), fontSize=10, color="on_surface/0.5" }),
    }),
    ui.button({ glyph="folder", text="Change", variant="outline", controlSize="sm", onClick="onPickFolder" }),
    ui.button({ glyph="refresh", variant="ghost", controlSize="sm", onClick="onRefresh" }),
  }))

  -- Now Playing
  if track~="" then
    table.insert(rows, ui.column({ gap=6, fill= active and "primary/0.10" or "surface_variant/0.3", radius=0, padding=10 }, {
      ui.label({ text=noctalia.tr("panel.nowplaying"), fontSize=11, fontWeight="bold", color="primary" }),
      ui.row({ gap=8, align="center" }, {
        ui.glyph({ name= isPlaying and "player-play" or "player-pause", size=18, color="primary" }),
        ui.label({ text=baseName(track), flexGrow=1, fontWeight="bold", maxLines=2 }),
      }),
      ui.row({ gap=6, align="center" }, {
        ui.button({ glyph="player-skip-back", variant="outline", controlSize="sm", onClick="onPrev" }),
        ui.button({ text= (active and isPlaying) and "⏸ Pause" or "▶ Play", variant="primary", onClick="onToggle" }),
        ui.button({ glyph="player-skip-forward", variant="outline", controlSize="sm", onClick="onNext" }),
        ui.button({ glyph="arrows-shuffle", variant= shuffle and "primary" or "ghost", controlSize="sm", onClick="onShuffle" }),
        ui.button({ glyph="repeat", variant= repeat_ and "primary" or "ghost", controlSize="sm", onClick="onRepeat" }),
      }),
      ui.row({ gap=8, align="center" }, {
        ui.label({ text=noctalia.tr("panel.volume"), fontSize=11, minWidth=46 }),
        ui.glyph({ name="volume", size=14, color="on_surface/0.7" }),
        ui.slider({ min=0, max=1, step=0.05, value=volume, onChange="onVolume", onDragEnd="onVolumeEnd", flexGrow=1 }),
        ui.label({ text=tostring(math.floor(volume*100+0.5)).."%", fontSize=11, minWidth=36 }),
      }),
      ui.row({ gap=8, align="center" }, {
        ui.label({ text=noctalia.tr("panel.wallpaper"), fontSize=11, flexGrow=1 }),
        ui.toggle({ checked=wallpaper, onChange="onWallpaper" }),
      }),
    }))
  else
    table.insert(rows, ui.label({ text=noctalia.tr("panel.empty"), fontSize=11, color="on_surface/0.6" }))
  end

  -- Playlist
  table.insert(rows, ui.row({ align="center", justify="space_between" }, {
    ui.label({ text=noctalia.tr("panel.playlist"), fontSize=12, fontWeight="bold" }),
    ui.label({ text= track~="" and ("#" .. tostring(index) .. "/" .. tostring(#playlist)) or "", fontSize=10, color="on_surface/0.5" }),
  }))
  if #playlist==0 then
    table.insert(rows, ui.label({ text="Empty", fontSize=11, color="on_surface/0.5" }))
  else
    local items={}
    for i, p in ipairs(playlist) do
      local sel = i==index
      local name = baseName(p)
      table.insert(items, ui.row({
        gap=8, align="center", fill= sel and (active and "primary/0.12" or "primary/0.06") or "surface_variant/0.0",
        radius=0, padding=7, border=sel, borderWidth= sel and 1 or 0,
        onClick=function() onPlayIdx(i) end
      }, {
        ui.label({ text=tostring(i), fontSize=10, color= sel and "primary" or "on_surface/0.5", minWidth=18 }),
        ui.glyph({ name= sel and (isPlaying and "player-play-filled" or "circle-dot") or "music", size=14, color= sel and "primary" or "on_surface/0.6" }),
        ui.label({ text=name, flexGrow=1, fontSize=12, maxLines=1 }),
        ui.glyph({ name="player-play", size=12, color= sel and "primary" or "on_surface/0.3" }),
      }))
    end
    -- scrollable list, max height via scroll container
    table.insert(rows, ui.scroll({ fill="surface_variant/0.2", radius=0, padding=4 }, items))
  end

  table.insert(rows, ui.label({ text="Folder = any audio/video • Video plays bg audio • Wallpaper follow sets cover.jpg near track", fontSize=10, color="on_surface/0.45" }))

  panel.render(ui.column({ gap=8, padding=14 }, rows))
end

function onOpen()
  folder = noctalia.state.get("nowplay:folder") or folder
  playlist = noctalia.state.get("nowplay:playlist") or {}
  track = noctalia.state.get("nowplay:track") or ""
  index = noctalia.state.get("nowplay:index") or 1
  active = noctalia.state.get("nowplay:active")==true
  isPlaying = noctalia.state.get("nowplay:isPlaying")==true
  local vol = noctalia.state.get("nowplay:volume"); if type(vol)=="number" then volume=vol end
  shuffle = noctalia.state.get("nowplay:shuffle")==true
  repeat_ = noctalia.state.get("nowplay:repeat")~=false
  wallpaper = noctalia.state.get("nowplay:wallpaper_follow")==true
  -- also pull from getConfig for folder fallback
  local cfgFolder = noctalia.getConfig and noctalia.getConfig("media_folder")
  if type(cfgFolder)=="string" and cfgFolder~="" then folder=cfgFolder end
  render()
end

-- watches
noctalia.state.watch("nowplay:folder", function(v) if type(v)=="string" then folder=v end; render() end)
noctalia.state.watch("nowplay:playlist", function(v) if type(v)=="table" then playlist=v end; render() end)
noctalia.state.watch("nowplay:track", function(v) if type(v)=="string" then track=v end; render() end)
noctalia.state.watch("nowplay:index", function(v) if type(v)=="number" then index=v end; render() end)
noctalia.state.watch("nowplay:active", function(v) active=v==true; render() end)
noctalia.state.watch("nowplay:isPlaying", function(v) isPlaying=v==true; render() end)
noctalia.state.watch("nowplay:volume", function(v) if type(v)=="number" then volume=v end; render() end)
noctalia.state.watch("nowplay:shuffle", function(v) shuffle=v==true; render() end)
noctalia.state.watch("nowplay:repeat", function(v) repeat_=v==true; render() end)

function onPickFolder() noctalia.openSettings() end
function onRefresh() noctalia.runAsync("noctalia msg plugin hadi/nowplay:service all refresh ''") end
function onToggle() noctalia.runAsync("noctalia msg plugin hadi/nowplay:service all toggle ''") end
function onPrev() noctalia.runAsync("noctalia msg plugin hadi/nowplay:service all prev ''") end
function onNext() noctalia.runAsync("noctalia msg plugin hadi/nowplay:service all next ''") end
function onVolume(val) volume=tonumber(val) or volume; render() end
function onVolumeEnd(val) local v=tonumber(val); if v then noctalia.runAsync("noctalia msg plugin hadi/nowplay:service all volume " .. tostring(v)) end end
function onShuffle(val) if val==nil then val="toggle" end; noctalia.runAsync("noctalia msg plugin hadi/nowplay:service all shuffle " .. val) end
function onRepeat(val) if val==nil then val="toggle" end; noctalia.runAsync("noctalia msg plugin hadi/nowplay:service all repeat " .. val) end
function onWallpaper(val) noctalia.runAsync("noctalia msg plugin hadi/nowplay:service all wallpaper " .. val) end
function onPlayIdx(idx) noctalia.runAsync("noctalia msg plugin hadi/nowplay:service all play " .. tostring(idx)) end
function onClose() panel.close() end
