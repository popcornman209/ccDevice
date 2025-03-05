resX, resY = term.getSize()

function clear(text)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,resY)
    term.write(text)
    paintutils.drawBox(1,1,resX,1,colors.gray)
    term.setCursorPos(resX/2-9,1)
    term.write("CCDevice installer")
    term.setBackgroundColor(colors.black)
end

function drawChoices(scroll,choices)
    clear("(up/down/enter): navigate")
    for i = 1+scroll,math.min(#choices,(resY-4)+scroll) do
        term.setCursorPos(4,i+2-scroll)
        print(choices[i])
    end
end

function getChoice(choices)
    cursorPos = 1
    scroll = 0
    drawChoices(scroll,choices)
    going = true
    while going do
        paintutils.drawBox(2,3,2,resY-2)
        term.setCursorPos(2,cursorPos+2-scroll)
        print(">")
        event, key = os.pullEvent("key")
        if key == 265 then
            cursorPos = math.max(cursorPos-1,1)
            if cursorPos < 1+scroll then
                scroll = scroll-1
                drawChoices(scroll,choices)
            end
        elseif key == 264 then
            cursorPos = math.min(cursorPos+1,#choices)
            if cursorPos > (resY-4)+scroll then
                scroll = scroll+1
                drawChoices(scroll,choices)
            end
        elseif key == 257 then
            going = false
            return cursorPos
        end
    end
end

function selectWebsocket()
    while true do
        choice = getChoice({"default server adress","custom..."})
        if choice == 2 then
            clear("enter to continue.")
            term.setCursorPos(1,2)
            print("server ip: ")
            address = read()
        else address = "ws://127.0.0.1:42069/" end

        ws = http.websocket(address)
        if ws == false then
            clear("wait 2 seconds...")
            term.setCursorPos(1,2)
            print("could not connect!")
            os.sleep(2)
        else
            ws.send("installer")
            ws.send("close")
            ws.close()
            return address
        end
    end
end

choice = getChoice({"phone","computer"})
if choice == 1 then
    term.clear()
    term.setCursorPos(1,1)

    dirs = {
        "modules"
    }
    programs = {
        "os",
        "settings",
        "appStore"
    }
    modules = {
        {"modules/update","https://raw.githubusercontent.com/popcornman209/ccDevice/refs/heads/main/server/files/all/update"},
        {"modules/sha","https://pastebin.com/raw/9c1h7812"} -- CREDIT: https://pastebin.com/9c1h7812 :)
    }
    
    for i = 1,#dirs do fs.makeDir(dirs[i]) end
    for i = 1,#modules do shell.run("wget", modules[i][2], modules[i][1]) end

    clear("enter to continue.")
    term.setCursorPos(1,2)
    print("phone name: ")
    os.setComputerLabel(read())

    address = selectWebsocket()

    settings.set("servers", {main=address})
    settings.set("device", "phone")
    settings.save("data/serverData")

    require("modules/update")

    for i = 1,#programs do
        download(programs[i],"nil",true)
    end

    clear("wait 2 seconds...")
    term.setCursorPos(1,2)
    print("restarting...")
    os.sleep(2)
    os.reboot()
elseif choice == 2 then
    term.clear()
    term.setCursorPos(1,1)

    dirs = {
        "modules"
    }
    programs = {
        "bootLoader",
        "apt",
        "CraftOS"
    }
    modules = {
        {"modules/update","https://raw.githubusercontent.com/popcornman209/ccDevice/refs/heads/main/server/files/all/update"},
        {"modules/sha","https://pastebin.com/raw/9c1h7812"} -- CREDIT: https://pastebin.com/9c1h7812 :)
    }
    
    for i = 1,#dirs do fs.makeDir(dirs[i]) end
    for i = 1,#modules do shell.run("wget", modules[i][2], modules[i][1]) end

    clear("enter to continue.")
    term.setCursorPos(1,2)
    print("device name: ")
    os.setComputerLabel(read())

    address = selectWebsocket()

    settings.set("servers", {main=address})
    settings.set("device", "computer")
    settings.save("data/serverData")

    require("modules/update")

    for i = 1,#programs do
        download(programs[i],"nil",true,address,"all")
    end
    
    settingData = '{\n\t[ "shell.allow_disk_startup" ] = false,\n}'
    file = fs.open(".settings","w")
    file.write(settingData)
    file.close()

    clear("wait 2 seconds...")
    term.setCursorPos(1,2)
    print("restarting...")
    os.sleep(2)
    os.reboot()
end
