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

if ws ~= false then
    ws.send(os.getComputerLabel())

    settings.clear()
    settings.load("data/main")
    bgColor = getSetting("bgColor",colors.cyan)
    txtColor = getSetting("txtColor",colors.white)
    buttonColor = getSetting("buttonColor",colors.blue)

    quit = false
    while quit == false do
        going = true
        while going do
            if settings.load("account") == false then
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
            end
        
            settings.load("account")
            id = settings.get("id")
            key = settings.get("key")
            
            term.setBackgroundColor(bgColor)
            term.setTextColor(txtColor)
            term.clear()

            term.setBackgroundColor(colors.red)
            if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
            term.setCursorPos(1,1)
            term.write("X")
            term.setBackgroundColor(bgColor)
            
            write("bank account",2)

            term.setBackgroundColor(buttonColor)
            paintutils.drawBox(5,4,21,4)
            write("view balance",4)
            paintutils.drawBox(5,6,21,6)
            write("send money",6)
            paintutils.drawBox(5,8,21,8)
            write("receive money",8)

            event, button, x, y = os.pullEvent("mouse_click")
            if x >= 5 and x <= 21 and y == 4 then
                settings.load("settings")
                balance = settings.get("balance")
                term.setBackgroundColor(bgColor)
                term.clear()
                write("balance:",2)
                write("$"..balance,3)
                term.setBackgroundColor(colors.red)
                if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
                term.setCursorPos(1,1)
                term.write("<")
                term.setBackgroundColor(bgColor)
                going2 = true
                while going2 do
                    event, button, x, y = os.pullEvent("mouse_click")
                    if x == 1 and y == 1 then going2 = false end
                end
            elseif x >= 5 and x <= 21 and y == 6 then
                settings.load("settings")
                settings.clear()
                balance = settings.get("balance")
                term.setBackgroundColor(bgColor)
                term.clear()
                write("scanning for people...",2)
                rednet.open("back")
                rednet.broadcast("scan", "transfer")
                recieving = true
                people = {}
                while recieving do
                    id, message, prot = rednet.receive("transferScan", 1)
                    if message ~= nil then table.insert(people, {id, message})
                    else recieving = false end
                end
                if people[1] == nil then
                    term.setBackgroundColor(colors.red)
                    if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
                    term.setCursorPos(1,1)
                    term.write("<")
                    term.setBackgroundColor(bgColor)
                    going2 = true
                    write("no people receiving right now.",2)
                    while going2 do
                        event, button, x, y = os.pullEvent("mouse_click")
                        if x == 1 and y == 1 then going2 = false end
                    end
                else
                    term.setBackgroundColor(bgColor)
                    term.clear()
                    write("people:",2)
                    for i = 1,table.getn(people) do
                        paintutils.drawBox(3,i*2+2,23,i*2+2,buttonColor)
                        write(people[i][2].."  id:"..people[i][1],i*2+2)
                    end
                    going2 = true
                    cancelled = false
                    term.setBackgroundColor(colors.red)
                    if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
                    term.setCursorPos(1,1)
                    term.write("<")
                    while going2 do
                        event, button, x, y = os.pullEvent("mouse_click")
                        if x == 1 and y == 1 then
                            going2 = false
                            cancelled = true
                        elseif x <= 23 and x >= 3 then
                            person = y/2-1
                            if person <= table.getn(people) and person >= 1 and person == math.floor(person) then
                                going2 = false
                            end
                        end
                    end
                    
                    if cancelled == false then
                        settings.clear()
                        settings.load("settings")
                        balance = settings.get("balance")
                        term.setBackgroundColor(bgColor)
                        term.clear()
                        write("how much to send?",2)
                        write("(bal: "..tostring(balance)..")",3)

                        term.setBackgroundColor(buttonColor)
                        term.setCursorPos(7,5)
                        term.write("<")
                        term.setCursorPos(19,5)
                        term.write(">")
                        term.setBackgroundColor(colors.red)
                        if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
                        term.setCursorPos(1,1)
                        term.write("<")
                        term.setBackgroundColor(buttonColor)
                        paintutils.drawBox(7,7,19,7)
                        write("continue",7)

                        going2 = true
                        amountSending = 0
                        while going2 do
                            paintutils.drawBox(8,5,18,5,colors.lightGray)
                            write(tostring(amountSending),5)
                            event, button, x, y = os.pullEvent("mouse_click")
                            if x == 7 and y == 5 then amountSending = amountSending-1
                            elseif x == 19 and y == 5 then amountSending = amountSending+1
                            elseif x == 1 and y == 1 then
                                going2 = false
                                cancelled = true
                            elseif x >= 7 and x <= 19 and y == 7 then going2 = false
                            end

                            if amountSending > balance then amountSending = balance end
                            if amountSending < 0 then amountSending = 0 end
                        end

                        if cancelled == false then
                            if amountSending >= 0 and amountSending <= balance then
                                term.setBackgroundColor(bgColor)
                                term.clear()
                                write("starting transaction...",2)
                                rednet.send(people[person][1], amountSending, "transfer")
                                rednet.send(people[person][1], name, "transfer")
                                sender, message, prot = rednet.receive("transfer",2)
                                if sender ~= nil and tonumber(sender) == people[person][1] then
                                    term.clear()
                                    write("sent $"..amountSending.." to "..people[person][2]..".",2)
                                    settings.set("balance", balance-amountSending)
                                    settings.save("settings")
                                    term.setBackgroundColor(colors.red)
                                    if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
                                    term.setCursorPos(1,1)
                                    term.write("<")
                                    going2 = true
                                    while going2 do
                                        event, button, x, y = os.pullEvent("mouse_click")
                                        if x == 1 and y == 1 then
                                            going2 = false
                                        end
                                    end
                                else
                                    term.clear()
                                    write(sender,2)
                                    term.setBackgroundColor(colors.red)
                                    if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
                                    term.setCursorPos(1,1)
                                    term.write("<")
                                    going2 = true
                                    while going2 do
                                        event, button, x, y = os.pullEvent("mouse_click")
                                        if x == 1 and y == 1 then
                                            going2 = false
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif x >= 5 and x <= 21 and y == 8 then
                settings.clear()
                settings.load("settings")
                name = os.getComputerLabel()
                balance = settings.get("balance")
                id = os.getComputerID()
                term.setBackgroundColor(bgColor)
                term.clear()
                write("name: "..name,1)
                write("id: "..id,2)
                write("--------------------------",3)
                write("listening...",4)
                going = true
                while going do
                    sender, amount, prot = rednet.receive("transfer")
                    if amount == "scan" then
                        rednet.send(sender, name, "transferScan")
                    else
                        sender, name, prot = rednet.receive("transfer",1)
                        os.sleep(0.05)
                        rednet.send(sender, "thanks.", "transfer")
                        term.setBackgroundColor(bgColor)
                        term.clear()
                        write("recieved $"..amount.." from "..name.." (id: "..sender..")",2)
                        settings.set("balance", balance+tonumber(amount))
                        settings.save("settings.")
                        term.setBackgroundColor(colors.red)
                        if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
                        term.setCursorPos(1,1)
                        term.write("<")
                        going2 = true
                        while going2 do
                            event, button, x, y = os.pullEvent("mouse_click")
                            if x == 1 and y == 1 then
                                going2 = false
                                going = false
                            end
                        end
                    end
                end
            elseif x == 1 and y == 1 then
                going = false
                quit = true
            end
        end
    end
    ws.send("close")
else
    settings.clear()
    settings.load("data/main")
    bgColor = getSetting("bgColor",colors.cyan)
    term.setBackgroundColor(bgColor)
    term.clear()
    write("no service.",2)
    os.sleep(2)
end