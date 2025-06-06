return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  import = "plugins.snacks",
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    explorer = { enabled = false },
    indent = { enabled = true },
    input = { enabled = true },
    lazygit = { enabled = true },
    git = { enabled = false },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    zen = { enabled = false },
  },
  keys = function()
    local Snacks = require("snacks")
    return {
      -- Other
      { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      {
        "<leader>S",
        function() Snacks.scratch.select() end,
        desc = "Select Scratch Buffer",
      },
      {
        "<leader>n",
        function() Snacks.notifier.show_history() end,
        desc = "Notification History",
      },
      {
        "<leader>bd",
        function() Snacks.bufdelete() end,
        desc = "Delete Buffer",
      },
      {
        "<leader>rN",
        function() Snacks.rename.rename_file() end,
        desc = "Rename File",
      },
      {
        "<leader>gg",
        function() Snacks.lazygit() end,
        desc = "Lazygit",
      },
      {
        "<c-t>",
        function() Snacks.terminal() end,
        desc = "Toggle Terminal",
      },
    }
  end,
  init = function()
    local Snacks = require("snacks")

    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...) Snacks.debug.inspect(...) end
        _G.bt = function() Snacks.debug.backtrace() end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
        Snacks.toggle
          .new({
            id = "transparency_toggle",
            name = "Transparency",
            get = function() return vim.g.theme_transparency end,
            set = function(state) vim.g.theme_transparency = state end,
          })
          :map("<leader>uT")
      end,
    })
  end,
}
