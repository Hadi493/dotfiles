-- ==============================
--  LSP + CMP Configuration
-- ==============================

require("nvim-lsp-installer")

-- Safe require
local cmp = require("cmp")
local luasnip = require("luasnip")

-- ==============================
--  nvim-cmp Setup
-- ==============================
cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"]   = cmp.mapping.scroll_docs(-4),
    ["<C-f>"]   = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"]   = cmp.mapping.abort(),
    ["<CR>"]    = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})

-- ==============================
--  Keymaps on LSP Attach
-- ==============================
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(args)
    local bufnr = args.buf

    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K",  vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<space>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<space>gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)
  end,
})

-- ==============================
--  LSP Servers
-- ==============================

-- Lua
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      telemetry = { enable = false },
    },
  },
})
vim.lsp.enable("lua_ls")

-- Python
vim.lsp.config("pyright", {})
vim.lsp.enable("pyright")

-- Rust
vim.lsp.config("rust_analyzer", {})
vim.lsp.enable("rust_analyzer")

-- TypeScript/JavaScript
vim.lsp.config("ts_ls", {})
vim.lsp.enable("ts_ls")

-- Bash
vim.lsp.config("bashls", {})
vim.lsp.enable("bashls")

-- Docker
vim.lsp.config("dockerls", {})
vim.lsp.enable("dockerls")

-- JSON
vim.lsp.config("jsonls", {})
vim.lsp.enable("jsonls")

-- YAML
vim.lsp.config("yamlls", {})
vim.lsp.enable("yamlls")

-- Markdown
vim.lsp.config("marksman", {})
vim.lsp.enable("marksman")

-- XML
vim.lsp.config("lemminx", {})
vim.lsp.enable("lemminx")

-- ==============================
--  Grammar (LTeX)
-- ==============================
vim.lsp.config("ltex", {
  settings = {
    ltex = {
      language = "en-US",
      disabledRules = {
        ["en-US"] = { "MORFOLOGIK_RULE_EN_US" },
      },
    },
  },
})
vim.lsp.enable("ltex")

-- ==============================
--  ✅ NEW: C/C++ (clangd)
-- ==============================
vim.lsp.config("clangd", {
  cmd = { "clangd", "--background-index" },
})
vim.lsp.enable("clangd")

-- ==============================
--  ✅ NEW: Assembly / FASM (asm-lsp)
-- ==============================
vim.lsp.config("asm_lsp", {
  cmd = { "asm-lsp" },
  filetypes = { "asm", "s", "S" },
})
vim.lsp.enable("asm_lsp")

-- ==============================
--  Java
-- ==============================
vim.lsp.config("jdtls", {})
vim.lsp.enable("jdtls")

-- Optional: Toast on LSP attach
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    vim.notify("LSP Attached: " .. client.name)
  end,
})

