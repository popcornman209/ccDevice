import standard, asyncio, os, json, random
from modules import accounts

def createChat(user,passw,name,owner): #if owner = "" everyone is an owner, otherwise make it username
    account = accounts.loadAccount(user,passw)
    if "chats" not in account:
        account["chats"] = []
        accounts.saveAccount(account)
    if account:
        id = str(random.randint(0,standard.settings["idMaxNumber"])) #generate random id
        chat = {
            "name":name,
            "id":id,
            "owner":owner,
            "users":[user],
            "messages":[]
        }
        with open("moduleFiles/chats/"+id,"w") as f:
            json.dump(chat,f) #saves it to chat file
        return True
    else: return False

def getChat(cId):
    if os.path.exists("moduleFiles/chats/"+cId): #check if chat exists
        with open("moduleFiles/chats/"+cId,"r") as f: #opens file
            account = json.load(f) #load chat info
        return account #returns chat if success
    else:
        return False #return false if failure

def saveChat(cId,chat):
    with open("moduleFiles/chats/"+cId,"r") as f: #opens file
        json.dump(chat,f) #save chat information

def SendText(cId,user,password,text):
    chat = getChat(cId)
    account = accounts.loadAccount(user,password)
    if chat:
        if user in chat["users"] and account:
            chat["messages"].append("{}: {}".format(user,text))
            saveChat(cId,chat)
            return True
        else: return False
    else: return False

async def WSAPIcreateChat(args): #create the messaging account
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    username = message["username"] #account id
    password = message["password"]
    displayName = message["displayName"]
    owner = message["owner"]

    account = createChat(username,password,displayName,owner)
    if type(account) == dict: #if create chat succeeded
        await websocket.send("success") #send chat ID to client
        standard.prnt("created messaging chat: %s"%(displayName),"norm", deviceName)
    else: #if it failed
        await websocket.send("invalid info!") #send that it failed to client, so it doesnt sit there and wait for a response forever
        standard.prnt("failed to create chat: %s"%(account),"err", deviceName) #output that it failed in console

async def WSAPIgetChat(args): #transfer money between accounts
    websocket = args["websocket"]
    deviceName = args["deviceName"]
    
    message = json.loads(await websocket.recv())
    username = message["username"] #account id
    password = message["password"]
    cId = message["cId"]
    
    s = getChat(cId)
    account = accounts.loadAccount(username,password)

    if s and account and username in s["users"]:
        standard.prnt("loaded messages %s"%(cId),"spam", deviceName)
        await websocket.send(json.dumps(s)) #sends chat info
    else:
        standard.prnt("failed to get messages {}".format(cId),"err", deviceName)
        await websocket.send("failed")
    

async def WSAPIaddUser(args): #joins chat 
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    cId = message["cId"]
    newUser = message["newUser"]
    invUser = message["username"]
    invPass = message["password"]

    chat = getChat(cId)
    invAccount = accounts.loadAccount(invUser,invPass)
    newAccount = accounts.loadAccount(newUser,"",byPassPassword=True)

    if chat and invAccount and newAccount: # if all information valid
        if  invUser == chat["owner"] or (invUser in chat["users"] and chat["owner"] == ""): #if they are allowed to invite
            chat["users"].append(newUser)
            if "chats" not in newAccount:
                newAccount["chats"] = []
            newAccount["chats"].append(cId)
            accounts.saveAccount(newAccount)
            saveChat(cId,chat)
            standard.prnt("user {} invited {} to chat {}".format(invUser,newUser,cId),"norm", deviceName)
            await websocket.send("success")
    else:
        await websocket.send("failed")

async def WSAPIsendText(args): #sends a text to the chat
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    cId = message["username"]
    user = message["username"] #account id
    password = message["password"]
    text = message["displayName"]

    s = SendText(cId,user,password,text)
    if s:
        standard.prnt("sent message to cId: %s"%(cId),"spam", deviceName)
        await websocket.send("success") #compelte transaction  
    else:
        standard.prnt("failed to send text to chat {}".format(cId),"err", deviceName)
        await websocket.send("failed") #compelte transaction  
     

apiCalls = {
    "message-addUser": WSAPIaddUser,
    "message-createChat": WSAPIcreateChat,
    "message-getChat": WSAPIgetChat,
    "message-send": WSAPIsendText
}
description = "adds messaging api :3"
documentation = "documentation/messaging.txt"