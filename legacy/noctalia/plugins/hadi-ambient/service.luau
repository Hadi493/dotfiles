-- service.luau — Dynamic background sound loops (mpv)
local sounds = require("./lib/sounds.luau")

local DATA_FILE = "ambient.json"
local CUSTOM_DIR = "custom"

local function pluginDir() return noctalia.pluginDir() or "." end
local function dataDir()
  local d = noctalia.pluginDataDir()
  if d then return d end
  return pluginDir()
end
local function customDir() return dataDir() .. "/" .. CUSTOM_DIR end
local function dataPath() return dataDir() .. "/" .. DATA_FILE end

local catalog = {} -- { {name=..., file=..., bundled=bool} }
local state = nil

local function names()
  local out = {}
  for _, e in ipairs(catalog) do table.insert(out, e.name) end
  return out
end

local function publishCatalog()
  local n, labels = {}, {}
  for _, e in ipairs(catalog) do
    table.insert(n, e.name)
    labels[e.name] = sounds.pretty(e.name)
  end
  noctalia.state.set("ambient:sounds", n)
  noctalia.state.set("ambient:labels", labels)
end

local function known(name)
  if not name then return false end
  for _, e in ipairs(catalog) do if e.name == name then return true end end
  return false
end

local function findEntry(name)
  if not name then return nil end
  for _, e in ipairs(catalog) do if e.name == name then return e end end
  local lower = string.lower(name)
  for _, e in ipairs(catalog) do if string.lower(e.name) == lower then return e end end
  return nil
end

