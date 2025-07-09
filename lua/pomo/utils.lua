-- /lua/pomo/utils.lua
-- Helper functions used across the plugin.

local M = {}

local C = require("pomo.config")

function M.ensure_directory(dir)
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end
end

function M.format_time(seconds)
	local minutes = math.floor(seconds / 60)
	local remaining_seconds = seconds % 60
	return string.format("%02d:%02d", minutes, remaining_seconds)
end

function M.notify(msg, title)
  vim.notify(msg, vim.log.levels.INFO, { title = title or "Pomo" })
end

function M.error(msg)
  M.notify(msg, "Error")
end

function M.warn(msg)
  M.notify(msg, "Warning")
end

function M.info(msg)
  M.notify(msg, "Info")
end

function M.debug(msg)
  M.notify(msg, "Debug")
end

function M.trace(msg)
  M.notify(msg, "Trace")
end

function M.error_hook(event, err)
  M.notify("Error running hook '" .. event .. "': " .. err, "Error")

function M.run_hook(event)
	if C.config.hooks[event] and type(C.config.hooks[event]) == "function" then
		local ok, err = pcall(C.config.hooks[event])
		if not ok then
			M.notify("Error running hook '" .. event .. "': " .. err, "Error")
		end
	end
end

return M
