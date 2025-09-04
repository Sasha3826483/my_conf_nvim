-- init.lua: Основной файл конфигурации Neovim
-- Этот файл задаёт основные настройки редактора, управляет установкой плагинов через lazy.nvim,
-- настраивает автодополнение с LSP (включая поддержку C/C++), отладку через DAP и интеграцию с UI.

-- == Основные настройки редактора ==

-- Настройки отображения номеров строк
vim.opt.number = true           -- Включить абсолютные номера строк
vim.opt.relativenumber = true   -- Включить относительные номера строк для удобной навигации

-- Настройки отступов и табуляции
vim.opt.tabstop = 4             -- Установить ширину табуляции в 4 пробела
vim.opt.shiftwidth = 4          -- Установить ширину автоматического отступа в 4 пробела
vim.opt.expandtab = true        -- Заменять символы табуляции пробелами
vim.opt.autoindent = true       -- Включить автоматический отступ для новых строк

-- Настройки поиска
vim.opt.ignorecase = true       -- Игнорировать регистр символов при поиске
vim.opt.smartcase = true        -- Учитывать регистр, если в запросе есть заглавные буквы

-- Настройки интерфейса
vim.opt.cursorline = true       -- Подсвечивать текущую строку для лучшей видимости
vim.opt.termguicolors = true    -- Включить поддержку 24-битных цветов для цветовых схем
vim.opt.wrap = false            -- Отключить перенос строк для удобства работы с длинными строками
vim.opt.scrolloff = 8           -- Оставлять минимум 8 строк над и под курсором при прокрутке

-- Интеграция с буфером обмена
vim.opt.clipboard = 'unnamedplus' -- Использовать системный буфер обмена для копирования/вставки
vim.opt.mouse = 'a'             -- Включить поддержку мыши во всех режимах редактора

-- lua/config/autocmds.lua
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
    desc = "Format C/C++ files on save",
})

-- == Установка менеджера плагинов Lazy ==

-- Определение пути для установки lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    -- Автоматическая установка lazy.nvim, если он отсутствует
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none", -- Оптимизация клонирования (без загрузки лишних данных)
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath) -- Добавить lazy.nvim в начало runtimepath

-- == Установка и настройка плагинов ==

