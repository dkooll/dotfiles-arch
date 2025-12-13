local function make_key(key, func_name, desc, param1, param2)
  local action = param1 and function()
    local ok, err = pcall(require("obsidian-config")[func_name], param1, param2)
    if not ok then
      vim.notify("Obsidian error: " .. tostring(err), vim.log.levels.ERROR)
    end
  end or function()
    local ok, err = pcall(require("obsidian-config")[func_name])
    if not ok then
      vim.notify("Obsidian error: " .. tostring(err), vim.log.levels.ERROR)
    end
  end
  return { key, action, desc = "Obsidian: " .. desc }
end

return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    make_key("<leader>onf", "create_note", "New fleeting note", "fleeting", "Fleeting note title: "),
    make_key("<leader>onl", "create_note", "New literature note", "literature", "Literature note title: "),
    make_key("<leader>onp", "create_note", "New permanent note", "permanent", "Permanent note title: "),
    make_key("<leader>os", "search_notes", "Search notes content"),
    make_key("<leader>of", "find_notes", "Find notes"),
    make_key("<leader>ob", "show_backlinks", "Show backlinks"),
    make_key("<leader>ol", "show_links", "Show links"),
    { "<leader>or", "<cmd>ObsidianRename<CR>", desc = "Obsidian: Rename note" },
    make_key("<leader>ow", "switch_workspace", "Switch workspace"),
    make_key("<leader>ot", "find_tags", "Find tags"),
  },

  config = function()
    local NOTES_PATH_PATTERN = "obsidian%-notes"
    local WORKSPACES = {
      { name = "tech",    path = "/home/dev/workspaces/dkooll/obsidian-notes/tech" },
      { name = "worship", path = "/home/dev/workspaces/dkooll/obsidian-notes/worship" },
    }

    local highlights = {
      NotesBrown = { fg = "#9E8069" },
      NotesBrownBold = { fg = "#9E8069", bold = true },
      NotesBrownItalic = { fg = "#9E8069", italic = true },
      NotesPink = { fg = "#D3869B" },
      NotesBlue = { fg = "#7DAEA3" },
      ObsidianParentDir = { fg = "#9E8069", bold = false },
      NotesWhiteItalic = { fg = "#C0B8A8", italic = true },
      NotesWhiteItalicDark = { fg = "#968A80", italic = true },
      NotesLightItalic = { fg = "#C0B8A8", italic = true },
      NotesYamlString = { fg = "#968A80", italic = true },
      NotesYamlKey = { fg = "#C0B8A8", italic = false },
      ['@markup.raw.block.markdown.markdown'] = { fg = "#968A80", italic = true },
      markdownCodeBlock = { fg = "#968A80", italic = true },
    }
    for name, opts in pairs(highlights) do
      vim.api.nvim_set_hl(0, name, opts)
    end

    local NOTES_HIGHLIGHTS =
    '@punctuation.special:NotesBrown,@markup.heading.1.markdown:NotesLightItalic,@markup.heading.2.markdown:NotesLightItalic,@markup.heading.3.markdown:NotesLightItalic,@markup.heading.4.markdown:NotesLightItalic,@markup.heading.5.markdown:NotesLightItalic,@markup.heading.6.markdown:NotesLightItalic,@markup.heading:NotesLightItalic,markdownCode:NotesWhiteItalic,@markup.raw.markdown_inline:NotesWhiteItalic,@text.literal.markdown_inline:NotesWhiteItalic,@markup.strong.markdown_inline:NotesLightItalic,markdownItalic:NotesLightItalic,markdownItalicDelimiter:NotesLightItalic,@text.emphasis:NotesLightItalic,@text.strong:NotesLightItalic,@markup.italic.markdown_inline:NotesLightItalic,@markup.bold.markdown_inline:NotesLightItalic,@markup.link.label:NotesBlue,@markup.link:NotesBlue,@markup.link.url:NotesBlue,@text.uri:NotesBlue,@text.reference:NotesBlue,@keyword.directive:NotesWhiteItalic,@property:NotesYamlKey,@property.yaml:NotesYamlKey,@string.yaml:NotesYamlString'

    local function is_notes_file(filename)
      return vim.bo.filetype == "markdown" and filename:match(NOTES_PATH_PATTERN)
    end

    local autocmds = {
      { "BufWritePre", "*.md", function()
        local filename = vim.api.nvim_buf_get_name(0)
        if filename:match(NOTES_PATH_PATTERN) then
          vim.cmd("undojoin")
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          for i, line in ipairs(lines) do
            if line:match("^modified:") then
              vim.api.nvim_buf_set_lines(0, i - 1, i, false, { "modified: " .. os.date("%Y-%m-%d %H:%M") })
              break
            end
          end
        end
      end },
      { "BufWritePost", "*.md", function()
        local filename = vim.api.nvim_buf_get_name(0)
        if vim.bo.filetype == "markdown" and filename:match(NOTES_PATH_PATTERN) then
          -- Save cursor position and reload to fix highlighting
          local view = vim.fn.winsaveview()
          vim.defer_fn(function()
            vim.cmd("edit")
            vim.fn.winrestview(view)
            -- Re-trigger BufEnter to reinitialize obsidian.nvim state
            vim.cmd("doautocmd BufEnter")
          end, 50)
        end
      end },
      { { "BufEnter", "BufWinEnter" }, "*", function()
        local filename = vim.api.nvim_buf_get_name(0)
        if is_notes_file(filename) then
          vim.opt_local.conceallevel = 2
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.wo.winhighlight = NOTES_HIGHLIGHTS
        end
      end },
      { "BufLeave", "*", function()
        local filename = vim.api.nvim_buf_get_name(0)
        if is_notes_file(filename) then
          vim.wo.winhighlight = ''
        end
      end },
      { { "BufRead", "BufNewFile", "WinEnter", "ColorScheme" }, "*", function()
        vim.schedule(function()
          for _, winid in ipairs(vim.api.nvim_list_wins()) do
            local bufnr = vim.api.nvim_win_get_buf(winid)
            local filename = vim.api.nvim_buf_get_name(bufnr)
            if vim.bo[bufnr].filetype == "markdown" and filename:match(NOTES_PATH_PATTERN) then
              local current_winhighlight = vim.api.nvim_get_option_value('winhighlight', { win = winid })
              if not current_winhighlight:match("NotesBrown") then
                vim.api.nvim_set_option_value('winhighlight', NOTES_HIGHLIGHTS, { win = winid })
              end
            end
          end
        end)
      end },
      { { "BufEnter", "BufWinEnter" }, { "*.yaml", "*.yml" }, function()
        local filename = vim.api.nvim_buf_get_name(0)
        if not filename:match(NOTES_PATH_PATTERN) then
          vim.wo.winhighlight = ''
        end
      end }
    }

    for _, autocmd in ipairs(autocmds) do
      vim.api.nvim_create_autocmd(autocmd[1], { pattern = autocmd[2], callback = autocmd[3] })
    end

    local obsidian_config = {}
    vim.g.obsidian_current_workspace = WORKSPACES[1].name
    local tag_cache, cache_timestamp = {}, 0
    local file_cache, file_cache_timestamp = {}, 0
    local CACHE_DURATION = 10

    local function safe_file_operation(func, error_msg)
      local ok, result = pcall(func)
      if not ok then
        vim.notify(error_msg .. ": " .. tostring(result), vim.log.levels.ERROR)
        return nil
      end
      return result
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
      local workspace_name = vim.g.obsidian_current_workspace
      if not workspace_name then
        vim.notify("No workspace set, using default", vim.log.levels.WARN)
        workspace_name = WORKSPACES[1].name
      end

      for _, workspace in ipairs(WORKSPACES) do
        if workspace.name == workspace_name then
          local expanded_path = vim.fn.expand(workspace.path)
          if vim.fn.isdirectory(expanded_path) == 0 then
            vim.notify("Workspace directory does not exist: " .. expanded_path, vim.log.levels.ERROR)
            return vim.fn.expand(WORKSPACES[1].path)
          end
          return expanded_path
        end
      end
      return vim.fn.expand(WORKSPACES[1].path)
    end

    local function telescope_config(title, cwd)
      return require("telescope.themes").get_ivy({
        prompt_title = title .. " (" .. vim.g.obsidian_current_workspace .. ")",
        cwd = cwd,
        previewer = false,
        layout_config = { height = 0.31 },
      })
    end

    local function make_file_display(file_path, workspace_path)
      local relative_path = file_path:gsub("^" .. vim.pesc(workspace_path) .. "/", "")
      local folder = vim.fn.fnamemodify(relative_path, ":h")
      local filename = vim.fn.fnamemodify(relative_path, ":t")

      if folder and folder ~= "." then
        local entry_display = require("telescope.pickers.entry_display")
        local displayer = entry_display.create {
          separator = "/",
          items = { { width = nil }, { width = nil } },
        }
        return displayer { folder, { filename, "ObsidianParentDir" } }
      end
      return filename
    end

    local function picker(title, items, on_select, is_files, mappings)
      require("telescope.pickers").new(telescope_config(title, nil), {
        finder = require("telescope.finders").new_table({
          results = items,
          entry_maker = function(entry)
            if is_files then
              local workspace_path = get_workspace()
              local relative_path = entry:gsub("^" .. vim.pesc(workspace_path) .. "/", "")
              local folder = vim.fn.fnamemodify(relative_path, ":h")
              local filename = vim.fn.fnamemodify(relative_path, ":t")
              return {
                value = entry,
                display = make_file_display(entry, workspace_path),
                ordinal = folder and folder ~= "." and (folder .. "/" .. filename) or filename,
                path = entry
              }
            else
              return { value = entry, display = entry, ordinal = entry }
            end
          end,
        }),
        sorter = require("telescope.config").values.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          require("telescope.actions").select_default:replace(function()
            local selection = require("telescope.actions.state").get_selected_entry()
            require("telescope.actions").close(prompt_bufnr)
            if selection and on_select then on_select(selection.value) end
          end)
          if mappings then mappings(prompt_bufnr, map) end
          return true
        end,
      }):find()
    end

    local function get_tags()
      local now = os.time()
      if tag_cache.data and (now - cache_timestamp) < CACHE_DURATION then return tag_cache.data end
      local ws = get_workspace()
      if not ws then return {} end
      local tag_set = {}
      local cmd = vim.fn.executable('rg') == 1 and
          string.format(
            "rg --no-filename --no-line-number -o '(^  - [a-zA-Z0-9_-]+$|#[a-zA-Z0-9_-]+)' '%s' --type md 2>/dev/null",
            ws) or
          string.format("grep -r -h -o -E '(^  - [a-zA-Z0-9_-]+$|#[a-zA-Z0-9_-]+)' '%s' --include='*.md' 2>/dev/null", ws)
      local output = safe_file_operation(function() return vim.fn.system(cmd) end, "Failed to search for tags")
      if output and vim.v.shell_error == 0 then
        for match in output:gmatch("[^\r\n]+") do
          local tag = match:match("^  %- (.+)") or match:match("#(.+)")
          if tag and tag ~= "" and tag:len() <= 50 then tag_set[tag] = true end
        end
      end
      local tags = {}
      for tag in pairs(tag_set) do table.insert(tags, tag) end
      table.sort(tags)
      tag_cache.data, cache_timestamp = tags, now
      return tags
    end

    local function get_files_with_tag(tag)
      if not validate_input(tag, "tag") then return {} end

      local ws = get_workspace()
      if not ws then return {} end

      local escaped_tag = vim.fn.shellescape(tag)
      local cmd = vim.fn.executable('rg') == 1 and
          string.format("rg --files-with-matches '^  - %s$' '%s' --type md 2>/dev/null", escaped_tag, ws) or
          string.format("grep -l '^  - %s$' '%s'/*.md '%s'/*/*.md 2>/dev/null", escaped_tag, ws, ws)

      local output = safe_file_operation(function() return vim.fn.system(cmd) end, "Failed to search files with tag")
      local files = {}
      if output and vim.v.shell_error == 0 then
        for file in output:gmatch("[^\r\n]+") do
          if file ~= "" and vim.fn.filereadable(file) == 1 then
            table.insert(files, file)
          end
        end
      end
      return files
    end

    function obsidian_config.create_note(folder, prompt)
      if not validate_input(folder, "folder") or not validate_input(prompt, "prompt") then return end

      local title = vim.fn.input(prompt)
      if not validate_input(title, "title") then return end

      local workspace = get_workspace()
      if not workspace then return end

      local timestamp = os.time()
      local date = os.date("%Y-%m-%d")
      local time = os.date("%H:%M")
      local safe_title = title:gsub("[^%w%s%-]", ""):gsub("%s+", "-"):lower()
      if safe_title:len() > 50 then safe_title = safe_title:sub(1, 50) end

      local folder_path = string.format("%s/%s", workspace, folder)
      if vim.fn.isdirectory(folder_path) == 0 then
        vim.fn.mkdir(folder_path, "p")
      end

      local filename = string.format("%s/%s-%s.md", folder_path, date, safe_title)
      local template_path = string.format("%s/templates/%s.md", workspace, folder)

      if vim.fn.filereadable(template_path) == 0 then
        vim.notify("Template not found: " .. template_path, vim.log.levels.ERROR)
        return
      end

      local template_content = vim.fn.readfile(template_path)
      if not template_content then return end

      local content = {}
      local id = string.format("%s-%s", timestamp, safe_title)

      for _, line in ipairs(template_content) do
        local new_line = line:gsub("{{title}}", title)
            :gsub("{{date}}", date)
            :gsub("{{time}}", time)
            :gsub("{{id}}", id)
            :gsub("{{modified}}", date .. " " .. time)
        table.insert(content, new_line)
      end

      vim.fn.writefile(content, filename)
      file_cache = {}
      file_cache_timestamp = 0
      tag_cache = {}
      cache_timestamp = 0
      vim.cmd("edit " .. vim.fn.fnameescape(filename))
    end

    function obsidian_config.search_notes()
      local workspace = get_workspace()
      if not workspace then return end

      require("telescope.pickers").new(telescope_config("Search Notes", workspace), {
        finder = require("telescope.finders").new_job(function(prompt)
          if not prompt or prompt == "" then return nil end
          return { "rg", "--with-filename", "--line-number", "--column", "--smart-case",
            "--max-count", "100", prompt, workspace, "--type", "md" }
        end, function(entry)
          local make_entry = require("telescope.make_entry")
          local default_entry = make_entry.gen_from_vimgrep({})(entry)
          if not default_entry then return end
          default_entry.display = make_file_display(default_entry.filename, workspace)
          return default_entry
        end, 120),
        sorter = require("telescope.config").values.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
          require("telescope.actions").select_default:replace(function()
            local selection = require("telescope.actions.state").get_selected_entry()
            require("telescope.actions").close(prompt_bufnr)
            if selection then
              vim.cmd("edit " .. vim.fn.fnameescape(selection.filename))
              if selection.lnum then
                vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col - 1 })
              end
            end
          end)
          return true
        end,
      }):find()
    end

    function obsidian_config.find_notes()
      local workspace_path = get_workspace()
      if not workspace_path then return end

      local now = os.time()
      if file_cache.data and file_cache.workspace == workspace_path and (now - file_cache_timestamp) < CACHE_DURATION then
        picker("Find Notes", file_cache.data, function(file)
          vim.cmd("edit " .. vim.fn.fnameescape(file))
        end, true, function(prompt_bufnr, map)
          map("i", "<C-d>", function()
            local selection = require("telescope.actions.state").get_selected_entry()
            if selection and selection.value then
              os.remove(selection.value)
              file_cache = {}
              local current_line = require("telescope.actions.state").get_current_line()
              require("telescope.actions").close(prompt_bufnr)
              vim.schedule(function()
                obsidian_config.find_notes()
                if current_line ~= "" then vim.api.nvim_feedkeys(current_line, "n", false) end
              end)
            end
          end)
        end)
        return
      end

      vim.schedule(function()
        local cmd = vim.fn.executable('fd') == 1 and string.format("fd -e md -t f . '%s' 2>/dev/null", workspace_path) or
            vim.fn.executable('rg') == 1 and string.format("rg --files --type md '%s' 2>/dev/null", workspace_path) or
            string.format("find '%s' -name '*.md' -type f 2>/dev/null", workspace_path)

        local output = safe_file_operation(function() return vim.fn.system(cmd) end, "Failed to find notes")
        local files = {}
        if output and vim.v.shell_error == 0 then
          for file in output:gmatch("[^\r\n]+") do
            if file ~= "" and vim.fn.filereadable(file) == 1 then
              table.insert(files, file)
            end
          end
        end
        table.sort(files)

        file_cache = { data = files, workspace = workspace_path }
        file_cache_timestamp = now

        picker("Find Notes", files, function(file)
          vim.cmd("edit " .. vim.fn.fnameescape(file))
        end, true, function(prompt_bufnr, map)
          map("i", "<C-d>", function()
            local selection = require("telescope.actions.state").get_selected_entry()
            if selection and selection.value then
              os.remove(selection.value)
              file_cache = {}
              local current_line = require("telescope.actions.state").get_current_line()
              require("telescope.actions").close(prompt_bufnr)
              vim.schedule(function()
                obsidian_config.find_notes()
                if current_line ~= "" then vim.api.nvim_feedkeys(current_line, "n", false) end
              end)
            end
          end)
        end)
      end)
    end

    function obsidian_config.show_backlinks()
      local current_file = vim.api.nvim_buf_get_name(0)
      if not validate_input(current_file, "current file") then return end

      local filename = vim.fn.fnamemodify(current_file, ":t:r")
      local workspace_path = get_workspace()
      if not workspace_path then return end

      local escaped_filename = vim.fn.shellescape(filename)
      local cmd = string.format(
        "rg --with-filename --line-number --max-count 50 '\\[\\[.*%s.*\\]\\]' '%s' --type md 2>/dev/null",
        escaped_filename, workspace_path)

      vim.schedule(function()
        local output = safe_file_operation(function() return vim.fn.system(cmd) end, "Failed to search backlinks")
        local results = {}

        if output and vim.v.shell_error == 0 then
          for line in output:gmatch("[^\r\n]+") do
            if line ~= "" then table.insert(results, line) end
          end
        end

        if #results == 0 then
          vim.notify("No backlinks found for " .. filename, vim.log.levels.INFO)
          return
        end

        require("telescope.pickers").new(telescope_config("Backlinks", nil), {
          finder = require("telescope.finders").new_table({
            results = results,
            entry_maker = function(entry)
              local file_path, lnum, text = entry:match("^([^:]+):(%d+):(.*)$")
              if not file_path then return end
              return {
                value = entry,
                display = make_file_display(file_path, workspace_path),
                ordinal = file_path,
                filename = file_path,
                lnum = tonumber(lnum),
                text = text,
              }
            end,
          }),
          sorter = require("telescope.config").values.generic_sorter({}),
        }):find()
      end)
    end

    function obsidian_config.show_links()
      local current_file = vim.api.nvim_buf_get_name(0)
      local cmd = string.format("rg --with-filename --line-number '\\[\\[.*\\]\\]' '%s'", current_file)
      local output = safe_file_operation(function() return vim.fn.system(cmd) end, "Failed to search links")
      local results = {}

      if output and vim.v.shell_error == 0 then
        for line in output:gmatch("[^\r\n]+") do
          if line ~= "" then table.insert(results, line) end
        end
      end

      if #results == 0 then
        vim.notify("No links found in current file", vim.log.levels.INFO)
        return
      end

      require("telescope.pickers").new(telescope_config("Links", nil), {
        finder = require("telescope.finders").new_table({
          results = results,
          entry_maker = function(entry)
            local file_path, lnum, text = entry:match("^([^:]+):(%d+):(.*)$")
            if not file_path then return end
            local link_content = text:match("%[%[(.-)%]%]")
            return {
              value = entry,
              display = link_content or text,
              ordinal = text,
              filename = file_path,
              lnum = tonumber(lnum),
              text = text,
            }
          end,
        }),
        sorter = require("telescope.config").values.generic_sorter({}),
      }):find()
    end

    function obsidian_config.find_tags()
      local function show_tags()
        picker("Find Tags", get_tags(), function(tag)
          picker("Files with tag: " .. tag, get_files_with_tag(tag), function(file)
            vim.cmd("edit " .. vim.fn.fnameescape(file))
          end, true, function(prompt_bufnr, map)
            local back_to_tags = function()
              require("telescope.actions").close(prompt_bufnr)
              vim.schedule(show_tags)
            end
            map("i", "<Esc>", back_to_tags)
            map("n", "<Esc>", back_to_tags)
          end)
        end, false)
      end
      show_tags()
    end

    function obsidian_config.switch_workspace()
      local available = {}
      for _, ws in ipairs(WORKSPACES) do
        if ws.name ~= vim.g.obsidian_current_workspace then
          table.insert(available, ws.name)
        end
      end

      if #available == 0 then
        vim.notify("No other workspaces available", vim.log.levels.INFO)
        return
      end

      picker("Switch Workspace", available, function(ws)
        vim.g.obsidian_current_workspace = ws
        tag_cache = {}
        cache_timestamp = 0
        file_cache = {}
        file_cache_timestamp = 0
        vim.notify("Switched to " .. ws .. " workspace", vim.log.levels.INFO)
      end, false)
    end

    package.loaded["obsidian-config"] = obsidian_config

    require("obsidian").setup({
      workspaces = WORKSPACES,
      templates = { subdir = "templates", date_format = "%Y-%m-%d", time_format = "%H:%M" },
      completion = { nvim_cmp = true, min_chars = 2, use_path_only = true },

      mappings = {
        ["gf"] = {
          action = function()
            local cfile = vim.fn.expand('<cfile>')

            -- Check for URLs first (before stripping brackets)
            if cfile:match('^https?://') or cfile:match('%[%[https?://') then
              local url = cfile:match('https?://[^%]%s]+') or cfile:match('^https?://.*$')
              if url then
                vim.fn.system('open ' .. vim.fn.shellescape(url))
                return
              end
            end

            -- Extract filename from wikilink if present
            local filename = cfile:match('%[%[([^|%]]+)') or cfile:gsub('%[%[', ''):gsub('%]%]', '')

            -- Handle image files - open in system viewer
            if filename:match('%.png$') or filename:match('%.jpe?g$') then
              local full_path = vim.fn.expand('%:p:h:h') .. '/attachments/' .. filename
              vim.fn.system('open ' .. vim.fn.shellescape(full_path))
              return
            end

            -- Handle YAML files from configs directory
            if filename:match('%.ya?ml$') then
              local full_path = vim.fn.expand('%:p:h:h') .. '/configs/' .. filename
              if vim.fn.filereadable(full_path) == 1 then
                vim.cmd('edit ' .. vim.fn.fnameescape(full_path))
                return
              end
            end

            -- For markdown files/wikilinks, let obsidian handle it
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
        local date = os.date("%Y-%m-%d")
        local safe_title = title:gsub("[^%w%s%-]", ""):gsub("%s+", "-"):lower()
        return string.format("%s-%s", date, safe_title)
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
