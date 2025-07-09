-- /plugin/pomo.lua
-- This file is loaded by Neovim to set up the plugin and its commands.

local pomo = require("pomo")

-- Expose the setup function for users
_G.pomo = pomo

local commands = {
	Pomo = pomo.toggle_dashboard,
	PomoToggleAutoCycle = pomo.toggle_auto_cycle,
	PomoStart = pomo.start_pomodoro,
	PomoPause = pomo.pause_resume_timer,
	PomoShortBreak = pomo.start_short_break,
	PomoLongBreak = pomo.start_long_break,
	PomoView = pomo.view_pomodoros,
}

for name, func in pairs(commands) do
	vim.api.nvim_create_user_command(name, func, {})
end

vim.api.nvim_create_user_command("PomoSetGoal", function(opts)
	pomo.set_goal(opts.args)
end, { nargs = 1 })
