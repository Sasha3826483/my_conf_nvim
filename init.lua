-- Номера строк
vim.opt.number = false
vim.opt.relativenumber = true

-- Табы и отступы
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true

-- Поиск
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Интерфейс
vim.opt.cursorline = true
vim.opt.termguicolors = true

-- Системный буфер обмена
vim.opt.clipboard = 'unnamedplus'

-- Настроим плагины

-- Установка Lazy (если его нет)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Загрузка плагинов
require("lazy").setup({
    -- Сниппеты
    { "L3MON4D3/LuaSnip" },

    -- Источники автодополнения
    { "hrsh7th/cmp-buffer" },      -- из открытого буфера
    { "hrsh7th/cmp-path" },        -- пути к файлам
    { "saadparwaiz1/cmp_luasnip" }, -- интеграция сниппетов

    -- Цветовая схема
    { "catppuccin/nvim", name = "catppuccin" },

    -- Автодополнение (LSP)
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },

    {
        "windwp/nvim-autopairs",
        event = "insertEnter",
        config = function()
            require("nvim-autopairs").setup({})
        end
    },

    -- Файловый менеджер
    { "nvim-tree/nvim-tree.lua" },
})

vim.cmd.colorscheme("catppuccin")

-- LSP
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.pyright.setup({
    capabilities = capabilities,
})
lspconfig.clangd.setup({
    capabilities = capabilities,
})

lspconfig.bashls.setup({
    capabilities = capabilities
})

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  }),
})
