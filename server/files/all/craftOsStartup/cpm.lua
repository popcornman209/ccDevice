local completion = require("cc.shell.completion")
shell.setCompletionFunction(
	"bin/cpm.lua",
	completion.build({ completion.choice, { "install", "update", "remove", "search", "list" } })
)
-- Ccdevice Package Manager autocompletion
