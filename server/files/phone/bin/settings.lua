---@diagnostic disable: undefined-global, undefined-field

quit = false
while quit == false do
	apps = fs.list("settingData/")
	settings.clear()
	appNames = {}
	for i = 1, table.getn(apps) do
		settings.load("settingData/" .. apps[i])
		table.insert(appNames, settings.get("name"))
	end
	app = getChoice(appNames, "Settings", true, "<")
	if app == "back" then
		going = false
		quit = true
	else
		settings.clear()
		settings.load("settingData/" .. apps[app])
		file = settings.get("file")
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
end

