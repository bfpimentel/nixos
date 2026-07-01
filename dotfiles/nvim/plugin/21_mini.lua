local function setup_mini_icons()
  local MiniIcons = require("mini.icons")
  MiniIcons.setup()
end

local function setup_mini_pick()
  local MiniPick = require("mini.pick")
  MiniPick.setup({
    options = {
      use_cache = true,
    },
    mappings = {
      choose_marked = "<C-q>",
    },
    source = {
      choose_marked = function(items) MiniPick.default_choose_marked(items, { list_type = "location" }) end,
    },
  })

  vim.ui.select = MiniPick.ui_select
end

local function setup_mini_files()
  local MiniFiles = require("mini.files")
  MiniFiles.setup({
    mappings = {
      mark_set = "<localleader>m",
    },
    windows = {
      max_number = 3,
      preview = false,
      width_focus = 40,
      width_nofocus = 20,
      width_preview = 50,
    },
  })
end

local function setup_mini_indentscope()
  local MiniIndentScope = require("mini.indentscope")
  MiniIndentScope.setup({
    symbol = "│",
  })
end

local function setup_mini_jump2d()
  local MiniJump2D = require("mini.jump2d")
  MiniJump2D.setup({
    view = {
      dim = true,
    },
    allowed_windows = {
      current = true,
      not_current = false,
    },
  })
end

local function setup_mini_completion()
  local MiniCompletion = require("mini.completion")

  ---@diagnostic disable-next-line: duplicate-set-field
  _G.cr_action = function()
    if vim.fn.complete_info()["selected"] ~= -1 then return "\25" end
    return "\r"
  end

  vim.keymap.set("i", "<CR>", "v:lua.cr_action()", { expr = true })

  MiniCompletion.setup({
    delay = { completion = 100, info = 100, signature = 50 },
    source = {
      nvim_lsp = true,
      buffer = true,
      path = true,
      luasnip = true,
    },
  })

  require("mini.icons").tweak_lsp_kind()
end

local function setup_mini_cmdline()
  local MiniCmdline = require("mini.cmdline")
  MiniCmdline.setup()
end

local function setup_mini_input()
  local MiniInput = require("mini.input")

  local input_view = MiniInput.gen_view.floatwin({
    style = "BM",
    adjust_config = function(state, config)
      local input = state.input or ""
      local prompt = state.prompt or ""
      local input_width = vim.fn.strdisplaywidth(prompt .. input) + 10
      local min_width = math.floor(vim.o.columns * 0.5)
      local max_width = math.floor(vim.o.columns * 0.9)

      config.width = math.min(max_width, math.max(min_width, input_width))
      config.col = math.floor((vim.o.columns - config.width) * 0.5)

      return config
    end,
  })

  MiniInput.setup({
    handlers = {
      complete = MiniInput.default_complete,
      view = input_view,
    },
  })
end

local function setup_mini_hipatterns()
  local MiniHipatterns = require("mini.hipatterns")

  local zero_x_colors = function(_, match)
    local len = string.len(match)
    if len == 8 or len == 10 then
      local start = len == 8 and 3 or 5
      local eend = len == 8 and 8 or 10
      local hex = string.format("#%s", match:sub(start, eend))
      return MiniHipatterns.compute_hex_color_group(hex, "bg")
    end

    return false
  end

  local hex_colors = function(_, match)
    local len = string.len(match)
    if len == 7 then
      local hex = string.format("#%s", match:sub(2, 7)) -- #FFFFFF
      return MiniHipatterns.compute_hex_color_group(hex, "bg")
    elseif len == 9 then
      local hex = string.format("#%s", match:sub(4, 9)) -- #00FFFFFF
      return MiniHipatterns.compute_hex_color_group(hex, "bg")
    end

    return false
  end

  MiniHipatterns.setup({
    highlighters = {
      fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
      hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
      todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
      note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
      zero_x_colors = {
        pattern = "0x%x+",
        group = zero_x_colors,
      },
      hex_colors = {
        pattern = "#%x+",
        group = hex_colors,
      },
    },
  })
end

local function setup_mini_clue()
  local MiniClue = require("mini.clue")
  MiniClue.setup({
    clues = {
      MiniClue.gen_clues.g(),
      MiniClue.gen_clues.windows(),
    },
    triggers = {
      -- Leader triggers
      { mode = "n", keys = "<leader>" },
      { mode = "x", keys = "<leader>" },

      -- Key triggers
      { mode = "n", keys = "<leader>g" },
      { mode = "x", keys = "<leader>g" },
      { mode = "n", keys = "<leader>s" },
      { mode = "x", keys = "<leader>s" },

      -- Window commands
      { mode = "n", keys = "<C-w>" },
    },
  })
end

local function setup_mini_statusline()
  local MiniStatusline = require("mini.statusline")

  local check_macro_recording = function()
    if vim.fn.reg_recording() ~= "" then
      return "REC @" .. vim.fn.reg_recording()
    else
      return ""
    end
  end

  local function mode_hl()
    local CTRL_V = vim.api.nvim_replace_termcodes("<C-V>", true, true, true)

    local modes = setmetatable({
      -- Normal
      ["n"] = "MiniIconsGrey",
      -- Insert
      ["i"] = "MiniIconsBlue",
      -- Visual
      ["v"] = "MiniIconsPurple",
      ["V"] = "MiniIconsPurple",
      [CTRL_V] = "MiniIconsPurple",
    }, {
      __index = function() return "MiniIconsYellow" end,
    })

    return modes[vim.fn.mode()]
  end

  local function groups()
    local mode = MiniStatusline.section_mode({ trunc_width = 30 })
    local git = MiniStatusline.section_git({ trunc_width = 40 })
    local diff = MiniStatusline.section_diff({ trunc_width = 75 })
    local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
    local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
    local filename = vim.fn.expand("%:t")

    return MiniStatusline.combine_groups({
      { hl = mode_hl(), strings = { mode } },
      "%<", -- Mark general truncate point
      { hl = "MiniStatuslineFilename", strings = { filename } },
      { hl = "MiniIconsRed", strings = { check_macro_recording() } },
      "%=", -- End left alignment
      { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, lsp } },
    })
  end

  MiniStatusline.setup({
    content = {
      active = groups,
      inactive = nil,
    },
  })
