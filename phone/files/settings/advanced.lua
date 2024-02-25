function drawMenu()
    term.setBackgroundColor(bgColor)
    term.setTextColor(txtColor)
    term.clear()
    term.setBackgroundColor(colors.red)
    if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
    term.setCursorPos(1,1)
    term.write("<")
    term.setBackgroundColor(bgColor)

    write("advanced settings",2)
    write("dev mode:", 4)
    write("auto update:", 7)
    paintutils.drawBox(4,10,23,10,buttonColor)
    write("repair files", 10)
    paintutils.drawBox(4,12,23,12,buttonColor)
    write("uninstall apps", 12)
    term.setBackgroundColor(colors.lime)
    if bgColor == colors.green then term.setBackgroundColor(colors.green) end
    paintutils.drawBox(8,19,19,19)
    write("apply.", 19)
    term.setBackgroundColor(bgColor)
end
drawMenu()

settings.clear()
settings.load("data/main")
devMode = getSetting("devMode",false)
autoUpdate = getSetting("autoUpdate",true)

going = true
while going do
    paintutils.drawBox(9,5,17,5,buttonColor)
    paintutils.drawBox(9,8,17,8,buttonColor)
    write(tostring(devMode).." ",5)
    write(tostring(autoUpdate).." ",8)

    event, button, x, y = os.pullEvent("mouse_click")
    if x == 1 and y == 1 then going = false
    elseif x >= 9 and x <= 17 and y == 5 then
        if devMode then devMode = false
        else devMode = true end
    elseif x >= 9 and x <= 17 and y == 8 then
        if autoUpdate then autoUpdate = false
        else autoUpdate = true end
    elseif x >= 4 and x <= 23 and y == 10 then
        term.setBackgroundColor(bgColor)
        term.clear()
        write("repairing files...",1)
        term.setCursorPos(1,2)
        apps = fs.list("apps/")
        for i = 1,table.getn(apps) do
            settings.load("apps/"..apps[i])
            os.run({fileId = settings.get("id"), currentVersion = "update", log = true, restart = false},"update.lua")
        end
        os.run({fileId = "os", currentVersion = "update", log = true, restart = false},"update.lua")
        os.run({fileId = "update", currentVersion = "update", log = true, restart = false},"update.lua")
        drawMenu()
        write("repaired all files.",20)
    elseif x >= 4 and x <= 23 and y == 12 then
        term.setBackgroundColor(bgColor)
        term.clear()
        write("app to uninstall:",2)
        term.setBackgroundColor(colors.red)
        if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
        term.setCursorPos(1,1)
        term.write("<")
        term.setBackgroundColor(bgColor)

        apps = fs.list("uninstall/")
        for i = 1,table.getn(apps) do
            paintutils.drawBox(6,i*2+2,20,i*2+2,buttonColor)
            settings.load("uninstall/"..apps[i])
            write(settings.get("name"),i*2+2)
        end

        going2 = true
        uninstall = false
        while going2 do
            event, button, x, y = os.pullEvent("mouse_click")
            if x == 1 and y == 1 then going2 = false
            elseif x <= 20 and x >= 6 then
                app = y/2-1
                if app <= table.getn(apps) and app >= 1 and app == math.floor(app) then
                    going2 = false
                    uninstall = true
                end
            end
        end
        if uninstall then
            settings.clear()
            settings.load("uninstall/"..apps[app])
            files = settings.get("files")
            for i = 1,table.getn(files) do
                fs.delete(files[i])
            end
        end
        drawMenu()
        write("deleted "..settings.get("name"),20)
    elseif x >= 8 and x <= 19 and y == 19 then
        term.setBackgroundColor(bgColor)
        settings.clear()
        settings.load("data/main")
        settings.set("devMode",devMode)
        settings.set("autoUpdate",autoUpdate)
        settings.save("data/main")
        write("saved.",20)
    end
end