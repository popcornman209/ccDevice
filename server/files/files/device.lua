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
function getSetting(name, defVal)
    out = settings.get(name)
    if out == nil then
        out = defVal
        settings.set(name,defVal)
    end
    return out
end

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
    going = true
    while going do
        event, button, x, y = os.pullEvent("mouse_click")
        if x == 1 and y == 1 then
            going = false
            quit = true
        end
    end
else
    quit = false
    while quit == false do
        for i = 1,table.getn(devices) do
            paintutils.drawBox(6,i*2+2,20,i*2+2,buttonColor)
            write(devices[i]["name"],i*2+2)
        end

        going = true
        while going do
            event, button, x, y = os.pullEvent("mouse_click")
            if x <= 20 and x >= 6 then
                button = y/2-1
                if button <= table.getn(devices) and button >= 1 and button == math.floor(button) then
                    going = false
                end
            elseif x == 1 and y == 1 then
                going = false
                quit = true
            end
        end

        if quit == false then
            rednet.send(devices[button]["id"], devices[button]["password"], "doorToggle")
            sender, message = rednet.receive("doorResponse", 3)
            term.setBackgroundColor(bgColor)
            if message == nil then write("could not connect.", 20)
            elseif sender == devices[button]["id"] then write(message, 20)
            else write("didnt hear, please try again.", 20) end
        end
    end
end