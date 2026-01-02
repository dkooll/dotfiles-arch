local function call_config(func_name, ...)
  local ok, err = pcall(require("obsidian-config")[func_name], ...)
  if not ok then
    vim.notify("Obsidian error: " .. tostring(err), vim.log.levels.ERROR)
  end
end

return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>onf", function() call_config("create_note", "fleeting", "Fleeting note title: ") end,     desc = "Obsidian: New fleeting note" },
    { "<leader>onl", function() call_config("create_note", "literature", "Literature note title: ") end, desc = "Obsidian: New literature note" },
    { "<leader>onp", function() call_config("create_note", "permanent", "Permanent note title: ") end,   desc = "Obsidian: New permanent note" },
    { "<leader>os",  function() call_config("search_notes") end,                                         desc = "Obsidian: Search notes content" },
    { "<leader>of",  function() call_config("find_notes") end,                                           desc = "Obsidian: Find notes" },
    { "<leader>ob",  function() call_config("show_backlinks") end,                                       desc = "Obsidian: Show backlinks" },
    { "<leader>ol",  function() call_config("show_links") end,                                           desc = "Obsidian: Show links" },
    { "<leader>or",  "<cmd>ObsidianRename<CR>",                                                          desc = "Obsidian: Rename note" },
    { "<leader>ow",  function() call_config("switch_workspace") end,                                     desc = "Obsidian: Switch workspace" },
    { "<leader>ot",  function() call_config("find_tags") end,                                            desc = "Obsidian: Find tags" },
  },

  config = function()
    local themes = require("telescope.themes")
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local entry_display = require("telescope.pickers.entry_display")
    local telescope_config_values = require("telescope.config").values
    local make_entry = require("telescope.make_entry")

    local NOTES_PATH_PATTERN = "obsidian%-notes"
    local CACHE_DURATION = 10
    local WORKSPACES = {
      { name = "tech",    path = "/home/dkooll/workspaces/dkooll/obsidian-notes/tech" },
      { name = "worship", path = "/home/dkooll/workspaces/dkooll/obsidian-notes/worship" },
    }

    local highlights = {
      NotesBrown = { fg = "#9E8069" },
      NotesBrownBold = { fg = "#9E8069", bold = true },
      NotesBrownItalic = { fg = "#9E8069", italic = true },
      NotesPink = { fg = "#D3869B" },
      NotesBlue = { fg = "#7DAEA3" },
      ObsidianParentDir = { fg = "#9E8069" },
      NotesWhiteItalic = { fg = "#C0B8A8", italic = true },
      NotesWhiteItalicDark = { fg = "#968A80", italic = true },
      NotesLightItalic = { fg = "#C0B8A8", italic = true },
      NotesYamlString = { fg = "#968A80", italic = true },
      NotesYamlKey = { fg = "#C0B8A8" },
      ['@markup.raw.block.markdown.markdown'] = { fg = "#968A80", italic = true },
      markdownCodeBlock = { fg = "#968A80", italic = true },
    }
    for name, opts in pairs(highlights) do
      vim.api.nvim_set_hl(0, name, opts)
    end

    local NOTES_HIGHLIGHTS = table.concat({
      "@punctuation.special:NotesBrown",
      "@markup.heading.1.markdown:NotesLightItalic", "@markup.heading.2.markdown:NotesLightItalic",
      "@markup.heading.3.markdown:NotesLightItalic", "@markup.heading.4.markdown:NotesLightItalic",
      "@markup.heading.5.markdown:NotesLightItalic", "@markup.heading.6.markdown:NotesLightItalic",
      "@markup.heading:NotesLightItalic", "markdownCode:NotesWhiteItalic",
      "@markup.raw.markdown_inline:NotesWhiteItalic", "@text.literal.markdown_inline:NotesWhiteItalic",
      "@markup.strong.markdown_inline:NotesLightItalic", "markdownItalic:NotesLightItalic",
      "markdownItalicDelimiter:NotesLightItalic", "@text.emphasis:NotesLightItalic",
      "@text.strong:NotesLightItalic", "@markup.italic.markdown_inline:NotesLightItalic",
      "@markup.bold.markdown_inline:NotesLightItalic", "@markup.link.label:NotesBlue",
      "@markup.link:NotesBlue", "@markup.link.url:NotesBlue", "@text.uri:NotesBlue",
      "@text.reference:NotesBlue", "@keyword.directive:NotesWhiteItalic",
      "@property:NotesYamlKey", "@property.yaml:NotesYamlKey", "@string.yaml:NotesYamlString",
    }, ",")

    vim.g.obsidian_current_workspace = WORKSPACES[1].name
    local cache = { tags = {}, files = {}, timestamp = { tags = 0, files = 0 } }

    local function is_notes_file(filename)
      return filename:match("%.md$") and filename:match(NOTES_PATH_PATTERN)
    end

    local function apply_notes_highlights(winid)
      vim.api.nvim_set_option_value('winhighlight', NOTES_HIGHLIGHTS, { win = winid })
    end

    local function clear_cache()
      cache = { tags = {}, files = {}, timestamp = { tags = 0, files = 0 } }
    end

    local function system_lines(cmd)
      local output = vim.fn.system(cmd)
      if vim.v.shell_error ~= 0 then return {} end
      local lines = {}
      for line in output:gmatch("[^\r\n]+") do
        if line ~= "" then table.insert(lines, line) end
      end
      return lines
    end

    local function validate_input(input, input_type)
      if not input or input == "" then
        vim.notify("Invalid " .. input_type .. ": cannot be empty", vim.log.levels.WARN)
        return false
      end
      if input_type == "filename" and input:match("[<>:\"|?*]") then
        vim.notify("Invalid filename: contains illegal characters", vim.log.levels.WARN)
        return false
      end
      return true
    end

    local function get_workspace()
      local name = vim.g.obsidian_current_workspace or WORKSPACES[1].name
      for _, ws in ipairs(WORKSPACES) do
        if ws.name == name then
          local path = vim.fn.expand(ws.path)
          if vim.fn.isdirectory(path) == 1 then return path end
          vim.notify("Workspace directory does not exist: " .. path, vim.log.levels.ERROR)
          break
        end
      end
      return vim.fn.expand(WORKSPACES[1].path)
    end

    local function telescope_opts(title, opts)
      opts = opts or {}
      return themes.get_ivy({
        prompt_title = title .. " (" .. vim.g.obsidian_current_workspace .. ")",
        cwd = opts.cwd,
        previewer = opts.previewer or false,
        layout_config = { height = 0.31 },
        borderchars = opts.previewer and { preview = { " ", " ", " ", " ", " ", " ", " ", " " } } or nil,
      })
    end

    local file_displayer = entry_display.create({ separator = "/", items = { { width = nil }, { width = nil } } })

    local function make_file_display(file_path, workspace_path)
      local relative = file_path:gsub("^" .. vim.pesc(workspace_path) .. "/", "")
      local folder, filename = vim.fn.fnamemodify(relative, ":h"), vim.fn.fnamemodify(relative, ":t")
      if folder and folder ~= "." then
        return file_displayer({ folder, { filename, "ObsidianParentDir" } })
      end
      return filename
    end

    local function file_entry_maker(workspace_path)
      return function(entry)
        local relative = entry:gsub("^" .. vim.pesc(workspace_path) .. "/", "")
        local folder, filename = vim.fn.fnamemodify(relative, ":h"), vim.fn.fnamemodify(relative, ":t")
        return {
          value = entry,
          path = entry,
          display = make_file_display(entry, workspace_path),
          ordinal = folder ~= "." and (folder .. "/" .. filename) or filename,
        }
      end
    end

    local function simple_picker(title, items, on_select, opts)
      opts = opts or {}
      local workspace_path = opts.is_files and get_workspace() or nil
      pickers.new(telescope_opts(title), {
        finder = finders.new_table({
          results = items,
          entry_maker = opts.is_files and file_entry_maker(workspace_path) or
              function(e) return { value = e, display = e, ordinal = e } end,
        }),
        sorter = telescope_config_values.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local sel = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if sel and on_select then on_select(sel.value) end
          end)
          if opts.mappings then opts.mappings(prompt_bufnr, map) end
          return true
        end,
      }):find()
    end

    local autocmds = vim.api.nvim_create_augroup("ObsidianNotes", { clear = true })

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = autocmds,
      pattern = "*.md",
      callback = function()
        local filename = vim.api.nvim_buf_get_name(0)
        if filename:match(NOTES_PATH_PATTERN) then
          vim.cmd("silent! undojoin")
          local lnum = vim.fn.search("^modified:", "nw")
          if lnum > 0 then
            vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { "modified: " .. os.date("%Y-%m-%d %H:%M") })
          end
        end
      end,
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
      group = autocmds,
      pattern = "*.md",
      callback = function()
        local filename = vim.api.nvim_buf_get_name(0)
        if is_notes_file(filename) then
          local view = vim.fn.winsaveview()
          vim.defer_fn(function()
            vim.cmd("silent! edit")
            vim.fn.winrestview(view)
            vim.cmd("silent! doautocmd BufEnter")
          end, 50)
        end
      end,
    })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufRead", "BufNewFile", "WinEnter" }, {
      group = autocmds,
      pattern = "*",
      callback = function()
        local filename = vim.api.nvim_buf_get_name(0)
        if is_notes_file(filename) then
          vim.opt_local.conceallevel = 2
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          apply_notes_highlights(0)
        elseif filename:match("%.ya?ml$") and not filename:match(NOTES_PATH_PATTERN) then
          vim.wo.winhighlight = ''
        end
      end,
    })

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = autocmds,
      pattern = "*",
      callback = function()
        vim.schedule(function()
          for _, winid in ipairs(vim.api.nvim_list_wins()) do
            local bufnr = vim.api.nvim_win_get_buf(winid)
            local filename = vim.api.nvim_buf_get_name(bufnr)
            if vim.bo[bufnr].filetype == "markdown" and filename:match(NOTES_PATH_PATTERN) then
              apply_notes_highlights(winid)
            end
          end
        end)
      end,
    })

    local obsidian_config = {}

    local function get_tags()
      local now = os.time()
      if cache.tags.data and (now - cache.timestamp.tags) < CACHE_DURATION then return cache.tags.data end
      local ws = get_workspace()
      local cmd = string.format(
        "rg --no-filename --no-line-number -o '(^  - [a-zA-Z0-9_-]+$|#[a-zA-Z0-9_-]+)' '%s' --type md 2>/dev/null", ws)
      local tag_set = {}
      for _, match in ipairs(system_lines(cmd)) do
        local tag = match:match("^  %- (.+)") or match:match("#(.+)")
        if tag and tag ~= "" and #tag <= 50 then tag_set[tag] = true end
      end
      local tags = vim.tbl_keys(tag_set)
      table.sort(tags)
      cache.tags.data, cache.timestamp.tags = tags, now
      return tags
    end

    local function get_files_with_tag(tag)
      if not validate_input(tag, "tag") then return {} end
      local ws = get_workspace()
      local cmd = string.format("rg --files-with-matches '^  - %s$' '%s' --type md 2>/dev/null", vim.fn.shellescape(tag),
        ws)
      local files = {}
      for _, file in ipairs(system_lines(cmd)) do
        if vim.fn.filereadable(file) == 1 then table.insert(files, file) end
      end
      return files
    end

    function obsidian_config.create_note(folder, prompt)
      if not validate_input(folder, "folder") or not validate_input(prompt, "prompt") then return end
      local title = vim.fn.input(prompt)
      if not validate_input(title, "title") then return end

      local workspace = get_workspace()
      local date, time = os.date("%Y-%m-%d"), os.date("%H:%M")
      local safe_title = title:gsub("[^%w%s%-]", ""):gsub("%s+", "-"):lower():sub(1, 50)
      local folder_path = workspace .. "/" .. folder

      if vim.fn.isdirectory(folder_path) == 0 then vim.fn.mkdir(folder_path, "p") end

      local filename = string.format("%s/%s-%s.md", folder_path, date, safe_title)
      local template_path = workspace .. "/templates/" .. folder .. ".md"

      if vim.fn.filereadable(template_path) == 0 then
        vim.notify("Template not found: " .. template_path, vim.log.levels.ERROR)
        return
      end

      local id = os.time() .. "-" .. safe_title
      local content = {}
      for _, line in ipairs(vim.fn.readfile(template_path)) do
        table.insert(content,
          (line:gsub("{{title}}", title):gsub("{{date}}", date):gsub("{{time}}", time):gsub("{{id}}", id):gsub("{{modified}}", date .. " " .. time)))
      end

      vim.fn.writefile(content, filename)
      clear_cache()
      vim.cmd("edit " .. vim.fn.fnameescape(filename))
    end

    function obsidian_config.search_notes()
      local workspace = get_workspace()
      local preview_group = vim.api.nvim_create_augroup("ObsidianSearchNotesPreview", { clear = true })

      local function apply_preview_highlights(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        if not picker or not picker.previewer or not picker.previewer.state then return end
        local winid, bufnr = picker.previewer.state.winid, picker.previewer.state.bufnr
        if winid then
          apply_notes_highlights(winid)
          vim.api.nvim_set_option_value('wrap', true, { win = winid })
          vim.api.nvim_set_option_value('linebreak', true, { win = winid })
          vim.api.nvim_set_option_value('conceallevel', 2, { win = winid })
        end
        if bufnr and vim.api.nvim_buf_is_valid(bufnr) then vim.bo[bufnr].filetype = "markdown" end
      end

      pickers.new(telescope_opts("Search Notes", { cwd = workspace, previewer = true }), {
        finder = finders.new_job(function(prompt)
          if not prompt or prompt == "" then return nil end
          return { "rg", "--with-filename", "--line-number", "--column", "--smart-case", "--max-count", "100", prompt,
            workspace, "--type", "md" }
        end, function(entry)
          local default_entry = make_entry.gen_from_vimgrep({})(entry)
          if default_entry then default_entry.display = make_file_display(default_entry.filename, workspace) end
          return default_entry
        end, 120),
        sorter = telescope_config_values.generic_sorter({}),
        previewer = telescope_config_values.grep_previewer({}),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local sel = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if sel then
              vim.cmd("edit " .. vim.fn.fnameescape(sel.filename))
              if sel.lnum then vim.api.nvim_win_set_cursor(0, { sel.lnum, sel.col - 1 }) end
            end
          end)
          vim.api.nvim_create_autocmd("User", {
            group = preview_group,
            pattern = "TelescopePreviewerLoaded",
            callback = function()
              if vim.api.nvim_buf_is_valid(prompt_bufnr) then apply_preview_highlights(prompt_bufnr) end
            end,
          })
          vim.schedule(function() apply_preview_highlights(prompt_bufnr) end)
          return true
        end,
      }):find()
    end

    function obsidian_config.find_notes()
      local workspace_path = get_workspace()
      local now = os.time()

      local function delete_mapping(prompt_bufnr, map)
        map("i", "<C-d>", function()
          local sel = action_state.get_selected_entry()
          if sel and sel.value then
            os.remove(sel.value)
            cache.files = {}
            local current_line = action_state.get_current_line()
            actions.close(prompt_bufnr)
            vim.schedule(function()
              obsidian_config.find_notes()
              if current_line ~= "" then vim.api.nvim_feedkeys(current_line, "n", false) end
            end)
          end
        end)
      end

      local function show_picker(files)
        simple_picker("Find Notes", files, function(file) vim.cmd("edit " .. vim.fn.fnameescape(file)) end,
          { is_files = true, mappings = delete_mapping })
      end

      if cache.files.data and cache.files.workspace == workspace_path and (now - cache.timestamp.files) < CACHE_DURATION then
        show_picker(cache.files.data)
        return
      end

      vim.schedule(function()
        local cmd = vim.fn.executable('fd') == 1 and string.format("fd -e md -t f . '%s' 2>/dev/null", workspace_path)
            or string.format("rg --files --type md '%s' 2>/dev/null", workspace_path)
        local files = {}
        for _, file in ipairs(system_lines(cmd)) do
          if vim.fn.filereadable(file) == 1 then table.insert(files, file) end
        end
        table.sort(files)
        cache.files = { data = files, workspace = workspace_path }
        cache.timestamp.files = now
        show_picker(files)
      end)
    end

    function obsidian_config.show_backlinks()
      local current_file = vim.api.nvim_buf_get_name(0)
      if not validate_input(current_file, "current file") then return end

      local filename = vim.fn.fnamemodify(current_file, ":t:r")
      local workspace_path = get_workspace()
      local cmd = string.format(
        "rg --with-filename --line-number --max-count 50 '\\[\\[.*%s.*\\]\\]' '%s' --type md 2>/dev/null",
        vim.fn.shellescape(filename), workspace_path)

      vim.schedule(function()
        local results = system_lines(cmd)
        if #results == 0 then
          vim.notify("No backlinks found for " .. filename, vim.log.levels.INFO)
          return
        end
        pickers.new(telescope_opts("Backlinks"), {
          finder = finders.new_table({
            results = results,
            entry_maker = function(entry)
              local file_path, lnum, text = entry:match("^([^:]+):(%d+):(.*)$")
              if not file_path then return end
              return {
                value = entry,
                display = make_file_display(file_path, workspace_path),
                ordinal = file_path,
                filename =
                    file_path,
                lnum = tonumber(lnum),
                text = text
              }
            end,
          }),
          sorter = telescope_config_values.generic_sorter({}),
        }):find()
      end)
    end

    function obsidian_config.show_links()
      local current_file = vim.api.nvim_buf_get_name(0)
      local results = system_lines(string.format("rg --with-filename --line-number '\\[\\[.*\\]\\]' '%s'", current_file))
      if #results == 0 then
        vim.notify("No links found in current file", vim.log.levels.INFO)
        return
      end
      pickers.new(telescope_opts("Links"), {
        finder = finders.new_table({
          results = results,
          entry_maker = function(entry)
            local file_path, lnum, text = entry:match("^([^:]+):(%d+):(.*)$")
            if not file_path then return end
            return {
              value = entry,
              display = text:match("%[%[(.-)%]%]") or text,
              ordinal = text,
              filename = file_path,
              lnum =
                  tonumber(lnum),
              text = text
            }
          end,
        }),
        sorter = telescope_config_values.generic_sorter({}),
      }):find()
    end

    function obsidian_config.find_tags()
      local function show_tags()
        simple_picker("Find Tags", get_tags(), function(tag)
          simple_picker("Files with tag: " .. tag, get_files_with_tag(tag), function(file)
            vim.cmd("edit " .. vim.fn.fnameescape(file))
          end, {
            is_files = true,
            mappings = function(prompt_bufnr, map)
              local back = function()
                actions.close(prompt_bufnr); vim.schedule(show_tags)
              end
              map("i", "<Esc>", back)
              map("n", "<Esc>", back)
            end,
          })
        end)
      end
      show_tags()
    end

    function obsidian_config.switch_workspace()
      local available = vim.tbl_filter(function(ws) return ws.name ~= vim.g.obsidian_current_workspace end, WORKSPACES)
      local names = vim.tbl_map(function(ws) return ws.name end, available)
      if #names == 0 then
        vim.notify("No other workspaces available", vim.log.levels.INFO)
        return
      end
      simple_picker("Switch Workspace", names, function(ws)
        vim.g.obsidian_current_workspace = ws
        clear_cache()
        vim.notify("Switched to " .. ws .. " workspace", vim.log.levels.INFO)
      end)
    end

    package.loaded["obsidian-config"] = obsidian_config

    require("obsidian").setup({
      workspaces = WORKSPACES,
      log_level = vim.log.levels.WARN,
      templates = { subdir = "templates", date_format = "%Y-%m-%d", time_format = "%H:%M" },
      completion = { nvim_cmp = true, min_chars = 2, use_path_only = true },
      mappings = {
        ["gf"] = {
          action = function()
            local cfile = vim.fn.expand('<cfile>')
            if cfile:match('^https?://') or cfile:match('%[%[https?://') then
              local url = cfile:match('https?://[^%]%s]+') or cfile:match('^https?://.*$')
              if url then
                vim.fn.system('open ' .. vim.fn.shellescape(url)); return
              end
            end
            local filename = cfile:match('%[%[([^|%]]+)') or cfile:gsub('%[%[', ''):gsub('%]%]', '')
            local workspace_root = vim.fn.expand('%:p:h:h')
            if filename:match('%.png$') or filename:match('%.jpe?g$') then
              vim.fn.system('open ' .. vim.fn.shellescape(workspace_root .. '/attachments/' .. filename))
              return
            end
            if filename:match('%.ya?ml$') then
              local full_path = workspace_root .. '/configs/' .. filename
              if vim.fn.filereadable(full_path) == 1 then
                vim.cmd('edit ' .. vim.fn.fnameescape(full_path)); return
              end
            end
            return require("obsidian").util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        ["<leader>ch"] = {
          action = function() return require("obsidian").util.toggle_checkbox() end,
          opts = { buffer = true },
        },
      },
      new_notes_location = "current_dir",
      wiki_link_func = function(opts)
        return string.format("[[%s]]", opts.path:match("([^/]+)%.md$") or opts.path)
      end,
      note_id_func = function(title)
        return os.date("%Y-%m-%d") .. "-" .. title:gsub("[^%w%s%-]", ""):gsub("%s+", "-"):lower()
      end,
      sort_by = "modified",
      sort_reversed = true,
      ui = {
        enable = true,
        update_debounce = 200,
        max_file_length = 5000,
        checkboxes = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "", hl_group = "ObsidianDone" },
          [">"] = { char = "", hl_group = "ObsidianRightArrow" },
          ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
        },
        hl_groups = {
          ObsidianTodo = { bold = true, fg = "#9E8069" },
          ObsidianDone = { bold = true, fg = "#9E8069" },
          ObsidianRightArrow = { bold = true, fg = "#9E8069" },
          ObsidianTilde = { bold = true, fg = "#9E8069" },
        },
      },
      attachments = {
        img_folder = "attachments",
        img_text_func = function(client, path)
          path = client:vault_relative_path(path) or path
          return string.format("![%s](%s)", path.name, path)
        end,
      },
    })
  end
}
