-- Gruber Darker x Ayu Dark theme for vis.
--
-- Ported from the Emacs theme in
-- dotfiles/emacs.conf/.emacs.rc/gruber-darker-ayu-theme.el

local lexers = vis.lexers

-- Palette
local bg      = "#181818"
local bg1     = "#0d0d0d"
local bg2     = "#1c1c2a"
local bg3     = "#2a2a3e"
local bg4     = "#363652"
local gray    = "#6B7B8E"
local gold    = "#FFCC77"
local orange  = "#FF9944"
local func    = "#FFD064"
local green   = "#C5E665"
local blue    = "#6DCFFF"
local purple  = "#E0B8FF"
local red     = "#FF7B85"
local peach   = "#FFA375"
local cyan    = "#4AC8E6"
local teal    = "#A8F0D8"
local var     = "#F5CD98"
local comment = "#95a99f"
local dim     = "#3d4658"
local fg      = "#ffffff"

-- Syntax
lexers.STYLE_DEFAULT          = "fore:" .. fg .. ",back:" .. bg
lexers.STYLE_NOTHING          = ""
lexers.STYLE_WHITESPACE       = ""
lexers.STYLE_IDENTIFIER       = ""
lexers.STYLE_COMMENT          = "fore:" .. comment .. ",italics"
lexers.STYLE_STRING           = "fore:" .. green
lexers.STYLE_NUMBER           = "fore:" .. teal
lexers.STYLE_CONSTANT         = "fore:" .. purple
lexers.STYLE_CONSTANT_BUILTIN = "fore:" .. purple .. ",bold"
lexers.STYLE_KEYWORD          = "fore:" .. orange .. ",bold"
lexers.STYLE_OPERATOR         = "fore:" .. peach
lexers.STYLE_PREPROCESSOR     = "fore:" .. red
lexers.STYLE_FUNCTION         = "fore:" .. func
lexers.STYLE_FUNCTION_BUILTIN = "fore:" .. func .. ",bold"
lexers.STYLE_FUNCTION_METHOD  = "fore:" .. func
lexers.STYLE_DEFINITION       = "fore:" .. func .. ",bold"
lexers.STYLE_CLASS            = "fore:" .. blue .. ",bold"
lexers.STYLE_TYPE             = "fore:" .. blue
lexers.STYLE_VARIABLE         = "fore:" .. var
lexers.STYLE_VARIABLE_BUILTIN = "fore:" .. var .. ",italics"
lexers.STYLE_LABEL            = "fore:" .. gold
lexers.STYLE_REGEX            = "fore:" .. cyan
lexers.STYLE_EMBEDDED         = "fore:" .. peach
lexers.STYLE_TAG              = "fore:" .. red
lexers.STYLE_ATTRIBUTE        = "fore:" .. var
lexers.STYLE_ERROR            = "fore:" .. red .. ",back:" .. bg3 .. ",bold"

-- Markup
lexers.STYLE_HEADING          = "fore:" .. orange .. ",bold"
lexers.STYLE_BOLD             = "bold"
lexers.STYLE_ITALIC           = "italics"
lexers.STYLE_UNDERLINE        = "underlined"
lexers.STYLE_CODE             = "fore:" .. green
lexers.STYLE_LINK             = "fore:" .. blue .. ",underlined"
lexers.STYLE_REFERENCE        = "fore:" .. purple
lexers.STYLE_ANNOTATION       = "fore:" .. comment .. ",italics"
lexers.STYLE_LIST             = ""

-- Interface
lexers.STYLE_LINENUMBER        = "fore:" .. gray
lexers.STYLE_LINENUMBER_CURSOR = "fore:" .. gold
lexers.STYLE_CURSOR            = "back:" .. gold .. ",keep_attribute"
lexers.STYLE_CURSOR_PRIMARY    = "fore:" .. bg .. ",back:" .. gold .. ",bold,keep_attribute"
lexers.STYLE_CURSOR_LINE       = "back:" .. bg2 .. ",keep_attribute"
lexers.STYLE_COLOR_COLUMN      = "back:" .. bg3
lexers.STYLE_SELECTION         = "back:" .. bg4
lexers.STYLE_STATUS            = "fore:" .. comment .. ",back:" .. bg1
lexers.STYLE_STATUS_FOCUSED    = "fore:" .. func .. ",back:" .. bg2 .. ",bold"
lexers.STYLE_SEPARATOR         = "fore:" .. dim
lexers.STYLE_INFO              = "fore:" .. gold .. ",bold"
lexers.STYLE_EOF               = "fore:" .. dim
