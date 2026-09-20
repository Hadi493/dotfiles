-- panel.luau — Background sound selection (dynamic catalog)
local sounds = require("./lib/sounds.luau")

local MSG = "noctalia msg plugin hadi/ambient:service all"

local active = false
local sound = "rain"
local volume = 0.32
local mixes = {}
local catalog = {} -- names array
local labels = {} -- name -> pretty label
local addText = ""

local function labelOf(name)
  if labels[name] then return labels[name] end
  return sounds.pretty(name)
end

local function isMixed(n)
  for _, v in ipairs(mixes) do if v == n then return true end end
  return false
end

local function syncFromState()
  local a = noctalia.state.get("ambient:active")
  if a ~= nil then active = a == true end
  local s = noctalia.state.get("ambient:sound")
  if type(s) == "string" then sound = s end
  local v = noctalia.state.get("ambient:volume")
  if type(v) == "number" then volume = v end
  local m = noctalia.state.get("ambient:mixes")
  if type(m) == "table" then mixes = m end
  local c = noctalia.state.get("ambient:sounds")
  if type(c) == "table" then catalog = c end
  local l = noctalia.state.get("ambient:labels")
  if type(l) == "table" then labels = l end
end

local function hero()
  local status = active and noctalia.tr("panel.status.playing") or noctalia.tr("panel.status.stopped")
  return ui.row({
    gap = 12, align = "center",
    fill = active and "primary/0.12" or "surface_variant/0.5",
    radius = 12, padding = 14,
  }, {
    ui.row({
      width = 52, height = 52, align = "center", justify = "center",
      fill = active and "primary/0.18" or "surface_variant/0.7",
      radius = 12,
    }, {
      ui.glyph({ name = sounds.glyph(sound), size = 26, color = active and "primary" or "on_surface/0.7" }),
    }),
    ui.column({ flexGrow = 1, gap = 2 }, {
      ui.label({ text = labelOf(sound), fontSize = 15, fontWeight = "bold", color = active and "primary" or "on_surface" }),
      ui.label({ text = status, fontSize = 11, color = "on_surface/0.6" }),
    }),
    ui.button({
      glyph = active and "player-pause-filled" or "player-play-filled",
      variant = "primary", controlSize = "lg",
      tooltip = status, onClick = "onToggleMaster",
    }),
  })
end

local function volumeRow()
  return ui.row({ gap = 10, align = "center" }, {
    ui.glyph({ name = active and "volume" or "volume-3", size = 16, color = "on_surface/0.6" }),
    ui.slider({ min = 0, max = 1, step = 0.05, value = volume, onChange = "onVolume", onDragEnd = "onVolumeEnd", flexGrow = 1 }),
    ui.label({ text = tostring(math.floor(volume * 100 + 0.5)) .. "%", fontSize = 12, minWidth = 40, textAlign = "end" }),
  })
end

