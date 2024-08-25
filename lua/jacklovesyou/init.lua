local M = {}

function M.sayHello()
    print("Hello")
end

vim.api.nvim_set_keymap("n", "<leader>j", ":lua require('jacklovesyou').sayHello()<CR>", { noremap = true, silent = true })

return M

