-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

if vim.env.SSH_TTY then
	local osc52 = require("vim.ui.clipboard.osc52")

	-- Many terminals don't allow OSC 52 *reads* (or prompt for them),
	-- which makes paste hang, so paste from Neovim's own register instead.
	local function paste()
		return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
	end

	vim.g.clipboard = {
		name = "OSC 52",
		copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
		paste = { ["+"] = paste, ["*"] = paste },
	}
end
