local ok, err = xpcall(function()
  for _, sample in ipairs({ { "python", "pylsp", "print(  'hello' )" }, { "ruby", "solargraph", "puts  'hello'" } }) do
    local file = vim.env.NVIM_DOCUMENTS .. "/example." .. (sample[1] == "python" and "py" or "rb")
    vim.fn.mkdir(vim.fs.dirname(file), "p")
    vim.cmd.edit(vim.fn.fnameescape(file))
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { sample[3] })
    vim.bo.filetype = sample[1]
    assert(vim.wait(60000, function()
      local clients = vim.lsp.get_clients({ bufnr = 0, name = sample[2] })
      return #clients > 0 and clients[1].initialized
    end, 100), sample[2] .. " failed to initialize")
    local client = vim.lsp.get_clients({ bufnr = 0, name = sample[2] })[1]
    local response, reason = client:request_sync("textDocument/formatting", {
      textDocument = vim.lsp.util.make_text_document_params(), options = { tabSize = vim.bo.tabstop, insertSpaces = true },
    }, 30000, 0)
    assert(response and not response.err, sample[2] .. " formatting: " .. vim.inspect(response or reason))
    assert(type(response.result) == "table" and #response.result > 0, sample[2] .. " returned no formatting edits")
    vim.lsp.util.apply_text_edits(response.result, 0, client.offset_encoding)
    assert(vim.api.nvim_get_current_line() ~= sample[3], sample[2] .. " did not format")
    vim.bo.modified = false
    vim.cmd("enew")
  end
  print("LSP_OK: Python and Ruby started and formatted code")
end, debug.traceback)
if not ok then io.stderr:write(tostring(err) .. "\n"); vim.cmd("cquit 1") else vim.cmd("qa!") end
