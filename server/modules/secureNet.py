import standard, os, json

if not os.path.isdir("moduleFiles/secureNet"): os.mkdir("moduleFiles/secureNet")

activeDnsConnections = {}

class connection:
    def __init__(self, websocket, hostName, key, receiveBroadcasts, listeningChannels):
        self.ws = websocket #websocket connection, what to send messages to.
        self.hName = hostName #hostname, can be used to index activeDnsConnections
        self.key = key #private key, used for authenticating that the sender is who they say they are
        self.rcvBroad = receiveBroadcasts #wehter to receive broadcasts or not, spam
        self.channels = listeningChannels #wwhat channels to listen to
    
    async def rcvMsg(self,sender,message,channel,broadcast): #receive messages
        if self.ws.state == 1 and channel in self.channels and (self.rcvBroad or broadcast == False): #if should be received, if connected, listening to provided channel, and if its broadcasted wether listening to that
            await self.ws.send(json.dumps({ #send the message
                "sender": sender.hName,
                "message": message,
                "channel": channel,
                "broadcasted": broadcast
            }))
            return True #success
        else: return False #failure
    
    async def sendMsg(self,message,receiver,channel=""):
        if type(receiver) == str:
            if receiver not in activeDnsConnections: return False
            rcv = activeDnsConnections[receiver] #if hostname provided
        else: rcv = receiver #if connection object provided
        return await rcv.rcvMsg(self,message,channel,False) #send message
    
    async def broadcast(self,message,channel=""): #broadcast message
        for connection in activeDnsConnections: #go through all connections
            if connection != self.hName: #if not the sender
                await activeDnsConnections[connection].rcvMsg(self,message,channel,True) #broadcast a message to them
        return True #success

class serverConnection(connection): #fake connection, cant receive messages
    def __init__(self, hostName, key, receiveBroadcasts, listeningChannels, messagereceivedMethod=None):
        super().__init__(None,hostName,key,receiveBroadcasts,listeningChannels) #initiate
        self.rcvMethod = messagereceivedMethod #sets the receiving message method

    def rcvMsg(self,sender,message,channel,broadcast): #receive message
        if self.rcvMethod != None: #if able to receive messages
            return self.rcvMethod(sender,message,channel,broadcast) #do so
        else: return False #failure


def verifyDNS(hostName, key): #authenticate connection
    if hostName in activeDnsConnections: #if connection exists
        if activeDnsConnections[hostName].key == key: #if key is valid
            return True #return success
    return False #failure

def registerStaticDNS(hostName): #register a static dns address
    if hostName not in os.listdir("moduleFiles/secureNet") and standard.usernameCheck(hostName): #if not already taken
        key = standard.randString(standard.settings["secureNetKeyLength"]) #generate a key
        with open("moduleFiles/secureNet/"+hostName,"w") as f: #save the data
            f.write(key) #write the key
        return key #return the key
    else: return False #failure

def removeStaticDNS(hostName, key): #remove static dns
    if hostName in os.listdir("moduleFiles/secureNet") and standard.usernameCheck(hostName): #if exists
        with open("moduleFiles/secureNet/"+hostName,"r") as f: #open file
            if f.read() != key: return False #if invalid cancel
        os.remove("moduleFiles/secureNet/"+hostName) #remove the file
        return True #success
    else: return False #failure

def connectTempDNS(hostName, websocket, receiveBroadcasts = True, listeningChannels = []): #register and connect temporary adress
    key = standard.randString(standard.settings["secureNetKeyLength"]) #gen a key
    if hostName in activeDnsConnections: #if the hostname is already registered
        if activeDnsConnections[hostName].ws.state != 1: #check if it got disconnected
            del(activeDnsConnections[hostName]) #disconnect it if so
    if hostName not in activeDnsConnections and hostName not in os.listdir("moduleFiles/secureNet"): #if not already taken
        activeDnsConnections[hostName] = connection(websocket,hostName,key,receiveBroadcasts,listeningChannels) #connect
        return key #return key
    else: return False

