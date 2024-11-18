import standard, asyncio, os, json, random

async def createBank(websocket,deviceName): #create the bank account
    displayName = await websocket.recv()
    id = str(random.randint(0,standard.settings["idMaxNumber"])) #generate random id
    key = str(random.randint(0,standard.settings["keyMaxNumber"])) #generate random key, number should be large enough for no duplicates
    await websocket.send(id) #send account login info to client
    await websocket.send(key)
    account = {"name":displayName,"key":key,"balance":0,"admin":False,"notifAccounts":[],"transactions":["created account"]}
    with open("moduleFiles/bank/"+id,"w") as f:
        json.dump(account,f) #saves it to account file
    standard.prnt("created bank account: %s"%(displayName),"norm", deviceName)

async def accountLoad(websocket,deviceName): #loading account name and balance
    id = await websocket.recv()
    key = await websocket.recv() #get id and key
    if os.path.exists("moduleFiles/bank/%s"%(id)): #check if account exists
        with open("moduleFiles/bank/%s"%(id),"r") as f:
            details = json.load(f) #load account info
        if details["key"] == key: #check account id
            if details["admin"]: await websocket.send("999999") #if admin infinite money
            else: await websocket.send(str(details["balance"])) #send real balance if not
            await websocket.send(str(details["name"])) #send account name
            standard.prnt("sent bank account %s info"%(id),"spam", deviceName)
        else:
            await websocket.send("invalid login info!") #wrong key
            standard.prnt("attemped to get balance: wrong key","err", deviceName)
    else:
        await websocket.send("invalid login info!")
        standard.prnt("attemped to get balance: wrong id (id)","err", deviceName)

async def accountNameChange(websocket,deviceName): #chaning account name
    id = await websocket.recv() #get account id
    key = await websocket.recv() #get account key
    name = await websocket.recv() #get new account name
    if os.path.exists("moduleFiles/bank/%s"%(id)): #check if account exists
        with open("moduleFiles/bank/%s"%(id),"r") as f:
            details = json.load(f) #get account details
        if details["key"] == key: #check key
            details["name"] = name #changes name
            with open("moduleFiles/bank/"+id,"w") as f:
                json.dump(details,f) #saves file
            standard.prnt("changed account %s name to %s."%(id,name),"norm", deviceName)
            await websocket.send("success")
        else:
            await websocket.send("invalid login info!")
            standard.prnt("attemped to change name: wrong key","err", deviceName)
    else:
        await websocket.send("invalid login info!")
        standard.prnt("attemped to change name: wrong id","err", deviceName)

async def transferMoney(websocket,deviceName): #transfer money between accounts
    id = await websocket.recv() #get sender id
    key = await websocket.recv() #get sender key
    reciever = await websocket.recv() #get reciever id
    amount = float(await websocket.recv()) #get amount to send
    if amount >= 0: #if sending something (no negative amounts)
        if os.path.exists("moduleFiles/bank/%s"%(id)) and os.path.exists("moduleFiles/bank/%s"%(reciever)): #if both accounts exist
            with open("moduleFiles/bank/%s"%(id),"r") as f:
                details = json.load(f) #load sender account info
            if details["key"] == key: #if key is valid
                if details["balance"] >= amount or details["admin"]: #if has money
                    if details["admin"] == False:
                        details["balance"] -= amount #remove money from acocunt
                    details["transactions"].append("$%s to %s"%(amount,reciever)) #add transaction
                    with open("moduleFiles/bank/%s"%(id),"w") as f:
                        json.dump(details,f) #save details
                    with open("moduleFiles/bank/%s"%(reciever),"r") as f:
                        details = json.load(f) #load reciever account
                    details["balance"] += amount #add money
                    details["transactions"].append("$%s from %s"%(amount,id)) #add transaction
                    with open("moduleFiles/bank/%s"%(reciever),"w") as f:
                        json.dump(details,f) #save new details
                    await websocket.send("success") #compelte transaction
                    standard.prnt("sent $%s from %s to %s."%(str(amount),id,reciever),"norm", deviceName)
                else:
                    await websocket.send("not enough money!")
                    standard.prnt("attemped send money: no money","err", deviceName)
            else:
                await websocket.send("invalid login info!")
                standard.prnt("attemped send money: wrong key","err", deviceName)
        else:
            await websocket.send("invalid login info!")
            standard.prnt("attemped send money: wrong id","err", deviceName)
    else:
        await websocket.send("no negative or zero amounts!")
        standard.prnt("attemped send money: invalid price","err", deviceName)

async def getTransactions(websocket,deviceName): #get all transactions
    id = await websocket.recv() #get account info
    key = await websocket.recv()
    if os.path.exists("moduleFiles/bank/%s"%(id)): #if account exists
        with open("moduleFiles/bank/%s"%(id),"r") as f:
            details = json.load(f) #load details
        if details["key"] == key: #if valid key
            for transaction in reversed(details["transactions"]):
                await websocket.send(transaction) #send each transaction as message
            await websocket.send("complete") #complete message 
            standard.prnt("sent transactions %s"%(id),"spam", deviceName)
        else:
            await websocket.send("invalid login info!")
            standard.prnt("attemped to get transactions: wrong key","err", deviceName)
    else:
        await websocket.send("invalid login info!")
        standard.prnt("attemped to get transactions: wrong id","err", deviceName)
    
apiCalls = {
    "bank-create": createBank,
    "bank-load": accountLoad,
    "bank-nameChange": accountNameChange,
    "bank-transfer": transferMoney,
    "bank-transactions": getTransactions
}
description = "adding bank accounts and a money system"
documentation = "documentation/banking.txt"