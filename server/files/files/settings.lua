function getSetting(name, defVal)
    out = settings.get(name)
    if out == nil then
        out = defVal
        settings.set(name,defVal)
    end
    return out
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

quit = false
while quit == false do
    settings.clear()
    settings.load("data/main")
    bgColor = getSetting("bgColor",colors.cyan)
    txtColor = getSetting("txtColor",colors.white)
    buttonColor = getSetting("buttonColor",colors.blue)
    devMode = getSetting("devMode",false)

    term.setBackgroundColor(bgColor)
    term.setTextColor(txtColor)
    term.clear()
    term.setBackgroundColor(colors.red)
    if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
    term.setCursorPos(1,1)
    term.write("X")
    term.setBackgroundColor(bgColor)
    write("settings",2)

    apps = fs.list("settingData/")
    settings.clear()
    for i = 1,table.getn(apps) do
        settings.load("settingData/"..apps[i])
        paintutils.drawBox(6,i*2+2,20,i*2+2,buttonColor)
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
        elseif x == 1 and y == 1 then
            going = false
            quit = true
        end
    end
    if quit == false then
        settings.clear()
        settings.load("settingData/"..apps[button])
        file = settings.get("file")
        env = {}
        env.bgColor = bgColor
        env.txtColor = txtColor
        env.buttonColor = buttonColor
        env.write = write
        env.getSetting = getSetting
        os.run(env,file)
        if devMode then os.sleep(1) end
    end
end