Pack.now(function()
  Pack.add({
    {
      src = "https://github.com/sainnhe/gruvbox-material",
      name = "gruvbox-material",
    },
  })

  vim.g.gruvbox_material_background = "soft"
  vim.g.gruvbox_material_foreground = "material"
  vim.g.gruvbox_material_enable_italic = 0
  vim.g.gruvbox_material_transparent_background = 2
  vim.g.gruvbox_material_float_style = "dim"

  vim.cmd("colorscheme gruvbox-material")
end)
