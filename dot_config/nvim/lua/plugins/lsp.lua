-- lua/plugins/lsp.lua
return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "pyright", -- Python
        "ts_ls",   -- TypeScript/JavaScript
        "clangd",  -- C/C++
      },
    },
  },
}
