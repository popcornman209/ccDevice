function getSetting(name, defVal)
    out = settings.get(name)
    if out == nil then
        out = defVal
        settings.set(name,defVal)
    end
    return out
end

version = "1.4.4"
updateVersion = "3.0.0"

settings.clear()
settings.load("data/main")
bgColor = getSetting("bgColor",colors.cyan)
txtColor = getSetting("txtColor",colors.white)
buttonColor = getSetting("buttonColor",colors.blue)

devMode = getSetting("devMode",false)
autoUpdate = getSetting("autoUpdate",true)
notifications = getSetting("notifications",true)

pass = getSetting("pass",false)
passType = getSetting("passType","none")
settings.save("data/main")

require("/modules/update")
require("/modules/sha")

if autoUpdate then
    download("update",updateVersion,true)
    if download("os",version,true) then os.reboot() end
end

function write(text, y)
    if #text <= 26 then
        term.setCursorPos(14-#text/2, y)
        term.write(text)
    else
        current = text
        for i = 0,math.ceil(#text/26)-1 do
            temp = string.sub(current,i*26+1, math.min(26,#current)+i*26)
            term.setCursorPos(14-#temp/2, y+i)
            term.write(temp)
        end
    end
end

function enterPass(pass,passType)
    if passType == "pin" then
        input = enterNum("enter pin:",true,false)
        if digestStr(input) == pass then return true
        else return false end
    elseif passType == "pass" then
        term.setBackgroundColor(bgColor)
        term.clear()
        write("enter pass:",2)
        term.setCursorPos(1,3)
        if digestStr(read("*")) == pass then return true
        else return false end
    elseif passType == "none" then return true end
end

function enterNum(text, blur, decimal)
    term.setBackgroundColor(bgColor)
    term.setTextColor(txtColor)
    term.clear()
    write(text,3)
    term.setBackgroundColor(buttonColor)

    term.setCursorPos(11, 6)
    term.write("1")
    term.setCursorPos(13, 6)
    term.write("2")
    term.setCursorPos(15, 6)
    term.write("3")
    term.setCursorPos(11, 8)
    term.write("4")
    term.setCursorPos(13, 8)
    term.write("5")
    term.setCursorPos(15, 8)
    term.write("6")
    term.setCursorPos(11, 10)
    term.write("7")
    term.setCursorPos(13, 10)
    term.write("8")
    term.setCursorPos(15, 10)
    term.write("9")
    term.setCursorPos(13, 12)
    term.write("0")
    if decimal then 
        term.setCursorPos(11, 12)
        term.write(".")
    end

    term.setBackgroundColor(colors.red)
    if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
    term.setCursorPos(17, 6)
    term.write("<-")
    term.setBackgroundColor(colors.lime)
    if bgColor == colors.lime then term.setBackgroundColor(colors.green) end
    term.setCursorPos(15, 12)
    term.write(">")

    input = ""
    term.setBackgroundColor(bgColor)
    going = true
    while going do
        paintutils.drawBox(1,4,26,4,bgColor)
        term.setCursorPos(14-string.len(input)/2, 4)
        if blur then for i = 1,string.len(input) do term.write("*") end
        else term.write(input) end
        event, button, x, y = os.pullEventRaw()
        if event == "mouse_click" then
            if x == 11 and y == 6 then input = input..1
            elseif x == 13 and y == 6 then input = input..2
            elseif x == 15 and y == 6 then input = input..3
            elseif x == 11 and y == 8 then input = input..4
            elseif x == 13 and y == 8 then input = input..5
            elseif x == 15 and y == 8 then input = input..6
            elseif x == 11 and y == 10 then input = input..7
            elseif x == 13 and y == 10 then input = input..8
            elseif x == 15 and y == 10 then input = input..9
            elseif x == 11 and y == 12 and decimal then input = input.."."
            elseif x == 13 and y == 12 then input = input..0
            elseif x == 15 and y == 12 then going = false
            elseif (x == 17 or x == 18) and y == 6 then input = input:sub(1,-2) end
        elseif event == "key" then
            if button == 257 then going = false
            elseif button == 259 then input = input:sub(1,-2)
            elseif button >= 48 and button <= 57 then input = input..button-48
            elseif button == 46 and decimal then input = input.."." end
        end
    end
    return input
end

function getChoice(choices, text, clickable, back, add)
    scroll = 1
    going = true
    while going do
        term.setBackgroundColor(bgColor)
        term.setTextColor(txtColor)
        term.clear()
        write(text,2)
        for i = scroll/2, math.min(#choices,scroll/2+8) do
            if clickable then paintutils.drawBox(6,math.ceil(i)*2+3-scroll,20,math.ceil(i)*2+3-scroll,buttonColor) end
            write(choices[math.ceil(i)],math.ceil(i)*2+3-scroll)
        end
        if back then
            term.setBackgroundColor(colors.red)
            if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
            term.setCursorPos(1, 1)
            term.write(back)
        end
        if add then
            term.setBackgroundColor(colors.lime)
            if bgColor == colors.lime then term.setBackgroundColor(colors.green) end
            term.setCursorPos(26, 1)
            term.write(add)
        end
        event, button, x, y = os.pullEventRaw()
        if event == "mouse_scroll" then
            scroll = scroll + button
            if scroll < 1 then scroll = 1
            elseif scroll > math.max(1,#choices*2-16) then scroll = math.max(1,#choices*2-16) end
        elseif event == "mouse_click" then
            if x == 1 and y == 1 and back then return "back"
            elseif x == 26 and y == 1 and add then return "add"
            elseif x >= 6 and x <= 20 and clickable then
                choice = (y+scroll-3)/2
                if choice == math.ceil(choice) and choice >= 1 and choice <= #choices then return choice end 
            end
        elseif event == "terminate" and back then return "back" end
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
    write(os.getComputerLabel(),3)
    ws = http.websocket(servers.main)
    if ws == false then
        term.setCursorPos(1,1)
        term.write("no service.")
    else
        ws.send(os.getComputerLabel())
        ws.send("close")
    end
    paintutils.drawBox(10,19,17,19,buttonColor)
    write("open",19)
    term.setCursorPos(1,20)
    term.write("<")
    term.setBackgroundColor(bgColor)
    going = true
    os.startTimer(0)
    while going do
        event, button, x, y = os.pullEventRaw()
        if (event == "mouse_click" and x == 1 and y == 20) or event == "terminate" then
            term.setBackgroundColor(colors.black)
            term.clear()
            term.setCursorPos(1,1)
            term.setTextColor(colors.yellow)
            term.write(os.version())
            term.setTextColor(colors.white)
            term.setCursorPos(1,2)
            print('type "startup" or reboot to exit.')
            return
        elseif event == "mouse_click" then 
            if x <= 17 and x >= 10 and y == 19 then going = false end 
        elseif event == "key" then
            if button == 32 or button == 257 then going = false end
        elseif event == "timer" then
            time = "  "..textutils.formatTime(os.time())
            term.setCursorPos(27-#time,1)
            term.write(time)
            clock = os.startTimer(0.83)
        end
    end
    if enterPass(pass,passType) then going2 = false end
end
while true do
    apps = fs.list("apps/")
    appNames = {}
    for i = 1,table.getn(apps) do
        settings.load("apps/"..apps[i])
        table.insert(appNames, settings.get("name"))
    end
    app = getChoice(appNames, "apps:", true)

    settings.clear()
    settings.load("apps/"..apps[app])
    file = settings.get("file")
    version = settings.get("version")
    id = settings.get("id")
    if autoUpdate then
        settings.clear()
        settings.load("data/mirrors")
        server = settings.get(id)
        download(id,version,false,server)
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
        require=require
    }
    os.run(env,file)
    if devMode then os.sleep(1) end
end