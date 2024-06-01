local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local config = require("telescope.config").values
local log = require("plenary.log"):new()
log.level = "debug"

local M = {}

M.reload_config = function()
	M.themes = M.load_themes()
end

local exists = function(file)
	local ok, _, code = os.rename(file, file)
	if not ok then
		if code == 13 then
			-- Permission denied but exists
			return true
		end
	end
	return ok
end

---@param opts table
M.setup = function(opts)
	M.modDir = opts["modDir"] or os.getenv("HOME") .. "/.config/nvim/lua/theming/"
	M.themesModPath = opts["themesModPath"] or "theming."
	M.themesPath = opts["themesPath"] or M.modDir
	local filePath = M.modDir .. "current.th"
	M.cachePath = opts["cachePath"] or filePath
	if not exists(M.cachePath) then
		log.debug("Creating dirs and files " .. M.cachePath)
		local dir = vim.split(M.cachePath, "/")
		dir = vim.list_slice(dir, 0, #dir - 1)
		local ok, err, code = os.execute("mkdir " .. vim.fn.join(dir, "/"))
		log.debug(err)
		log.debug(code)
		ok, err, code = os.execute("touch " .. M.cachePath)
		log.debug(err)
		log.debug(code)
	end
	M.current_theme = opts["defaultTheme"] or "habamax"
	M.themes = M.load_themes()
	log.debug("all themes\n" .. vim.inspect(M.themes))
	return M
end

---@param theme table
---@param style string | nil
---@param transparency boolean
M.activate_theme = function(theme, name, style, transparency)
	if theme then
		if style then
			theme.activate(style, transparency)
		else
			theme.activate()
		end
	else
		vim.cmd.colorscheme(name)
	end
end

M.get_current_theme = function()
	local file = io.open(M.cachePath, "rb")
	if file then
		io.input(file)
		local theme = io.read()
		if theme == nil or theme == "" then
			M.set_theme(M.current_theme)
			return
		end
		M.current_theme = theme
		local themeSettings = vim.split(theme, "-")
		M.activate_theme(M.themes[themeSettings[1]], themeSettings[1], themeSettings[2], false)
		io.close(file)
	else
		vim.notify("File not found", 4)
	end
end

---@param themestring string
M.set_theme = function(themestring)
	local file = io.open(M.cachePath, "wb")
	if file then
		file:write(themestring)
		local themeSettings = vim.split(themestring, "-")
		M.current_theme = themestring
		M.activate_theme(M.themes[themeSettings[1]], themeSettings[1], themeSettings[2], false)
	else
		vim.notify("File not found", 4)
	end
	io.close(file)
end

---@return table
M.get_all_themes = function()
	return M.themes
end

M.load_themes = function()
	local themes = {}
	local themes_path = M.themesPath
	local files = vim.fn.readdir(themes_path, function(name)
		return string.match(name, "%a*.lua$") ~= nil
	end)
	log.debug(vim.inspect(files))

	for _, file in ipairs(files) do
		local theme_name = file:match("(.+)%..+$")
		log.debug(M.themesModPath .. theme_name)
		local ok, theme = pcall(require, M.themesModPath .. theme_name)
		if ok then
			themes[theme_name] = theme
		else
			vim.notify("Error loading theme: " .. theme_name, vim.log.levels.ERROR)
		end
	end

	return themes
end

local function get_entries(theme_entries)
	log.debug(vim.inspect(theme_entries))
	local entries = {}
	for theme_name, theme in pairs(theme_entries) do
		for _, style in pairs(theme.style) do
			table.insert(entries, {
				theme_name,
				style,
				theme.transparent,
			})
		end
	end

	return entries
end

M.select_theme_telescope = function(opts)
	pickers
		.new(opts, {
			finder = finders.new_table({
				results = get_entries(M.themes or M.get_all_themes()),
				entry_maker = function(entry)
					local name = entry[1] .. " - " .. entry[2]
					if (entry[1] .. "-" .. entry[2]) == M.current_theme then
						name = "* " .. name
					end
					return {
						value = entry[1] .. "-" .. entry[2],
						display = name,
						ordinal = name,
					}
				end,
			}),
			sorter = config.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					M.set_theme(action_state.get_selected_entry().value)
				end)
				return true
			end,
		})
		:find()
end

return M
