local binds = {
	["up"] = 265,
	["down"] = 264,
	["enter"] = 257,
	["back"] = 259,
}

---@diagnostic disable-next-line: undefined-field
if os.about ~= nil then -- if using craft os pc emulator
	binds = {
		["up"] = 200,
		["down"] = 208,
		["enter"] = 28,
		["back"] = 14,
	}
end

local resX, resY = term.getSize()

local function clear(text) -- clear screen with title at top and text at bottom
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setCursorPos(1, resY)
	term.write(text)
	paintutils.drawBox(1, 1, resX, 1, colors.gray)
	term.setCursorPos(resX / 2 - 9, 1)
	term.write("CCDevice installer")
	term.setBackgroundColor(colors.black)
end

local function drawChoices(scroll, choices) -- draws a list of items with scrolling
	clear("(up/down/enter): navigate")
	for i = 1 + scroll, math.min(#choices, (resY - 4) + scroll) do
		term.setCursorPos(4, i + 2 - scroll)
		print(choices[i])
	end
end

local function getChoice(choices) -- lets user select an item in a list
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
			cursorPos = math.max(cursorPos - 1, 1) -- clamp cursor pos and move up
			if cursorPos < 1 + scroll then -- scrolling up
				scroll = scroll - 1
				drawChoices(scroll, choices) -- redraw
			end
		elseif key == binds["down"] then
			cursorPos = math.min(cursorPos + 1, #choices) -- clamp cursor pos and move down
			if cursorPos > (resY - 4) + scroll then -- scrolling down
				scroll = scroll + 1
				drawChoices(scroll, choices) -- redraw
			end
		elseif key == binds["enter"] then -- item selected
			going = false
			return cursorPos -- return index
		end
	end
end

local function selectWebsocket() -- select websocket address
	while true do
		local choice = getChoice({ "default server adress", "custom..." })
		local address = nil
		if choice == 2 then -- if "custom..." was selected
			clear("enter to continue.")
			term.setCursorPos(1, 2)
			print("server ip: ")
			address = read() -- read text input
		else
			address = "ws://127.0.0.1:42069/" -- default address
		end

		if address ~= nil then -- if one was set (not sure of a case it wouldnt be, but lua-ls was yelling at me for this)
			local ws = http.websocket(address) -- attempt to connect
			if ws == false then -- if connection failed
				clear("wait 2 seconds...")
				term.setCursorPos(1, 2)
				print("could not connect!") -- display warning
				os.sleep(2) -- wait 2 seconds
			else -- if successful
				ws.send("installer") -- send name
				ws.send("close") --  properly close connection
				ws.close()
				return address
			end
		end
	end
end

local function removeInstall() -- removes install file
	if fs.exists("install.lua") then -- if it exists
		local choice = getChoice({ "remove install file", "keep it" })
		if choice == 1 then -- if remove was selected
			fs.delete("install.lua") -- remove file
		end
		clear("wait 2 seconds.") -- reboot
		term.setCursorPos(1, 2)
		print("restarting...")
		os.sleep(2)
		os.reboot()
	end
end

local dirs = { -- list of directories required for install
	"lib",
}
local programs = {} -- list of programs needed
local libs = { -- list of libraries that need to be downloaded prior to install
	{
		"lib/update",
		"https://raw.githubusercontent.com/popcornman209/ccDevice/refs/heads/main/server/files/all/lib/update",
	},
}

local function install()
	term.clear()
	term.setCursorPos(1, 1)

	for _, dir in pairs(dirs) do -- create needed directories
		fs.makeDir(dir)
	end
	for _, lib in pairs(libs) do -- wget needed libraries
		shell.run("wget", lib[2], lib[1])
	end

	-- get device name
	clear("enter to continue.")
	term.setCursorPos(1, 2)
	print("device name: ")
	os.setComputerLabel(read())

	-- select an address
	local address = selectWebsocket()

	-- set required serverData settings
	settings.clear()
	settings.set("servers", { main = address })
	if choice == 1 then
		settings.set("device", "phone")
	elseif choice == 2 then
		settings.set("device", "computer")
	elseif choice == 3 then
		settings.set("device", "turtle")
	end
	settings.save("data/serverData")

	-- load update library
	local update = require("lib/update")

	-- install needed requirements
	for _, program in pairs(programs) do
		update.download(program[1], "nil", true, nil, program[2])
	end
end

local choice = getChoice({ "phone", "computer", "turtle" })
if choice == 1 then -- if phone was selected
	programs = {
		{ "os" },
		{ "settings" },
		{ "appStore" },
		{ "simpleGui" },
		{ "sha", "all" },
	}
elseif choice == 2 or choice == 3 then
	programs = {
		{ "bootLoader", "all" },
		{ "apt", "all" },
		{ "CraftOS", "all" },
		{ "simpleTui", "all" },
		{ "sha", "all" },
	}

	-- disable booting from disks, boot loader should handle that
	local settingData = '{\n\t[ "shell.allow_disk_startup" ] = false,\n}'
	local file = fs.open(".settings", "w")
	if file ~= nil then
		file.write(settingData)
		file.close()
	end
end

-- run actual install process
install()
removeInstall()
