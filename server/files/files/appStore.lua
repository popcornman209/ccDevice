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

    receiving = true
    rednet.open("back")
    rednet.broadcast("scan","server")
    write("finding server...",2)
    server,message,prot = rednet.receive("serverFind",1)
    write("  loading apps...  ",2)
    appIds = {}
    appNames = {}
    appDescs = {}
    rednet.send(server,"appStoreLoad","server")
    i = 1
    while receiving do
        server,name,prot = rednet.receive("appStore",0.5)
        if name ~= nil then
            sender,id,port = rednet.receive("appStore",0.5)
            sender,desc,port = rednet.receive("appStore",0.5)
            paintutils.drawBox(6,i*2+2,20,i*2+2,buttonColor)
            write(name,i*2+2)
            table.insert(appIds,id)
            table.insert(appNames,name)
            table.insert(appDescs,desc)
        else receiving = false
        end
        i = i+1
    end
    term.setBackgroundColor(colors.red)
    if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
    term.setCursorPos(1,1)
    term.write("X")
    term.setBackgroundColor(bgColor)
    write("     app store      ",2)

    going = true
    while going do
        event, button, x, y = os.pullEvent("mouse_click")
        if x <= 20 and x >= 6 then
            button = y/2-1
            if button <= table.getn(appNames) and button >= 1 and button == math.floor(button) then
                going = false
            end
        elseif x == 1 and y == 1 then
            going = false
            quit = true
        end
    end

    if quit == false then
        appId = appIds[button]
        appName = appNames[button]
        appDesc = appDescs[button]
        term.setBackgroundColor(bgColor)
        term.setTextColor(txtColor)
        term.clear()
        term.setBackgroundColor(colors.red)
        if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
        term.setCursorPos(1,1)
        term.write("<")
        term.setBackgroundColor(bgColor)
        write(appName,2)
        paintutils.drawBox(5,4,21,4,buttonColor)
        write("install/update",4)
        term.setBackgroundColor(bgColor)
        write(appDesc,6)
        os.sleep(1)
        going = true
        while going do
            event, button, x, y = os.pullEvent("mouse_click")
            if x >= 5 and x <= 21 and y == 4 then
                os.run({fileId = appId,currentVersion = "nil",log = false,restart = false},"update.lua")
                write("installed.",20)
            elseif x == 1 and y == 1 then
                going = false
            end
        end
    end
end