-- Конфигурация менеджера плагинов lazy.nvim
require("lazy").setup({
    -- Цветовая схема
    {
        "catppuccin/nvim",          -- Плагин цветовой схемы Catppuccin
        name = "catppuccin",        -- Имя плагина для lazy.nvim
        priority = 1000,            -- Высокий приоритет для ранней загрузки
        config = function()
            vim.cmd.colorscheme("catppuccin") -- Установить цветовую схему
        end
    },

    -- Поддержка сниппетов
    {
        "L3MON4D3/LuaSnip",         -- Плагин для работы со сниппетами
        version = "*",              -- Использовать последнюю версию
        dependencies = {
            "rafamadriz/friendly-snippets", -- Готовые сниппеты для C/C++ и других языков
        },
        config = function()
            -- Загрузка VSCode-совместимых сниппетов
            require("luasnip.loaders.from_vscode").lazy_load()
        end
    },

    -- Источники автодополнения
    { "hrsh7th/cmp-buffer" },       -- Автодополнение из текста в буфере
    { "hrsh7th/cmp-path" },         -- Автодополнение путей к файлам
    { "saadparwaiz1/cmp_luasnip" }, -- Интеграция LuaSnip с nvim-cmp

    -- Поддержка LSP и автодополнения
    { "neovim/nvim-lspconfig" },    -- Конфигурация языковых серверов
    { "hrsh7th/nvim-cmp" },         -- Основной плагин автодополнения
    { "hrsh7th/cmp-nvim-lsp" },     -- Интеграция LSP с автодополнением

    -- Автоматическое закрытие скобок
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",      -- Загружать при входе в режим вставки
        config = function()
            require("nvim-autopairs").setup({}) -- Настройка автозакрытия скобок
        end
    },

    -- Файловый менеджер
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            require("nvim-tree").setup({
                view = {
                    width = 30,         -- Ширина панели файлового менеджера
                    side = "left",      -- Расположение панели слева
                },
                renderer = {
                    icons = {
                        show = {
                            file = true,    -- Показывать иконки файлов
                            folder = true,  -- Показывать иконки папок
                            folder_arrow = true, -- Показывать стрелки для папок
                            git = true,     -- Показывать статус Git
                        },
                    },
                },
            })
        end
    },

    -- Переключение между .h и .cpp файлами
    {
        "derekwyatt/vim-fswitch",
        config = function()
            -- Привязка клавиши для переключения между заголовочным и исходным файлом
            vim.keymap.set("n", "<leader>fs", ":FSHere<CR>", { desc = "Switch between header/source" })
        end
    },

    -- Подсветка синтаксиса с помощью Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate", -- Обновление парсеров при установке
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "c", "cpp", "lua", "python", "bash" }, -- Поддерживаемые языки
                highlight = { enable = true }, -- Включить подсветку синтаксиса
                indent = { enable = true },   -- Включить улучшенные отступы
            })
        end
    },

	{
        "theHamsta/nvim-dap-virtual-text",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            require("nvim-dap-virtual-text").setup({
                enabled = true,
                highlight_changed_variables = true,
            })
        end
    },

        -- Поиск файлов и текста
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" }, -- Зависимость для Telescope
        config = function()
            local telescope = require("telescope")
            telescope.setup({}) -- Базовая настройка Telescope
            -- Привязки клавиш для поиска
            vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
            vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Grep in files" })
        end
    },

    -- Статусная строка
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" }, -- Иконки для статусной строки
        config = function()
            require("lualine").setup({
                options = {
                    theme = "catppuccin", -- Интеграция с цветовой схемой
                    icons_enabled = true,  -- Включить отображение иконок
                },
                sections = {
                    lualine_a = { "mode" },       -- Режим редактора
                    lualine_b = { "branch", "diff" }, -- Информация о ветке Git и изменениях
                    lualine_c = { "filename" },   -- Имя текущего файла
                    lualine_x = { "encoding", "fileformat", "filetype" }, -- Кодировка, формат и тип файла
                    lualine_y = { "progress" },   -- Прогресс в файле
                    lualine_z = { "location" },   -- Положение курсора
                },
            })
        end
    },

    -- Интеграция с Git
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                signs = {
                    add = { text = "+" },      -- Знак для добавленных строк
                    change = { text = "~" },   -- Знак для изменённых строк
                    delete = { text = "_" },   -- Знак для удалённых строк
                },
            })
        end
    },

    -- Комментирование кода
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup() -- Настройка плагина для комментирования
        end
    },

    -- Отладка кода
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")
            -- Настройка адаптера отладки для C/C++ (lldb)
            dap.adapters.lldb = {
                type = "executable",
                command = "lldb-vscode", -- Путь к lldb-vscode, если требуется
                name = "lldb"
            }
            -- Конфигурация отладки для C/C++
            dap.configurations.cpp = {
                {
                    name = "Launch",
                    type = "lldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/a.out")
                    end,
                    cwd = "${workspaceFolder}", -- Рабочая директория
                    stopOnEntry = false,       -- Не останавливаться на точке входа
                    args = {},                 -- Аргументы командной строки
                },
            }
            dap.configurations.c = dap.configurations.cpp -- Использовать ту же конфигурацию для C
        end
    },

    -- UI для отладки
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        config = function()
            local dap, dapui = require("dap"), require("dapui")
            dapui.setup() -- Настройка интерфейса отладки
            -- Автоматическое открытие/закрытие UI при отладке
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
        end
    },

    -- Форматирование автодополнения
    {
        "onsails/lspkind.nvim",
        config = function()
            require("cmp").setup({
                formatting = {
                    format = require("lspkind").cmp_format({
                        mode = "symbol_text", -- Отображать иконки и текст
                        maxwidth = 50,        -- Ограничить ширину всплывающего окна
                    }),
                },
            })
        end
    }
})

