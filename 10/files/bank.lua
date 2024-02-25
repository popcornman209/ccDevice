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

settings.load("data/serverData")
address = settings.get("address")

ws = http.websocket(address)

settings.clear()
settings.load("data/main")
bgColor = getSetting("bgColor",colors.cyan)
txtColor = getSetting("txtColor",colors.white)
buttonColor = getSetting("buttonColor",colors.blue)

if ws ~= false then
    ws.send(os.getComputerLabel())

    quit = false
    while quit == false do
        if settings.load("data/account") == false then
            going = true
            while going do
                term.setBackgroundColor(bgColor)
                term.setTextColor(txtColor)
                term.clear()

                term.setBackgroundColor(colors.red)
                if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
                term.setCursorPos(1,1)
                term.write("X")
                term.setBackgroundColor(bgColor)
                
                write("not logged in",2)
                term.setBackgroundColor(buttonColor)
                paintutils.drawBox(5,4,21,4)
                write("log in",4)
                paintutils.drawBox(5,6,21,6)
                write("sign up",6)

                event, button, x, y = os.pullEvent("mouse_click")
                if x >= 5 and x <= 21 and y == 4 then
                    settings.clear()
                    term.setBackgroundColor(bgColor)
                    term.clear()
                    write("id:",1)
                    term.setCursorPos(1,2)
                    settings.set("id",read())
                    term.clear()
                    write("key:",1)
                    term.setCursorPos(1,2)
                    settings.set("key",read())
                    settings.save("data/account")
                    going = false
                elseif x >= 5 and x <= 21 and y == 6 then
                    term.setBackgroundColor(bgColor)
                    term.clear()
                    write("create a display name:",1)
                    term.setCursorPos(1,2)
                    displayName = read()
                    ws.send("createBank")
                    ws.send(displayName)

                    id = ws.receive()
                    key = ws.receive()
            
                    settings.clear()
                    settings.set("id", id)
                    settings.set("key", key)
                    settings.save("data/account")
                    going = false
                elseif x == 1 and y == 1 then
                    going = false
                    quit = true
                end
            end
        end
    
        if quit == false then
            settings.load("account")
            id = settings.get("id")
            key = settings.get("key")

            term.setBackgroundColor(bgColor)
            term.clear()

            ws.send("accountLoad")
            ws.send(id)
            ws.send(key)
            balance = ws.receive()
            if balance ~= "invalid login info!" then
                name = ws.receive()
                term.setCursorPos(1,20)
                term.write("id: "..id)
                write("hello "..name.."!",2)
                write("balance: $"..balance,3)
                
                term.setBackgroundColor(colors.red)
                if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
                term.setCursorPos(1,1)
                term.write("X")
                term.setBackgroundColor(bgColor)

                term.setBackgroundColor(buttonColor)
                paintutils.drawBox(4,5,22,5)
                write("send money",5)
                paintutils.drawBox(4,7,22,7)
                write("account settings",7)
                
                event, button, x, y = os.pullEvent("mouse_click")
                if x >= 4 and x <= 22 and y == 5 then
                    term.setBackgroundColor(bgColor)
                    term.clear()
                    term.setCursorPos(1,1)
                    term.write("$"..balance)
                    write("reciever id:", 2)
                    term.setCursorPos(2,3)
                    reciever = read()
                    term.clear()
                    term.setCursorPos(1,1)
                    term.write("$"..balance)
                    write("amount:", 2)
                    term.setCursorPos(2,3)
                    amount = read()

                    ws.send("transferMoney")
                    ws.send(id)
                    ws.send(key)
                    ws.send(reciever)
                    ws.send(amount)
                    success = ws.receive()
                    if success == "success" then
                        term.setBackgroundColor(bgColor)
                        term.clear()
                        write("sent $"..amount.." to "..reciever,2)
                        os.sleep(2)
                    else
                        term.setBackgroundColor(bgColor)
                        term.clear()
                        write("failed.",2)
                        write("reason:",6)
                        write(success,7)
                        os.sleep(2)
                    end

                elseif x >= 4 and x <= 22 and y == 7 then
                    inSettings = true
                    showKey = false
                    while inSettings do
                        term.setBackgroundColor(bgColor)
                        term.clear()

                        write("account settings",2)
                        term.setCursorPos(1,19)
                        term.write("id: "..id)
                        term.setCursorPos(1,20)
                        term.write("key: ")
                        if showKey then term.write(key)
                        else paintutils.drawBox(6,20,#key+6,20,buttonColor) end
                        
                        term.setBackgroundColor(colors.red)
                        if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
                        term.setCursorPos(1,1)
                        term.write("<")
                        term.setBackgroundColor(bgColor)

                        term.setBackgroundColor(buttonColor)
                        paintutils.drawBox(4,4,22,4)
                        write("change name",4)
                        paintutils.drawBox(4,6,22,6)
                        write("log out",6)

                        event, button, x, y = os.pullEvent("mouse_click")
                        if x >= 4 and x <= 22 and y == 4 then
                            term.setBackgroundColor(bgColor)
                            term.clear()
                            write("new name: ", 2)
                            term.setCursorPos(2,3)
                            ws.send("accountNameChange")
                            ws.send(id)
                            ws.send(key)
                            ws.send(read())
                        elseif x >= 4 and x <= 22 and y == 6 then
                            fs.delete("data/account")
                            inSettings = false
                        elseif x >= 6 and x <= #key+6 and y == 20 then
                            showKey = true
                        elseif x==1 and y==1 then inSettings = false
                        end
                    end

                elseif x == 1 and y == 1 then
                    quit = true
                    going = false
                end
            else
                write("invalid login info.",2)
                fs.delete("data/account")
                os.sleep(2)
            end
        end
    end
    ws.send("close")
else
    term.setBackgroundColor(bgColor)
    term.clear()
    write("no service.",2)
    os.sleep(2)
end