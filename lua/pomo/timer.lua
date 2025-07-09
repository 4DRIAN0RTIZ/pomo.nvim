-- /lua/pomo/timer.lua
-- The core timer logic for the plugin.

local M = {}

local C = require("pomo.config")
local S = require("pomo.state")
local U = require("pomo.utils")
local D = require("pomo.dashboard")

local function tick()
	if S.status.paused then
		S.save_state()
		D.update_dashboard()
		vim.defer_fn(tick, 1000)
		return
	end

	if S.status.time_left > 0 and S.status.mode ~= "idle" then
		local current_time = os.time()
		S.status.time_left = S.status.end_time - current_time
		if S.status.time_left < 0 then
			S.status.time_left = 0
		end
		S.save_state()
		D.update_dashboard()
		vim.schedule(function()
			vim.cmd("redrawstatus")
		end)
		vim.defer_fn(tick, 1000)
	elseif S.status.mode ~= "idle" then -- Timer finished
		local previous_mode = S.status.mode

		if previous_mode == "pomodoro" then
			S.status.pomodoros_completed_total = S.status.pomodoros_completed_total + 1
			table.insert(S.pomodoros, { description = S.status.description, timestamp = S.status.end_time })
			S.save_pomodoros()
			S.update_today_count()
			U.notify("Pomodoro completed. Good job!")
			U.run_hook("on_pomodoro_end")

			if S.status.pomodoros_today == S.status.daily_goal then
				U.notify("🎉 Congratulations! You have reached your daily goal of " .. S.status.daily_goal .. " pomodoros.", "Goal Achieved")
			end
		else -- A break finished
			U.notify("Break finished. Back to work!")
			U.run_hook("on_break_end")
		end

		if C.config.auto_cycle then
			if previous_mode == "pomodoro" then
				if S.status.pomodoros_today > 0 and S.status.pomodoros_today % C.config.long_break_interval == 0 then
					M.start_timer("long_break", "Automatic long break")
				else
					M.start_timer("short_break", "Automatic short break")
				end
			else -- a break ended
				M.start_timer("pomodoro", "Siguiente Pomodoro")
			end
		else
			S.status.mode = "idle"
			S.status.description = ""
			S.status.time_left = 0
			S.status.end_time = nil
			S.status.paused = false
			S.save_state()
			D.update_dashboard()
		end
	end
end

function M.start_timer(mode, description, resume)
	if not C.config.timers[mode] then
		U.notify("Invalid mode: " .. mode, "Error")
		return
	end

	if not resume then
		S.status.mode = mode
		S.status.time_left = C.config.timers[mode]
		S.status.description = description or ""
		S.status.end_time = os.time() + S.status.time_left
		S.status.paused = false
		U.notify("Starting " .. mode .. " (" .. U.format_time(S.status.time_left) .. ")")
		S.save_state()

		if mode == "pomodoro" then
			U.run_hook("on_pomodoro_start")
		else
			U.run_hook("on_break_start")
		end
	else
		local current_time = os.time()
		S.status.time_left = S.status.end_time - current_time
		if S.status.time_left < 0 then
			S.status.time_left = 0
		end
	end

	tick()
end

return M
