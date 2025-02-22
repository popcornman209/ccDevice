ws = http.websocket(serverAddress)

function drawChoices(scroll,choices)
    for i = 1+scroll,math.min(#choices,(resY-4)+scroll) do
        term.setCursorPos(4,i+2-scroll)
        print(i, choices[i])
    end
end

if ws ~= false then
    ws.send(os.getComputerLabel())

    quit = false
    while quit == false do
        groups = fs.list("data/PhoneMessage")
        choice = getChoice(groups,"groups:",true,"X","+")
        
        if choice == "add" then
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
                
                write("no messages?",2)
                write("no problem click below to make a group",4)
                term.setBackgroundColor(buttonColor)
                paintutils.drawBox(5,7,21,7)
                write("make group",7)

                event, button, x, y = os.pullEvent("mouse_click")
                if x >= 5 and x <= 21 and y == 7 then
                    username = "test"
                    password = "testPass"
                    term.setBackgroundColor(bgColor)
                    term.clear()
                    write("create a display name:",1)
                    term.setCursorPos(1,2)
                    displayName = read()
                    write("do you want to be the",4)     
                    write("owner of this group?",5)      
                    write("if not everyone is the",6)
                    write("owner",7)
                    term.setCursorPos(1,8)
                    owner = read()
                    if owner == "yes" or owner == "Yes" then
                        owner = username
                    else
                        owner = ""
                    end
                    message = {
                        username=username,
                        password=password,
                        displayName=displayName,
                        owner=owner
                    }
                    ws.send("message-createChat")
                    ws.send(textutils.serialiseJSON(message))
                    cId = ws.receive()
                    if cId == "invalid info!" then
                        term.clear()
                        write("Something went wrong! try again later",4)
                        os.sleep(2)
                        going = false
                    end
                    ws.send("message-getChat")
                    message = {username=username, password=password, cId=cId}
                    ws.send(textutils.serialiseJSON(message))
                    chatD = textutils.unserialiseJSON(ws.receive(), {parse_null = true})
            
                    settings.clear()
                    settings.set("name", chatD["name"])
                    settings.set("id", chatD["id"])
                    settings.set("owner", chatD["owner"])
                    settings.set("users", chatD["users"])
                    settings.set("messages", chatD["messages"])
                    settings.save("data/PhoneMessage/"..displayName)
                    account = displayName
                    going = false
                elseif x == 1 and y == 1 then
                    going = false
                    quit = true
                    choice = "back"
                end
            end
        elseif choice ~= "back" then account = accounts[choice] end
    
        if choice ~= "back" then
            inAccount = true
            while inAccount do
                settings.load("data/bankAccounts/"..account)
                id = settings.get("id")
                key = settings.get("key")

                term.setBackgroundColor(bgColor)
                term.clear()

                ws.send("bank-load")
                message = {id=id, key=key}
                ws.send(textutils.serialiseJSON(message))

                accountStr = ws.receive()
                if accountStr ~= "invalid login info!" then
                    accountData = textutils.unserialiseJSON(accountStr)
                    term.setCursorPos(1,20)
                    term.write("id: "..key)
                    write("hello "..accountData["name"].."!",2)
                    write("balance: $"..accountData["balance"],3)
                    
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
                    paintutils.drawBox(4,9,22,9)
                    write("transactions",9)
                    
                    event, button, x, y = os.pullEvent("mouse_click")
                    if x >= 4 and x <= 22 and y == 5 then
                        term.setBackgroundColor(bgColor)
                        term.clear()
                        term.setCursorPos(1,1)
                        term.write("$"..accountData["balance"])
                        write("reciever id:", 2)
                        term.setCursorPos(2,3)
                        reciever = read()
                        term.clear()
                        term.setCursorPos(1,1)
                        term.write("$"..accountData["balance"])
                        write("amount:", 2)
                        term.setCursorPos(2,3)
                        amount = read()

                        ws.send("bank-transfer")
                        message = {
                            id=id,
                            key=key,
                            reciever=reciever,
                            amount=tonumber(amount)
                        }
                        ws.send(textutils.serialiseJSON(message))
                        
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
                                ws.send("bank-nameChange")
                                message = {
                                    id=id,
                                    key=key,
                                    name=read()
                                }
                                ws.send(textutils.serialiseJSON(message))

                                if ws.receive() ~= "success" then
                                    term.setBackgroundColor(bgColor)
                                    term.clear()
                                    write("invalid login info!")
                                    os.sleep(2)
                                end
                            elseif x >= 4 and x <= 22 and y == 6 then
                                fs.delete("data/bankAccounts/"..account)
                                inSettings = false
                                inAccount = false
                            elseif x >= 6 and x <= #key+6 and y == 20 then
                                showKey = true
                            elseif x==1 and y==1 then inSettings = false
                            end
                        end
                    elseif x >= 4 and x <= 22 and y == 9 then
                        getChoice(accountData["transactions"],"transactions:",false,"<")
                    elseif x == 1 and y == 1 then
                        quit = true
                        going = false
                        inAccount = false
                    end
                else
                    write("invalid login info.",2)
                    fs.delete("data/bankAccounts/"..account)
                    inAccount = false
                    os.sleep(2)
                end
            end
        else quit = true
        end
    end
    ws.send("close")
else
    term.setBackgroundColor(bgColor)
    term.clear()
    write("no service.",2)
    os.sleep(2)
end