local config = require("themify.config")
local M = {}

---@param user_opts Themify.Config?
M.setup = function(user_opts)
	-- this ensures that if a user calls setup without explicit config, the default will be used
	if user_opts then
		config.set(user_opts)
	end

	config.handle_theme_on_setup()
	-- -- without scheduling, some vim api calls will not return accurate values
	-- vim.schedule(setup_usercmds)
end

return M
