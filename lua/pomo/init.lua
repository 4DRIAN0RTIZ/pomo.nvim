-- /lua/pomo/init.lua
-- Main plugin file, exposes the public API.

local M = {}

local C = require("pomo.config")
local S = require("pomo.state")
local U = require("pomo.utils")
local D = require("pomo.dashboard")
local T = require("pomo.timer")

-- Public API
function M.setup(user_config)
	C.config = vim.tbl_deep_extend("force", C.config, user_config or {})
end

function M.start_pomodoro()
	if S.status.mode ~= "idle" and not S.status.paused then
		U.notify("Ya hay un temporizador en curso.")
		return
	end
	vim.ui.input({ prompt = "Descripción del Pomodoro: " }, function(input)
		if input and input ~= "" then
			T.start_timer("pomodoro", input)
		end
	end)
end

function M.start_short_break()
	if S.status.mode ~= "idle" and not S.status.paused then
		U.notify("Ya hay un temporizador en curso.")
		return
	end
	T.start_timer("short_break")
end

function M.start_long_break()
	if S.status.mode ~= "idle" and not S.status.paused then
		U.notify("Ya hay un temporizador en curso.")
		return
	end
	T.start_timer("long_break")
end

function M.pause_resume_timer()
	if S.status.mode == "idle" then
		U.notify("No hay un temporizador activo para pausar/reanudar.")
		return
	end

	S.status.paused = not S.status.paused

	if S.status.paused then
		U.notify("Temporizador pausado.")
	else
		S.status.end_time = os.time() + S.status.time_left
		U.notify("Temporizador reanudado.")
	end
	S.save_state()
	D.update_dashboard()
end

function M.toggle_auto_cycle()
	C.config.auto_cycle = not C.config.auto_cycle
	U.notify("Ciclo automático " .. (C.config.auto_cycle and "activado." or "desactivado."))
	D.update_dashboard()
end

function M.set_goal(goal)
	local num_goal = tonumber(goal)
	if num_goal and num_goal > 0 then
		S.status.daily_goal = num_goal
		S.save_state()
		U.notify("Objetivo diario establecido en " .. num_goal .. " pomodoros.")
		D.update_dashboard()
	else
		U.notify("Por favor, proporciona un número válido para el objetivo.", "Error")
	end
end

function M.get_lualine_status()
	if S.status.mode == "idle" then
		return ""
	else
		local visual = ""
		if S.status.mode == "pomodoro" then
			local elapsed = C.config.timers.pomodoro - S.status.time_left
			if elapsed < 5 * 60 then
				visual = C.config.stages.seed
			elseif elapsed < 25 * 60 then
				visual = C.config.stages.sprout
			else
				visual = C.config.stages.tree
			end
		end
		local paused_indicator = S.status.paused and " ⏸️" or ""
		local goal_str = string.format("[%d/%d]", S.status.pomodoros_today, S.status.daily_goal)
		return string.format("%s %s (%s) - %s%s", goal_str, visual, U.format_time(S.status.time_left), S.status.description, paused_indicator)
	end
end

function M.view_pomodoros()
	S.load_pomodoros()
	if #S.pomodoros == 0 then
		U.notify("No hay pomodoros registrados.")
		return
	end

	local choices = {}
	for i, p in ipairs(S.pomodoros) do
		table.insert(choices, string.format("%d: %s (%s)", i, p.description or "Sin desc.", os.date("%Y-%m-%d %H:%M", p.timestamp)))
	end

	vim.ui.select(choices, { prompt = "Pomodoros Completados. Selecciona uno para gestionar:", kind = "pomo" }, function(choice)
		if not choice then return end
		local selected_index = tonumber(choice:match("^(%d+):"))
		if not selected_index then return end

		local pomodoro_to_manage = S.pomodoros[selected_index]
		vim.ui.select({ "Eliminar", "Cancelar" }, { prompt = "Qué quieres hacer con: '" .. pomodoro_to_manage.description .. "'?" }, function(action)
			if action == "Eliminar" then
				table.remove(S.pomodoros, selected_index)
				S.save_pomodoros()
				S.update_today_count()
				U.notify("Pomodoro eliminado.")
				D.update_dashboard()
			end
		end)
	end)
end

function M.toggle_dashboard()
	D.toggle_dashboard()
end

-- Initial load
S.load_pomodoros()
S.load_state()
if S.status.mode ~= "idle" and not S.status.paused then
	T.start_timer(S.status.mode, S.status.description, true)
end

return M
