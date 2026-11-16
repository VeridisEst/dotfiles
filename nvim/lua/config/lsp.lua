local capabilities = require("cmp_nvim_lsp").default_capabilities()
vim.diagnostic.config({ virtual_text = false, severity_sort = true, float = { border = "rounded" } })
vim.lsp.config("pylsp", {
  cmd = { "pylsp" }, filetypes = { "python" }, capabilities = capabilities,
  root_markers = { "pyproject.toml", "setup.py", ".git" },
  settings = { pylsp = { plugins = {
    black = { enabled = true }, autopep8 = { enabled = false }, yapf = { enabled = false },
    pyflakes = { enabled = true }, pycodestyle = { enabled = false },
  } } },
})
vim.lsp.config("solargraph", {
  cmd = { "solargraph", "stdio" }, filetypes = { "ruby" }, capabilities = capabilities,
  root_markers = { "Gemfile", ".solargraph.yml", ".git" },
  settings = { solargraph = { diagnostics = true, formatting = true } },
})
for _, server in ipairs({ "pylsp", "solargraph" }) do
  if vim.fn.executable(server) == 1 then vim.lsp.enable(server) end
end
vim.api.nvim_create_autocmd("LspAttach", { callback = function(args)
  local function map(key, fn, desc) vim.keymap.set("n", key, fn, { buffer = args.buf, desc = desc }) end
  map("gd", vim.lsp.buf.definition, "Ga naar definitie")
  map("K", vim.lsp.buf.hover, "Uitleg bij code")
  map("<leader>cr", vim.lsp.buf.rename, "Hernoemen")
  map("<leader>ca", vim.lsp.buf.code_action, "Codeactie kiezen")
  map("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Code formatteren")
end })
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.py", "*.rb" }, callback = function(args)
    if vim.g.veridis_autoformat ~= false and #vim.lsp.get_clients({ bufnr = args.buf, method = "textDocument/formatting" }) > 0 then
      vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 3000 })
    end
  end,
})
