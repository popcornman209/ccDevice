---@diagnostic disable: undefined-global, undefined-field, deprecated

local binds = {
	["up"] = 265,
	["down"] = 264,
	["enter"] = 257,
	["back"] = 259,
}

if os.about ~= nil then -- if using craft os pc emulator
	binds = {
		["up"] = 200,
		["down"] = 208,
		["enter"] = 28,
		["back"] = 14,
	}
end

local resX, resY = term.getSize()

local function clear(text)
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setCursorPos(1, resY)
	term.write(text)
	paintutils.drawBox(1, 1, resX, 1, colors.gray)
	term.setCursorPos(resX / 2 - 9, 1)
	term.write("CCDevice installer")
	term.setBackgroundColor(colors.black)
end

local function drawChoices(scroll, choices)
	clear("(up/down/enter): navigate")
	for i = 1 + scroll, math.min(#choices, (resY - 4) + scroll) do
		term.setCursorPos(4, i + 2 - scroll)
		print(choices[i])
	end
end

local function getChoice(choices)
	local cursorPos = 1
	local scroll = 0
	drawChoices(scroll, choices)
	local going = true
	while going do
		paintutils.drawBox(2, 3, 2, resY - 2)
		term.setCursorPos(2, cursorPos + 2 - scroll)
		print(">")
		local _, key = os.pullEvent("key")
		if key == binds["up"] then
			cursorPos = math.max(cursorPos - 1, 1)
			if cursorPos < 1 + scroll then
				scroll = scroll - 1
				drawChoices(scroll, choices)
			end
		elseif key == binds["down"] then
			cursorPos = math.min(cursorPos + 1, #choices)
			if cursorPos > (resY - 4) + scroll then
				scroll = scroll + 1
				drawChoices(scroll, choices)
			end
		elseif key == binds["enter"] then
			going = false
			return cursorPos
		end
	end
end

local function selectWebsocket()
	while true do
		local choice = getChoice({ "default server adress", "custom..." })
		local address = ""
		if choice == 2 then
			clear("enter to continue.")
			term.setCursorPos(1, 2)
			print("server ip: ")
			address = read()
		else
			address = "ws://127.0.0.1:42069/"
		end

		local ws = http.websocket(address)
		if ws == false then
			clear("wait 2 seconds...")
			term.setCursorPos(1, 2)
			print("could not connect!")
			os.sleep(2)
		else
			ws.send("installer")
			ws.send("close")
			ws.close()
			return address
		end
	end
end

local function removeInstall()
	if fs.exists("install.lua") then
		local choice = getChoice({ "remove install file", "keep it" })
		if choice == 1 then
			fs.delete("install.lua")
			clear("wait 2 seconds.")
			term.setCursorPos(1, 2)
			print("restarting...")
			os.sleep(2)
			os.reboot()
		else
			clear("wait 2 seconds.")
			term.setCursorPos(1, 2)
			print("restarting...")
			os.sleep(2)
			os.reboot()
		end
	end
end

local choice = getChoice({ "phone", "computer" })
if choice == 1 then
	term.clear()
	term.setCursorPos(1, 1)

	local dirs = {
		"modules",
	}
	local programs = {
		"os",
		"settings",
		"appStore",
	}
	local modules = {
		{
			"modules/update",
			"https://raw.githubusercontent.com/popcornman209/ccDevice/refs/heads/main/server/files/all/update",
		},
		{ "modules/sha", "https://pastebin.com/raw/9c1h7812" }, -- CREDIT: https://pastebin.com/9c1h7812 :)
	}

	for i = 1, #dirs do
		fs.makeDir(dirs[i])
	end
	for i = 1, #modules do
		shell.run("wget", modules[i][2], modules[i][1])
	end

	clear("enter to continue.")
	term.setCursorPos(1, 2)
	print("phone name: ")
	os.setComputerLabel(read())

	local address = selectWebsocket()

	settings.clear()
	settings.set("servers", { main = address })
	settings.set("device", "phone")
	settings.save("data/serverData")

	require("modules/update")

	for i = 1, #programs do
		download(programs[i], "nil", true)
	end

	removeInstall()
elseif choice == 2 then
	term.clear()
	term.setCursorPos(1, 1)

	local dirs = {
		"modules",
	}
	local programs = {
		"bootLoader",
		"apt",
		"CraftOS",
	}
	local modules = {
		{
			"modules/update",
			"https://raw.githubusercontent.com/popcornman209/ccDevice/refs/heads/main/server/files/all/update",
		},
		{
			"modules/simpleui",
			"https://raw.githubusercontent.com/popcornman209/ccDevice/refs/heads/main/server/files/all/simpleui",
		},
		{ "modules/sha", "https://pastebin.com/raw/9c1h7812" }, -- CREDIT: https://pastebin.com/9c1h7812 :)
	}

	for i = 1, #dirs do
		fs.makeDir(dirs[i])
	end
	for i = 1, #modules do
		shell.run("wget", modules[i][2], modules[i][1])
	end

	clear("enter to continue.")
	term.setCursorPos(1, 2)
	print("device name: ")
	os.setComputerLabel(read())

	local address = selectWebsocket()

	settings.clear()
	settings.set("servers", { main = address })
	settings.set("device", "computer")
	settings.save("data/serverData")

	require("modules/update")

	for i = 1, #programs do
		download(programs[i], "nil", true, address, "all")
	end

	local settingData = '{\n\t[ "shell.allow_disk_startup" ] = false,\n}'
	local file = fs.open(".settings", "w")
	file.write(settingData)
	file.close()

	removeInstall()
end
