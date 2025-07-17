return {
  { "tpope/vim-sleuth", lazy = false },
  {
    "smjonas/inc-rename.nvim",
    lazy = true,
    cmd = { "IncRename" },
    opts = {},
    keys = {
      { "<Leader>rn", ":IncRename ", desc = "Rename Symbol" },
    },
  },
  {
    "andrewferrier/wrapping.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    lazy = true,
    ft = {
      "asciidoc",
      "gitcommit",
      "latex",
      "mail",
      "markdown",
      "rst",
      "tex",
      "text",
    },
    opts = {
      auto_set_mode_filetype_allowlist = {
        "asciidoc",
        "gitcommit",
        "latex",
        "mail",
        "markdown",
        "rst",
        "tex",
        "text",
      },
    },
  },
  {
    "OXY2DEV/markview.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    lazy = true,
    ft = { "markdown", "codecompanion" },
    opts = {
      preview = {
        filetypes = { "markdown", "codecompanion" },
        ignore_buftypes = {},
      },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    lazy = false,
    opts = {},
    keys = function()
      local Terminal = require("toggleterm.terminal").Terminal

      local lazygit = Terminal:new({
        cmd = "lazygit",
        hidden = true,
        direction = "float",
        float_opts = {
          border = vim.opt.winborder,
          width = function() return math.floor(vim.o.columns * 0.8) end,
          height = 50,
        },
      })

      local function toggle_lazygit() lazygit:toggle() end

      return {
        { "<Leader>gg", toggle_lazygit, desc = "Toggle LazyGit", noremap = true, silent = true },
      }
    end,
  },
}
