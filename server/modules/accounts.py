import standard, asyncio, os, json,random

if not os.path.isdir("moduleFiles/accounts"): os.mkdir("moduleFiles/accounts")

def createAccount(username,password): #creates account, returns nothing if account already exists
    account = {"pass":password,"notifications":{},"ownedApps":[]}
    if not os.path.exists("moduleFiles/accounts/"+username): #check if account doesnt already exist
        saveAccount(username,account) #saves new account
        return True #return success
    else: return False
    
def saveAccount(username,account): #saves account file
    with open("moduleFiles/accounts/"+username,"w") as f: #open file
        json.dump(account,f) #saves it to account file
    
def loadAccount(username,password,byPassPassword = False): #load account info, returns nothing if login info incorrect
    if os.path.exists("moduleFiles/accounts/"+username): #check if account exists
        with open("moduleFiles/accounts/%s"%(username),"r") as f: #opens file
            account = json.load(f) #load account info
        if account["pass"] == password or byPassPassword: #check account password
            return account #returns account if success
        else:
            return False, 1 #returns failure
    else:
        return False, 2 #also returns failure

def changePassword(username,password,NewPassword):
    account = loadAccount(username,password) #loads account
    if account:
        account["pass"] = NewPassword #changes password
        saveAccount(username,account) #saves new account
        return True
    else: return False

def sendNotification(username,password,notification,app,byPassPassword=False):
    account = loadAccount(username,password,byPassPassword=byPassPassword) #loads account
    if account: #checks if account information valid
        notifId = "{}-{}".format(app,random.randint(0,standard.settings["notificationIdMaxNum"]))
        account["notifications"][notifId] = {"text":notification,"app":app} #adds notification
        saveAccount(username,account) #saves new account information
        return notifId #returns sucess
    else: return False

def readNotification(username,password,notificationId):
    account = loadAccount(username,password) #loads account
    if account: #checks if account information valid
        if notificationId in account["notifications"]:
            account["notifications"].pop(notificationId) #removes notification
            saveAccount(username,account) #saves new account information
            return True #returns sucess
        else:
            return False, 1 #returns failure
    else:
        return False, 2 #also returns failure


async def WSAPIcreateAcc(args): #create the bank account
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    username = message["username"] #account id
    password = message["password"]

    account = createAccount(username, password) #creates new account
    if account: #if success
        await websocket.send("success") #tell client
        standard.prnt("created account: %s"%(username),"norm", deviceName) #output to console
    else:
        await websocket.send("account already exists") #failed, tell client reasoning
        standard.prnt("failed to create account account: %s already exists."%(username),"err", deviceName) #output to terminal

async def WSAPIloadAccount(args): #create the bank account
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    username = message["username"] #account id
    password = message["password"]

    account = loadAccount(username, password) #load account
    if account:
        await websocket.send(json.dumps(account)) #if success send account
        standard.prnt("loaded account: %s"%(username),"spam", deviceName)
    else:
        await websocket.send("failed") #tell client it failed
        standard.prnt("failed to create account account: %s already exists."%(username),"err", deviceName) #output to terminal

async def WSAPIchangePassword(args): #create the bank account
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    username = message["username"] #account id
    password = message["password"],
    newPassword = message["newPassword"] #new account password

    s = changePassword(username,password,newPassword)
    if s:
        await websocket.send("success") #send if success
        standard.prnt("changed {} password".format(username),"spam", deviceName)
    else:
        await websocket.send("failed") #send if failure
        standard.prnt("failed to change {} password".format(username),"err", deviceName)

async def WSAPIsendNotif(args): #create the bank account
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    username = message["username"] #account id
    password = message["password"]
    notification = message["notification"] #nofication string
    app = message["app"] #app name

    id = sendNotification(username,password,notification,app)
    
    if id:
        await websocket.send(id) #send notification id if success
        standard.prnt("sent notification {} to {}".format(id,username),"spam", deviceName)
    else:
        await websocket.send("failed") #send failed
        standard.prnt("failed to send notification to {}".format(username),"err", deviceName)

async def WSAPIreadNotif(args): #create the bank account
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    username = message["username"] #account id
    password = message["password"]
    notification = message["notification"]

    s = readNotification(username,password,notification)
    if s:
        await websocket.send("success") #send success if worked
        standard.prnt("read notification {} to {}".format(notification,username),"spam", deviceName)
    else:
        await websocket.send("failed") #send failed if failed
        standard.prnt("failed to read notification {} for {}".format(notification,username),"err", deviceName)

async def WSAPIgetNotifList(args):
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    username = message["username"] #account id
    password = message["password"]

    account = loadAccount(username, password) #load account
    if account:
        result = [{"id": notif, "text": account["notifications"][notif]["text"], "app": account["notifications"][notif]["app"]} for notif in account["notifications"]]
        await websocket.send(json.dumps(result)) #if success send account
        standard.prnt("loaded account: %s"%(username),"spam", deviceName)
    else:
        await websocket.send("failed") #tell client it failed
        standard.prnt("failed to create account account: %s already exists."%(username),"err", deviceName) #output to terminal

apiCalls = {
    "accounts-create": WSAPIcreateAcc,
    "accounts-load": WSAPIloadAccount,
    "accounts-changePass": WSAPIchangePassword,
    "accounts-sendNotif": WSAPIsendNotif,
    "accounts-readNotif": WSAPIreadNotif,
    "accounts-getNotifList": WSAPIgetNotifList
}

description = "adds accounts and notifications"
documentation = "documentation/accounts.txt"