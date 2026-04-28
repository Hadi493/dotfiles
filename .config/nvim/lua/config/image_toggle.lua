local M = {}

local image_enabled = true -- Initial state

function M.toggle_image_preview()
  image_enabled = not image_enabled

  local patterns = {}
  if image_enabled then
    patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" }
  end

  require("image").setup({
    backend = "ueberzug", -- Assuming ueberzug is still the backend
    max_width = 100,
    max_height = 50,
    max_width_window_percentage = 50,
    max_height_window_percentage = 50,
    window_overlap_clear_enabled = true,
    hijack_file_patterns = patterns,
  })

  if not image_enabled then
    require("image").clear() -- Clear existing images when disabling
  end

  print("Image preview " .. (image_enabled and "enabled" or "disabled"))
end

return M