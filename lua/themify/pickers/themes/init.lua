local telescope_action_state = require("telescope.actions.state")

local actions = require("themify.pickers.themes.actions")
local picker_utils = require("themify.pickers.utils")
local mappings = require("themify.pickers.themes.mappings")
local api = require("themify-manager.api")

local function render()
	local themes = api.colorscheme.installed()

	picker_utils.picker_builder({
		picker = "themes",
		prompt_title = "Themify",
		finder = {
			results = themes,
		},
		default_action = function()
			actions.save_on_select(telescope_action_state)
		end,
		mappings = function(map)
			mappings.attach(map, actions)
		end,
	})
end

return {
	render = render,
}
