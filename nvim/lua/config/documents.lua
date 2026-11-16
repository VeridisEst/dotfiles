local M = {}
function M.root() return vim.fs.normalize(vim.env.NVIM_DOCUMENTS or (vim.env.HOME or vim.env.USERPROFILE) .. "/documenten") end
function M.open(relative, lines)
  local file = M.root() .. "/" .. relative
  vim.fn.mkdir(vim.fs.dirname(file), "p")
  vim.cmd.edit(vim.fn.fnameescape(file))
  if vim.fn.filereadable(file) == 0 and vim.api.nvim_buf_line_count(0) == 1 and vim.api.nvim_get_current_line() == "" then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines or { "# " .. vim.fn.fnamemodify(file, ":t:r"), "" })
  end
end
function M.tasks(area)
  local file = M.root() .. "/" .. area .. "/taken.md"
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)) == file then
      if #vim.api.nvim_tabpage_list_wins(0) > 1 then vim.api.nvim_win_close(win, false) end
      return
    end
  end
  vim.cmd("botright 45vsplit")
  M.open(area .. "/taken.md", { "# Taken — " .. area, "", "## Te doen", "", "## Bezig", "", "## Afgerond", "" })
  vim.wo.winfixwidth = true
end
function M.toggle_task()
  local line = vim.api.nvim_get_current_line()
  local changed, n = line:gsub("^(%s*[-*] )%[ %]", "%1[x]", 1)
  if n == 0 then changed, n = line:gsub("^(%s*[-*] )%[[xX]%]", "%1[ ]", 1) end
  if n > 0 then vim.api.nvim_set_current_line(changed) end
end
function M.week()
  local today = os.date("*t")
  today.hour, today.min, today.sec = 12, 0, 0
  local now = os.time(today)
  local weekday = (today.wday + 5) % 7 + 1
  local thursday = os.date("*t", now + (4 - weekday) * 86400)
  return string.format("%d-W%02d", thursday.year, math.floor((thursday.yday - 1) / 7) + 1)
end
function M.setup()
  local map = function(key, fn, desc) vim.keymap.set("n", key, fn, { desc = desc }) end
  map("<leader>no", function() M.open("org/overzicht.md") end, "Documentenoverzicht")
  map("<leader>nj", function()
    local date = os.date("%Y-%m-%d")
    M.open("org/dagboek/" .. date .. ".md", { "# " .. date, "", "## Gebeurtenissen", "", "## Gedachten en reflectie", "" })
  end, "Dagboek vandaag")
  map("<leader>nw", function()
    local week = M.week()
    M.open("org/weekplanning/" .. week .. ".md", { "# " .. week, "", "## Focus", "", "## Afspraken", "", "## Terugblik", "", "[Werktaken](../../werk/taken.md) · [Privétaken](../../prive/taken.md)" })
  end, "Weekplanning")
  map("<leader>nf", function() require("mini.pick").builtin.files(nil, { source = { cwd = M.root() } }) end, "Zoek document")
  map("<leader>ng", function() require("mini.pick").builtin.grep_live(nil, { source = { cwd = M.root() } }) end, "Zoek in documenten")
  map("<leader>tw", function() M.tasks("werk") end, "Werktaken zijpaneel")
  map("<leader>tp", function() M.tasks("prive") end, "Privétaken zijpaneel")
  map("<leader>tt", M.toggle_task, "Taak afvinken")
  vim.api.nvim_create_user_command("Documenten", function() M.open("org/overzicht.md") end, {})
end
return M
