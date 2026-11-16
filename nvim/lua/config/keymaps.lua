local map = function(key, fn, desc) vim.keymap.set("n", key, fn, { desc = desc }) end
map("<leader>e", function() require("mini.files").open(vim.api.nvim_buf_get_name(0) ~= "" and vim.api.nvim_buf_get_name(0) or vim.fn.getcwd()) end, "Bestanden verkennen")
map("<leader>ff", function() require("mini.pick").builtin.files() end, "Zoek bestand")
map("<leader>fg", function() require("mini.pick").builtin.grep_live() end, "Zoek tekst")
map("<leader>fb", function() require("mini.pick").builtin.buffers() end, "Open bestanden")
map("<leader>w", "<cmd>write<cr>", "Opslaan")
map("<leader>cd", vim.diagnostic.open_float, "Foutmelding tonen")
map("<leader>us", function() vim.wo.spell = not vim.wo.spell end, "Spelling aan/uit")
map("<leader>ua", function() require("nvim-autopairs").toggle() end, "Automatische haakjes aan/uit")
map("<leader>uf", function()
  vim.g.veridis_autoformat = vim.g.veridis_autoformat == false
  vim.notify("Formatteren bij opslaan: " .. tostring(vim.g.veridis_autoformat))
end, "Formatteren bij opslaan aan/uit")
for _, key in ipairs({ "j", "k" }) do
  vim.keymap.set({ "n", "x" }, key, function() return vim.v.count == 0 and "g" .. key or key end, { expr = true })
end
map("<Esc>", "<cmd>nohlsearch<cr>", "Zoekmarkering uit")
map("<leader>?", function() vim.cmd.edit(vim.fn.fnameescape(vim.fn.stdpath("config") .. "/README.md")) end, "Handleiding")
