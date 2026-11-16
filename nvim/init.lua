vim.g.mapleader = " "
vim.g.maplocalleader = ","
require("config.options")
-- Exact plugin commits are installed by install.sh, never at editor startup.
if vim.env.VERIDIS_RELEASE then
  vim.opt.packpath:prepend(vim.env.VERIDIS_RELEASE .. "/site")
  vim.opt.runtimepath:prepend(vim.env.VERIDIS_RELEASE .. "/site")
end
vim.cmd("packloadall")
require("config.plugins")
require("config.documents").setup()
require("config.lsp")
require("config.keymaps")
