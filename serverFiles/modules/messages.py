import standard, asyncio, os, json, random
from modules import accounts

def createChat(user,passw,name,owner): #if owner = "" everyone is an owner, otherwise make it username
    account = accounts.loadAccount(user,passw)
    if "chats" not in account:
        account["chats"] = []
        accounts.saveAccount(user, account)
    if account:
        id = str(random.randint(0,standard.settings["idMaxNumber"])) #generate random id
        chat = {
            "name":name,
            "id":id,
            "owner":owner,
            "users":[user],
            "messages":[]
        }
        with open(f"moduleFiles/chats/{id}","w") as f:
            json.dump(chat,f) #saves it to chat file
        id = str(id)
        return id
    else: return False

def getChat(cId):
    if os.path.exists(f"moduleFiles/chats/{cId}"): #check if chat exists
        with open(f"moduleFiles/chats/{cId}","r") as f: #opens file
            account = json.load(f) #load chat info
        return account #returns chat if success
    else:
        return False #return false if failure

def saveChat(cId,chat):
    with open(f"moduleFiles/chats/{cId}","w") as f: #opens file
        json.dump(chat,f) #save chat information

def delchat(cId):
    os.remove(f"moduleFiles/chats/{cId}")

def SendText(cId,user,password,text):
    chat = getChat(cId)
    account = accounts.loadAccount(user,password)
    if chat:
        if user in chat["users"] and account:
            if len(chat["messages"]) >= 16:
                del chat["messages"][0]
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

    chat = createChat(username,password,displayName,owner)
    account = accounts.loadAccount(username,password)
    if type(chat) == str: #if create chat succeeded
        account["chats"].append(chat)
        accounts.saveAccount(username,account)
        await websocket.send(chat) #send chat ID to client
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

async def WSAPIdelchat(args):
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    cId = message["cId"]
    user = message["username"]
    password = message["password"]

    chat = getChat(cId)
    account = accounts.loadAccount(user,password)

    if chat and account:
        if chat["owner"] == user or (user in chat["users"] and chat["owner"] == ""):
            for user in chat["users"]:
                userAccount = accounts.loadAccount(user,"",byPassPassword=True)
                index = userAccount["chats"].index(cId)
                del userAccount["chats"][index]
                accounts.saveAccount(user,userAccount)
            delchat(cId)
            standard.prnt(f"deleted chat {cId}","spam", deviceName)
            await websocket.send("success")
        else:
            standard.prnt(f"failed to delete chat {cId}","err", deviceName)
            await websocket.send("Not the owner")
    else:
        standard.prnt(f"failed to delete chat {cId} because it does not exist","err", deviceName)
        await websocket.send("Does not exist!")
    

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
                accounts.saveAccount(newUser, newAccount)
            newAccount["chats"].append(cId)
            accounts.saveAccount(newUser, newAccount)
            saveChat(cId,chat)
            standard.prnt("user {} invited {} to chat {}".format(invUser,newUser,cId),"norm", deviceName)
            await websocket.send("success")
        else:
            await websocket.send("Not owner")
    else:
        await websocket.send("Incorrect info")

async def WSAPIsendText(args): #sends a text to the chat
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    cId = message["cId"]
    user = message["username"] #account id
    password = message["password"]
    text = message["message"]

    s = SendText(cId,user,password,text)
    if s:
        standard.prnt("sent message to cId: %s"%(cId),"spam", deviceName)
        await websocket.send("success") #compelte transaction  
    else:
        standard.prnt("failed to send text to chat {}".format(cId),"err", deviceName)
        await websocket.send("failed") #compelte transaction  

async def WSAPIcheckgroup(args):
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    cId = await websocket.recv()

    directory = f"moduleFiles/chats"
    file_check = f"{cId}"
    files_in_dir = os.listdir(directory)
    if file_check in files_in_dir:
        await websocket.send("success")
    else:
        await websocket.send("failed")
     

apiCalls = {
    "message-addUser": WSAPIaddUser,
    "message-createChat": WSAPIcreateChat,
    "message-delChat": WSAPIdelchat,
    "message-getChat": WSAPIgetChat,
    "message-send": WSAPIsendText,
    "message-checkGroup": WSAPIcheckgroup
}
description = "adds messaging api :3"
documentation = "documentation/messaging.txt"