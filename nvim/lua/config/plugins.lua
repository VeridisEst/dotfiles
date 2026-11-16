require("mini.icons").setup({ style = "ascii" })
require("mini.statusline").setup({ use_icons = false })
require("mini.files").setup({ windows = { preview = true }, options = { use_as_default_explorer = true } })
require("mini.pick").setup()
require("mini.surround").setup()
require("mini.ai").setup()
require("mini.clue").setup({
  triggers = { { mode = "n", keys = "<Leader>" }, { mode = "n", keys = "g" }, { mode = "n", keys = "<C-w>" } },
  clues = {
    require("mini.clue").gen_clues.g(), require("mini.clue").gen_clues.windows(),
    { mode = "n", keys = "<Leader>n", desc = "+ Documenten" },
    { mode = "n", keys = "<Leader>t", desc = "+ Taken" },
    { mode = "n", keys = "<Leader>f", desc = "+ Zoeken" },
    { mode = "n", keys = "<Leader>c", desc = "+ Code" },
    { mode = "n", keys = "<Leader>u", desc = "+ Schakelaars" },
  }, window = { delay = 350 },
})
require("nvim-autopairs").setup({ enable_moveright = true, enable_check_bracket_line = true, disable_in_macro = true })
local cmp = require("cmp")
cmp.setup({
  snippet = { expand = function(args) vim.snippet.expand(args.body) end },
  preselect = cmp.PreselectMode.None,
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-y>"] = cmp.mapping.confirm({ select = false }),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if vim.snippet.active({ direction = 1 }) then vim.snippet.jump(1) else fallback() end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if vim.snippet.active({ direction = -1 }) then vim.snippet.jump(-1) else fallback() end
    end, { "i", "s" }),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer", keyword_length = 2, option = { get_bufnrs = function() return { vim.api.nvim_get_current_buf() } end } },
    { name = "path" },
    { name = "spell", keyword_length = 3, option = { keep_all_entries = false, enable_in_context = function() return vim.wo.spell end } },
  },
  formatting = { format = function(entry, item)
    item.menu = ({ buffer = "[document]", spell = "[spelling]", path = "[pad]", nvim_lsp = "[code]" })[entry.source.name]
    return item
  end },
})
-- No extra function-call parentheses on completion, avoiding double insertion.
