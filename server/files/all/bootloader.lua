local sTui = require("/lib/simpleTui")

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
		sTui.clear("CCDevice Bootloader")
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
				if detail == sTui.binds["back"] then
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
	local bootChoice = sTui.getChoice(bootNames, mountPoints, "CCDevice Bootloader")
	if bootChoice == nil then -- if backspace, settings menu
		local settingOptions = { "defaultBoot", "defaultBootDelay", "wipe drive" }
		local choice = sTui.getChoice(settingOptions, nil, "Settings")
		if choice == 1 then -- if default boot selected
			table.insert(mountPoints, 1, "Custom...")
			choice = sTui.getChoice(mountPoints, nil, "sel defaultBoot")

			if choice == 1 then -- custom...
				local path = tonumber(sTui.input("default boot path:", "enter to continue...", "Settings")) -- get input
				if path ~= nil then
					settings.set("defaultBoot", path)
				end
			else
				settings.set("defaultBoot", mountPoints[choice])
			end
			settings.save("data/bootLoader")
			table.remove(mountPoints, 1)
		elseif choice == 2 then -- if default boot delay selected
			local delay = tonumber(sTui.input("default boot delay:", "enter to continue...", "Settings")) -- get input
			if delay ~= nil then
				settings.set("defaultBootDelay", delay)
				settings.save("data/bootLoader")
			end
		elseif choice == 3 then -- wipe drive selected
			local confirmation = sTui.input('type "wipe drive" to confirm', "enter to continue...", "Settings")
			if confirmation == "wipe drive" then
				for _, file in pairs(fs.list("/")) do
					if file ~= "rom" then
						fs.delete(file)
					end
				end
				sTui.clear("Settings")
				term.setCursorPos(1, 2)
				term.write("drive fully wiped, restarting (3s)")
				os.sleep(3)
				os.reboot()
			end
		end
	else -- boot
		bootFile(mountPoints[bootChoice])
		return
	end
end
