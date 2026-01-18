return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "b0o/schemastore.nvim",
    },
    keys = {
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
      { "<leader>lR", "<cmd>Telescope lsp_references<cr>",                                           desc = "Show references (Telescope)" },
      { "<leader>lw", "<cmd>Telescope diagnostics<cr>",                                              desc = "Show diagnostics (Telescope)" },
      { "<leader>lt", [[<Esc><Cmd>lua require('telescope').extensions.refactoring.refactors()<CR>]], desc = "Refactoring options" },
      { "<C-h>",      vim.lsp.buf.signature_help,                                                    mode = "i",                           desc = "Signature help" },
    },
    config = function()
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local schemastore = require("schemastore")

      local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

      local lsp_config_path = vim.fn.stdpath("config") .. "/lsp"
      local ft_to_lsp = {}
      local lsp_configs = {}

      for _, file in ipairs(vim.fn.glob(lsp_config_path .. "/*.lua", false, true)) do
        local server_name = vim.fn.fnamemodify(file, ":t:r")
        local config = dofile(file)
        lsp_configs[server_name] = config
        for _, ft in ipairs(config.filetypes or {}) do
          ft_to_lsp[ft] = server_name
        end
      end

      local loaded_lsps = {}

      local function load_lsp_for_filetype(ft)
        local server_name = ft_to_lsp[ft]
        if not server_name or loaded_lsps[server_name] then return end

        local config = lsp_configs[server_name]
        if not config then return end

        config.capabilities = capabilities

        -- Special handling for jsonls
        if server_name == "jsonls" then
          config.settings = config.settings or {}
          config.settings.json = config.settings.json or {}
          config.settings.json.schemas = schemastore.json.schemas()
          config.settings.json.validate = { enable = true }
        end

        vim.lsp.config(server_name, config)
        vim.lsp.enable(server_name)
        loaded_lsps[server_name] = true
      end

      -- Load LSP for current buffer
      load_lsp_for_filetype(vim.bo.filetype)

      -- Load LSP when filetype changes
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          load_lsp_for_filetype(args.match)
        end,
      })

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
        },
      })

      local signs = {
        Error = "󰊨",
        Warn = "󰝦",
        Hint = "󰈧",
        Info = "󰉉",
      }

      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
    end,
  },
}
