-- service.luau — Now Play + Wallpaper: folder browse, mpv bg play, playlist, shuffle/repeat, wallpaper follow
local SUPPORTED = { mp3=true, flac=true, ogg=true, m4a=true, wav=true, opus=true, mp4=true, mkv=true, webm=true, avi=true, mov=true, wma=true, aac=true }
local DATA_FILE = "nowplay.json"

local function pluginDir() return noctalia.pluginDir() or "." end
local function dataDir() local d = noctalia.pluginDataDir(); if d then return d end return pluginDir() end
local function dataPath() return dataDir() .. "/" .. DATA_FILE end
local function expand(p) return noctalia.expandPath(p) end

local state = {
  active=false,
  track="", -- full path
  index=1,
  playlist={},
  volume=0.45,
  shuffle=false,
  repeat_ = false, -- single play by default, no auto-switch every 2-3s
  wallpaper_follow=false,
  folder="~/Videos",
  isPlaying=false
}

local function loadState()
  local raw = noctalia.readFile(dataPath())
  if raw then
    local ok, tbl = pcall(noctalia.json.decode, raw)
    if ok and type(tbl)=="table" then
      for k,v in pairs(tbl) do state[k]=v end
    end
  end
  -- override from settings where applicable
  local cfgFolder = noctalia.getConfig("media_folder")
  if type(cfgFolder)=="string" and cfgFolder~="" then state.folder=cfgFolder end
  local vol = noctalia.getConfig("volume"); if type(vol)=="number" then state.volume=vol end
  local sh = noctalia.getConfig("shuffle"); if type(sh)=="boolean" then state.shuffle=sh end
  local rp = noctalia.getConfig("repeat"); if type(rp)=="boolean" then state.repeat_=rp end
  local wf = noctalia.getConfig("wallpaper_follow"); if type(wf)=="boolean" then state.wallpaper_follow=wf end
end

local function saveState()
  noctalia.writeFile(dataPath(), noctalia.json.encode(state))
  publish()
end

function publish()
  noctalia.state.set("nowplay:active", state.active)
  noctalia.state.set("nowplay:track", state.track)
  noctalia.state.set("nowplay:index", state.index)
  noctalia.state.set("nowplay:playlist", state.playlist)
  noctalia.state.set("nowplay:volume", state.volume)
  noctalia.state.set("nowplay:shuffle", state.shuffle)
  noctalia.state.set("nowplay:repeat", state.repeat_)
  noctalia.state.set("nowplay:folder", state.folder)
  noctalia.state.set("nowplay:isPlaying", state.isPlaying)
end

local function getExt(path)
  local ext = path:match("%.([^%.%/\\]+)$")
  if ext then return string.lower(ext) end
  return ""
end

local function scanFolder(folder)
  local dir = expand(folder)
  local entries = noctalia.listDir(dir)
  if not entries then return {} end
  local out={}
  for _, name in ipairs(entries) do
    local full = dir .. "/" .. name
    local info = noctalia.fileInfo(full)
    if info and not info.isDir then
      local ext = getExt(name)
      if SUPPORTED[ext] then
        table.insert(out, full)
      end
    elseif info and info.isDir then
      -- one level deep: scan subfolders for media (flexibility)
      local sub = noctalia.listDir(full)
      if sub then
        for _, sn in ipairs(sub) do
          local sfull = full .. "/" .. sn
          local sinfo = noctalia.fileInfo(sfull)
          if sinfo and not sinfo.isDir then
            local sext = getExt(sn)
            if SUPPORTED[sext] then table.insert(out, sfull) end
          end
        end
      end
    end
  end
  table.sort(out)
  return out
end

local function baseName(path)
  return path:match("([^/\\]+)$") or path
end

local function dirOf(path)
  return path:match("^(.*)/[^/]+$") or expand(state.folder)
end

