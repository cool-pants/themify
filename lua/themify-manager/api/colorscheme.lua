local log = require("themify-manager.utils.log")
local config = require("themify.config")

local M = {}

--- Reads and returns the persisted colorscheme as a 'scheme' according to
--- {path} or "themify-theme" file.
---
--- If reading failed, return nil
---
---@param path? string
---@return string|nil
M.get = function(path)
	path = path or config.current.themify_persisted_theme_file

	local file, err = io.open(path, "r")

	if file == nil then
		return nil, log.notify("From colorscheme.get() - Error reading file: \n" .. err, "error")
	end

	local line = file:read()
	file:close()

	return line
end

--- Returns string[] where each item is a theme name
---@param exclude? string[]
---@return string[]
M.installed = function(exclude)
	exclude = exclude or config.current.exclude
	local themes = vim.fn.getcompletion("", "color", true)
	local manually_installed = {}

	---@type string
	for _, theme in pairs(themes) do
		if not vim.tbl_contains(exclude, themes) then
			table.insert(manually_installed, theme)
		end
	end

	return manually_installed
end

--- Writes colorscheme to {path}, return true if write was successful, else
--- false
---
---@param colorscheme string
---@param path? string
---@return boolean
M.save = function(colorscheme, path)
	path = path or config.current.themify_persisted_theme_file
	local file, err = io.open(path, "w+")

	if file == nil then
		return false, log.notify("From colorscheme.save() - Error writing to file: \n" .. err, "error")
	end
	file:write(colorscheme)
	file:close()

	return true
end

return M
