-- /lua/pomo/state.lua
-- Manages the plugin's state and data persistence.

local M = {}

local U = require("pomo.utils")

M.pomodoro_dir = vim.fn.stdpath("data") .. "/pomo"
M.pomodoro_log_file = M.pomodoro_dir .. "/pomodoros.json"
M.pomodoro_state_file = M.pomodoro_dir .. "/state.json"

M.status = {
	mode = "idle",
	time_left = 0,
	pomodoros_completed_total = 0,
	pomodoros_today = 0,
	daily_goal = 8,
	description = "",
	paused = false,
}

M.pomodoros = {}

function M.update_today_count()
	local today_str = os.date("%Y-%m-%d")
	local count = 0
	for _, p in ipairs(M.pomodoros) do
		if p.timestamp and os.date("%Y-%m-%d", p.timestamp) == today_str then
			count = count + 1
		end
	end
	M.status.pomodoros_today = count
end

function M.save_pomodoros()
	U.ensure_directory(M.pomodoro_dir)
	local f = io.open(M.pomodoro_log_file, "w")
	if f then
		f:write(vim.fn.json_encode(M.pomodoros))
		f:close()
	end
end

function M.load_pomodoros()
	U.ensure_directory(M.pomodoro_dir)
	if vim.fn.filereadable(M.pomodoro_log_file) == 1 then
		local f = io.open(M.pomodoro_log_file, "r")
		if f then
			local content = f:read("*a")
			f:close()
			if content and content ~= "" then
				local ok, data = pcall(vim.fn.json_decode, content)
				if ok and data then
					M.pomodoros = data
					M.update_today_count()
				end
			end
		end
	end
end

function M.save_state()
	U.ensure_directory(M.pomodoro_dir)
	local f = io.open(M.pomodoro_state_file, "w")
	if f then
		f:write(vim.fn.json_encode(M.status))
		f:close()
	end
end

function M.load_state()
	U.ensure_directory(M.pomodoro_dir)
	if vim.fn.filereadable(M.pomodoro_state_file) == 1 then
		local f = io.open(M.pomodoro_state_file, "r")
		if f then
			local content = f:read("*a")
			f:close()
			if content and content ~= "" then
				local ok, data = pcall(vim.fn.json_decode, content)
				if ok and data then
					M.status = vim.tbl_deep_extend("force", M.status, data)
				end
			end
		end
	end
end

return M
