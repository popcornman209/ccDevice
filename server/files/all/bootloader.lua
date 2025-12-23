---@diagnostic disable: undefined-global, undefined-field

local sUI = require("/modules/simpleui")

local function bootFile(path) -- runs a boot file
	settings.clear()
	if fs.exists(".settings") then
		settings.load(".settings")
	end
	term.clear()
	term.setCursorPos(1, 1)
	shell.run(path)
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
		sUI.Clear("CCDevice Bootloader")
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
	local bootChoice = sUI.GetChoice(bootNames, mountPoints, "CCDevice Bootloader")
	if bootChoice == nil then -- if backspace, settings menu
		local settingOptions = { "defaultBoot", "defaultBootDelay" }
		local choice = sUI.GetChoice(settingOptions, nil, "Settings")
		if choice == 1 then -- if default boot selected
			table.insert(mountPoints, 1, "Custom...")
			choice = sUI.GetChoice(mountPoints, nil, "sel defaultBoot")

			if choice == 1 then -- custom...
				sUI.Clear("Settings")
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
			sUI.Clear("Settings")
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
