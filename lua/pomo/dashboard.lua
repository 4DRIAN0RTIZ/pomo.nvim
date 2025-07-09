-- /lua/pomo/dashboard.lua
-- Handles the interactive dashboard window.

local M = {}

local C = require("pomo.config")
local S = require("pomo.state")
local U = require("pomo.utils")

function M.update_dashboard()
	if not C.config.dashboard.win or not vim.api.nvim_win_is_valid(C.config.dashboard.win) then
		return
	end

	local lines = {
		"╔══════════════════════════════╗",
		"║       🍅 Pomo Dashboard      ║",
		"╟──────────────────────────────╢",
		string.format("║ Status: %-20s ║", S.status.mode .. (S.status.paused and " (Paused)" or "")),
		string.format("║ Time:   %-20s ║", U.format_time(S.status.time_left)),
		string.format("║ Desc:   %-20.20s ║", S.status.description),
		"╟──────────────────────────────╢",
		string.format("║ Goal: %-3d / %-3d  Total: %-5d║", S.status.pomodoros_today, S.status.daily_goal, #S.pomodoros),
		string.format("║ Auto-cycle: %-16s ║", C.config.auto_cycle and "On" or "Off"),
		"╚══════════════════════════════╝",
		"  [s] Start   [p] Pause/Resume",
		"  [b] Break   [l] Long Break",
		"  [a] Auto-cycle  [q] Close",
	}

	vim.api.nvim_buf_set_lines(C.config.dashboard.buf, 0, -1, false, lines)
end

function M.toggle_dashboard()
	if C.config.dashboard.win and vim.api.nvim_win_is_valid(C.config.dashboard.win) then
		vim.api.nvim_win_close(C.config.dashboard.win, true)
		C.config.dashboard.win = nil
		C.config.dashboard.buf = nil
		return
	end

	local width = 32
	local height = 13
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	C.config.dashboard.buf = vim.api.nvim_create_buf(false, true)
	C.config.dashboard.win = vim.api.nvim_open_win(C.config.dashboard.buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "none",
	})

	vim.api.nvim_buf_set_option(C.config.dashboard.buf, "filetype", "pomo_dashboard")
	vim.api.nvim_buf_set_keymap(C.config.dashboard.buf, "n", "q", "<cmd>q<cr>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(C.config.dashboard.buf, "n", "s", "<cmd>PomoStart<cr>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(C.config.dashboard.buf, "n", "p", "<cmd>PomoPause<cr>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(C.config.dashboard.buf, "n", "b", "<cmd>PomoShortBreak<cr>",
		{ noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(C.config.dashboard.buf, "n", "l", "<cmd>PomoLongBreak<cr>",
		{ noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(C.config.dashboard.buf, "n", "a", "<cmd>PomoToggleAutoCycle<cr>",
		{ noremap = true, silent = true })

	M.update_dashboard()
end

return M
