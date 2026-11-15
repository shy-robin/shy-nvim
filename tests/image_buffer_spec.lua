vim.opt.runtimepath:prepend(vim.fn.getcwd())
dofile("lua/plugins/snacks.lua").init()

local buf = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(buf)
vim.bo[buf].filetype = "image"
-- Snacks writes progress/error text after initially clearing 'modified'.
vim.bo[buf].modifiable = true
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "# Image Conversion Failed:", "No command available" })
vim.bo[buf].modifiable = false
vim.wait(50, function()
  return not vim.bo[buf].modified
end)
assert(not vim.bo[buf].modified, "image preview must not become modified after rendering")
assert(vim.bo[buf].buftype == "nowrite", "preview text must never overwrite the image")
local normal = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_lines(normal, 0, -1, false, { "edited" })
assert(vim.bo[normal].modified, "normal edits must remain modified")
print("OK image preview buffer state")
