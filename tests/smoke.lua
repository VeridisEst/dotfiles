local ok, err = xpcall(function()
  assert(vim.g.mapleader == " ", "init.lua did not load")
  assert(package.loaded["config.plugins"], "plugins did not load")
  assert(package.loaded["luasnip"] == nil, "unexpected LuaSnip")
  assert(vim.fn.maparg("<Space>tw", "n") ~= "", "missing work tasks key")
  vim.cmd("enew")
  vim.bo.filetype = "markdown"
  assert(vim.wo.spell and vim.wo.wrap, "writing options missing")
  assert(vim.bo.spelllang:find("nl") and vim.bo.spelllang:find("en"), "spell languages")
  assert(vim.fn.spellbadword("vergadering")[1] == "", "Dutch dictionary")
  assert(vim.fn.spellbadword("document")[1] == "", "English dictionary")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "- [ ] Voorbeeld" })
  local docs = require("config.documents")
  docs.toggle_task()
  assert(vim.api.nvim_get_current_line() == "- [x] Voorbeeld", "check task")
  docs.toggle_task()
  assert(vim.api.nvim_get_current_line() == "- [ ] Voorbeeld", "uncheck task")
  vim.bo.modified = false
  vim.cmd("enew")
  vim.bo.filetype = "python"
  assert(vim.bo.shiftwidth == 4, "Python indentation")
  vim.cmd("enew")
  vim.bo.filetype = "ruby"
  assert(vim.bo.shiftwidth == 2, "Ruby indentation")
  assert(require("nvim-autopairs").config.enable_moveright, "skip existing close bracket")
  assert(require("cmp").get_config().preselect == require("cmp").PreselectMode.None, "completion must not preselect")
  vim.cmd("enew")
  vim.bo.filetype = "text"
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('i()<Esc>', true, false, true), "xt", false)
  assert(vim.api.nvim_get_current_line() == "()", "manually typed close bracket doubled")
  vim.bo.modified = false
  vim.cmd("enew")
  vim.bo.filetype = "text"
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('i""<Esc>', true, false, true), "xt", false)
  assert(vim.api.nvim_get_current_line() == '""', "manually typed quote doubled")
  print("SMOKE_OK: configuration, plugins, NL/EN spelling, tasks, indentation, completion")
end, debug.traceback)
if not ok then io.stderr:write(tostring(err) .. "\n"); vim.cmd("cquit 1") else vim.cmd("qa!") end