local function tryWallpaper(trackPath)
  if not state.wallpaper_follow then return end
  if trackPath=="" then return end
  local dir = dirOf(trackPath)
  local candidates = {
    dir .. "/cover.jpg", dir .. "/cover.png", dir .. "/folder.jpg", dir .. "/folder.png",
    dir .. "/" .. (trackPath:match("([^/]+)%.%w+$") or ""):gsub("%.%w+$","") .. ".jpg",
    dir .. "/" .. (trackPath:match("([^/]+)%.%w+$") or ""):gsub("%.%w+$","") .. ".png",
  }
  for _, c in ipairs(candidates) do
    if noctalia.fileExists(c) then
      noctalia.setWallpaper(c)
      noctalia.log("NowPlay wallpaper: " .. c)
      return
    end
  end
  -- fallback: if folder has any image, pick first
  local entries = noctalia.listDir(dir)
  if entries then
    for _, n in ipairs(entries) do
      local ext=getExt(n)
      if ext=="jpg" or ext=="png" or ext=="jpeg" or ext=="webp" then
        noctalia.setWallpaper(dir .. "/" .. n)
        return
      end
    end
  end
end

local function shellEscape(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function killNowplay()
  noctalia.runAsync("pkill -f '[m]pv.*nowplay-' 2>/dev/null; true")
  state.isPlaying=false
  publish()
end

local function notifyTrack()
  if not noctalia.getConfig("show_notifications") then return end
  if state.track~="" then
    noctalia.notify("Now Playing", baseName(state.track))
  end
end

local function playAt(idx)
  if #state.playlist==0 then
    state.playlist = scanFolder(state.folder)
    publish()
  end
  if #state.playlist==0 then
    noctalia.notifyError("Now Play", "No media in " .. state.folder)
    state.active=false; state.isPlaying=false; publish(); return
  end
  idx = math.clamp(idx, 1, #state.playlist)
  state.index=idx
  state.track=state.playlist[idx]
  state.active=true
  state.isPlaying=true
  saveState()
  notifyTrack()
  tryWallpaper(state.track)
  killNowplay()
  noctalia.runAsync("sleep 0.5", function()
    local v = math.floor(math.clamp(state.volume,0,1)*100+0.5)
    local escPath = shellEscape(state.track)
    local title = "nowplay-" .. tostring(idx)
    local cmd = string.format("mpv --no-video --volume=%d --title=%s %s >/dev/null 2>&1", v, title, escPath)
    noctalia.runAsync(cmd, function(res)
      if state.active and res.exitCode==0 then
        if state.shuffle or state.repeat_ then
          nextTrack()
        else
          state.active=false; state.isPlaying=false; publish(); saveState()
        end
      elseif res.exitCode~=0 and res.exitCode~=143 then
        state.active=false; state.isPlaying=false; publish(); saveState()
      else
        state.isPlaying=false; publish()
      end
    end)
    state.isPlaying=true
    publish()
  end)
end

local function nextTrack()
  if #state.playlist==0 then return end
  local idx
  if state.shuffle then
    idx = math.random(1, #state.playlist)
    -- avoid same
    if #state.playlist>1 and idx==state.index then idx = idx % #state.playlist + 1 end
  else
    idx = state.index + 1
    if idx > #state.playlist then
      if state.repeat_ then idx=1 else state.active=false; killNowplay(); saveState(); return end
    end
  end
  playAt(idx)
end

local function prevTrack()
  if #state.playlist==0 then return end
  local idx = state.index - 1
  if idx < 1 then idx = state.repeat_ and #state.playlist or 1 end
  playAt(idx)
end

loadState()
state.playlist = scanFolder(state.folder)
-- if saved track not in new playlist, reset index
if state.track~="" then
  local found=false
  for i,p in ipairs(state.playlist) do if p==state.track then state.index=i; found=true end end
  if not found and #state.playlist>0 then state.track=state.playlist[1]; state.index=1 end
elseif #state.playlist>0 then
  state.track=state.playlist[1]; state.index=1
end
publish()
if state.active and noctalia.getConfig("auto_play") and state.track~="" then
  -- resume
  noctalia.setUpdateInterval(1000)
  playAt(state.index)
else
  state.active=false; state.isPlaying=false; publish()
end

noctalia.setUpdateInterval(1000)
function update()
  -- No auto-next polling — mpv callback handles it.
  -- Just keep isPlaying in sync via process check without auto-switching
  if state.active and state.track~="" then
    noctalia.processMatches(function(matched)
      state.isPlaying = matched
      publish()
    end, "nowplay-")
  end
end

function onIpc(event, payload)
  payload = payload or ""
  if event=="play" then
    if payload~="" then
      -- payload is index or path
      local idx=tonumber(payload)
      if idx then
        playAt(idx)
      else
        -- try find path
        for i,p in ipairs(state.playlist) do if p==payload or baseName(p)==payload then playAt(i); return end end
        -- fallback: treat as path with proper escaping
        state.track=payload; state.active=true; saveState(); killNowplay()
        local esc = shellEscape(payload)
        noctalia.runAsync(string.format("mpv --no-video --volume=%d --title='nowplay-test' %s >/dev/null 2>&1 &", math.floor(state.volume*100+0.5), esc))
      end
    else
      if state.track~="" then playAt(state.index) else if #state.playlist>0 then playAt(1) end end
    end
  elseif event=="toggle" then
    if state.active and state.isPlaying then
      -- pause via kill? mpv pause not simple, we kill and remember pos not. Use pkill SIGSTOP?
      -- For simplicity, toggle = stop/resume
      state.active=false; killNowplay(); saveState()
    else
      if state.track~="" then playAt(state.index) else if #state.playlist>0 then playAt(1) end end
    end
  elseif event=="stop" then
    state.active=false; killNowplay(); saveState()
  elseif event=="next" then
    nextTrack()
  elseif event=="prev" then
    prevTrack()
  elseif event=="volume" then
    local vol=tonumber(payload)
    if vol then
      state.volume=math.clamp(vol,0,1); saveState(); publish()
      -- do not restart track on volume change — next play will use new volume
      -- try live adjust via pactl if mpv is running (best effort)
      noctalia.runAsync(string.format("pactl set-sink-input-volume $(pactl list sink-inputs 2>/dev/null | grep -B5 'media.name.*nowplay' | grep 'Sink Input #' | head -n1 | cut -d# -f2) %d%% 2>/dev/null; true", math.floor(state.volume*100+0.5)))
    end
  elseif event=="shuffle" then
    state.shuffle = payload=="true" or payload=="1" or payload=="toggle" and not state.shuffle or false
    if payload=="toggle" then state.shuffle=not state.shuffle end
    saveState(); publish()
  elseif event=="repeat" then
    state.repeat_ = payload=="true" or payload=="1"
    if payload=="toggle" then state.repeat_=not state.repeat_ end
    saveState(); publish()
  elseif event=="wallpaper" then
    state.wallpaper_follow = payload=="true" or payload=="1"
    if payload=="toggle" then state.wallpaper_follow=not state.wallpaper_follow end
    saveState(); publish()
    if state.wallpaper_follow and state.track~="" then tryWallpaper(state.track) end
  elseif event=="scan" then
    local folder = payload~="" and payload or state.folder
    state.folder=folder
    state.playlist=scanFolder(folder)
    if #state.playlist>0 then state.track=state.playlist[1]; state.index=1 else state.track=""; state.index=1 end
    saveState(); publish()
    noctalia.notify("Now Play", "Scanned " .. tostring(#state.playlist) .. " tracks in " .. folder)
  elseif event=="refresh" then
    state.playlist=scanFolder(state.folder)
    publish(); saveState()
  end
end

function onConfigChanged()
  local nf = noctalia.getConfig("media_folder")
  if type(nf)=="string" and nf~=state.folder then
    state.folder=nf
    state.playlist=scanFolder(nf)
    if #state.playlist>0 then state.track=state.playlist[1]; state.index=1 else state.track=""; state.index=1 end
    saveState(); publish()
  end
  local vol = noctalia.getConfig("volume"); if type(vol)=="number" then state.volume=vol; publish() end
  local sh = noctalia.getConfig("shuffle"); if type(sh)=="boolean" then state.shuffle=sh; publish() end
  local rp = noctalia.getConfig("repeat"); if type(rp)=="boolean" then state.repeat_=rp; publish() end
  local wf = noctalia.getConfig("wallpaper_follow"); if type(wf)=="boolean" then state.wallpaper_follow=wf; publish() end
end

function onExit(_sig, reason)
  if reason=="shutdown" or reason=="disable" then killNowplay() end
end
