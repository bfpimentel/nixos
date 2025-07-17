local is_initialized = false

local function init_themes()
  if is_initialized then return end

  vim.g.everforest_enable_italic = true
  vim.g.everforest_better_performance = true

  vim.cmd([[ colorscheme everforest ]])

  is_initialized = true
end

return {
  {
    "sainnhe/everforest",
    name = "everforest",
    lazy = false,
    priority = 10000,
    init = init_themes,
  },
  {
    "adibhanna/forest-night.nvim",
    name = "forest-night",
    lazy = false,
    priority = 10000,
    init = init_themes,
  },
}
