---@diagnostic disable: undefined-global, undefined-field

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

local function bootFile(path) -- runs a boot file
	settings.clear()
	if fs.exists(".settings") then
		settings.load(".settings")
	end
	term.clear()
	term.setCursorPos(1, 1)
	shell.run(path)
end

local resX, resY = term.getSize()
local function clear(title) -- clear screen function, draws bars
	term.setBackgroundColor(colors.black)
	term.clear()
	paintutils.drawBox(1, 1, resX, 1, colors.gray)
	term.setCursorPos(resX / 2 - #title / 2, 1)
	term.write(title)
	term.setCursorPos(1, resY)
	term.setBackgroundColor(colors.black)
	term.write("(up/down/enter/backspace): navigate")
end

local function drawChoices(choices, choiceDetails, scroll, title) -- draws a list of choices, bout it
	clear(title)
	for i = 1 + scroll, math.min(#choices, (resY - 4) + scroll) do
		term.setCursorPos(4, i + 2 - scroll)
		print(choices[i])
		if choiceDetails ~= nil then
			term.setCursorPos(resX / 2, i + 2 - scroll)
			print(choiceDetails[i])
		end
	end
end

local function getChoice(choices, choiceDetails, title) -- gets user inputs and lets you select different choices
	local cursorPos = 1
	local scroll = 0
	drawChoices(choices, choiceDetails, scroll, title)
	while true do
		paintutils.drawBox(2, 3, 2, resY - 2)
		term.setCursorPos(2, cursorPos + 2 - scroll)
		print(">")
		local _, key = os.pullEvent("key")
		if key == binds["up"] then
			cursorPos = math.max(cursorPos - 1, 1)
			if cursorPos < 1 + scroll then
				scroll = scroll - 1
				drawChoices(choices, choiceDetails, scroll, title)
			end
		elseif key == binds["down"] then
			cursorPos = math.min(cursorPos + 1, #choices)
			if cursorPos > (resY - 4) + scroll then
				scroll = scroll + 1
				drawChoices(choices, choiceDetails, scroll, title)
			end
		elseif key == binds["enter"] then
			return cursorPos
		elseif key == binds["back"] then
			return nil
		end
	end
end

settings.clear()
if fs.exists("data/bootLoader") then -- if settings file exists
	settings.load("data/bootLoader")
else -- if it doesnt make a defualt one
	settings.set("defaultBoot", "")
	settings.set("defaultBootDelay", 5)
	settings.save("data/bootLoader")
end

if settings.get("defaultBoot") ~= "" then -- if default boot setting
	if fs.exists(settings.get("defaultBoot")) then -- check if valid
		clear("CCDevice Bootloader")
		term.setCursorPos(2, 3)
		term.write("booting " .. settings.get("defaultBoot") .. " in " .. settings.get("defaultBootDelay") .. "s")
		term.setCursorPos(2, 4)
		term.write("press backspace to cancel")
		os.startTimer(settings.get("defaultBootDelay"))
		while true do
			local event, detail = os.pullEventRaw()
			if event == "timer" then
				bootFile(settings.get("defaultBoot"))
				return
			elseif event == "key" then
				if detail == binds["back"] then
					break
				end
			end
		end
	end
end

local drives = {}
if fs.exists("boot") then
	drives = { "boot" }
end

local peripherals = peripheral.getNames() -- peripherals
for i = 1, #peripherals do
	if peripheral.getType(peripherals[i]) == "drive" then -- if its a drive
		table.insert(drives, disk.getMountPath(peripherals[i])) -- add it as a valid mount point
	end
end

local mountPoints = {} -- path to file
local bootNames = {} -- name of the boot files
for drive = 1, #drives do
	local mounts = fs.list(drives[drive]) -- list of files in the drive
	for mount = 1, #mounts do
		table.insert(mountPoints, drives[drive] .. "/" .. mounts[mount])
		table.insert(bootNames, mounts[mount])
	end
end

while true do
	local bootChoice = getChoice(bootNames, mountPoints, "CCDevice Bootloader")
	if bootChoice == nil then -- if backspace, settings menu
		local settingOptions = { "defaultBoot", "defaultBootDelay" }
		local choice = getChoice(settingOptions, nil, "Settings")
		if choice == 1 then -- if default boot selected
			table.insert(mountPoints, 1, "Custom...")
			choice = getChoice(mountPoints, nil, "sel defaultBoot")

			if choice == 1 then -- custom...
				clear("Settings")
				term.setCursorPos(1, 2)
				term.write("default boot path:")
				term.setCursorPos(1, 3)
				settings.set("defaultBoot", read())
			else
				settings.set("defaultBoot", mountPoints[choice])
			end
			settings.save("data/bootLoader")
			table.remove(mountPoints, 1)
		elseif choice == 2 then -- if default boot delay selected
			clear("Settings")
			term.setCursorPos(1, 2)
			term.write("default boot delay:")
			term.setCursorPos(1, 3)
			settings.set("defaultBootDelay", tonumber(read()))
			settings.save("data/bootLoader")
		end
	else -- boot
		bootFile(mountPoints[bootChoice])
		return
	end
end

