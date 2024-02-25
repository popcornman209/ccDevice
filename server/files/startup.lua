function getSetting(name, defVal)
    out = settings.get(name)
    if out == nil then
        out = defVal
        settings.set(name,defVal)
    end
    return out
end

version = "1.2.2"
updateVersion = "2.0.0"

settings.load("data/main")
bgColor = getSetting("bgColor",colors.cyan)
txtColor = getSetting("txtColor",colors.white)
buttonColor = getSetting("buttonColor",colors.blue)
devMode = getSetting("devMode",false)
autoUpdate = getSetting("autoUpdate",true)

if autoUpdate then 
    os.run({fileId = "update", currentVersion = updateVersion, log = true, restart = false},"update.lua")
    os.run({fileId = "os", currentVersion = version, log = true, restart = true},"update.lua")
end

function write(thing, y)
    len = string.len(thing)
    if len <= 26 then
        term.setCursorPos(14-string.len(thing)/2, y)
        term.write(thing)
    else
        current = thing
        for i = 0,math.ceil(len/26)-1 do
            temp = string.sub(current,i*26+1, math.min(26,string.len(current))+i*26)
            term.setCursorPos(14-string.len(temp)/2, y+i)
            term.write(temp)
        end
    end
end

function enterPass()
    if pass ~= false then
        term.setBackgroundColor(bgColor)
        term.setTextColor(txtColor)
        term.clear()
        term.setCursorPos(9,3)
        term.write("enter pass:")
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

        term.setBackgroundColor(colors.red)
        if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
        term.setCursorPos(11, 12)
        term.write("X")
        term.setBackgroundColor(colors.lime)
        if bgColor == colors.green then term.setBackgroundColor(colors.green) end
        term.setCursorPos(15, 12)
        term.write(">")

        input = ""
        term.setBackgroundColor(bgColor)
        goingasd = true
        while goingasd do
            paintutils.drawBox(1,4,26,4,bgColor)
            term.setCursorPos(14-string.len(input)/2, 4)
            for i = 1,string.len(input) do term.write("*") end
            event, button, x, y = os.pullEvent("mouse_click")
            if x == 11 and y == 6 then input = input..1
            elseif x == 13 and y == 6 then input = input..2
            elseif x == 15 and y == 6 then input = input..3
            elseif x == 11 and y == 8 then input = input..4
            elseif x == 13 and y == 8 then input = input..5
            elseif x == 15 and y == 8 then input = input..6
            elseif x == 11 and y == 10 then input = input..7
            elseif x == 13 and y == 10 then input = input..8
            elseif x == 15 and y == 10 then input = input..9
            elseif x == 11 and y == 12 then input = ""
            elseif x == 13 and y == 12 then input = input..0
            elseif x == 15 and y == 12 then goingasd = false end
        end
        correct = false
        if input == pass then correct = true end
        return correct, input
    elseif pass == false then return true,"noPass"
    end
end

pass = getSetting("pass",false)
settings.save("data/main")

settings.load("data/serverData")
address = settings.get("address")

going2 = true
while going2 do
    term.setBackgroundColor(bgColor)
    term.setTextColor(txtColor)
    term.clear()
    write(os.getComputerLabel(),3)
    ws = http.websocket(address)
    if ws == false then
        term.setCursorPos(1,1)
        term.write("no service.")
    else
        ws.send(os.getComputerLabel())
        ws.send("close")
    end
    paintutils.drawBox(10,19,17,19,buttonColor)
    term.setCursorPos(12,19)
    term.write("open")
    going = true
    while going do
        event, button, x, y = os.pullEvent("mouse_click")
        if x <= 17 and x >= 10 and y == 19 then going = false end
    end
    correct, typed = enterPass()
    if correct then going2 = false end
end
while true do
    term.setBackgroundColor(bgColor)
    term.setTextColor(txtColor)
    term.clear()
    write("apps:",2)
    term.setBackgroundColor(buttonColor)
    apps = fs.list("apps/")
    settings.clear()
    for i = 1,table.getn(apps) do
        settings.load("apps/"..apps[i])
        paintutils.drawBox(6,i*2+2,20,i*2+2)
        write(settings.get("name"),i*2+2)
    end
    going = true
    while going do
        event, button, x, y = os.pullEvent("mouse_click")
        if x <= 20 and x >= 6 then
            button = y/2-1
            if button <= table.getn(apps) and button >= 1 and button == math.floor(button) then
                going = false
            end
        end
    end
    settings.clear()
    settings.load("apps/"..apps[button])
    file = settings.get("file")
    version = settings.get("version")
    id = settings.get("id")
    if autoUpdate then os.run({fileId = id, currentVersion = version, log = false, restart = false},"update.lua") end
    os.run({},file)
    if devMode then os.sleep(1) end
end