local function cycleNext(cur)
  local n = names()
  if #n == 0 then return nil end
  for i, s in ipairs(n) do
    if s == cur then return n[(i % #n) + 1] end
  end
  return n[1]
end

local function killAll()
  noctalia.runAsync("pkill -f 'mpv.*--title=ambient-' 2>/dev/null; true")
end

local function soundPath(name)
  local e = findEntry(name)
  if not e then return nil end
  return e.file
end

local function playOne(name, vol)
  local path = soundPath(name)
  if not path or not noctalia.fileExists(path) then
    noctalia.notifyError("Background Sounds", "Missing file for: " .. (name or "?"))
    return
  end
  local v = math.floor(math.clamp(vol or state.volume, 0, 1) * 100 + 0.5)
  local cmd = string.format("mpv --no-video --loop --volume=%d --title=%s %s >/dev/null 2>&1 &",
    v, sounds.shQuote("ambient-" .. name), sounds.shQuote(path))
  noctalia.runAsync(cmd)
end

local function syncPlayback()
  killAll()
  noctalia.runAsync("sleep 0.35", function()
    if not state.active then return end
    if #catalog == 0 then return end
    if state.mixes and #state.mixes > 0 and noctalia.getConfig("allow_multiple") then
      for _, n in ipairs(state.mixes) do playOne(n, state.volume) end
    else
      playOne(state.sound, state.volume)
    end
  end)
end

local function loadState()
  local fallback = noctalia.getConfig("default_sound") or "rain"
  if not known(fallback) and #catalog > 0 then fallback = catalog[1].name end
  local raw = noctalia.readFile(dataPath())
  if raw then
    local ok, tbl = pcall(noctalia.json.decode, raw)
    if ok and type(tbl) == "table" then
      if not known(tbl.sound) then tbl.sound = fallback end
      if type(tbl.volume) ~= "number" then tbl.volume = noctalia.getConfig("volume") or 0.32 end
      if tbl.mixes then
        local nm = {}
        for _, v in ipairs(tbl.mixes) do if known(v) then table.insert(nm, v) end end
        tbl.mixes = #nm > 0 and nm or { tbl.sound }
      else
        tbl.mixes = { tbl.sound }
      end
      if tbl.active ~= true then tbl.active = false end
      return tbl
    end
  end
  return { active = false, sound = fallback, volume = noctalia.getConfig("volume") or 0.32, mixes = { fallback } }
end

local function saveState(s)
  s = s or state
  noctalia.writeFile(dataPath(), noctalia.json.encode(s))
  noctalia.state.set("ambient:active", s.active)
  noctalia.state.set("ambient:sound", s.sound)
  noctalia.state.set("ambient:volume", s.volume)
  noctalia.state.set("ambient:mixes", s.mixes)
end

-- Re-scan dirs and publish. Restarts playback only when the current
-- selection vanished. Returns entry count.
local function rescan(quiet)
  noctalia.mkdirAll(customDir())
  catalog = sounds.scan(pluginDir() .. "/sounds", customDir())
  publishCatalog()
  if #catalog == 0 then
    if state and state.active then
      state.active = false
      state.mixes = {}
      saveState()
      killAll()
    end
    if not quiet then noctalia.notify("Background Sounds", "No sounds found — add one below") end
    return 0
  end
  if state then
    local needSync = false
    if not known(state.sound) then
      local ds = noctalia.getConfig("default_sound")
      state.sound = (ds and known(ds)) and ds or catalog[1].name
      needSync = true
    end
    local nm = {}
    if state.mixes then
      for _, v in ipairs(state.mixes) do if known(v) then table.insert(nm, v) end end
    end
    if #nm == 0 then
      nm = { state.sound }
      needSync = true
    elseif #nm ~= #(state.mixes or {}) then
      needSync = true
    end
    state.mixes = nm
    saveState()
    if needSync and state.active then syncPlayback() end
  end
  if not quiet then noctalia.notify("Background Sounds", #catalog .. " sound(s) available") end
  return #catalog
end

local function uniqueDest(base, ext)
  noctalia.mkdirAll(customDir())
  local name, i = base, 1
  while noctalia.fileExists(customDir() .. "/" .. name .. "." .. ext) do
    i = i + 1
    name = base .. "-" .. tostring(i)
  end
  return name, customDir() .. "/" .. name .. "." .. ext
end

local function doAdd(payload)
  local src = noctalia.string.trim(payload or "")
  if src == "" then
    noctalia.notifyError("Background Sounds", "Add needs a file path or URL")
    return
  end
  if string.match(src, "^https?://") then
    local last = string.match(src, "([^/?#]+)(%?[^#]*)?(#.*)?$") or "download"
    local base, ext = sounds.splitFile(last)
    if not ext or not sounds.AUDIO_EXTS[ext] then
      noctalia.notifyError("Background Sounds", "URL must end in .mp3/.ogg/.wav/.flac/.opus/.m4a")
      return
    end
    base = sounds.sanitize(base)
    local name, dest = uniqueDest(base, ext)
    noctalia.notify("Background Sounds", "Downloading " .. name .. " …")
    noctalia.download(src, dest, function(ok)
      if ok then
        rescan(true)
        state.sound = name
        state.mixes = { name }
        saveState()
        noctalia.notify("Background Sounds", "Added " .. name)
      else
        noctalia.notifyError("Background Sounds", "Download failed")
      end
    end)
    return
  end
  local expanded = noctalia.expandPath(src)
  if not noctalia.fileExists(expanded) then
    noctalia.notifyError("Background Sounds", "File not found: " .. src)
    return
  end
  local info = noctalia.fileInfo(expanded)
  if info and info.isDir then
    noctalia.notifyError("Background Sounds", "Not a file: " .. src)
    return
  end
  local fname = string.match(expanded, "([^/]+)$") or expanded
  if not sounds.isAudio(fname) then
    noctalia.notifyError("Background Sounds", "Unsupported type — use .mp3/.ogg/.wav/.flac/.opus/.m4a")
    return
  end
  local base, ext = sounds.splitFile(fname)
  base = sounds.sanitize(base)
  local name, dest = uniqueDest(base, ext)
  noctalia.runAsync("cp -- " .. sounds.shQuote(expanded) .. " " .. sounds.shQuote(dest), function(result)
    if result and result.exitCode == 0 then
      rescan(true)
      state.sound = name
      state.mixes = { name }
      saveState()
      noctalia.notify("Background Sounds", "Added " .. name)
    else
      local err = (result and result.stderr) or "copy failed"
      noctalia.notifyError("Background Sounds", noctalia.string.trim(err))
    end
  end)
end

local function doRemove(payload)
  local target = noctalia.string.trim(payload or "")
  if target == "" then
    noctalia.notifyError("Background Sounds", "Remove needs a sound name")
    return
  end
  local e = findEntry(target)
  if not e then
    noctalia.notifyError("Background Sounds", "Unknown sound: " .. target)
    return
  end
  local ok, err = noctalia.removeFile(e.file)
  if not ok then
    noctalia.notifyError("Background Sounds", err or ("Could not delete " .. e.name))
    return
  end
  local wasCurrent = state.sound == e.name
  rescan(true)
  if wasCurrent then
    if #catalog > 0 then
      state.sound = catalog[1].name
      state.mixes = { state.sound }
    else
      state.active = false
      state.mixes = {}
    end
    saveState()
    syncPlayback()
  end
  local extra = e.bundled and " (bundled — commit dotfiles to keep it deleted)" or ""
  noctalia.notify("Background Sounds", "Removed " .. e.name .. extra)
end

-- boot
noctalia.mkdirAll(customDir())
catalog = sounds.scan(pluginDir() .. "/sounds", customDir())
publishCatalog()

state = loadState()
saveState()

if state.active and noctalia.getConfig("auto_play") then
  syncPlayback()
elseif not noctalia.getConfig("auto_play") and state.active then
  state.active = false
  saveState()
end

function onIpc(event, payload)
  payload = payload or ""
  if event == "toggle" then
    if #catalog == 0 then
      noctalia.notifyError("Background Sounds", "No sounds — add one first")
      return
    end
    state.active = not state.active
    local t = noctalia.string.trim(payload)
    if state.active and t ~= "" and known(t) then state.sound = t end
    if not known(state.sound) then state.sound = catalog[1].name end
    saveState()
    syncPlayback()
    noctalia.notify("Background Sounds", state.active and ("▶ " .. state.sound) or "⏸ Stopped")
  elseif event == "play" then
    if #catalog == 0 then
      noctalia.notifyError("Background Sounds", "No sounds — add one first")
      return
    end
    local t = noctalia.string.trim(payload)
    if t ~= "" and known(t) then state.sound = t end
    if not known(state.sound) then state.sound = catalog[1].name end
    state.active = true
    if noctalia.getConfig("allow_multiple") then
      state.mixes = state.mixes or {}
      local found = false
      for _, v in ipairs(state.mixes) do if v == state.sound then found = true end end
      if not found then table.insert(state.mixes, state.sound) end
    else
      state.mixes = { state.sound }
    end
    saveState()
    syncPlayback()
  elseif event == "set-sound" then
    local t = noctalia.string.trim(payload)
    if known(t) then state.sound = t end
    state.mixes = { state.sound }
    saveState()
    if state.active then syncPlayback() end
  elseif event == "stop" then
    state.active = false
    saveState()
    killAll()
  elseif event == "stop-one" then
    if state.mixes then
      local t = noctalia.string.trim(payload)
      local n = {}
      for _, v in ipairs(state.mixes) do if v ~= t then table.insert(n, v) end end
      state.mixes = n
      if #n == 0 then state.active = false end
      saveState()
      syncPlayback()
    end
  elseif event == "volume" then
    local vol = tonumber(payload)
    if vol then
      state.volume = math.clamp(vol, 0, 1)
      saveState()
      if state.active then syncPlayback() end
    end
  elseif event == "cycle" then
    local nxt = cycleNext(state.sound)
    if not nxt then
      noctalia.notifyError("Background Sounds", "No sounds — add one first")
      return
    end
    state.sound = nxt
    state.active = true
    state.mixes = { state.sound }
    saveState()
    syncPlayback()
  elseif event == "rescan" then
    rescan(false)
  elseif event == "refresh" then
    rescan(true)
  elseif event == "list" then
    local n = names()
    if #n == 0 then
      noctalia.notify("Background Sounds", "No sounds — add one first")
    else
      noctalia.notify("Background Sounds", table.concat(n, ", "))
    end
  elseif event == "add" then
    doAdd(payload)
  elseif event == "remove" then
    doRemove(payload)
  elseif event == "open-folder" then
    noctalia.mkdirAll(customDir())
    noctalia.runAsync("xdg-open " .. sounds.shQuote(pluginDir() .. "/sounds") .. " >/dev/null 2>&1 &")
    noctalia.runAsync("xdg-open " .. sounds.shQuote(customDir()) .. " >/dev/null 2>&1 &")
    noctalia.notify("Background Sounds", "Custom sounds live in " .. customDir())
  end
end

function onConfigChanged()
  local v = noctalia.getConfig("volume")
  if v and v ~= state.volume then
    state.volume = v
    saveState()
    if state.active then syncPlayback() end
  end
  local ds = noctalia.getConfig("default_sound")
  if ds and not state.active and known(ds) then
    state.sound = ds
    saveState()
  end
end

function onExit(_sig, reason)
  if reason == "shutdown" or reason == "disable" then killAll() end
end
