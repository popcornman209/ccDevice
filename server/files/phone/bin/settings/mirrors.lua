---@diagnostic disable: undefined-global, undefined-field

settings.clear()
settings.load("data/serverData")
servers = settings.get("servers")

going = true
while going do
	serverList = {}
	for key, value in pairs(servers) do
		table.insert(serverList, key)
	end
	choice = getChoice(serverList, "Mirrors:", true, "<", "+")
	if choice == "back" then
		going = false
	elseif choice == "add" then
		term.setBackgroundColor(bgColor)
		term.clear()
		write("mirror name:", 2)
		term.setCursorPos(1, 3)
		name = read()
		term.clear()
		write("mirror address:", 2)
		term.setCursorPos(1, 3)
		address = read()

		servers[name] = address
		settings.set("servers", servers)
		settings.save("data/serverData")
		term.clear()
		write("saved. restart to apply", 2)
		os.sleep(2)
	else
		choice2 = getChoice({ "yes", "no" }, "delete?", true, "<")
		if choice2 == 1 then
			servers[serverList[choice]] = nil
			settings.set("servers", servers)
			settings.save("data/serverData")
			term.setBackgroundColor(bgColor)
			term.clear()
			write("saved. restart to apply", 2)
			os.sleep(1)
		end
	end
end

