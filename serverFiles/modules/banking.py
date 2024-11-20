import standard, asyncio, os, json, random

def transferMoney(sId,sKey,rId,amount):
    if amount >= 0: #if sending something (no negative amounts)
        if os.path.exists("moduleFiles/bank/%s"%(sId)) and os.path.exists("moduleFiles/bank/%s"%(rId)): #if both accounts exist
            with open("moduleFiles/bank/%s"%(sId),"r") as f:
                details = json.load(f) #load sender account info
            if details["key"] == sKey: #if key is valid
                if details["balance"] >= amount or details["admin"]: #if has money
                    if details["admin"] == False:
                        details["balance"] -= amount #remove money from acocunt
                    details["transactions"].append("$%s to %s"%(amount,rId)) #add transaction
                    with open("moduleFiles/bank/%s"%(sId),"w") as f:
                        json.dump(details,f) #save details
                    with open("moduleFiles/bank/%s"%(rId),"r") as f:
                        details = json.load(f) #load reciever account
                    details["balance"] += amount #add money
                    details["transactions"].append("$%s from %s"%(amount,sId)) #add transaction
                    with open("moduleFiles/bank/%s"%(rId),"w") as f:
                        json.dump(details,f) #save new details
                    return "success"
                else:
                    return "not enough money!"
            else:
                return "invalid login info!"
        else:
            return "invalid login info!"
    else:
        return "no negative or zero amounts!"
    
def createAccount(name):
    id = str(random.randint(0,standard.settings["idMaxNumber"])) #generate random id
    key = str(random.randint(0,standard.settings["keyMaxNumber"])) #generate random key, number should be large enough for no duplicates
    account = {"name":name,"key":key,"balance":0,"admin":False,"notifAccounts":[],"transactions":["created account"]}
    with open("moduleFiles/bank/"+id,"w") as f:
        json.dump(account,f) #saves it to account file
    return {"id":id,"key":key}

def loadAccount(id,key): #returns nothing if information invalid
    if os.path.exists("moduleFiles/bank/%s"%(id)): #check if account exists
        with open("moduleFiles/bank/%s"%(id),"r") as f:
            details = json.load(f) #load account info
        if details["key"] == key: #check account id
            if details["admin"]: details["balance"] = 999999 #if admin infinite money
            return details

async def WSAPIcreateBank(args): #create the bank account
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    displayName = await websocket.recv()
    account = createAccount(displayName)
    await websocket.send(json.dumps(account))
    standard.prnt("created bank account: %s"%(displayName),"norm", deviceName)
    

async def WSAPIaccountLoad(args): #loading account name and balance
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    id = message["id"] #account id
    key = message["key"] #account key

    account = loadAccount(id,key)
    if account:
        await websocket.send(json.dumps(account)) #send account info
        standard.prnt("sent bank account %s info"%(id),"spam", deviceName)
    else:
        standard.prnt("attemped to get transactions: wrong id","err", deviceName)
    

async def WSAPIaccountNameChange(args): #chaning account name
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    id = message["id"] #account id
    key = message["key"] #account key
    name = message["name"] #new name

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


async def WSAPItransferMoney(args): #transfer money between accounts
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    id = message["id"] #id for sender
    key = message["key"] #key for sender
    reciever = message["reciever"] #reciever of money
    amount = message["amount"] #amount of money to send

    s = transferMoney(id,key,reciever,amount)
    if s == "success": standard.prnt("sent $%s from %s to %s."%(str(amount),id,reciever),"norm", deviceName)
    else: standard.prnt("attemped send money: "+s,"err", deviceName)
    await websocket.send(s) #compelte transaction

    
apiCalls = {
    "bank-create": WSAPIcreateBank,
    "bank-load": WSAPIaccountLoad,
    "bank-nameChange": WSAPIaccountNameChange,
    "bank-transfer": WSAPItransferMoney
}

description = "adding bank accounts and a money system"
documentation = "documentation/banking.txt"
