local o = vim.opt
o.number = true
o.relativenumber = true
o.termguicolors = true
o.mouse = "a"
o.ignorecase = true
o.smartcase = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.autoindent = true
o.breakindent = true
o.linebreak = true
o.wrap = false
o.scrolloff = 5
o.signcolumn = "yes"
o.splitright = true
o.splitbelow = true
o.undofile = true
o.confirm = true
o.updatetime = 250
o.completeopt = { "menu", "menuone", "noselect" }
o.spelllang = { "nl", "en" }
o.spelloptions = "camel"
o.clipboard = "unnamedplus"
vim.cmd.colorscheme("habamax")
-- SSH takes precedence over WSL. Paste remotely with the terminal shortcut;
-- do not issue OSC 52 read requests which unsupported terminals cannot answer.
if vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
  local osc = require("vim.ui.clipboard.osc52")
  local function paste(reg)
    return function() return { vim.fn.getreg(reg, 1, true), vim.fn.getregtype(reg) } end
  end
  vim.g.clipboard = {
    name = "SSH OSC52 copy / local register paste",
    copy = { ["+"] = osc.copy("+"), ["*"] = osc.copy("*") },
    paste = { ["+"] = paste("+"), ["*"] = paste("*") },
  }
elseif vim.fn.has("wsl") == 1 and vim.fn.executable("clip.exe") == 1 and vim.fn.executable("powershell.exe") == 1 then
  local paste = { "powershell.exe", "-NoProfile", "-Command", '[Console]::Out.Write((Get-Clipboard -Raw).Replace("`r", ""))' }
  vim.g.clipboard = {
    name = "WSL Windows clipboard", cache_enabled = 0,
    copy = { ["+"] = "clip.exe", ["*"] = "clip.exe" },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
    vim.opt_local.textwidth = 0
    vim.opt_local.conceallevel = 0
    vim.opt_local.formatoptions:remove({ "t", "c" })
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python", callback = function() vim.opt_local.shiftwidth = 4; vim.opt_local.tabstop = 4 end,
})
vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.hl.on_yank({ timeout = 150 }) end })
