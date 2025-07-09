# 🍅 pomo.nvim

A simple yet powerful Pomodoro timer for Neovim, designed to keep you focused and productive without leaving your editor.

Inspired by the need to efficiently manage work and rest time, `pomo.nvim` offers an integrated and customizable experience.

## ✨ Features

- **Pomodoro Timer:** Start timers for work sessions (pomodoros), short breaks, and long breaks.
- **Interactive Dashboard:** A floating panel to view the current timer status, your daily progress, and the description of the current task.
- **Auto Cycle:** Configure the plugin to automatically start breaks and pomodoros.
- **Daily Goals:** Set a daily pomodoro goal to track your progress.
- **Notifications:** Receive notifications when starting, pausing, or completing a timer.
- **Customizable:** Adjust timer durations and define hooks to run your own functions on different events.
- **Persistence:** The timer's state is saved and restored between Neovim sessions.
- **Lualine Integration:** Display the timer status directly in your status bar (requires configuration).

## 📋 Requirements

- Neovim >= 0.7.0

## 📦 Installation

You can install `pomo.nvim` using your favorite plugin manager.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "4DRIAN0RTIZ/pomo.nvim",
    config = function()
        require("pomo").setup({
            -- Your configuration here
        })
    end,
},
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    "4DRIAN0RTIZ/pomo.nvim",
    config = function()
        require("pomo").setup({
            -- Your configuration here
        })
    end,
}
```

## 🚀 Usage

### Commands

The plugin exposes several commands to control the timer:

| Command               | Description                                                              |
| --------------------- | ------------------------------------------------------------------------ |
| `:Pomo`               | Shows/hides the timer dashboard.                                         |
| `:PomoStart`          | Starts a new pomodoro. It will prompt for a task description.            |
| `:PomoPause`          | Pauses or resumes the current timer.                                     |
| `:PomoShortBreak`     | Starts a short break.                                                    |
| `:PomoLongBreak`      | Starts a long break.                                                     |
| `:PomoView`           | Shows a list of today's completed pomodoros to manage them.              |
| `:PomoSetGoal <num>`  | Sets your daily pomodoro goal. E.g., `:PomoSetGoal 8`.                   |
| `:PomoToggleAutoCycle`| Enables or disables the automatic cycle of pomodoros and breaks.         |

### Suggested Mappings

You can map the commands to keybindings for quicker access:

```lua
-- Start a pomodoro
vim.keymap.set("n", "<leader>ps", "<cmd>PomoStart<cr>", { desc = "Pomo: Start Pomodoro" })
-- Pause/Resume
vim.keymap.set("n", "<leader>pp", "<cmd>PomoPause<cr>", { desc = "Pomo: Pause/Resume" })
-- Show/Hide the dashboard
vim.keymap.set("n", "<leader>pd", "<cmd>Pomo<cr>", { desc = "Pomo: Show Dashboard" })
```

## ⚙️ Configuration

You can customize the plugin by passing a table to the `setup()` function.

Here are the default values:

```lua
require("pomo").setup({
    timers = {
        pomodoro = 25 * 60,      -- Duration of a pomodoro in seconds (25 minutes)
        short_break = 5 * 60,    -- Duration of a short break (5 minutes)
        long_break = 15 * 60,    -- Duration of a long break (15 minutes)
    },
    stages = {
        seed = "🌱",             -- Icon for the beginning of the pomodoro
        sprout = "🌿",           -- Icon for the middle of the pomodoro
        tree = "🌳",             -- Icon for the end of the pomodoro
    },
    auto_cycle = false,          -- Automatically start the next cycle
    long_break_interval = 4,     -- Number of pomodoros before a long break
    hooks = {
        on_pomodoro_start = nil, -- Function to run when a pomodoro starts
        on_pomodoro_end = nil,   -- Function to run when a pomodoro ends
        on_break_start = nil,    -- Function to run when a break starts
        on_break_end = nil,      -- Function to run when a break ends
    },
})
```

### Lualine Integration

To display the timer status in [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim), add a component that calls the `get_lualine_status` function:

```lua
-- Example lualine configuration
require('lualine').setup {
  options = {
    -- ... your other options
  },
  sections = {
    lualine_a = {'mode'},
    -- ...
    lualine_x = {
      {
        require("pomo").get_lualine_status,
        cond = function()
          -- Optional: only show if a timer is active
          return require("pomo").get_lualine_status() ~= ""
        end,
      },
      'encoding',
      'fileformat',
      'filetype'
    },
    -- ...
  }
}
```

## ❤️ Contributing

Contributions are welcome. If you have ideas, suggestions, or find a bug, please open an [issue](https://github.com/4DRIAN0RTIZ/pomo.nvim/issues) or submit a [pull request](https://github.com/4DRIAN0RTIZ/pomo.nvim/pulls).

## 📜 License

This project is licensed under the MIT License.

---

Made with ❤️ by [Adrián Ortiz](https://github.com/4DRIAN0RTIZ).
