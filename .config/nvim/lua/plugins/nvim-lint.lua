local lint = require('lint')

lint.linters_by_ft = { --some of these need to be installed from package manager
  lua = {'luac'},
  python = {'ruff'},
  sh = {'bash'},
  c = {'cppcheck'},
  rust = {'clippy'},
  css = {'stylelint'},
  html = {'htmlhint'},
}

-- Filter out linters that are not installed to prevent ENOENT errors
local filtered_linters = {}
for ft, linters in pairs(lint.linters_by_ft) do
  local valid_linters = {}
  for _, linter in ipairs(linters) do
    if vim.fn.executable(linter) == 1 then
      table.insert(valid_linters, linter)
    end
  end
  if #valid_linters > 0 then
    filtered_linters[ft] = valid_linters
  end
end
lint.linters_by_ft = filtered_linters

-- Some linters require a file to be saved to disk, others support linting stdin input.
-- For such linters you could also define a more aggressive autocmd,
-- for example on the InsertLeave or TextChanged events.
-- To get the filetype of a buffer you can run := vim.bo.filetype.

-- lints on close, see autocmd