end

local function setup_mini_diff()
  require("mini.diff").setup({
    view = { style = "sign" },
  })
end

Pack.now(function()
  require("mini.ai").setup()
  require("mini.surround").setup()
  require("mini.visits").setup()

  setup_mini_icons()
  setup_mini_pick()
  setup_mini_files()
  setup_mini_indentscope()
  setup_mini_jump2d()
  setup_mini_completion()
  setup_mini_cmdline()
  setup_mini_input()
  setup_mini_hipatterns()
  setup_mini_clue()
  setup_mini_statusline()
  setup_mini_diff()

  Util.patch_hl_with_transparency("MiniInputCaret")
  Util.patch_hl_with_transparency("MiniPickPrompt")
  Util.patch_hl_with_transparency("MiniPickPromptCaret")
  Util.patch_hl_with_transparency("MiniPickPromptPrefix")
  Util.patch_hl_with_transparency("MiniStatuslineDevinfo")
  Util.patch_hl_with_transparency("MiniStatuslineFilename")

  Util.patch_hl_with_transparency("FloatBorder")
  Util.patch_hl_with_transparency("FloatTitle")
  Util.patch_hl_with_transparency("NormalFloat")
  Util.patch_hl_with_transparency("Pmenu")
  Util.patch_hl_with_transparency("PmenuBorder")

  local MiniPick = require("mini.pick")
  local MiniExtra = require("mini.extra")
  local MiniFiles = require("mini.files")

  local function toggle_files()
    local _ = MiniFiles.close() or MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
    vim.defer_fn(function() MiniFiles.reveal_cwd() end, 30)
  end

  local function filter_visits(path_data)
    local is_directory = vim.fn.isdirectory(path_data.path) == 1
    local is_scratch = path_data.path:match("/scratch") ~= nil
    return not is_directory and not is_scratch
  end

  local function pick_files()
    if vim.fn.executable("rg") ~= 1 then return MiniPick.builtin.files() end

    MiniPick.builtin.cli({
      command = { "rg", "--files", "--hidden", "--glob", "!**/.git/**", "--color=never" },
    }, {
      source = {
        name = "Files (rg)",
        show = function(buf_id, items, query) MiniPick.default_show(buf_id, items, query, { show_icons = true }) end,
      },
    })
  end

  Util.map_keys({
    -- stylua: ignore start
    { "<leader>,",  function() MiniPick.builtin.buffers() end, opts = { desc = "Buffers" } },
    { "<leader>/",  function() MiniPick.builtin.grep_live() end, opts = { desc = "Grep" } },
    -- History
    { "<leader>hc", function() MiniExtra.pickers.history({ scope = ":" }) end, opts = { desc = "Commands History" } },
    { "<leader>hs", function() MiniExtra.pickers.history({ scope = "/" }) end, opts = { desc = "Search History" } },
    -- Files
    { "<leader>fp", function() pick_files() end, opts = { desc = "Files" } },
    { "<leader>fr", function() MiniExtra.pickers.visit_paths({ cwd = nil, recency_weight = 1, filter = filter_visits }) end, opts = { desc = "Recent Files" } },
    -- Search
    { '<leader>s"', function() MiniExtra.pickers.registers() end, opts = { desc = "Registers" } },
    { "<leader>sc", function() MiniExtra.pickers.commands() end, opts = { desc = "Commands" } },
    { "<leader>sd", function() MiniExtra.pickers.diagnostic() end, opts = { desc = "Diagnostics" } },
    { "<leader>sh", function() MiniPick.builtin.help() end, opts = { desc = "Help Pages" } },
    { "<leader>sH", function() MiniExtra.pickers.hl_groups() end, opts = { desc = "Highlight Groups" } },
    { "<leader>sk", function() MiniExtra.pickers.keymaps() end, opts = { desc = "Keymaps" } },
    { "<leader>sm", function() MiniExtra.pickers.marks() end, opts = { desc = "Marks" } },
    { "<leader>sC", function() MiniExtra.pickers.colorschemes() end, opts = { desc = "Colorschemes" } },
    -- LSP
    { "<leader>gD", function() MiniExtra.pickers.lsp({ scope = "declaration" }) end, opts = { desc = "Declarations" } },
    { "<leader>gd", function() MiniExtra.pickers.lsp({ scope = "definition" }) end, opts = { desc = "Definitions" } },
    { "<leader>gr", function() MiniExtra.pickers.lsp({ scope = "references" }) end, opts = { desc = "References" } },
    { "<leader>gI", function() MiniExtra.pickers.lsp({ scope = "implementation" }) end, opts = { desc = "Implementation" } },
    { "<leader>gy", function() MiniExtra.pickers.lsp({ scope = "type_definition" }) end, opts = { desc = "Type Definition" } },
    { "<leader>gs", function() MiniExtra.pickers.lsp({ scope = "document_symbol" }) end, opts = { desc = "Symbols" } },
    { "<leader>gS", function() MiniExtra.pickers.lsp({ scope = "workspace_symbol" }) end, opts = { desc = "Workspace Symbols" } },
    -- Explorer
    { "<leader>e",  function() toggle_files() end, opts = { desc = "File Explorer" } },
    -- stylua: ignore end
  })
end)
