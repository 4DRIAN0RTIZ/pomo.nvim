-- /lua/pomo/config.lua
-- Defines the default configuration for the plugin.

local M = {}

M.config = {
	timers = {
		pomodoro = 25 * 60,
		short_break = 5 * 60,
		long_break = 15 * 60,
	},
	stages = {
		seed = "🌱",
		sprout = "🌿",
		tree = "🌳",
	},
	auto_cycle = false,
	long_break_interval = 4,
	dashboard = {
		win = nil,
		buf = nil,
	},
	hooks = {
		on_pomodoro_start = nil,
		on_pomodoro_end = nil,
		on_break_start = nil,
		on_break_end = nil,
	},
}

return M
