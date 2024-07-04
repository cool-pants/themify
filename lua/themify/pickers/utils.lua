local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local telescope_actions = require("telescope.actions")

local config = require("themify.config")

local M = {}

--- Builds a layout for a specific picker based on a preset.
---
--- If layout is nil, use purely the opts passed to the picker
---@param picker "themes" | "live" | "ensured" | "favorites"
M.layout_builder = function(picker)
	local preset = {
		sorting_strategy = "ascending",
		layout_strategy = "vertical",
		layout_config = {},
	}

	preset.layout_config.anchor = "E"
	preset.layout_config.width = 0.15
	preset.layout_config.height = vim.api.nvim_win_get_height(0)
	preset.layout_config.prompt_position = "top"

	return vim.tbl_deep_extend("force", preset, {})
end

---@class Themify.PickerBuilder
---@field picker "themes" | "live"| "ensured"
---@field prompt_title string
---@field finder  table
---@field default_action? function
---@field mappings function

--- Builds a picker
---@param opts Themify.PickerBuilder
M.picker_builder = function(opts)
	local telescope_opts = M.layout_builder(opts.picker)
	opts.default_action = opts.default_action or function() end

	pickers
		.new(telescope_opts, {
			prompt_title = opts.prompt_title,
			finder = finders.new_table(opts.finder),
			sorter = conf.generic_sorter(telescope_opts),
			attach_mappings = function(bufnr, map)
				telescope_actions.select_default:replace(function()
					telescope_actions.close(bufnr)

					opts.default_action(bufnr)
				end)

				opts.mappings(map)

				return true
			end,
		})
		:find()
end

return M
