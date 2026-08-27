-- service.luau — Minimal: Rain & Cloudy Ocean only
local SOUNDS = { "rain", "ocean" }
local DATA_FILE = "ambient.json"

local function pluginDir() return noctalia.pluginDir() or "." end
local function dataDir() local d = noctalia.pluginDataDir(); if d then return d end return pluginDir() end
local function dataPath() return dataDir() .. "/" .. DATA_FILE end

local function loadState()
  local raw = noctalia.readFile(dataPath())
  if raw then
    local ok, tbl = pcall(noctalia.json.decode, raw)
    if ok and type(tbl)=="table" then
      -- migrate old sound names to remaining two
      if tbl.sound and tbl.sound ~= "rain" and tbl.sound ~= "ocean" then tbl.sound = "rain" end
      if tbl.mixes then
        local nm={}
        for _,v in ipairs(tbl.mixes) do if v=="rain" or v=="ocean" then table.insert(nm, v) end end
        tbl.mixes = #nm>0 and nm or {"rain"}
      end
      return tbl
    end
  end
  return { active=false, sound=noctalia.getConfig("default_sound") or "rain", volume=noctalia.getConfig("volume") or 0.32, mixes={} }
end

local function saveState(s)
  noctalia.writeFile(dataPath(), noctalia.json.encode(s))
  noctalia.state.set("ambient:active", s.active)
  noctalia.state.set("ambient:sound", s.sound)
  noctalia.state.set("ambient:volume", s.volume)
  noctalia.state.set("ambient:mixes", s.mixes)
end

local state = loadState()
noctalia.state.set("ambient:active", state.active)
noctalia.state.set("ambient:sound", state.sound)
noctalia.state.set("ambient:volume", state.volume)
noctalia.state.set("ambient:mixes", state.mixes)
noctalia.state.set("ambient:sounds", SOUNDS)

local function soundPath(name) return pluginDir() .. "/sounds/" .. name .. ".ogg" end

local function killAll()
  noctalia.runAsync("pkill -f 'mpv.*--title=ambient-' 2>/dev/null; true")
end

local function playOne(name, vol)
  local path = soundPath(name)
  if not noctalia.fileExists(path) then
    noctalia.notifyError("Background Sounds", "Missing: " .. name .. ".ogg")
    return
  end
  local v = math.floor(math.clamp(vol or state.volume, 0, 1) * 100 + 0.5)
  local cmd = string.format("mpv --no-video --loop --volume=%d --title=ambient-%s '%s' >/dev/null 2>&1 &", v, name, path)
  noctalia.runAsync(cmd)
end

local function syncPlayback()
  killAll()
  noctalia.runAsync("sleep 0.35", function()
    if not state.active then return end
    if state.mixes and #state.mixes > 0 and noctalia.getConfig("allow_multiple") then
      for _, n in ipairs(state.mixes) do playOne(n, state.volume) end
    else
      playOne(state.sound, state.volume)
    end
  end)
end

if state.active and noctalia.getConfig("auto_play") then
  syncPlayback()
elseif not noctalia.getConfig("auto_play") and state.active then
  state.active = false
  saveState(state)
end

function onIpc(event, payload)
  if event == "toggle" then
    state.active = not state.active
    if state.active and payload and payload ~= "" then
      for _, s in ipairs(SOUNDS) do if s==payload then state.sound=payload end end
    end
    saveState(state)
    syncPlayback()
    noctalia.notify("Background Sounds", state.active and ("▶ " .. state.sound) or "⏸ Stopped")
  elseif event == "play" then
    state.sound = payload ~= "" and payload or state.sound
    if state.sound ~= "rain" and state.sound ~= "ocean" then state.sound="rain" end
    state.active = true
    if noctalia.getConfig("allow_multiple") then
      state.mixes = state.mixes or {}
      local found=false
      for _,v in ipairs(state.mixes) do if v==state.sound then found=true end end
      if not found then table.insert(state.mixes, state.sound) end
    else
      state.mixes = { state.sound }
    end
    saveState(state)
    syncPlayback()
  elseif event == "set-sound" then
    for _, s in ipairs(SOUNDS) do if s==payload then state.sound=payload end end
    state.mixes = { state.sound }
    saveState(state)
    if state.active then syncPlayback() end
  elseif event == "stop" then
    state.active = false
    saveState(state)
    killAll()
  elseif event == "stop-one" then
    if state.mixes then
      local n={}
      for _,v in ipairs(state.mixes) do if v~=payload then table.insert(n,v) end end
      state.mixes=n
      if #n==0 then state.active=false end
      saveState(state)
      syncPlayback()
    end
  elseif event == "volume" then
    local vol = tonumber(payload)
    if vol then
      state.volume = math.clamp(vol, 0, 1)
      saveState(state)
      if state.active then syncPlayback() end
    end
  elseif event == "cycle" then
    state.sound = state.sound=="rain" and "ocean" or "rain"
    state.active = true
    state.mixes = { state.sound }
    saveState(state)
    syncPlayback()
  end
end

function onConfigChanged()
  local v = noctalia.getConfig("volume")
  if v and v ~= state.volume then
    state.volume = v
    saveState(state)
    if state.active then syncPlayback() end
  end
  local ds = noctalia.getConfig("default_sound")
  if ds and not state.active and (ds=="rain" or ds=="ocean") then
    state.sound = ds
    saveState(state)
  end
end

function onExit(_sig, reason)
  if reason=="shutdown" or reason=="disable" then killAll() end
end