local function sectionHeader()
  return ui.row({ gap = 8, align = "center" }, {
    ui.label({ text = noctalia.tr("panel.section.sounds", { count = #catalog }), fontSize = 12, fontWeight = "bold", color = "primary", flexGrow = 1 }),
    ui.button({ glyph = "refresh", variant = "ghost", controlSize = "sm", tooltip = noctalia.tr("panel.rescan"), onClick = "onRescan" }),
    ui.button({ glyph = "folder", variant = "ghost", controlSize = "sm", tooltip = noctalia.tr("panel.add.open_folder"), onClick = "onOpenFolder" }),
  })
end

local function soundRow(name)
  local sel = sound == name
  local playing = sel and active
  local mixed = isMixed(name)
  local sub = playing and noctalia.tr("panel.row.playing")
    or (mixed and noctalia.tr("panel.row.mixed") or noctalia.tr("panel.loop"))
  local tail = {
    ui.button({ glyph = "trash", variant = "ghost", controlSize = "sm", tooltip = noctalia.tr("panel.remove"),
      onClick = function() onRemove(name) end }),
  }
  if playing or mixed then
    table.insert(tail, 1, ui.glyph({
      name = "circle-dot-filled", size = 10,
      color = playing and "primary" or "primary/0.6",
    }))
  end
  return ui.row({
    key = "snd-" .. name,
    gap = 10, align = "center",
    fill = sel and (playing and "primary/0.14" or "primary/0.08") or "surface_variant/0.0",
    radius = 10, padding = 8,
    border = sel, borderWidth = sel and 1 or 0,
    onClick = function() onPick(name) end,
  }, {
    ui.row({
      width = 40, height = 40, align = "center", justify = "center",
      fill = sel and "primary/0.16" or "surface_variant/0.5",
      radius = 10,
    }, {
      ui.glyph({ name = sounds.glyph(name), size = 20, color = sel and "primary" or "on_surface/0.7" }),
    }),
    ui.column({ flexGrow = 1, gap = 1 }, {
      ui.label({ text = labelOf(name), fontSize = 13, fontWeight = sel and "bold" or "regular", color = sel and "primary" or "on_surface" }),
      ui.label({ text = sub, fontSize = 10, color = playing and "primary/0.8" or "on_surface/0.5" }),
    }),
    ui.row({ gap = 4, align = "center" }, tail),
  })
end

local function render()
  local body
  if #catalog == 0 then
    body = ui.column({ flexGrow = 1, gap = 6, align = "center", justify = "center" }, {
      ui.glyph({ name = "wave-sine", size = 28, color = "on_surface/0.3" }),
      ui.label({ text = noctalia.tr("panel.empty"), fontSize = 12, color = "on_surface/0.6" }),
    })
  else
    local items = {}
    for _, name in ipairs(catalog) do table.insert(items, soundRow(name)) end
    body = ui.scroll({ flexGrow = 1, gap = 6 }, items)
  end

  local parts = {
    ui.row({ align = "center", justify = "space_between" }, {
      ui.column({ gap = 1 }, {
        ui.label({ text = noctalia.tr("panel.title"), fontSize = 17, fontWeight = "bold", color = "primary" }),
        ui.label({ text = noctalia.tr("panel.subtitle"), fontSize = 11, color = "on_surface/0.6" }),
      }),
      ui.button({ glyph = "x", variant = "ghost", onClick = "onClose" }),
    }),
    hero(),
    volumeRow(),
    ui.separator({ spacing = 6 }),
  }
  if #catalog > 0 then table.insert(parts, sectionHeader()) end
  table.insert(parts, body)
  table.insert(parts, ui.separator({ spacing = 6 }))
  table.insert(parts, ui.row({ gap = 8, align = "center" }, {
    ui.input({ key = "add-input", placeholder = noctalia.tr("panel.add.placeholder"), onChange = "onAddChange", onSubmit = "onAddSubmit", flexGrow = 1 }),
    ui.button({ glyph = "plus", variant = "primary", controlSize = "sm", tooltip = noctalia.tr("panel.add.add"), onClick = "onAddClick" }),
  }))
  table.insert(parts, ui.label({ text = noctalia.tr("panel.hint"), fontSize = 10, color = "on_surface/0.4" }))
  panel.render(ui.column({ flexGrow = 1, gap = 10, align = "stretch", padding = 16 }, parts))
end

function onOpen()
  syncFromState()
  render()
  noctalia.runAsync(MSG .. " refresh ''")
end

noctalia.state.watch("ambient:active", function(v) active = v == true; render() end)
noctalia.state.watch("ambient:sound", function(v) if type(v) == "string" then sound = v end; render() end)
noctalia.state.watch("ambient:volume", function(v) if type(v) == "number" then volume = v end; render() end)
noctalia.state.watch("ambient:mixes", function(v) if type(v) == "table" then mixes = v end; render() end)
noctalia.state.watch("ambient:sounds", function(v) if type(v) == "table" then catalog = v end; render() end)
noctalia.state.watch("ambient:labels", function(v) if type(v) == "table" then labels = v end; render() end)

function onToggleMaster() noctalia.runAsync(MSG .. " toggle " .. sounds.shQuote(sound)) end
function onVolume(val) volume = tonumber(val) or volume; render() end
function onVolumeEnd(val)
  local v = tonumber(val)
  if v then noctalia.runAsync(MSG .. " volume " .. tostring(v)) end
end
function onPick(name)
  sound = name
  noctalia.runAsync(MSG .. " play " .. sounds.shQuote(name))
  render()
end
function onRemove(name)
  noctalia.runAsync(MSG .. " remove " .. sounds.shQuote(name))
end
function onAddChange(val) addText = val or "" end
function onAddSubmit(val)
  addText = val or ""
  onAddClick()
end
function onAddClick()
  local v = noctalia.string.trim(addText or "")
  if v == "" then return end
  noctalia.runAsync(MSG .. " add " .. sounds.shQuote(v))
  addText = ""
end
function onOpenFolder() noctalia.runAsync(MSG .. " open-folder ''") end
function onRescan() noctalia.runAsync(MSG .. " rescan ''") end
function onClose() panel.close() end
