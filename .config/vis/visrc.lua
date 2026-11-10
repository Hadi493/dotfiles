-- ~/.config/vis/visrc.lua
--
-- Emacs-flavoured configuration for vis.
--
-- The editor starts in INSERT mode.  Emacs style editing keys, C-x/C-c
-- prefixes and M-x work while inserting; <Escape> still drops into vis'
-- normal mode as a vi fallback.

local home = os.getenv("HOME") or ""

-- Prefer user-installed lexers (e.g. the vis-lexers package extracted to
-- ~/.local/share/vis).  Harmless when they are installed system-wide.
package.path = package.path .. ";" .. home .. "/.local/share/vis/?.lua"

require("vis")

local modes = vis.modes

-- ---------------------------------------------------------------------------
-- Debug helper (only active when VIS_DEBUG is set)
-- ---------------------------------------------------------------------------

local debug_file
local function debug(...)
    if not os.getenv("VIS_DEBUG") then return end
    if not debug_file then
        debug_file = io.open("/tmp/vis-debug.log", "a")
        if not debug_file then return end
    end
    local parts = {}
    for i = 1, select("#", ...) do
        parts[#parts + 1] = tostring(select(i, ...))
    end
    debug_file:write(table.concat(parts, " "), "\n")
    debug_file:flush()
end

-- ---------------------------------------------------------------------------
-- Small helpers
-- ---------------------------------------------------------------------------

local function file_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

local function shell_quote(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Byte offset of the first character of the line containing `pos`.
local function line_start(file, pos)
    local lineno = file:line_column_from_offset(pos)
    return file:offset_from_line_column(lineno, 1)
end

-- Byte offset of the newline which terminates the line containing `pos`
-- (or file.size for the last line).
local function line_finish(file, pos)
    local lineno = file:line_column_from_offset(pos)
    local next_start = file:offset_from_line_column(lineno + 1, 1)
    if next_start then
        return next_start - 1
    end
    return file.size
end

local function line_bounds(file, pos)
    local lineno = file:line_column_from_offset(pos)
    local start = file:offset_from_line_column(lineno, 1)
    return start, line_finish(file, pos), lineno
end

local function char_length_at(file, pos)
    local data = file:content(pos, 1)
    if not data or #data == 0 then return 0 end
    local b = data:byte()
    if b < 0x80 then return 1 end
    if b >= 0xF0 then return 4 end
    if b >= 0xE0 then return 3 end
    if b >= 0xC0 then return 2 end
    return 1
end

-- Insert text at every cursor.  vis:insert() bypasses mappings and already
-- handles multiple selections and the resulting offset adjustments.
local function insert_text_at_cursors(text)
    if not text or text == "" then return end
    vis:insert(text)
end

-- ---------------------------------------------------------------------------
-- Kill ring / mark
-- ---------------------------------------------------------------------------

local kill_ring = ""
local last_kill = { pos = nil, line = false }

local mark = { file = nil, mark = nil }

local function mark_pos()
    if not mark.mark or not mark.file then return nil end
    if mark.file ~= vis.win.file then return nil end
    return mark.file:mark_get(mark.mark)
end

local function set_mark()
    local win = vis.win
    if not win then return end
    mark.file = win.file
    mark.mark = win.file:mark_set(win.selection.pos)
    vis:info("Mark set")
end

local function clear_mark()
    mark.file = nil
    mark.mark = nil
end

local function region_range()
    local mpos = mark_pos()
    if not mpos then return nil end
    local pos = vis.win.selection.pos
    if mpos == pos then return nil end
    if mpos < pos then
        return { start = mpos, finish = pos }
    end
    return { start = pos, finish = mpos }
end

local function set_kill(text, is_line, pos)
    if is_line and last_kill.line and last_kill.pos == pos then
        kill_ring = kill_ring .. text
    else
        kill_ring = text
    end
    last_kill = { pos = pos, line = is_line }
    pcall(function() vis.registers['"'] = { kill_ring } end)
end

local function kill_region()
    local range = region_range()
    if not range then
        vis:info("The mark is not set")
        return
    end
    local file = vis.win.file
    local text = file:content(range.start, range.finish - range.start) or ""
    file:delete(range.start, range.finish - range.start)
    vis.win.selection.pos = range.start
    clear_mark()
    set_kill(text, false, nil)
end

local function copy_region()
    local range = region_range()
    if not range then
        vis:info("The mark is not set")
        return
    end
    local file = vis.win.file
    local text = file:content(range.start, range.finish - range.start) or ""
    set_kill(text, false, nil)
    vis:info(string.format("Copied %d bytes", #text))
end

local function kill_line()
    local win = vis.win
    if not win then return end
    local file, sel = win.file, win.selection
    local pos = sel.pos
    local _, finish = line_bounds(file, pos)
    local text
    if pos < finish then
        text = file:content(pos, finish - pos) or ""
        file:delete(pos, finish - pos)
    elseif finish < file.size then
        text = file:content(finish, 1) or ""
        file:delete(finish, 1)
    else
        text = ""
    end
    set_kill(text, true, pos)
end

local function yank()
    local text = kill_ring
    if text == "" then
        local reg = vis.registers['"']
        if reg and reg[1] then text = reg[1] end
    end
    insert_text_at_cursors(text)
end

local function exchange_point_and_mark()
    local mpos = mark_pos()
    if not mpos then
        vis:info("The mark is not set")
        return
    end
    local sel = vis.win.selection
    local pos = sel.pos
    mark.mark = mark.file:mark_set(pos)
    sel.pos = mpos
end

local function select_all()
    local win = vis.win
    if not win then return end
    local file = win.file
    if file.size == 0 then return end
    win.selection.range = { start = 0, finish = file.size - 1 }
end

local function beginning_of_buffer()
    local win = vis.win
    if not win then return end
    win.selection.pos = 0
end

-- vis' <vis-motion-line-last> only jumps to the first column of the last
-- line; Emacs M-> means end of buffer.
local function end_of_buffer()
    local win = vis.win
    if not win then return end
    win.selection.pos = win.file.size
end

local function escape_pending_prefix()
    -- Whatever C-x/C-c sequence is pending, park vis in normal mode so a
    -- half-typed prefix (including find-file-at-point) can never wedge the
    -- editor the way C-g aborts a key sequence in Emacs.
    pcall(function() vis:feedkeys("<Escape>") end)
    if vis.mode == modes.INSERT then
        pcall(function() vis:feedkeys("<Escape>") end)
    end
    clear_mark()
end

local function keyboard_quit()
    escape_pending_prefix()
end

-- ---------------------------------------------------------------------------
-- Editing commands
-- ---------------------------------------------------------------------------

local function delete_char()
    if region_range() then
        kill_region()
        return
    end
    local win = vis.win
    if not win then return end
    local file, pos = win.file, win.selection.pos
    if pos >= file.size then return end
    local len = char_length_at(file, pos)
    if len > 0 then file:delete(pos, len) end
end

local function open_line()
    local win = vis.win
    if not win then return end
    win.file:insert(win.selection.pos, "\n")
end

local function duplicate_line()
    local win = vis.win
    if not win then return end
    local file, sel = win.file, win.selection
    local start, finish = line_bounds(file, sel.pos)
    local text = file:content(start, finish - start) or ""
    local col = sel.pos - start
    file:insert(finish, "\n" .. text)
    sel.pos = finish + 1 + col
end

local function move_line(direction)
    local win = vis.win
    if not win then return end
    local file, sel = win.file, win.selection
    local start, finish, lineno = line_bounds(file, sel.pos)
    local text = file:content(start, finish - start) or ""
    local col = sel.pos - start

    if direction < 0 then
        if lineno <= 1 then return end
        local prev_start = file:offset_from_line_column(lineno - 1, 1)
        local _, prev_finish = line_bounds(file, prev_start)
        local prev_text = file:content(prev_start, prev_finish - prev_start) or ""
        file:delete(prev_start, finish - prev_start)
        file:insert(prev_start, text .. "\n" .. prev_text)
        sel.pos = prev_start + col
    else
        if finish >= file.size then return end
        local next_start = finish + 1
        local next_finish = line_finish(file, next_start)
        local next_text = file:content(next_start, next_finish - next_start) or ""
        file:delete(start, next_finish - start)
        file:insert(start, next_text .. "\n" .. text)
        sel.pos = start + #next_text + 1 + col
    end
end

local function transpose_chars()
    local win = vis.win
    if not win then return end
    local file, sel = win.file, win.selection
    local pos = sel.pos
    if pos == 0 or pos >= file.size then return end

    local before_start = pos - 1
    while before_start > 0 do
        local b = file:content(before_start, 1):byte()
        if b and b >= 0x80 and b < 0xC0 then
            before_start = before_start - 1
        else
            break
        end
    end

    local after_end = pos + 1
    while after_end < file.size do
        local b = file:content(after_end, 1):byte()
        if b and b >= 0x80 and b < 0xC0 then
            after_end = after_end + 1
        else
            break
        end
    end

    local before = file:content(before_start, pos - before_start) or ""
    local after = file:content(pos, after_end - pos) or ""
    if before:find("\n") or after:find("\n") then return end

    file:delete(before_start, after_end - before_start)
    file:insert(before_start, after .. before)
    sel.pos = after_end
end

-- Supports both vis return styles: a range table { start =, finish = }
-- (current builds) and bare start/finish numbers (older builds).
local function text_object_range(file, name, pos)
    local r = file[name](file, pos)
    if type(r) == "table" then return r.start, r.finish end
    return r
end

local function word_range_from_point()
    local win = vis.win
    if not win then return nil end
    local file, pos = win.file, win.selection.pos
    local start, finish = text_object_range(file, "text_object_word", pos)
    if not start then
        local data = file:content(pos, file.size - pos)
        if not data then return nil end
        local rel = data:find("[%w_]")
        if not rel then return nil end
        start, finish = text_object_range(file, "text_object_word", pos + rel - 1)
    end
    if not start or start == finish then return nil end
    local s, f = start, finish
    return { start = s, finish = f }
end

local function transform_word(fn)
    local range = word_range_from_point()
    if not range then return end
    local file = vis.win.file
    local text = file:content(range.start, range.finish - range.start) or ""
    local new = fn(text)
    if new ~= text then
        file:delete(range.start, range.finish - range.start)
        file:insert(range.start, new)
    end
end

local function upcase_word() transform_word(string.upper) end
local function downcase_word() transform_word(string.lower) end

local function capitalize_word()
    transform_word(function(s)
        return (s:gsub("^%l", string.upper))
    end)
end

local function kill_word()
    local range = word_range_from_point()
    if not range then return end
    local file = vis.win.file
    local text = file:content(range.start, range.finish - range.start) or ""
    file:delete(range.start, range.finish - range.start)
    vis.win.selection.pos = range.start
    set_kill(text, false, nil)
end

local function kill_word_backward()
    local win = vis.win
    if not win then return end
    local file, sel = win.file, win.selection
    local pos = sel.pos
    if pos == 0 then return end
    local start, finish = text_object_range(file, "text_object_word", pos - 1)
    if not start then return end
    if finish > pos then finish = pos end
    local text = file:content(start, finish - start) or ""
    file:delete(start, finish - start)
    sel.pos = start
    set_kill(text, false, nil)
end

local function transpose_words()
    local win = vis.win
    if not win then return end
    local file, sel = win.file, win.selection
    local pos = sel.pos

    local s1, e1 = text_object_range(file, "text_object_word", pos > 0 and pos - 1 or 0)
    if not s1 then return end
    if not e1 then return end

    local data = file:content(e1, file.size - e1)
    if not data then return end
    local rel = data:find("[%w_]")
    if not rel then return end

    local s2, e2 = text_object_range(file, "text_object_word", e1 + rel - 1)
    if not s2 then return end
    if not e2 then return end

    local w1 = file:content(s1, e1 - s1) or ""
    local w2 = file:content(s2, e2 - s2) or ""
    local middle = file:content(e1, s2 - e1) or ""

    file:delete(s1, e2 - s1)
    file:insert(s1, w2 .. middle .. w1)
    sel.pos = s1 + #w2 + #middle + #w1
end

-- ---------------------------------------------------------------------------
-- Search / replace helpers
-- ---------------------------------------------------------------------------

local function find_file_at_point()
    local win = vis.win
    if not win then return end
    local file, pos = win.file, win.selection.pos
    local start, finish = text_object_range(file, "text_object_word", pos)
    if not start then
        start, finish = line_bounds(file, pos)
    end
    local text = file:content(start, finish - start) or ""
    text = text:gsub("^[%s\"'`%(%)%[%]{}<>,;:]+", "")
    text = text:gsub("[%s\"'`%(%)%[%]{}<>,;:%.]+$", "")
    if text == "" then
        vis:info("No file name at point")
        return
    end
    if text:sub(1, 1) == "~" then
        text = home .. text:sub(2)
    end
    if not file_exists(text) then
        vis:info("No such file: " .. text)
        return
    end
    if not vis:command(string.format("open %s", shell_quote(text))) then
        vis:info("Could not open " .. text)
    end
end

local function insert_timestamp()
    insert_text_at_cursors(os.date("(%Y%m%d-%H%M%S)"))
end

local function insert_date()
    local status, out = vis:pipe("", "date")
    if status == 0 and out then
        insert_text_at_cursors((out:gsub("\n$", "")))
    end
end

local function count_words()
    local win = vis.win
    if not win then return end
    local file = win.file
    local text
    local range = region_range()
    if range then
        text = file:content(range.start, range.finish - range.start)
    else
        text = file:content(0, file.size)
    end
    if not text then return end
    local count = 0
    for _ in text:gmatch("%S+") do count = count + 1 end
    vis:info(string.format("%d words", count))
end

local function unfill_paragraph()
    local win = vis.win
    if not win then return end
    local file, sel = win.file, win.selection
    local pos = sel.pos

    local start, finish = line_bounds(file, pos)

    local pstart = start
    while pstart > 0 do
        local prev_end = pstart - 1
        local prev_start = line_start(file, prev_end)
        local prev_text = file:content(prev_start, prev_end - prev_start) or ""
        if prev_text:match("^%s*$") then break end
        pstart = prev_start
    end

    local pend = finish
    while pend < file.size do
        local next_start = pend + 1
        local next_finish = line_finish(file, next_start)
        local next_text = file:content(next_start, next_finish - next_start) or ""
        if next_text:match("^%s*$") then break end
        pend = next_finish
    end

    local para = file:content(pstart, pend - pstart) or ""
    local joined = para:gsub("%s*\n%s*", " ")
    if joined ~= para then
        file:delete(pstart, pend - pstart)
        file:insert(pstart, joined)
        sel.pos = pstart + #joined
    end
end

-- ---------------------------------------------------------------------------
-- Comment toggle
-- ---------------------------------------------------------------------------

-- vis' lexer names (the keys here) differ from major-mode names: plain
-- unextensioned files lex as "file", and .el files lex as "lisp" — Emacs
-- buffers default to elisp, so both get ";".
local comment_strings = {
    c = "//", cpp = "//", objective_c = "//", java = "//", javascript = "//",
    typescript = "//", rust = "//", go = "//", csharp = "//", scala = "//",
    kotlin = "//", dart = "//", swift = "//", php = "//",
    lua = "--", haskell = "--", sql = "--", ada = "--",
    python = "#", bash = "#", sh = "#", zsh = "#", fish = "#", ruby = "#",
    perl = "#", r = "#", yaml = "#", toml = "#", makefile = "#", ini = ";",
    vim = "\"", lisp = ";", scheme = ";", clojure = ";", emacs = ";",
    tex = "%", latex = "%", erlang = "%",
    file = "#",
}

local function comment_string_for(win)
    local name = win.file and win.file.name or ""
    if name:match("^Makefile") or name:match("%.mk$") then return "#" end
    return comment_strings[win.syntax or ""]
end

local function toggle_comment()
    local win = vis.win
    if not win then return end
    local file, sel = win.file, win.selection
    local cs = comment_string_for(win)
    if not cs then
        vis:info("No comment syntax for this filetype")
        return
    end

    -- Process line by line so a range/visual selection is never expanded
    -- past its last line when it ends exactly at a line boundary.
    local lines = {}
    local range = region_range()
    if range and range.finish > range.start then
        local lineno = file:line_column_from_offset(range.start)
        local s = file:offset_from_line_column(lineno, 1)
        while s and s < range.finish and s < file.size do
            lines[#lines + 1] = s
            local next_start = file:offset_from_line_column(lineno + 1, 1)
            if not next_start then break end
            s, lineno = next_start, lineno + 1
        end
    else
        local s = file:offset_from_line_column(file:line_column_from_offset(sel.pos), 1)
        if s then lines[1] = s end
    end
    if #lines == 0 then return end
    local starts = lines

    local escaped = cs:gsub("%p", "%%%0")
    local all_commented = true
    for _, s in ipairs(starts) do
        local _, e = line_bounds(file, s)
        local text = file:content(s, e - s) or ""
        if not text:match("^%s*" .. escaped) then
            all_commented = false
            break
        end
    end

    for i = #starts, 1, -1 do
        local s = starts[i]
        local _, e = line_bounds(file, s)
        local text = file:content(s, e - s) or ""
        local new
        if all_commented then
            new = text:gsub("^(%s*)" .. escaped .. " ?", "%1", 1)
        else
            local indent, rest = text:match("^(%s*)(.*)$")
            new = indent .. cs .. " " .. rest
        end
        if new ~= text then
            file:delete(s, e - s)
            file:insert(s, new)
        end
    end
    sel.pos = starts[1]
end

-- ---------------------------------------------------------------------------
-- Compile / grep / git
-- ---------------------------------------------------------------------------

local last_compile_command

local function detect_compile_command()
    if file_exists("Makefile") or file_exists("makefile") or file_exists("GNUmakefile") then
        return "make"
    end
    if file_exists("build.ninja") then return "ninja" end
    if file_exists("Cargo.toml") then return "cargo build" end
    if file_exists("CMakeCache.txt") then return "cmake --build ." end
    if file_exists("package.json") then return "npm run build" end
    if file_exists("pyproject.toml") or file_exists("setup.py") then return "python -m build" end
    if file_exists("go.mod") then return "go build ./..." end
    return "make"
end

local function show_output(title, text)
    if not vis:command("new") then
        vis:info("Could not create output window")
        return
    end
    local win = vis.win
    if not win then return end
    win:set_syntax("text")
    win.file:insert(0, text)
    win.selection.pos = 0
    vis:info(title)
end

local function run_compile(cmd)
    cmd = cmd or last_compile_command or detect_compile_command()
    last_compile_command = cmd
    local status, out, err = vis:pipe("", cmd)
    local text = (out or "") .. (err or "")
    if text == "" then text = "(no output)\n" end
    show_output(
        string.format("Compile: %s [%s]", cmd, status == 0 and "ok" or ("exit " .. tostring(status))),
        "$ " .. cmd .. "\n\n" .. text
    )
end

local function compile_default()
    run_compile(detect_compile_command())
end

local function recompile()
    run_compile(last_compile_command or detect_compile_command())
end

local function rgrep()
    local win = vis.win
    if not win then return end
    local file, sel = win.file, win.selection
    local term
    local range = region_range()
    if range then
        term = file:content(range.start, range.finish - range.start)
    else
        local s, e = text_object_range(file, "text_object_word", sel.pos)
        if s then term = file:content(s, e - s) end
    end
    if not term or term == "" then
        vis:info("No search term")
        return
    end
    term = trim(term:gsub("%s+", " "))
    local cmd = "rg -n --no-heading --color=never -- " .. shell_quote(term) .. " ."
    local status, out, err = vis:pipe("", cmd)
    local text = (out or "") .. (err or "")
    if text == "" then text = "No matches for: " .. term .. "\n" end
    show_output(
        string.format("rgrep: %s [%s]", term, status == 0 and "ok" or ("exit " .. tostring(status))),
        "$ " .. cmd .. "\n\n" .. text
    )
end

local function git_status()
    local status, out, err = vis:pipe("", "git status")
    show_output("git status", (out or "") .. (err or ""))
end

local function git_log()
    local status, out, err = vis:pipe("", "git log --oneline --decorate -n 50")
    show_output("git log", (out or "") .. (err or ""))
end

-- ---------------------------------------------------------------------------
-- Window / file commands
-- ---------------------------------------------------------------------------

local function close_window()
    local win = vis.win
    if not win then return end
    if not win:close(false) then
        vis:info("Window has unsaved changes (use :q! to discard)")
    end
end

local function delete_other_windows()
    local current = vis.win
    if not current then return end
    local others = {}
    for w in vis:windows() do
        if w ~= current then others[#others + 1] = w end
    end
    for _, w in ipairs(others) do
        if not w:close(false) then
            vis:info("Some windows have unsaved changes")
            break
        end
    end
end

local function quit_vis()
    local win = vis.win
    if not win then return end
    local file = win.file
    if file.modified then
        if file.path then
            if vis:command("w") then
                vis:info("Saved " .. (file.name or file.path))
            else
                return
            end
        else
            vis:info("Buffer is not visiting a file; use :w <file>")
            return
        end
    end
    vis:command("q")
end

-- ---------------------------------------------------------------------------
-- Options / appearance
-- ---------------------------------------------------------------------------

local function apply_window_options(win)
    if not win then return end
    pcall(os.execute, "stty -ixon -isig 2>/dev/null")
    if not win.options then return end

    -- NOTE: fetch win.options for every assignment.  vis caches window
    -- objects by address and win.options/win.selections share one, so a
    -- cached proxy can turn into a selections object after a redraw.
    win.options.tabwidth = 4
    win.options.expandtab = true
    win.options.autoindent = true
    win.options.numbers = true
    win.options.relativenumbers = true
    win.options.showeof = false
    win.options.shownewlines = false
    win.options.showspaces = false
    win.options.showtabs = false
    win.options.cursorline = false
    win.options.statusbar = true

    local syntax = win.syntax or ""
    local name = (win.file and win.file.name) or ""

    if syntax == "makefile" or name:match("^Makefile") or name:match("%.mk$") then
        -- Makefiles need real tabs.
        win.options.expandtab = false
        win.options.autoindent = false
    elseif syntax == "go" then
        -- gofmt uses tabs.
        win.options.expandtab = false
    elseif syntax == "markdown" or syntax == "text" or syntax == "asciidoc" then
        -- Soft-wrap prose at the window width.
        win.options.wrapcolumn = 0
    end
end

-- ---------------------------------------------------------------------------
-- Whitespace cleanup and autosave
-- ---------------------------------------------------------------------------

local cleanup_syntax = {
    c = true, cpp = true, objective_c = true, java = true, csharp = true,
    lua = true, python = true, rust = true, scala = true, haskell = true,
    erlang = true, go = true, nim = true, yaml = true, asm = true,
    emacs = true, lisp = true, scheme = true, clojure = true, markdown = true,
}

local function strip_trailing_whitespace(file)
    if not file or file.size == 0 or file.size > 4 * 1024 * 1024 then return end
    local data = file:content(0, file.size)
    if not data then return end
    local cleaned = data:gsub("[ \t]+\n", "\n"):gsub("[ \t]+$", "")
    if cleaned == data then return end

    local pos = vis.win and vis.win.selection.pos
    file:delete(0, file.size)
    file:insert(0, cleaned)
    if pos and vis.win and vis.win.file == file then
        vis.win.selection.pos = math.min(pos, #cleaned)
    end
end

local autosave_interval = 30
local last_autosave = os.time()

-- ---------------------------------------------------------------------------
-- Status line
-- ---------------------------------------------------------------------------

local mode_short = {
    [modes.NORMAL] = "N",
    [modes.INSERT] = "I",
    [modes.VISUAL] = "V",
    [modes.VISUAL_LINE] = "VL",
    [modes.REPLACE] = "R",
    [modes.OPERATOR_PENDING] = "O",
}

-- ---------------------------------------------------------------------------
-- Events
-- ---------------------------------------------------------------------------

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
    apply_window_options(win)
end)

vis.events.subscribe(vis.events.FILE_SAVE_PRE, function(file)
    local syntax
    for w in vis:windows() do
        if w.file == file then
            syntax = w.syntax
            break
        end
    end
    if syntax and cleanup_syntax[syntax] then
        strip_trailing_whitespace(file)
    end
end)

vis.events.subscribe(vis.events.INPUT, function()
    local now = os.time()
    if now - last_autosave < autosave_interval then return end
    last_autosave = now

    local win = vis.win
    if not win then return end
    if vis.input_queue and vis.input_queue ~= "" then return end

    local file = win.file
    if file and file.modified and file.path and file.size > 0 then
        local name = file.name or file.path
        if vis:command("w") then
            vis:info(string.format("(Auto-saving %s...done)", name))
        end
    end
end)

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, function(win)
    if win ~= vis.win then return end
    local range = region_range()
    if range then
        win:style(vis.ui.style_ids.SELECTION, range.start, range.finish)
    end
end)

vis.events.subscribe(vis.events.WIN_STATUS, function(win)
    if win ~= vis.win then return end
    local file = win.file
    local sel = win.selection
    if not file or not sel then return end

    local name = file.name or file.path or "[No Name]"
    local mode = mode_short[vis.mode] or ""
    local left = string.format(" %s  %s%s", mode, name, file.modified and " [+]" or "")

    local right_parts = {}
    if win.syntax then right_parts[#right_parts + 1] = win.syntax end
    local pos = sel.pos or 0
    local size = file.size
    local pct = size == 0 and 0 or math.floor(pos / size * 100 + 0.5)
    right_parts[#right_parts + 1] = string.format("%d:%d", sel.line, sel.col)
    right_parts[#right_parts + 1] = pct .. "%"
    if #win.selections > 1 then
        right_parts[#right_parts + 1] = string.format("%d/%d", sel.number, #win.selections)
    end

    win:status(left, " " .. table.concat(right_parts, "  ") .. " ")
end)

-- ---------------------------------------------------------------------------
-- Key bindings
-- ---------------------------------------------------------------------------

local failed_maps = {}

local function map(mode, key, rhs, help)
    if not vis:map(mode, key, rhs, help) then
        failed_maps[#failed_maps + 1] = key
    end
end

local function imap(key, rhs, help) map(modes.INSERT, key, rhs, help) end
local function nmap(key, rhs, help) map(modes.NORMAL, key, rhs, help) end
local function vmap(key, rhs, help) map(modes.VISUAL, key, rhs, help) end

local function map_prefixes(mode)
    -- C-x prefix
    map(mode, "<C-x><C-s>", "<vis-prompt-show>w<Enter>", "Save file")
    map(mode, "<C-x><C-c>", quit_vis, "Save and quit")
    map(mode, "<C-x><C-f>", "<vis-prompt-show>open ", "Find file")
    map(mode, "<C-x><C-w>", "<vis-prompt-show>w ", "Write file")
    map(mode, "<C-x>b", "<vis-prompt-show>open ", "Switch buffer")
    map(mode, "<C-x>k", "<vis-prompt-show>q<Enter>", "Kill buffer")
    map(mode, "<C-x>2", "<vis-prompt-show>split<Enter>", "Split window")
    map(mode, "<C-x>3", "<vis-prompt-show>vsplit<Enter>", "Split window vertically")
    map(mode, "<C-x>o", "<vis-window-next>", "Other window")
    map(mode, "<C-x>1", delete_other_windows, "Delete other windows")
    map(mode, "<C-x>0", close_window, "Delete window")
    map(mode, "<C-x>u", "<vis-undo>", "Undo")
    map(mode, "<C-x><C-r>", "<vis-redo>", "Redo")
    map(mode, "<C-x><C-g>", find_file_at_point, "Find file at point")
    map(mode, "<C-x>h", select_all, "Select all")
    map(mode, "<C-x>pd", insert_timestamp, "Insert timestamp")
    map(mode, "<C-x>ps", rgrep, "Search in project")

    -- C-c prefix
    map(mode, "<C-c>c", compile_default, "Compile")
    map(mode, "<C-c>r", recompile, "Recompile")
    map(mode, "<C-c>d", insert_date, "Insert date")
    map(mode, "<C-c><C-w>", count_words, "Count words")
    map(mode, "<C-c>ms", git_status, "Git status")
    map(mode, "<C-c>ml", git_log, "Git log")
    map(mode, "<C-c><M-q>", unfill_paragraph, "Unfill paragraph")
end

vis.events.subscribe(vis.events.START, function()
    -- Emacs-style keys need the tty raw-ish: turn off software flow control
    -- (C-s would freeze the display until C-q, breaking C-s/C-x C-s) and turn
    -- off signal chars (C-c prefixes compile/date/git commands, and with ISIG
    -- on it would be SIGINT instead of reaching vis).  Terminals enable both
    -- by default, so re-apply at every editor redraw in case the tty is reset.
    pcall(os.execute, "stty -ixon -isig 2>/dev/null")

    local theme = "gruber-darker-ayu"
    if package.searchpath and package.searchpath("themes/" .. theme, package.path) then
        if not vis:command("set theme " .. theme) then
            debug("failed to set theme", theme)
        end
    end

    -- Movement
    imap("<C-b>", "<vis-motion-char-prev>", "Backward char")
    imap("<C-f>", "<vis-motion-char-next>", "Forward char")
    imap("<C-p>", "<vis-motion-line-up>", "Previous line")
    imap("<C-n>", "<vis-motion-line-down>", "Next line")
    imap("<C-a>", "<vis-motion-line-begin>", "Beginning of line")
    imap("<C-e>", "<vis-motion-line-end>", "End of line")
    imap("<M-b>", "<vis-motion-word-start-prev>", "Backward word")
    imap("<M-f>", "<vis-motion-word-start-next>", "Forward word")
    imap("<M-<>", beginning_of_buffer, "Beginning of buffer")
    imap("<M->>", end_of_buffer, "End of buffer")
    imap("<M-{>", "<vis-motion-paragraph-prev>", "Backward paragraph")
    imap("<M-}>", "<vis-motion-paragraph-next>", "Forward paragraph")
    imap("<C-v>", "<vis-window-page-down>", "Page down")
    imap("<M-v>", "<vis-window-page-up>", "Page up")
    imap("<C-l>", "<vis-window-redraw-center>", "Recenter")

    -- Editing
    imap("<C-d>", delete_char, "Delete char")
    imap("<C-k>", kill_line, "Kill line")
    imap("<C-y>", yank, "Yank")
    imap("<C-w>", kill_region, "Kill region")
    imap("<M-w>", copy_region, "Copy region")
    -- vis names the NUL byte that terminals send for C-Space/C-@ as
    -- "<C- >"; the other spellings parse but never match a key.
    imap("<C- >", set_mark, "Set mark")
    imap("<C-space>", set_mark, "Set mark")
    imap("<C-@>", set_mark, "Set mark")
    imap("<C-x><C-x>", exchange_point_and_mark, "Exchange point and mark")
    imap("<C-_>", "<vis-undo>", "Undo")
    imap("<C-/>", "<vis-undo>", "Undo")
    imap("<M-_>", "<vis-redo>", "Redo")
    imap("<C-t>", transpose_chars, "Transpose chars")
    imap("<M-t>", transpose_words, "Transpose words")
    imap("<M-u>", upcase_word, "Upcase word")
    imap("<M-l>", downcase_word, "Downcase word")
    imap("<M-c>", capitalize_word, "Capitalize word")
    imap("<M-d>", kill_word, "Kill word")
    imap("<M-Backspace>", kill_word_backward, "Kill word backward")
    imap("<M-DEL>", kill_word_backward, "Kill word backward")
    imap("<C-o>", open_line, "Open line")
    imap("<M-;>", toggle_comment, "Comment dwim")
    imap("<C-,>", duplicate_line, "Duplicate line")
    imap("<M-p>", function() move_line(-1) end, "Move line up")
    imap("<M-n>", function() move_line(1) end, "Move line down")
    imap("<M-Up>", function() move_line(-1) end, "Move line up")
    imap("<M-Down>", function() move_line(1) end, "Move line down")

    -- Search and completion
    imap("<C-s>", "<vis-search-forward>", "Search forward")
    imap("<C-r>", "<vis-search-backward>", "Search backward")
    imap("<M-x>", "<vis-prompt-show>", "Execute command")

    -- Prefixes
    map_prefixes(modes.INSERT)
    map_prefixes(modes.NORMAL)
    map_prefixes(modes.VISUAL)

    -- C-g aborts any pending prefix, in every mode (Emacs keyboard-quit)
    imap("<C-g>", keyboard_quit, "Keyboard quit")
    nmap("<C-g>", keyboard_quit, "Keyboard quit")
    vmap("<C-g>", keyboard_quit, "Keyboard quit")

    -- Multiple cursors (approximations of multiple-cursors.el)
    -- Terminals send C-> as 0x1e and C-< as 0x1c, which vis spells <C-^> and
    -- <C-\>; both spellings are mapped so the X11 names keep working too.
    imap("<C->>", "<vis-selection-new-match-next>", "Mark next like this")
    imap("<C-^>", "<vis-selection-new-match-next>", "Mark next like this")
    imap("<C-<>", "<vis-selection-new-match-next>", "Mark next like this")
    imap("<C-\\>", "<vis-selection-new-match-next>", "Mark next like this")
    imap("<C-c><C-<>", "<vis-selection-new-match-all>", "Mark all like this")
    imap("<C-c><C-\\>", "<vis-selection-new-match-all>", "Mark all like this")
    imap("<C-\\\">", "<vis-selection-new-match-skip>", "Skip to next like this")
    imap("<C-:>", "<vis-selection-prev>", "Skip to previous like this")
    imap("<C-S-c><C-S-c>", "<vis-selection-new-lines-below>", "Edit lines")
    imap("<C-c><C-c>", "<vis-selection-new-lines-below>", "Edit lines")

    -- Normal/visual mode conveniences
    nmap("<M-x>", "<vis-prompt-show>", "Execute command")
    nmap("<C-s>", "<vis-search-forward>", "Search forward")
    vmap("<M-x>", "<vis-prompt-show>", "Execute command")

    if #failed_maps > 0 then
        vis:info("visrc: failed to map " .. table.concat(failed_maps, ", "))
    end

    -- Emacs is modeless: start in insert mode.
    if vis.mode ~= modes.INSERT then
        vis:feedkeys("i")
    end
end)
