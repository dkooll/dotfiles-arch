return {
  {
    "williamboman/mason.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "b0o/schemastore.nvim",
      "nvim-telescope/telescope.nvim",
      "folke/trouble.nvim",
    },
    config = function()
      local mason = require("mason")
      local mason_tool_installer = require("mason-tool-installer")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local schemastore = require("schemastore")

      local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

      mason.setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })

      mason_tool_installer.setup({
        ensure_installed = {
          "terraform-ls",
          "json-lsp",
          "vim-language-server",
          "lua-language-server",
          "gopls",
          "rust-analyzer",

          "prettier",
          "stylua",
          "tflint",
          "tfsec",
        },
        auto_update = false,
        run_on_start = false,
      })

      -- Auto-install only once on first run
      local install_flag = vim.fn.stdpath("data") .. "/.mason-installed"
      if vim.fn.filereadable(install_flag) == 0 then
        vim.defer_fn(function()
          vim.o.cmdheight = 0
          require("mason-tool-installer").check_install(true)
          vim.fn.writefile({}, install_flag)
        end, 2000)
      end

      -- Load LSP configurations from lsp/ folder
      local lsp_config_path = vim.fn.stdpath("config") .. "/lsp"
      local lsp_servers = {}

      -- Read all .lua files in lsp/ folder
      local lsp_files = vim.fn.glob(lsp_config_path .. "/*.lua", false, true)
      for _, file in ipairs(lsp_files) do
        local server_name = vim.fn.fnamemodify(file, ":t:r")
        local config = dofile(file)

        -- Merge capabilities into config
        config.capabilities = capabilities

        -- Special handling for jsonls to add schemastore
        if server_name == "jsonls" then
          config.settings = config.settings or {}
          config.settings.json = config.settings.json or {}
          config.settings.json.schemas = schemastore.json.schemas()
          config.settings.json.validate = { enable = true }
        end

        -- Configure the LSP server
        vim.lsp.config(server_name, config)
        table.insert(lsp_servers, server_name)
      end

      -- Enable all loaded LSP servers
      vim.lsp.enable(lsp_servers)

      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "if_many",
          header = "",
          prefix = "",
        }
      })

      local signs = {
        Error = "󰊨",
        Warn = "󰝦",
        Hint = "󰈧",
        Info = "󰉉"
      }

      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
    end,
    keys = {
      -- LSP Actions
      { "<leader>la", vim.lsp.buf.code_action,                                                       desc = "Code actions" },
      {
        "<leader>lA",
        function()
          vim.lsp.buf.code_action()
        end,
        mode = "v",
        desc = "Range code actions",
      },
      { "<leader>lf", vim.lsp.buf.format,                                                            desc = "Format code" },
      { "<leader>lr", vim.lsp.buf.rename,                                                            desc = "Rename symbol" },
      { "<leader>ls", vim.lsp.buf.signature_help,                                                    desc = "Signature help" },

      -- Telescope Integration
      { "<leader>lR", "<cmd>Telescope lsp_references<cr>",                                           desc = "Show references (Telescope)" },
      { "<leader>lw", "<cmd>Telescope diagnostics<cr>",                                              desc = "Show diagnostics (Telescope)" },
      { "<leader>lt", [[<Esc><Cmd>lua require('telescope').extensions.refactoring.refactors()<CR>]], desc = "Refactoring options" },

      -- Insert Mode Bindings
      { "<C-h>",      vim.lsp.buf.signature_help,                                                    mode = "i",                           desc = "Signature help" },
    }
  }
}
