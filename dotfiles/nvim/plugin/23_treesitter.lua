Pack.later(function()
  Pack.add({ "https://github.com/romus204/tree-sitter-manager.nvim" })

  local parsers = {
    "bash",
    "c",
    "comment",
    "css",
    "dart",
    "diff",
    "dockerfile",
    "git_config",
    "gitcommit",
    "gitignore",
    "go",
    "hcl",
    "html",
    "http",
    "java",
    "javascript",
    "jsdoc",
    "json",
    "json5",
    "jsx",
    "lua",
    "luadoc",
    "make",
    "nix",
    "python",
    "qmljs",
    "regex",
    "sql",
    "ssh_config",
    "tmux",
    "toml",
    "tsx",
    "typescript",
    "typst",
    "yaml",
  }

  require("tree-sitter-manager").setup({
    border = "single",
    ensure_installed = parsers,
  })

  Util.new_autocmd("Start Treesitter Highlighting", "FileType", parsers, function() vim.treesitter.start() end)
end)
