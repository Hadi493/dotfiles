local M = {}

function M.open_pdf(path)
  local out = "/tmp/npdf.png"
  os.execute("pdftoppm -png " .. path .. " > " .. out)
  vim.cmd("e " .. out)
  require("image").setup({ backend = "kitty" })
end

return M
