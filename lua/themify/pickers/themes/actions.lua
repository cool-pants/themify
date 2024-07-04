local telescope_actions = require("telescope.actions")
local telescope_actions_state = require("telescope.actions.state")
local api = require("themify-manager.api")
local log = require("themify-manager.utils.log")
local config = require("themify.config")

local M = {}

---Preview next theme in the picker
---@param bufnr integer
M.next_theme = function(bufnr)
	telescope_actions.move_selection_next(bufnr)
	local selected = telescope_actions_state.get_selected_entry()
	config.set_theme(selected[1])
end

---Preview previous theme in the picker
---@param bufnr integer
M.prev_theme = function(bufnr)
	telescope_actions.move_selection_previous(bufnr)
	local selected = telescope_actions_state.get_selected_entry()
	config.set_theme(selected[1])
end

-- Saves the selected colorscheme to the cache path
M.save_on_select = function(action_state)
	-- .get_selected_entry could be a nil, so we check for nil before accsessing
	-- value
	local selection = action_state.get_selected_entry()
	if selection == nil then
		log.notify("Must choose valid colorscheme", "error")
		return
	end

	local theme = selection.value
	api.colorscheme.save(theme)
	config.set_theme(theme)
	log.notify("selected " .. theme, "info")
end

return M
