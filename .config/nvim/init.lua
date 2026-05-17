vim.opt.shell = "bash"
vim.env.PATH = vim.fn.stdpath('config') .. '/node_modules/.bin:' .. vim.env.PATH

-- Shim for deprecated vim.tbl_flatten
if vim.iter then
  vim.tbl_flatten = function(t)
    return vim.iter(t):flatten():totable()
  end
end

-- Hadi's neovim config
-- keymaps are in lua/config/mappings.lua
-- install a patched font & ensure your terminal supports glyphs
-- enjoy :D

-- auto install vim-plug and plugins, if not found
local data_dir = vim.fn.stdpath('data')
if vim.fn.empty(vim.fn.glob(data_dir .. '/site/autoload/plug.vim')) == 1 then
	vim.cmd('silent !curl -fLo ' .. data_dir .. '/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
	vim.o.runtimepath = vim.o.runtimepath
	vim.cmd('autocmd VimEnter * PlugInstall --sync | source $MYVIMRC')
end

local vim = vim
local Plug = vim.fn['plug#']



vim.api.nvim_create_user_command("Pdf", function(opts)
  require("plugins.pdf").open_pdf(opts.args)
end, { nargs = 1 })

vim.g.start_time = vim.fn.reltime()
-- vim.loader.enable() --  SPEEEEEEEEEEED 
vim.call('plug#begin')

Plug('catppuccin/nvim', { ['as'] = 'catppuccin' }) --colorscheme
Plug('ellisonleao/gruvbox.nvim', { ['as'] = 'gruvbox' }) --colorscheme 2
-- Plug('uZer/pywal16.nvim', { [ 'as' ] = 'pywal16' }) --or, pywal colorscheme
Plug('folke/tokyonight.nvim', { [ 'as' ] = 'tokyonight' })
Plug('rose-pine/neovim', { [ 'as' ] = 'rose-pine' })
Plug('rebelot/kanagawa.nvim')
Plug('Mofiqul/dracula.nvim')
Plug('nvim-lualine/lualine.nvim') --statusline
Plug('nvim-tree/nvim-web-devicons') --pretty icons
Plug('folke/which-key.nvim') --mappings popup
Plug('romgrk/barbar.nvim') --bufferline
Plug('goolord/alpha-nvim') --pretty startup
Plug('nvim-treesitter/nvim-treesitter') --improved syntax
Plug('mfussenegger/nvim-lint') --async linter
Plug('nvim-tree/nvim-tree.lua') --file explorer
Plug('windwp/nvim-autopairs') --autopairs 
Plug('lewis6991/gitsigns.nvim') --git
Plug('numToStr/Comment.nvim') --easier comments
Plug('NvChad/nvim-colorizer.lua') --color highlight
Plug('ibhagwan/fzf-lua') --fuzzy finder and grep
Plug('numToStr/FTerm.nvim') --floating terminal
Plug('ron-rs/ron.vim') --ron syntax highlighting
Plug('MeanderingProgrammer/render-markdown.nvim') --render md inline
Plug('emmanueltouzery/decisive.nvim') --view csv files
Plug('folke/twilight.nvim') --surrounding dim
Plug('neovim/nvim-lspconfig') -- Collection of configurations for built-in LSP client
Plug('hrsh7th/nvim-cmp') -- Autocompletion plugin
Plug('hrsh7th/cmp-nvim-lsp') -- LSP source for nvim-cmp
Plug('hrsh7th/cmp-buffer') -- Buffer source for nvim-cmp
Plug('hrsh7th/cmp-path') -- Path source for nvim-cmp
Plug('hrsh7th/cmp-cmdline') -- Cmdline source for nvim-cmp
Plug('L3MON4D3/LuaSnip') -- Snippet engine
Plug('saadparwaiz1/cmp_luasnip') -- Snippet source for nvim-cmp
Plug('rafamadriz/friendly-snippets') -- A collection of snippets
Plug('rhysd/vim-grammarous') -- Grammar correction
-- Plug('andweeb/presence.nvim') -- discord
-- Plug('mistweaverco/discord.nvim') -- discord.nvim
Plug 'nvim-lua/plenary.nvim'
Plug 'stevearc/dressing.nvim' 
Plug 'nvim-flutter/flutter-tools.nvim'
Plug 'chomosuke/typst-preview.nvim'


-- Plug '3rd/image.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'xuhdev/vim-latex-live-preview'
Plug 'weirongxu/plantuml-previewer.vim'
Plug 'lervag/vimtex'

Plug 'williamboman/nvim-lsp-installer'
Plug 'nvim-mini/mini.nvim'

vim.call('plug#end')
vim.g.grammarous_lang = 'en-US,ar' -- For English (US) and Arabic
vim.g.livepreview_previewer = 'zathura'

-- move config and plugin config to alternate files
require("config.theme")
require("config.mappings")
require("config.options")
require("config.autocmd")
require("plugins.alpha")
require("plugins.barbar")
require("plugins.colorizer")
require("plugins.colorscheme")
require("plugins.comment")
require("plugins.gitsigns")
require("plugins.lualine")
require("plugins.nvim-lint")
require("plugins.render-markdown")
require("plugins.lsp_config")
require("plugins.typst-preview")
require("plugins.autopairs")
require("plugins.fterm")
require("plugins.fzf-lua")
require("plugins.nvim-tree")
require("plugins.treesitter")
require("plugins.twilight")
require("plugins.which-key")
-- require("plugins.presence")
-- require("plugins.discord")
require("plugins.flutter")
-- require("plugins.image")





load_theme()