def connectStaticDNS(hostName, key, websocket, receiveBroadcasts = True, listeningChannels = []): #connect to a static dns address
    if hostName in os.listdir("moduleFiles/secureNet") and standard.usernameCheck(hostName): #if exists
        with open("moduleFiles/secureNet/"+hostName,"r") as f: #open file
            if f.read() != key: return False #if invalid cancel
        activeDnsConnections[hostName] = connection(websocket, hostName, key, receiveBroadcasts, listeningChannels) #connect the address
        return True #success
    else: return False #failure

def diconnectDNS(hostName,key): #disconnect dns adress
    if verifyDNS(hostName,key): #if valid
        del(activeDnsConnections[hostName]) #disconnect the adress
        return True #success
    else: return False #failure



async def WSAPIRegisterStatic(args): #register static dns
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    hostName = await websocket.recv()
    key = registerStaticDNS(hostName)
    if key:
        await websocket.send(key)
        standard.prnt(f"registered static dns: {hostName}","norm", deviceName)
    else:
        await websocket.send("failure")
        standard.prnt(f"failed to register static dns: {hostName}","err", deviceName)

async def WSAPIConnectTempDNS(args): #connect to temporary dns
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    key = connectTempDNS(message["hostName"],websocket,message["receiveBroadcasts"],message["channels"])
    if key:
        await websocket.send(key)
        standard.prnt(f"registered and connected temporary dns: {message['hostName']}","spam", deviceName)
    else:
        await websocket.send("failure")
        standard.prnt(f"failed to register and connect temporary dns: {message['hostName']}","err", deviceName)

async def WSAPIConnectStaticDNS(args): #connect to static dns
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    success = connectStaticDNS(message["hostName"],message["key"],websocket,message["receiveBroadcasts"],message["channels"])
    if success:
        await websocket.send("success")
        standard.prnt(f"connected to static dns: {message['hostName']}","spam", deviceName)
    else:
        await websocket.send("failure")
        standard.prnt(f"failed to connected to static dns: {message['hostName']}","err", deviceName)
    
async def WSAPIDisconnect(args): #disconnect dns
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    success = diconnectDNS(message["hostName"],message["key"])
    if success:
        await websocket.send("success")
        standard.prnt(f"disconnected from dns: {message['hostName']}","spam", deviceName)
    else:
        await websocket.send("failure")
        standard.prnt(f"failed to disconnect from dns: {message['hostName']}","err", deviceName)

async def WSAPIRemoveStatic(args): #remove static dns
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    success = removeStaticDNS(message["hostName"],message["key"])
    if success:
        await websocket.send("success")
        standard.prnt(f"removed static dns: {message['hostName']}","spam", deviceName)
    else:
        await websocket.send("failure")
        standard.prnt(f"failed to remove static dns: {message['hostName']}","err", deviceName)

async def WSAPISendMsg(args): #send message
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    if verifyDNS(message["hostName"],message["key"]): #if valid
        if message["hostName"] in activeDnsConnections:
            success = await activeDnsConnections[message["hostName"]].sendMsg(message["message"],message["receiver"],channel=message["channel"])
            if success:
                await websocket.send("success")
                return
    await websocket.send("failure")
    standard.prnt(f"failed to send message from {message["hostName"]}","err", deviceName)

async def WSAPIBroadcast(args): #broadcast message
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    message = json.loads(await websocket.recv())
    if verifyDNS(message["hostName"],message["key"]): #if valid
        success = await activeDnsConnections[message["hostName"]].broadcast(message["message"],channel=message["channel"])
        if success: await websocket.send("success")
        else: await websocket.send("failure")
    else:
        await websocket.send("failure")
        standard.prnt(f"failed to broadcast message from {message["hostName"]}","err", deviceName)

apiCalls = {
    "snet-registerStatic": WSAPIRegisterStatic,
    "snet-connectTemp": WSAPIConnectTempDNS,
    "snet-connectStatic": WSAPIConnectStaticDNS,
    "snet-disconnect": WSAPIDisconnect,
    "snet-removeStatic": WSAPIRemoveStatic,
    "snet-sendMsg": WSAPISendMsg,
    "snet-broadcast": WSAPIBroadcast
}

description = "indirect replacement for rednet, no spoofing, cheaper without modems, and messages sent are private."
documentation = "documentation/secureNet.txt"