---@diagnostic disable: undefined-global, undefined-field

local completion = require("cc.shell.completion")
shell.setCompletionFunction(
	"bin/apt.lua",
	completion.build({ completion.choice, { "install", "update", "remove", "search", "list" } })
) -- apt autocompletion

