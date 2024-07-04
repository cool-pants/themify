local M = {}

---@class Themify.Config
---@field cache_path? string
---@field fallback? string
---@field suppress_messages? boolean
---@field exclude? string[]

---@class Themify.ThemeConf
---@field set_theme function

---@class Themify.InternalConfig
local DEFAULTS = {
	---@type string
	cache_path = vim.fs.normalize(vim.fn.stdpath("data") --[[@as string]]) .. "/themify",
	---@type string
	fallback = "default",
	---@type boolean
	suppress_messages = false,
	---@type string[]
	exclude = {
		"desert",
		"evening",
		"industry",
		"koehler",
		"morning",
		"murphy",
		"pablo",
		"peachpuff",
		"ron",
		"shine",
		"slate",
		"torte",
		"zellner",
		"blue",
		"darkblue",
		"delek",
		"quiet",
		"elflord",
		"habamax",
		"lunaperche",
		"zaibatsu",
		"wildcharm",
		"sorbet",
		"vim",
	},
}

M._DEFAULTS = DEFAULTS

---@class Themify.InternalConfig
M.current = M._DEFAULTS

---@type string
M.current.themify_persisted_theme_file = M.current.cache_path .. "/themify-theme"

---@param user_opts Themify.Config
M.set = function(user_opts)
	M.current = vim.tbl_deep_extend("force", M.current, user_opts)
end

---@param theme string
---@return boolean
M.set_theme = function(theme)
	---@type Themify.ThemeConf|nil
	local theme_conf = M[theme]
	if theme_conf == nil then
		-- Means no specific function to load theme, can be loaded normally
		local ok, _ = pcall(vim.cmd.colorscheme, theme)
		return ok
	end
	return theme_conf.set_theme(theme)
end

M.handle_theme_on_setup = function()
	local cache_path = M.current.cache_path
	local themify_theme_file = M.current.themify_persisted_theme_file
	local fallback = M.current.fallback
	local notify_opts = { title = "Themify.nvim" }

	-- check if cache dir exists, else create it
	if vim.fn.isdirectory(cache_path) == 0 then
		os.execute("mkdir " .. cache_path)
	end

	-- check if file exists to load persisted theme
	local file = io.open(themify_theme_file, "r+")

	if file then
		local theme_name = file:read("*l") -- read first line
		file:close()

		-- if theme does not exist resort to fallback
		if theme_name then
			local ok = M.set_theme(theme_name)

			if not ok then
				file = io.open(themify_theme_file, "w")

				if file then
					ok = M.set_theme(fallback)

					if not ok then
						file:write("default")
						M.set_theme("default")

						vim.notify(
							"The theme " .. theme_name .. " doesn't exist, fell back to " .. fallback,
							3,
							notify_opts
						)
						vim.notify(
							"The theme " .. fallback .. "doesn't exist, fell back to nvim's default theme",
							3,
							notify_opts
						)
						return
					end

					file:write(fallback)
					M.set_theme("default")
					vim.notify(
						"The theme " .. theme_name .. " doesn't exist, fell back to " .. fallback,
						3,
						notify_opts
					)
				end
				return
			end
			return
		end
	end

	-- if file doesn't exist or couldn't be read, create it with fallback theme
	file = io.open(themify_theme_file, "w")
	if file then
		file:write(fallback)
		file:close()
		vim.cmd("colorscheme " .. fallback)
		vim.notify(
			"No 'themify-theme' file was found, so one was created at \n"
				.. themify_theme_file
				.. " with the theme "
				.. fallback
				.. " as a fallback",
			3,
			notify_opts
		)
	end
end

return M
