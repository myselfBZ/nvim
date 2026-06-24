require("jakelovesyou")

--Lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
local plugins = {
    -- For lazy.nvim
    { 'nvim-tree/nvim-web-devicons' },

    {
        'nvim-telescope/telescope.nvim', tag = '0.1.6',
        -- or                              , branch = '0.1.x',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {"lewis6991/gitsigns.nvim"},
    {"rose-pine/neovim"},
    {'feline-nvim/feline.nvim'},
    {"Hitesh-Aggarwal/feline_one_monokai.nvim"},
    { 'machakann/vim-highlightedyank', event = 'TextYankPost' },
    {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
    {
        "williamboman/mason.nvim"
    },
    {
        "williamboman/mason-lspconfig.nvim"
    },
    {
        "neovim/nvim-lspconfig"
    },
    {
        'nvim-telescope/telescope-ui-select.nvim'
    },
    {
        'hrsh7th/nvim-cmp'
    },
    {
        'hrsh7th/cmp-path'
    },
    {
        'hrsh7th/cmp-buffer'
    },
    {
        'L3MON4D3/LuaSnip'
    },
    {
        'saadparwaiz1/cmp_luasnip'
    },
    {
        'rafamadriz/friendly-snippets'
    },
    {
        'hrsh7th/cmp-nvim-lsp'
    },
    {
        "nvim-tree/nvim-tree.lua"
    },
    {
        'tpope/vim-fugitive'
    },
    {
        "theprimeagen/harpoon"

    },
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
    }
}
local opts = {}
require("lazy").setup(plugins, opts)

require('nvim-web-devicons').setup { default = true }
require('feline').setup()
require('feline').winbar.setup()
local builtin = require("telescope.builtin")

-- This is your opts table

local config = require("nvim-treesitter.configs")
config.setup({
    ensure_installed = {"python", "go", "javascript", "lua", "rust", "c"},
    highlight = { enable = true },
})
-- how to configure machakann/vim-highlightedyan
vim.g.highlightedyank_highlight_duration = 90
-- my colors
require("rose-pine").setup({
    variant = "auto", -- auto, main, moon, or dawn
    dark_variant = "main", -- main, moon, or dawn
    dim_inactive_windows = false,
    extend_background_behind_borders = true,

    enable = {
        terminal = true,
        legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
        migrations = true, -- Handle deprecated options automatically
    },

    styles = {
        bold = false,
        italic = true,
        transparency = false,
    },

    groups = {
        border = "muted",
        link = "iris",
        panel = "surface",

        error = "love",
        hint = "iris",
        info = "foam",
        note = "pine",
        todo = "rose",
        warn = "gold",

        git_add = "foam",
        git_change = "rose",
        git_delete = "love",
        git_dirty = "rose",
        git_ignore = "muted",
        git_merge = "iris",
        git_rename = "pine",
        git_stage = "iris",
        git_text = "rose",
        git_untracked = "subtle",

        h1 = "iris",
        h2 = "foam",
        h3 = "rose",
        h4 = "gold",
        h5 = "pine",
        h6 = "foam",
    },

    palette = {
        -- Override the builtin palette per variant
        -- moon = {
        --     base = '#18191a',
        --     overlay = '#363738',
        -- },
    },

    highlight_groups = {
        -- Comment = { fg = "foam" },
        -- VertSplit = { fg = "muted", bg = "muted" },
    },

    before_highlight = function(group, highlight, palette)
        -- Disable all undercurls
        -- if highlight.undercurl then
        --     highlight.undercurl = false
        -- end
        --
        -- Change palette colour
        -- if highlight.fg == palette.pine then
        --     highlight.fg = palette.foam
        -- end
    end,
})

vim.cmd("colorscheme rose-pine")

require("mason").setup()
require("mason-lspconfig").setup{
    ensure_installed = {
        "ts_ls",
        "pyright",
        "gopls",
        "lua_ls",
    }
}

--file tree
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
})

require('gitsigns').setup()

local lsp_config = require("lspconfig")
local capabilities = require('cmp_nvim_lsp').default_capabilities()



