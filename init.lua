-- init.lua: Основной файл конфигурации Neovim
-- Этот файл задаёт настройки редактора, устанавливает плагины через lazy.nvim
-- и настраивает автодополнение с LSP, включая поддержку C/C++.

-- == Основные настройки редактора ==

-- Отображение номеров строк
vim.opt.number = false          -- Отключить абсолютные номера строк
vim.opt.relativenumber = true   -- Включить относительные номера строк

-- Настройки отступов и табуляции
vim.opt.tabstop = 4             -- Ширина табуляции (4 пробела)
vim.opt.shiftwidth = 4          -- Ширина автоматического отступа
vim.opt.expandtab = true        -- Заменять табы пробелами
vim.opt.autoindent = true       -- Автоматический отступ для новых строк

-- Настройки поиска
vim.opt.ignorecase = true       -- Игнорировать регистр при поиске
vim.opt.smartcase = true        -- Учитывать регистр, если в запросе есть заглавные буквы

-- Настройки интерфейса
vim.opt.cursorline = true       -- Подсвечивать текущую строку
vim.opt.termguicolors = true    -- Включить 24-битные цвета для цветовых схем

-- Интеграция с системным буфером обмена
vim.opt.clipboard = 'unnamedplus' -- Использовать системный буфер обмена

-- Дополнительные настройки
vim.opt.mouse = 'a'             -- Включить поддержку мыши во всех режимах
vim.opt.wrap = false            -- Отключить перенос строк
vim.opt.scrolloff = 8           -- Минимальное количество строк над/под курсором

-- == Установка менеджера плагинов Lazy ==

-- Путь для установки lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    -- Клонирование lazy.nvim, если он не установлен
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath) -- Добавить lazy.nvim в runtimepath

-- == Установка и настройка плагинов ==

require("lazy").setup({
    -- Цветовая схема
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000, -- Установить высокий приоритет для загрузки
    },

    -- Сниппеты
    { "L3MON4D3/LuaSnip", version = "*" }, -- Поддержка сниппетов

    -- Источники автодополнения
    { "hrsh7th/cmp-buffer" },      -- Автодополнение из текста в буфере
    { "hrsh7th/cmp-path" },        -- Автодополнение путей к файлам
    { "saadparwaiz1/cmp_luasnip" }, -- Интеграция сниппетов с nvim-cmp

    -- Поддержка LSP и автодополнения
    { "neovim/nvim-lspconfig" },   -- Конфигурация языковых серверов
    { "hrsh7th/nvim-cmp" },        -- Плагин автодополнения
    { "hrsh7th/cmp-nvim-lsp" },    -- Интеграция LSP с автодополнением

    -- Автоматическое закрытие скобок
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",     -- Загружать при входе в режим вставки
        config = function()
            require("nvim-autopairs").setup({})
        end
    },

    -- Файловый менеджер
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            require("nvim-tree").setup({
                view = {
                    width = 30,       -- Ширина панели файлового менеджера
                    side = "left",    -- Расположение панели (слева)
                },
                renderer = {
                    icons = {
                        show = {
                            file = true,
                            folder = true,
                            folder_arrow = true,
                            git = true,
                        },
                    },
                },
            })
        end
    },

    -- Поддержка C/C++: сниппеты и переключение между .h/.cpp
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "rafamadriz/friendly-snippets", -- Готовые сниппеты для C/C++ и других языков
        },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load() -- Загрузка VSCode-совместимых сниппетов
        end
    },
    {
        "derekwyatt/vim-fswitch", -- Переключение между .h и .cpp файлами
        config = function()
            vim.keymap.set("n", "<leader>fs", ":FSHere<CR>", { desc = "Switch between header/source" })
        end
    },
})

-- Установка цветовой схемы
vim.cmd.colorscheme("catppuccin")

-- == Настройка LSP ==

-- Подключение возможностей автодополнения для LSP
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Настройка языковых серверов
lspconfig.pyright.setup({
    capabilities = capabilities, -- Поддержка автодополнения
})
lspconfig.bashls.setup({
    capabilities = capabilities,
})
lspconfig.clangd.setup({
    capabilities = capabilities,
    -- Настройки специфичные для C/C++
    cmd = { "clangd", "--background-index", "--clang-tidy" }, -- Включить clang-tidy для анализа кода
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" }, -- Поддерживаемые типы файлов
    root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git"), -- Определение корня проекта
    settings = {
        clangd = {
            fallbackFlags = { "-std=c++20" }, -- Стандарт C++ по умолчанию
        },
    },
    -- Поддержка clang-format для форматирования кода
    on_attach = function(client, bufnr)
        vim.keymap.set("n", "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
        end, { buffer = bufnr, desc = "Format code with clang-format" })
    end,
})

-- == Настройка автодополнения ==

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
    -- Поддержка сниппетов
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    -- Настройка клавиш
    mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping.select_next_item(),   -- Следующий элемент автодополнения
        ["<S-Tab>"] = cmp.mapping.select_prev_item(), -- Предыдущий элемент
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Подтвердить выбор
    }),
    -- Источники автодополнения
    sources = cmp.config.sources({
        { name = "nvim_lsp" },  -- LSP
        { name = "luasnip" },   -- Сниппеты
        { name = "buffer" },    -- Текст из буфера
        { name = "path" },      -- Пути к файлам
    }),
})

-- == Дополнительные настройки клавиш ==
-- Открытие/закрытие nvim-tree
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- Компиляция и запуск C/C++ кода
vim.keymap.set("n", "<leader>cc", function()
    vim.cmd("w") -- Сохранить файл
    vim.fn.system("g++ -std=c++20 -o a.out " .. vim.fn.expand("%") .. " && ./a.out")
    print("Compiled and ran " .. vim.fn.expand("%"))
end, { desc = "Compile and run C/C++" })
