-- Detect nvim version, fall back to minimal config on old versions
if vim.fn.has("nvim-0.9") == 1 then
  require("config.lazy")
else
  -- Minimal config for neovim < 0.9 (old systems with ancient glibc)
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.expandtab = true
  vim.opt.shiftwidth = 2
  vim.opt.tabstop = 2
  vim.opt.smartindent = true
  vim.opt.hlsearch = true
  vim.opt.incsearch = true
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  vim.opt.mouse = "a"
  vim.opt.clipboard = "unnamedplus"
  vim.opt.termguicolors = true
end
