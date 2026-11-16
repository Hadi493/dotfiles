-- lib/sounds.luau — shared helpers (pure; no side effects at require time)
local M = {}

M.AUDIO_EXTS = {
  ogg = true, oga = true, mp3 = true, wav = true,
  flac = true, opus = true, m4a = true,
}

local EXACT_GLYPHS = {
  ["rain"] = "cloud-rain",
  ["gentle-rain"] = "cloud",
  ["calming-rain"] = "droplet",
}

local KEYWORD_GLYPHS = {
  { "thunder", "cloud-lightning" },
  { "storm", "cloud-lightning" },
  { "ocean", "waves" },
  { "sea", "waves" },
  { "wave", "waves" },
  { "stream", "droplet" },
  { "river", "droplet" },
  { "water", "droplet" },
  { "rain", "cloud-rain" },
  { "forest", "leaf" },
  { "bird", "leaf" },
  { "fire", "flame" },
  { "fireplace", "flame" },
  { "crackle", "flame" },
  { "wind", "wind" },
  { "night", "moon" },
  { "cricket", "moon" },
  { "cafe", "coffee" },
  { "coffee", "coffee" },
  { "city", "building" },
  { "train", "train" },
  { "noise", "wave-sine" },
}

function M.pretty(name)
  local s = string.gsub(name or "", "[-_]+", " ")
  s = string.gsub(s, "(%a)([%w]*)", function(a, b)
    return string.upper(a) .. b
  end)
  if s == "" then return "Unnamed" end
  return s
end

function M.glyph(name)
  if not name or name == "" then return "wave-sine" end
  local lower = string.lower(name)
  if EXACT_GLYPHS[lower] then return EXACT_GLYPHS[lower] end
  for _, pair in ipairs(KEYWORD_GLYPHS) do
    if string.find(lower, pair[1], 1, true) then return pair[2] end
  end
  return "wave-sine"
end

function M.sanitize(name)
  local s = string.lower(noctalia.string.trim(name or ""))
  s = string.gsub(s, "%s+", "-")
  s = string.gsub(s, "[^a-z0-9-_]", "")
  if s == "" then s = "custom" end
  return s
end

function M.splitFile(filename)
  local base, ext = string.match(filename, "^(.*)%.([A-Za-z0-9]+)$")
  if base and base ~= "" then return base, string.lower(ext) end
  return filename, nil
end

function M.isAudio(filename)
  local _, ext = M.splitFile(filename)
  return ext ~= nil and M.AUDIO_EXTS[ext] == true
end

-- Scan bundled + custom dirs. Returns sorted array of {name, file, bundled}.
function M.scan(bundledDir, customDir)
  local out, seen = {}, {}
  local function scanDir(dir, bundled)
    if not dir or dir == "" then return end
    local entries = noctalia.listDir(dir)
    if not entries then return end
    for _, f in ipairs(entries) do
      if M.isAudio(f) then
        local base, _ = M.splitFile(f)
        local key = string.lower(base)
        if base ~= "" and not seen[key] then
          seen[key] = true
          table.insert(out, { name = base, file = dir .. "/" .. f, bundled = bundled })
        end
      end
    end
  end
  scanDir(bundledDir, true)
  scanDir(customDir, false)
  table.sort(out, function(a, b) return string.lower(a.name) < string.lower(b.name) end)
  return out
end

function M.shQuote(s)
  return "'" .. string.gsub(s or "", "'", "'\\''") .. "'"
end

return M