-- == Настройка LSP ==

-- Подключение возможностей автодополнения для LSP
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Настройка языкового сервера для Python
lspconfig.pyright.setup({
    capabilities = capabilities, -- Поддержка автодополнения
})

-- Настройка языкового сервера для Bash
lspconfig.bashls.setup({
    capabilities = capabilities,
})

-- Настройка языкового сервера для C/C++
lspconfig.clangd.setup({
    capabilities = capabilities,
    cmd = { "clangd", "--background-index", "--clang-tidy" }, -- Включить фоновую индексацию и clang-tidy
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" }, -- Поддерживаемые типы файлов
    root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git"), -- Определение корня проекта
    settings = {
        clangd = {
            fallbackFlags = { "-std=c++20" }, -- Стандарт C++ по умолчанию
        },
    },
    on_attach = function(client, bufnr)
        -- Привязка клавиши для форматирования кода с помощью clang-format
        vim.keymap.set("n", "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
        end, { buffer = bufnr, desc = "Format code with clang-format" })
    end,
})

-- == Настройка автодополнения ==

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
    snippet = {
        -- Поддержка расширения сниппетов
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping.select_next_item(),   -- Выбор следующего элемента автодополнения
        ["<S-Tab>"] = cmp.mapping.select_prev_item(), -- Выбор предыдущего элемента
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Подтверждение выбора
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },  -- Источник автодополнения из LSP
        { name = "luasnip" },   -- Источник автодополнения из сниппетов
        { name = "buffer" },    -- Источник автодополнения из текста буфера
        { name = "path" },      -- Источник автодополнения из путей файлов
    }),
})

-- == Настройка горячих клавиш ==

-- Открытие/закрытие файлового менеджера
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- Компиляция и запуск C/C++ кода
vim.keymap.set("n", "<leader>cc", function()
    vim.cmd("w") -- Сохранить текущий файл
    local result = vim.fn.system("g++ -g -std=c++20 -o a.out " .. vim.fn.expand("%"))
    if vim.v.shell_error == 0 then
        vim.fn.system("./a.out") -- Запуск скомпилированной программы
        print("Compile and run " .. vim.fn.expand("%"))
    else
        print("Compilation failed: " .. result) -- Вывод ошибки компиляции
    end
end, { desc = "Compile and run C/C++" })

-- Компиляция и запуск в терминале
vim.keymap.set("n", "<leader>cr", function()
    vim.cmd("w") -- Сохранить текущий файл
    vim.cmd("term g++ -g -std=c++20 -o a.out % && ./a.out") -- Запуск в терминале
end, { desc = "Compile and run in terminal" })

-- Настройка диагностики
vim.diagnostic.config({
    virtual_text = false, -- Отключить виртуальный текст для диагностики
    signs = true,         -- Показывать знаки в столбце номеров строк
    update_in_insert = false, -- Не обновлять диагностику в режиме вставки
    float = { border = "rounded" }, -- Округлые границы для всплывающих окон
})

-- Привязки клавиш для навигации по диагностике
vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- Привязки клавиш для отладки (DAP)
vim.keymap.set("n", "<F5>", require("dap").continue, { desc = "DAP: Start/Continue" })
vim.keymap.set("n", "<F10>", require("dap").step_over, { desc = "DAP: Step Over" })
vim.keymap.set("n", "<F11>", require("dap").step_into, { desc = "DAP: Step Into" })
vim.keymap.set("n", "<F12>", require("dap").step_out, { desc = "DAP: Step Out" })
vim.keymap.set("n", "<leader>b", require("dap").toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>B", function()
    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP: Set Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dr", require("dap").repl.open, { desc = "DAP: Open REPL" })
vim.keymap.set("n", "<leader>du", require("dapui").toggle, { desc = "DAP: Toggle UI" })
