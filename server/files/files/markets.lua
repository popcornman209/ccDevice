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

rednet.open("back")

quit = false
while quit == false do
    settings.clear()
    settings.load("data/main")
    bgColor = getSetting("bgColor",colors.cyan)
    txtColor = getSetting("txtColor",colors.white)
    buttonColor = getSetting("buttonColor",colors.blue)

    term.setBackgroundColor(bgColor)
    term.setTextColor(txtColor)
    term.clear()
    write("scanning...",2)

    scanning = true
    rednet.broadcast("scan","markets")
    markets = {}
    i = 1
    while scanning do
        sender, message, prot = rednet.receive("markets",0.5)
        if message == nil then scanning = false
        else
            paintutils.drawBox(4,i*2+2,22,i*2+2,buttonColor)
            write(message,i*2+2)
            table.insert(markets,message)
        end
        i = i+1
    end
    term.setBackgroundColor(colors.red)
    if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
    term.setCursorPos(1,1)
    term.write("X")
    term.setBackgroundColor(bgColor)
    write("   markets   ",2)
    going = true
    quit = false
    while going do
        event, button, x, y = os.pullEvent("mouse_click")
        if x <= 22 and x >= 4 then
            market = y/2-1
            if market <= table.getn(markets) and market >= 1 and market == math.floor(market) then
                going = false
            end
        elseif x == 1 and y == 1 then
            going = false
            quit = true
        end
    end
    if quit == false then
        term.setBackgroundColor(bgColor)
        term.clear()
        term.setBackgroundColor(colors.red)
        if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
        term.setCursorPos(1,1)
        term.write("<")
        term.setBackgroundColor(bgColor)

        name = markets[market]
        rednet.broadcast(name,"markets")
        sender, location, prot = rednet.receive("markets",0.25)
        sender, coords, prot = rednet.receive("markets",0.25)
        sender, atm, prot = rednet.receive("markets",0.25)
        receiving = true
        i = 1
        while receiving do
            sender,message,prot = rednet.receive("markets",0.25)
            if message ~= "end" then write(message,i+7)
            else receiving = false end
            i = i+1
        end
        write(name,2)
        write(location,4)
        write("("..coords..")",5)
        write("has atm: "..atm,6)
        going = true
        while going do
            event, button, x, y = os.pullEvent("mouse_click")
            if x == 1 and y == 1 then going = false end
        end
    end
end