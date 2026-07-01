-- General keymaps
Util.map_keys({
  -- stylua: ignore start
  { "<S-u>", "<C-r><CR>" },
  { "<Esc>", "<CMD>nohlsearch<CR><CR>" },
  { "p",     "P", mode = "x" },

  { "<leader>rr", "<CMD>restart<CR>" },
  { "<leader>gg", "<CMD>terminal lazygit<CR>", opts = { desc = "Open Lazygit" } },

  { "<leader>pu", function() vim.pack.update() end, opts = { desc = "Open vim.pack updates buffer" } },
  -- stylua: ignore end
})

-- Window and multiplexer navigation
local function navigate(wincmd, direction)
  local previous_window = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. wincmd)
  if vim.api.nvim_get_current_win() ~= previous_window then return end

  if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
    local herdr = vim.env.HERDR_BIN_PATH
    if herdr == nil or herdr == "" then herdr = "herdr" end
    vim.fn.system({ herdr, "pane", "focus", "--direction", direction, "--current" })
  elseif vim.env.TMUX and vim.env.TMUX ~= "" then
    local tmux_directions = { left = "Left", down = "Down", up = "Up", right = "Right" }
    pcall(vim.cmd, "TmuxNavigate" .. tmux_directions[direction])
  end
end

Util.map_keys({
  { "<C-h>", function() navigate("h", "left") end, opts = { desc = "Navigate left (vim/herdr)" } },
  { "<C-j>", function() navigate("j", "down") end, opts = { desc = "Navigate down (vim/herdr)" } },
  { "<C-k>", function() navigate("k", "up") end, opts = { desc = "Navigate up (vim/herdr)" } },
  { "<C-l>", function() navigate("l", "right") end, opts = { desc = "Navigate right (vim/herdr)" } },
}, { silent = true })

-- Colemak-DH navigation
local navigation_keys = {
  { "m", "h" },
  { "n", "j" },
  { "e", "k" },
  { "i", "l" },
}

local navigation_modes = { "n", "x", "s", "o" }
local colemak_keymaps = {}
local previous_keymaps = {}
local colemak_enabled = false

for _, keys in ipairs(navigation_keys) do
  local lhs, rhs = keys[1], keys[2]
  table.insert(colemak_keymaps, { lhs, rhs, mode = navigation_modes })
  table.insert(colemak_keymaps, { lhs:upper(), rhs:upper(), mode = navigation_modes })
  table.insert(colemak_keymaps, { "<C-" .. lhs .. ">", "<C-" .. rhs .. ">" })
end

local function for_each_colemak_keymap(callback)
  for _, keymap in ipairs(colemak_keymaps) do
    local modes = type(keymap.mode) == "table" and keymap.mode or { keymap.mode or "n" }
    for _, mode in ipairs(modes) do
      callback(keymap[1], mode)
    end
  end
end

local function set_colemak(enabled, notify)
  if colemak_enabled == enabled then return end

  for_each_colemak_keymap(function(lhs, mode)
    local key = mode .. lhs
    if enabled then
      previous_keymaps[key] = vim.fn.maparg(lhs, mode, false, true)
      return
    end

    pcall(vim.keymap.del, mode, lhs)
    local previous = previous_keymaps[key]
    if previous and not vim.tbl_isempty(previous) then vim.fn.mapset(mode, false, previous) end
  end)

  if enabled then Util.map_keys(colemak_keymaps, { remap = true }) end

  colemak_enabled = enabled

  if notify then vim.notify("Colemak-DH keymaps " .. (enabled and "enabled" or "disabled")) end
end

local function toggle_colemak() set_colemak(not colemak_enabled, true) end

vim.api.nvim_create_user_command("ColemakToggle", toggle_colemak, {})
Util.map_keys({ { "<leader>cm", toggle_colemak, opts = { desc = "Toggle Colemak-DH keymaps" } } })

set_colemak(false, false)
