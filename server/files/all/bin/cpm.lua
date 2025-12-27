local args = { ... }

settings.clear()
settings.load("data/serverData")

local server = "main"
local servers = settings.get("servers")
local device = settings.get("device")
local forceDevice = false
local ignoreY = false
local package = nil

local current = 1
local skip = false
for arg = 1, #args do
	if skip == false then
		if string.sub(args[arg], 1, 1) == "-" then
			if args[arg] == "-m" or args[arg] == "--mirror" then
				if args[arg + 1] ~= nil then
					server = args[arg + 1]
					skip = true
				else
					error("no mirror given!")
				end
			elseif args[arg] == "-d" or args[arg] == "--device" then
				if args[arg + 1] ~= nil then
					device = args[arg + 1]
					skip = true
					forceDevice = true
				else
					error("no device given!")
				end
			elseif args[arg] == "-y" or args[arg] == "--device" then
				ignoreY = true
			elseif args[arg] == "-h" or args[arg] == "--help" then
				print(
					"--ccDevice Package Manager--\nusage:\ncpm [install/update/remove/list/search/view] [package]\n\ninstall: install new package\nupdate : update package, or whole system\nremove : uninstall a package\nlist   : list installed package\nsearch : search available packages\n\n-h --help  : open this menu\n-m --mirror: change mirror (main is default)\n-d --device: change device\n-y --yes: don't ask for input Y/n"
				)
				return
			end
		else
			if current == 1 then --install/update/remove
				Option = args[arg]
				current = 2
			elseif current == 2 then
				package = args[arg]
				current = 3
			else
				error("could not recognize " .. args[arg])
			end
		end
	else
		skip = false
	end
end

local update = require("/lib/update")

if Option == "install" then
	if package ~= nil then
		local confirmed = ignoreY
		if not confirmed then
			print("install " .. package .. "? [y/n] ")
			if read() == "y" then
				confirmed = true
			end
		end
		if confirmed then
			update.download(package, "nil", true, servers[server], device)
		end
	else
		error("no package given!")
	end
elseif Option == "update" then
	if package == nil then
		local confirmed = ignoreY
		if not confirmed then
			print("update system? [y/n] ")
			if read() == "y" then
				confirmed = true
			end
		end
		if confirmed then
			local files = fs.list("/packages")
			for _, file in pairs(files) do
				settings.clear()
				settings.load("/packages/" .. file)
				local tempDevice = device
				if forceDevice == false and settings.get("device") ~= nil then
					tempDevice = settings.get("device")
				end
				update.download(settings.get("id"), settings.get("version"), true, servers[server], tempDevice)
			end
		end
	else
		if fs.exists("packages/" .. package) then
			local confirmed = ignoreY
			if not confirmed then
				print("update " .. package .. "? [y/n] ")
				if read() == "y" then
					confirmed = true
				end
			end
			if confirmed then
				settings.clear()
				settings.load("/packages/" .. package)
				local tempDevice = device
				if forceDevice == false and settings.get("device") ~= nil then
					tempDevice = settings.get("device")
				end
				update.download(settings.get("id"), settings.get("version"), true, servers[server], tempDevice)
			end
		else
			error(package .. " wasnt found.")
		end
	end
elseif Option == "remove" then
	if package ~= nil then
		if fs.exists("uninstall/" .. package) then
			local confirmed = ignoreY
			if not confirmed then
				print("delete " .. package .. "? [y/n] ")
				if read() == "y" then
					confirmed = true
				end
			end
			if confirmed then
				settings.clear()
				settings.load("uninstall/" .. package)
				local files = settings.get("files")
				for i = 1, #files do
					fs.delete(files[i])
				end
			end
		else
			error(package .. " wasnt found.")
		end
	else
		error("No package given!")
	end
elseif Option == "list" then
	for _, item in pairs(fs.list("/packages")) do
		print(item)
	end
elseif Option == "search" then
	if package == nil then
		package = ""
	end
	local ws = http.websocket(servers[server])
	if ws then
		ws.send(os.getComputerLabel())
		ws.send("store")
		ws.send(device)
		local names = {}
		local ids = {}
		local receiving = true
		while receiving do
			local name = ws.receive()
			if name ~= "complete" and name ~= "goodbye" then
				local id = ws.receive()
				ws.receive()
				table.insert(ids, id)
				table.insert(names, name)
			elseif name == "goodbye" then
				error("failed, wrong device maybe?")
			else
				receiving = false
			end
		end
		for i, name in pairs(names) do
			if string.find(name, package) or string.find(ids[i], package) then
				print(ids[i] .. ": " .. name)
			end
		end
		ws.send("close")
	else
		error("could not connect to server!")
	end
else
	error("no choice given!")
end
