local Blink = require("blink.cmp")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = Blink.get_lsp_capabilities(capabilities)

--- @type vim.lsp.Config
return {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { ".git" },
  single_file_support = true,
  capabilities = vim.tbl_deep_extend("force", {}, capabilities, {
    fileOperations = {
      didRename = true,
      willRename = true,
    },
  }),
}
