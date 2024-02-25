function add()
    term.setBackgroundColor(bgColor)
    term.clear()
    print("name:")
    name = read()
    print("id:")
    id = tonumber(read())
    print("password:")
    password = read("*")

    temp = {}
    temp["name"] = name
    temp["id"] = id
    temp["password"] = password

    settings.clear()
    settings.load("data/devices")
    devices = settings.get("devices")
    table.insert(devices, temp)
    settings.set("devices",devices)
    settings.save("data/devices")
end

quit = false
while quit == false do
    if settings.load("data/devices") == false then
        settings.clear()
        settings.set("devices",{})
        settings.save("data/devices")
    end


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
    term.write("<")
    term.setBackgroundColor(bgColor)
    write("devices",2)

    settings.clear()
    settings.load("data/devices")
    devices = settings.get("devices")
    settings.clear()
    if table.getn(devices) == 0 then
        write("No devices!", 4)
        term.setBackgroundColor(colors.lime)
        if bgColor == colors.green then term.setBackgroundColor(colors.green) end
        term.setCursorPos(25, 2)
        term.write("+")
        going = true
        while going do
            event, button, x, y = os.pullEvent("mouse_click")
            if x == 1 and y == 1 then
                going = false
                quit = true
            elseif x == 25 and y == 2 then
                add()
                going = false
            end
        end
    else
        for i = 1,table.getn(devices) do
            paintutils.drawBox(6,i*2+2,20,i*2+2,buttonColor)
            term.setBackgroundColor(buttonColor)
            write(devices[i]["name"],i*2+2)
            term.setBackgroundColor(colors.red)
            if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
            term.setCursorPos(4,i*2+2)
            term.write("X")
        end
        
        term.setBackgroundColor(colors.lime)
        if bgColor == colors.green then term.setBackgroundColor(colors.green) end
        term.setCursorPos(25, 2)
        term.write("+")

        going = true
        while going do
            rmv = false
            event, button, x, y = os.pullEvent("mouse_click")
            if x == 4 then
                button = y/2-1
                if button <= table.getn(devices) and button >= 1 and button == math.floor(button) then
                    going = false
                    rmv = true
                end
            elseif x == 1 and y == 1 then
                going = false
                quit = true
            elseif x == 25 and y == 2 then
                add()
                going = false
            end
        end

        if rmv == true then
            table.remove(devices, button)
            settings.clear()
            settings.load("data/devices")
            settings.set("devices",devices)
            settings.save("data/devices")
        end
    end
end