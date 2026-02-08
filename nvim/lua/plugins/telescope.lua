return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    version = false,
    lazy = true,
    keys = {
      { "<leader>sf",       "<cmd>Telescope fd<cr>",                                        desc = "Telescope: Find Files" },
      { "<leader>sg",       "<cmd>Telescope live_grep<cr>",                                 desc = "Telescope: Live Grep" },
      { "<leader><leader>", "<cmd>Telescope buffers<cr>",                                   desc = "Telescope: Buffers" },
      { "<leader>sh",       "<cmd>Telescope help_tags<cr>",                                 desc = "Telescope: Help Tags" },
      { "<leader>sH",       "<cmd>Telescope highlights<cr>",                                desc = "Telescope: Find HighLight Groups" },
      { "<leader>so",       "<cmd>Telescope oldfiles<cr>",                                  desc = "Telescope: Recent Files" },
      { "<leader>sR",       "<cmd>Telescope registers<cr>",                                 desc = "Telescope: Registers" },
      { "<leader>sF",       "<cmd>Telescope current_buffer_fuzzy_find<cr>",                 desc = "Telescope: Current Buffer fuzzy Find" },
      { "<leader>sc",       "<cmd>Telescope commands<cr>",                                  desc = "Telescope: Find Commands" },
      { "<leader>su",       "<cmd>Telescope undo<cr>",                                      desc = "Telescope: Undo List" },
      { "<leader>sq",       "<cmd>Telescope quickfix<cr>",                                  desc = "Telescope: Quickfix" },
      { "<leader>sQ",       function() require("plugins.telescope").quickfix_history() end, desc = "Telescope: Quickfix History" },
      { "<leader>p",        "<cmd>Telescope treesitter<cr>",                                desc = "Telescope: Treesitter List Symbols" },
      { "<leader>sm",       "<cmd>Telescope marks<cr>",                                     desc = "Telescope: Marks" },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'nvim-telescope/telescope-ui-select.nvim',
      'debugloop/telescope-undo.nvim',
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')

      -- Shared configs
      local ivy_layout = { width = 0.5, height = 0.31 }
      local ivy_layout_preview = { width = 0.5, height = 0.31, horizontal = { preview_width = 0.6 } }
      local preview_border = { preview = { " ", " ", " ", " ", " ", " ", " ", " " } }

      local function ivy_picker(opts)
        return vim.tbl_extend("force", { theme = "ivy", previewer = false, layout_config = ivy_layout }, opts or {})
      end

      local function ivy_picker_preview(opts)
        return vim.tbl_extend("force", {
          theme = "ivy",
          previewer = true,
          layout_config = ivy_layout_preview,
          borderchars = preview_border,
        }, opts or {})
      end

      -- Treesitter display
      local ts_displayer = require("telescope.pickers.entry_display").create({
        separator = "/",
        items = { { width = nil }, { width = nil } },
      })

      telescope.setup({
        defaults = {
          buffer_previewer_maker = function(filepath, bufnr, opts)
            filepath = vim.fn.expand(filepath)
            if vim.fn.getfsize(filepath) > 50000 then return end
            opts = opts or {}
            opts.use_ft_detect = true
            local callback = opts.callback
            opts.callback = function(bufnr_cb)
              if callback then callback(bufnr_cb) end
              vim.schedule(function()
                if vim.api.nvim_buf_is_valid(bufnr_cb) then
                  local ft = vim.filetype.match({ buf = bufnr_cb, filename = filepath })
                  if ft then
                    vim.bo[bufnr_cb].filetype = ft
                  end
                end
              end)
            end
            require("telescope.previewers").buffer_previewer_maker(filepath, bufnr, opts)
          end,
          file_ignore_patterns = {
            "%.git/", "%.terraform/", "node_modules/", "target/", "bin/", "pkg/", "vendor/",
            "%.lock", "%.class", "__pycache__/", "package%-lock.json",
            "%.o$", "%.a$", "%.out$", "%.pdf$", "%.mkv$", "%.mp4$",
            "%.zip$", "%.tar$", "%.tar.gz$", "%.tar.bz2$", "%.rar$", "%.7z$",
            "%.jar$", "%.war$", "%.ear$", "%.min.js$", "%.min.css$", "dist/", "build/",
          },
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case", "--hidden", "--glob=!.git/",
          },
          cache_picker = { num_pickers = 20, limit_entries = 5000 },
          mappings = {
            i = {
              ["<esc>"] = actions.close,
              ["<C-u>"] = false,
              ["<C-d>"] = actions.delete_buffer,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
            n = {
              ["<esc>"] = actions.close,
              ["<C-d>"] = actions.delete_buffer,
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
            },
          },
          layout_strategy = 'horizontal',
          layout_config = { width = 0.75, height = 0.75, prompt_position = "top", preview_cutoff = 120 },
        },

        pickers = {
          marks = ivy_picker_preview(),
          commands = ivy_picker(),
          quickfix = ivy_picker(),
          fd = ivy_picker({
            hidden = true,
            follow = true,
            find_command = {
              "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--follow",
              "--exclude", ".git", "--exclude", "node_modules", "-E", "*.lock",
            },
          }),
          git_files = ivy_picker({ hidden = true, show_untracked = true }),
          live_grep = ivy_picker_preview({ only_sort_text = true }),
          oldfiles = ivy_picker({ path_display = { "smart" } }),
          grep_string = ivy_picker_preview({ only_sort_text = true, word_match = "-w" }),
          buffers = ivy_picker({ show_all_buffers = true, sort_mru = true, mappings = { i = { ["<c-d>"] = actions.delete_buffer } } }),
          current_buffer_fuzzy_find = ivy_picker(),
          lsp_references = { show_line = false, layout_config = { horizontal = { width = 0.9, height = 0.75, preview_width = 0.6 } } },
          treesitter = ivy_picker_preview({
            show_line = false,
            symbols = { "class", "function", "method", "interface", "type", "const", "variable", "property", "constructor", "module", "struct", "trait", "field" },
            entry_maker = function(entry)
              local result = require("telescope.make_entry").gen_from_treesitter({})(entry)
              local orig_display = result.display
              result.display = function(tbl)
                if tbl.kind then
                  return ts_displayer({ tbl.text or "", tbl.kind or "" })
                end
                return orig_display(tbl)
              end
              return result
            end,
          }),
        },

        extensions = {
          fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case" },
          undo = vim.tbl_extend("force", ivy_picker_preview(), { use_delta = true, side_by_side = true }),
          ["ui-select"] = {
            require("telescope.themes").get_ivy({
              layout_config = ivy_layout,
              previewer = false,
              initial_mode = "insert",
              attach_mappings = function(prompt_bufnr)
                vim.schedule(function()
                  if vim.api.nvim_buf_is_valid(prompt_bufnr) then
                    local prompt = vim.api.nvim_buf_get_lines(prompt_bufnr, 0, 1, false)[1] or ""
                    if prompt:match("^.") then
                      require("telescope.actions.state").get_current_picker(prompt_bufnr):reset_prompt("")
                    end
                  end
                end)
                return true
              end,
            }),
          },
        },
      })

      telescope.load_extension('fzf')
      telescope.load_extension('ui-select')
      telescope.load_extension('undo')

      -- Quickfix history picker
      local M = {}
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values

      local function ivy_opts(title, previewer)
        return require("telescope.themes").get_ivy({
          prompt_title = title,
          previewer = previewer or false,
          layout_config = { height = 0.31 },
          borderchars = previewer and preview_border or nil,
        })
      end

      local function show_quickfix_entries(qf_nr, on_back)
        local qf_list = vim.fn.getqflist({ nr = qf_nr, items = 1 }).items or {}
        if #qf_list == 0 then
          vim.notify("Quickfix list is empty", vim.log.levels.INFO)
          return
        end

        pickers.new(ivy_opts("Quickfix Entries", true), {
          finder = finders.new_table({
            results = qf_list,
            entry_maker = function(entry)
              local filename = (entry.bufnr and entry.bufnr > 0 and vim.api.nvim_buf_is_valid(entry.bufnr))
                  and vim.api.nvim_buf_get_name(entry.bufnr) or entry.filename or ""
              local lnum, col = entry.lnum or 1, entry.col or 1
              local display = string.format("%s:%d: %s", vim.fn.fnamemodify(filename, ":t"), lnum, entry.text or "")
              return {
                value = entry,
                display = display,
                ordinal = display,
                filename = filename,
                lnum = lnum,
                col = col,
                path =
                    filename
              }
            end,
          }),
          sorter = conf.generic_sorter({}),
          previewer = conf.grep_previewer({}),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              local sel = require("telescope.actions.state").get_selected_entry()
              actions.close(prompt_bufnr)
              if sel and sel.filename ~= "" then
                vim.cmd("edit " .. vim.fn.fnameescape(sel.filename))
                vim.api.nvim_win_set_cursor(0, { sel.lnum, sel.col - 1 })
              end
            end)
            if on_back then
              local go_back = function()
                actions.close(prompt_bufnr); vim.schedule(on_back)
              end
              map("i", "<Esc>", go_back)
              map("n", "<Esc>", go_back)
            end
            return true
          end,
        }):find()
      end

      function M.quickfix_history()
        local total = vim.fn.getqflist({ nr = "$" }).nr or 0
        if total == 0 then
          vim.notify("No quickfix lists available", vim.log.levels.INFO)
          return
        end

        if total == 1 then
          show_quickfix_entries(1, nil)
          return
        end

        local lists = {}
        for i = 1, total do
          local qf = vim.fn.getqflist({ nr = i, title = 1, size = 1 })
          lists[i] = { nr = i, title = qf.title ~= "" and qf.title or ("Quickfix #" .. i), size = qf.size or 0 }
        end

        pickers.new(ivy_opts("Quickfix History"), {
          finder = finders.new_table({
            results = lists,
            entry_maker = function(entry)
              local display = string.format("%s (%d items)", entry.title, entry.size)
              return { value = entry, display = display, ordinal = display, nr = entry.nr }
            end,
          }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              local sel = require("telescope.actions.state").get_selected_entry()
              actions.close(prompt_bufnr)
              if sel then show_quickfix_entries(sel.nr, M.quickfix_history) end
            end)
            return true
          end,
        }):find()
      end

      package.loaded["plugins.telescope"] = M
    end,
  },
}
