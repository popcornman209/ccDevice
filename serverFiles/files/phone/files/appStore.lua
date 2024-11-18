server = "main"
quit = false
while quit == false do
    term.setBackgroundColor(bgColor)
    term.setTextColor(txtColor)
    term.clear()

    write("connecting...",2)
    ws = http.websocket(servers[server])
    if ws ~= false then
        ws.send(os.getComputerLabel())
        write("  loading apps...  ",2)
        ws.send("store")
        ws.send("phone")
        appIds = {}
        appNames = {}
        appDescs = {}
        receiving = true
        while receiving do
            name = ws.receive()
            if name ~= "complete" then
                id = ws.receive()
                desc = ws.receive()
                table.insert(appIds,id)
                table.insert(appNames,name)
                table.insert(appDescs,desc)
            else receiving = false end
        end
        ws.send("close")
        
        choice = getChoice(appNames, "App store", true, "X", string.char(167))

        if choice ~= "back" and choice ~= "add" then
            term.setBackgroundColor(bgColor)
            term.setTextColor(txtColor)
            term.clear()
            term.setBackgroundColor(colors.red)
            if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
            term.setCursorPos(1,1)
            term.write("<")
            term.setBackgroundColor(bgColor)
            write(appNames[choice],2)
            paintutils.drawBox(5,4,21,4,buttonColor)
            write("install/update",4)
            term.setBackgroundColor(bgColor)
            write(appDescs[choice],6)
            going = true
            while going do
                event, button, x, y = os.pullEvent("mouse_click")
                if x >= 5 and x <= 21 and y == 4 then
                    download(appIds[choice],"nil",false,servers[server])
                    write("installed.",20)
                elseif x == 1 and y == 1 then
                    going = false
                end
            end
        elseif choice == "back" then
            quit = true
        elseif choice == "add" then
            serverList = {}
            for key,value in pairs(servers) do
                table.insert(serverList,key)
            end
            choice = getChoice(serverList, "Mirrors:", true, "<")
            if choice ~= "back" then
                server = serverList[choice]
            end
        end
    else
        write("could not connect!",2)
        os.sleep(2)
        quit = true
    end
end