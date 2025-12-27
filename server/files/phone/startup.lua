version = "1.5.0"
updateVersion = "3.0.0"

settings.clear()
settings.load("data/main")
bgColor = getSetting("bgColor", colors.cyan)
txtColor = getSetting("txtColor", colors.white)
buttonColor = getSetting("buttonColor", colors.blue)

devMode = getSetting("devMode", false)
autoUpdate = getSetting("autoUpdate", true)
notifications = getSetting("notifications", true)

pass = getSetting("pass", false)
passType = getSetting("passType", "none")
settings.save("data/main")

local update = require("/modules/update")
local sha = require("/modules/sha")
local sGui = require("/modules/simpleGui")

if autoUpdate then
	download("update", updateVersion, true)
	if download("os", version, true) then
		os.reboot()
	end
end

settings.load("data/serverData")
--serverAddress = settings.get("address")
servers = settings.get("servers")
settings.clear()

going2 = true
while going2 do
	term.setBackgroundColor(bgColor)
	term.setTextColor(txtColor)
	term.clear()
	write(os.getComputerLabel(), 3)
	ws = http.websocket(servers.main)
	if ws == false then
		term.setCursorPos(1, 1)
		term.write("no service.")
	else
		ws.send(os.getComputerLabel())
		ws.send("close")
	end
	paintutils.drawBox(10, 19, 17, 19, buttonColor)
	write("open", 19)
	term.setCursorPos(1, 20)
	term.write("<")
	term.setBackgroundColor(bgColor)
	going = true
	os.startTimer(0)
	while going do
		event, button, x, y = os.pullEventRaw()
		if (event == "mouse_click" and x == 1 and y == 20) or event == "terminate" then
			term.setBackgroundColor(colors.black)
			term.clear()
			term.setCursorPos(1, 1)
			term.setTextColor(colors.yellow)
			term.write(os.version())
			term.setTextColor(colors.white)
			term.setCursorPos(1, 2)
			print('type "startup" or reboot to exit.')
			return
		elseif event == "mouse_click" then
			if x <= 17 and x >= 10 and y == 19 then
				going = false
			end
		elseif event == "key" then
			if button == 32 or button == 257 then
				going = false
			end
		elseif event == "timer" then
			time = "  " .. textutils.formatTime(os.time())
			term.setCursorPos(27 - #time, 1)
			term.write(time)
			clock = os.startTimer(0.83)
		end
	end
	if enterPass(pass, passType) then
		going2 = false
	end
end
while true do
	apps = fs.list("apps/")
	appNames = {}
	for i = 1, table.getn(apps) do
		settings.load("apps/" .. apps[i])
		table.insert(appNames, settings.get("name"))
	end
	app = getChoice(appNames, "apps:", true)

	settings.clear()
	settings.load("apps/" .. apps[app])
	file = settings.get("file")
	version = settings.get("version")
	id = settings.get("id")
	if autoUpdate then
		settings.clear()
		settings.load("data/mirrors")
		server = settings.get(id)
		download(id, version, false, server)
		settings.clear()
	end
	env = {
		bgColor = bgColor,
		txtColor = txtColor,
		buttonColor = buttonColor,

		autoUpdate = autoUpdate,
		devMode = devMode,
		notifications = notifications,

		write = write,
		getSetting = getSetting,
		enterNum = enterNum,
		getChoice = getChoice,
		download = download,

		pass = pass,
		passType = passType,

		servers = servers,
		serverAddress = servers.main,

		digestStr = digestStr,
		enterPass = enterPass,
		shell = shell,
		require = require,
	}
	os.run(env, file)
	if devMode then
		os.sleep(1)
	end
end