-- On attach function to set key mappings
local on_attach = function(client, bufnr)
    local buf_map = function(bufnr, mode, lhs, rhs, opts)
        opts = vim.tbl_extend('force', {noremap = true, silent = true}, opts or {})
        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
    end

    -- Mappings for LSP functionality
    buf_map(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
    buf_map(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
    buf_map(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
    buf_map(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
    buf_map(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
    buf_map(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
    buf_map(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
end

-- Enhance LSP floating window appearance
local function short_message(msg, maxlen)
  maxlen = maxlen or 120
  -- collapse newlines, trim leading/trailing spaces
  msg = msg:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
  if #msg > maxlen then
    return msg:sub(1, maxlen - 1) .. "…"
  end
  return msg
end

-- diagnostic global config
vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
    -- show shortened virtual_text (inline) messages
    format = function(diag)
      return short_message(diag.message, 80)
    end,
  },
  underline = true,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    -- rounded border and size limits for diagnostic float
    border = "rounded",
    focusable = false,
    max_width = 80,
    max_height = 20,
    source = "if_many",
    -- format the diagnostic shown in the float
    format = function(diag)
      -- include source and code if available, but keep message short
      local s = diag.source and ("[" .. diag.source .. "] ") or ""
      if diag.code then s = s .. "(" .. tostring(diag.code) .. ") " end
      s = s .. short_message(diag.message, 200)
      return s
    end,
  },
})

-- apply rounded borders (and optional max_width) to other LSP floating handlers
local with_opts = function(handler, opts)
  return vim.lsp.with(handler, opts)
end

vim.lsp.handlers["textDocument/hover"] = with_opts(
  vim.lsp.handlers.hover,
  { border = "rounded", max_width = 80 }
)

vim.lsp.handlers["textDocument/signatureHelp"] = with_opts(
  vim.lsp.handlers.signature_help,
  { border = "rounded", max_width = 80 }
)

-- shorten window/showMessage (client -> server notifications shown as float)
vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local message = result.message or ""
  vim.notify(short_message(message, 200), result.type or vim.log.levels.INFO, {
    title = client and client.name or "LSP",
    timeout = 3000,
  })
end

lsp_config.pyright.setup{
    on_attach = on_attach,
    capabilities = capabilities
}

lsp_config.rust_analyzer.setup{

    on_attach = on_attach,
    capabilities = capabilities
}
lsp_config.gopls.setup{
    on_attach = on_attach,
    capabilities = capabilities
}
lsp_config.ts_ls.setup{

    on_attach = on_attach,
    capabilities = capabilities
}

lsp_config.clangd.setup{
    on_attach = on_attach,
    capabilities = capabilities
}

lsp_config.lua_ls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = {"vim"}
            }
        }
    }
}

-- This is your opts table
require("telescope").setup {
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {
      }

    }
  }
}
require("telescope").load_extension("ui-select")

local cmp = require'cmp'
require("luasnip.loaders.from_vscode").lazy_load()
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    -- formatting = {
    --     format = function(entry, vim_item)
    --         -- Customize how the items are displayed in the completion menu
    --         vim_item.kind = string.format("%s", vim_item.kind)  -- Add icons to the completion item (optional)
    --         return vim_item
    --     end,
    -- },

    window = {
        completion =  cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered()
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<C-k>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
        { name = 'buffer' },
    })

})

local mark = require("harpoon.mark")
local ui = require("harpoon.ui")


--key maps 
vim.keymap.set('n', "<leader>a", mark.add_file)
vim.keymap.set('n', "<C-e>", ui.toggle_quick_menu)
vim.keymap.set('n', "<C-h>",function() ui.nav_file(1) end)
vim.keymap.set('n', "<C-t>",  function() ui.nav_file(2) end)
vim.keymap.set('n', "<leader>n", function() ui.nav_file(3) end)
vim.keymap.set('n', "<leader>s",  function() ui.nav_file(4) end)
vim.keymap.set('n', '<leader>gs', vim.cmd.Git)
vim.keymap.set('n', '<leader>b', "<cmd>q!<CR>")
vim.keymap.set('n', '<leader>w', vim.cmd.wq)
vim.keymap.set('n', '<C-f>', vim.cmd.wa)
vim.api.nvim_set_keymap('n', '<leader>hl', 'ihttp://localhost:<Esc>', { noremap = true, silent = true })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>pg', builtin.live_grep, {})
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
vim.keymap.set("v", "<leader>y", "\"+y")
vim.api.nvim_set_keymap('n', '<leader>h', ':nohlsearch<CR>', { noremap = true, silent = true })
vim.keymap.set("i", "<C-c>", "<Esc>:wa<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>pv", ":NvimTreeFocus<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>t", ":tabf ", { noremap = true, silent = false })
-- vim.keymap.set("n", "<leader>fm", ":!gofmt -w .<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)


--vim.api.nvim_set_hl(0, "Normal", { bg="none" })
--vim.api.nvim_set_hl(0, "NormalFloat", { bg="none" })
