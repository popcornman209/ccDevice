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


choice = getChoice({"phone"})
if choice == 1 then
    term.clear()
    term.setCursorPos(1,1)
    shell.run("wget", "https://raw.githubusercontent.com/popcornman209/ccDevice/main/update.lua")

    dirs = {
        "apps",
        "data",
        "data/bankAccounts",
        "files",
        "files/settings",
        "settingData",
        "uninstall"
    }
    programs = {
        "os",
        "settings",
        "appStore"
    }
    for i = 1,#dirs do fs.makeDir(dirs[i]) end

    clear("enter to continue.")
    term.setCursorPos(1,2)
    print("phone name: ")
    os.setComputerLabel(read())

    connecting = true
    while connecting do
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
            ws.send("installingPhone")
            ws.close()
            connecting = false
        end
    end

    settings.set("address", address)
    settings.set("device", "phone")
    settings.save("data/serverData")

    for i = 1,#programs do
        os.run({fileId = programs[i], currentVersion = "", log = true, restart = false},"update.lua")
    end

    clear("wait 2 seconds...")
    term.setCursorPos(1,2)
    print("restarting...")
    os.sleep(2)
    os.reboot()
end
