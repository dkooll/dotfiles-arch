return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    version = false,
    lazy = true,
    keys = {
      { "<leader>sf",       "<cmd>Telescope fd<cr>",                        desc = "Telescope: Find Files" },
      { "<leader>sg",       "<cmd>Telescope live_grep<cr>",                 desc = "Telescope: Live Grep" },
      { "<leader><leader>", "<cmd>Telescope buffers<cr>",                   desc = "Telescope: Buffers" },
      { "<leader>sh",       "<cmd>Telescope help_tags<cr>",                 desc = "Telescope: Help Tags" },
      { "<leader>sH",       "<cmd>Telescope highlights<cr>",                desc = "Telescope: Find HighLight Groups" },
      { "<leader>so",       "<cmd>Telescope oldfiles<cr>",                  desc = "Telescope: Recent Files" },
      { "<leader>sR",       "<cmd>Telescope registers<cr>",                 desc = "Telescope: Registers" },
      { "<leader>sF",       "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Telescope: Current Buffer fuzzy Find" },
      { "<leader>sc",       "<cmd>Telescope commands<cr>",                  desc = "Telescope: Find Commands" },
      { "<leader>su",       "<cmd>Telescope undo<cr>",                      desc = "Telescope: Undo List" },
      { "<leader>sq",       "<cmd>Telescope quickfix<cr>",                  desc = "Telescope: Quickfix" },
      { "<leader>p",        "<cmd>Telescope treesitter<cr>",                desc = "Telescope: Treesitter List Symbols" },
      { "<leader>sm",       "<cmd>Telescope marks<cr>",                     desc = "Telescope: Marks" },
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
      local previewers = require("telescope.previewers")
      local sorters = require("telescope.sorters")
      -- Create a custom entry display for treesitter that shows "symbol/type" format
      local ts_entry_display = function(entry)
        local display = require("telescope.pickers.entry_display")

        -- Create display with name/type separated by "/"
        local displayer = display.create {
          separator = "/",
          items = {
            { width = nil }, -- Symbol name
            { width = nil }, -- Symbol type
          },
        }

        -- Return formatted display with highlighted type
        return displayer {
          entry.text or "",
          { entry.kind or "", "TelescopeBoldType" }
        }
      end

      local new_maker = function(filepath, bufnr, opts)
        opts = opts or {}
        filepath = vim.fn.expand(filepath)

        local file_size = vim.fn.getfsize(filepath)
        if file_size > 50000 then
          return
        end

        previewers.buffer_previewer_maker(filepath, bufnr, opts)
      end

      telescope.setup {
        defaults = {
          theme = 'horizontal',
          previewer = true,
          buffer_previewer_maker = new_maker,
          file_ignore_patterns = {
            "%.git/",
            "%.terraform/",
            "node_modules/",
            "target/",
            "bin/",
            "pkg/",
            "vendor/",
            "%.lock",
            "%.class",
            "__pycache__/",
            "package%-lock.json",
            "%.o$",
            "%.a$",
            "%.out$",
            "%.pdf$",
            "%.mkv$",
            "%.mp4$",
            "%.zip$",
            "%.tar$",
            "%.tar.gz$",
            "%.tar.bz2$",
            "%.rar$",
            "%.7z$",
            "%.jar$",
            "%.war$",
            "%.ear$",
            "%.min.js$",
            "%.min.css$",
            "dist/",
            "build/",
          },
          file_sorter = sorters.get_fuzzy_file,
          generic_sorter = sorters.get_generic_fuzzy_sorter,
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          initial_mode = "insert",
          selection_strategy = "reset",
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!.git/",
          },
          cache_picker = {
            num_pickers = 20,
            limit_entries = 5000,
          },
          mappings = {
            i = {
              ["<esc>"] = actions.close,
              ["<C-u>"] = false,
              ["<C-d>"] = require("telescope.actions").delete_buffer,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
            n = {
              ["<esc>"] = actions.close,
              ["<C-d>"] = require("telescope.actions").delete_buffer,
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
            },
          },
          layout_strategy = 'horizontal',
          layout_config = {
            width = 0.75,
            height = 0.75,
            prompt_position = "top",
            preview_cutoff = 120,
          },
        },

        pickers = {
          marks = {
            theme = "ivy",
            previewer = true,
            layout_config = {
              width = 0.5,
              height = 0.31,
              horizontal = {
                preview_width = 0.6,
              },
            },
            borderchars = {
              preview = { " ", " ", " ", " ", " ", " ", " ", " " },
            },
          },

          commands = {
            theme = "ivy",
            previewer = false,
            layout_config = {
              width = 0.5,
              height = 0.31,
              horizontal = {
                preview_width = 0.6,
              },
            },
          },

          quickfix = {
            theme = "ivy",
            previewer = false,
            layout_config = {
              width = 0.5,
              height = 0.31,
              horizontal = {
                preview_width = 0.6,
              },
            },
          },
          -- quickfixhistory = {
          --   theme = "ivy",
          --   previewer = false,
          --   layout_config = {
          --     width = 0.5,
          --     height = 0.31,
          --     horizontal = {
          --       preview_width = 0.6,
          --     },
          --   },
          -- },
          fd = {
            hidden = true,
            follow = true,
            theme = "ivy",
            find_command = {
              "fd",
              "--type", "f",
              "--hidden",
              "--follow",
              "--exclude", ".git",
              "--exclude", "node_modules",
              "-E", "*.lock",
            },
            previewer = false,
            layout_config = {
              width = 0.5,
              height = 0.31,
              horizontal = {
              },
            },
          },
          git_files = {
            theme = "ivy",
            hidden = true,
            previewer = false,
            show_untracked = true,
            layout_config = {
              width = 0.5,
              height = 0.31,
              horizontal = {
                preview_width = 0.6,
              },
            },
          },
          live_grep = {
            only_sort_text = true,
            previewer = true,
            theme = "ivy",
            layout_config = {
              width = 0.5,
              height = 0.31,
              horizontal = {
                preview_width = 0.6,
              },
            },
            borderchars = {
              preview = { " ", " ", " ", " ", " ", " ", " ", " " },
            },
          },
          oldfiles = {
            theme = "ivy",
            previewer = false,
            path_display = { "smart" },
            layout_config = {
              width = 0.5,
              height = 0.31,
              horizontal = {
                preview_width = 0.6,
              },
            },
          },
          grep_string = {
            theme = "ivy",
            only_sort_text = true,
            previewer = true,
            word_match = "-w",
            layout_config = {
              width = 0.5,
              height = 0.31,
              horizontal = {
                preview_width = 0.6,
              },
            },
          },
          buffers = {
            theme = "ivy",
            previewer = false,
            show_all_buffers = true,
            sort_mru = true,
            mappings = {
              i = {
                ["<c-d>"] = actions.delete_buffer,
              },
            },
            layout_config = {
              width = 0.5,
              height = 0.31,
              horizontal = {
                preview_width = 0.6,
              },
            },
          },
          current_buffer_fuzzy_find = {
            theme = "ivy",
            previewer = false,
            layout_config = {
              prompt_position = "top",
              preview_cutoff = 120,
              width = 0.5,
              height = 0.31
            },
          },
          lsp_references = {
            show_line = false,
            layout_config = {
              horizontal = {
                width = 0.9,
                height = 0.75,
                preview_width = 0.6,
              },
            },
          },
          treesitter = {
            theme = "ivy",
            show_line = false,
            entry_maker = function(entry)
              -- Get the default entry maker
              local make_entry = require("telescope.make_entry")
              local default_maker = make_entry.gen_from_treesitter({})
              local result = default_maker(entry)

              -- Store the original display function for fallback
              local original_display = result.display

              -- Override display function with our custom format
              result.display = function(tbl)
                if tbl.kind then
                  return ts_entry_display(tbl)
                else
                  return original_display(tbl)
                end
              end

              return result
            end,
            layout_config = {
              width = 0.5,
              height = 0.31,
              horizontal = {
                preview_width = 0.6,
              },
            },
            borderchars = {
              preview = { " ", " ", " ", " ", " ", " ", " ", " " },
            },
            symbols = {
              "class",
              "function",
              "method",
              "interface",
              "type",
              "const",
              "variable",
              "property",
              "constructor",
              "module",
              "struct",
              "trait",
              "field"
            }
          }
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          undo = {
            use_delta = true,
            side_by_side = true,
            layout_config = {
              width = 0.5,
              height = 0.31,
              horizontal = {
                preview_width = 0.6,
              },
            },
            theme = "ivy",
            borderchars = {
              preview = { " ", " ", " ", " ", " ", " ", " ", " " },
            },
          },
          ["ui-select"] = {
            require("telescope.themes").get_ivy({
              layout_config = {
                height = 0.31,
                width = 0.5,
              },
              previewer = false,
              initial_mode = "insert",
              attach_mappings = function(prompt_bufnr)
                -- Clear the prompt when opening
                vim.schedule(function()
                  if vim.api.nvim_buf_is_valid(prompt_bufnr) then
                    local prompt = vim.api.nvim_buf_get_lines(prompt_bufnr, 0, 1, false)[1] or ""
                    if prompt:match("^.") then
                      local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
                      picker:reset_prompt("")
                    end
                  end
                end)
                return true
              end
            })
          }
        }
      }

      -- Load critical extensions immediately
      telescope.load_extension('fzf')
      telescope.load_extension('ui-select')
      telescope.load_extension('undo')
    end
  },
}
