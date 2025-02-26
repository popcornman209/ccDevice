import standard, os, random, json

if not os.path.isdir("moduleFiles/secureNet"): os.mkdir("moduleFiles/secureNet")

activeDnsConnections = {}

class connection:
    def __init__(self, websocket, hostName, key, recieveBroadcasts, listeningChannels):
        self.ws = websocket #websocket connection, what to send messages to.
        self.hName = hostName #hostname, can be used to index activeDnsConnections
        self.key = key #private key, used for authenticating that the sender is who they say they are
        self.rcvBroad = recieveBroadcasts #wehter to receive broadcasts or not, spam
        self.channel = listeningChannels #wwhat channels to listen to
    
    async def rcvMsg(self,sender,message,channel,broadcast): #recieve messages
        if self.ws.connected and channel in self.channels and (self.rcvBroad or broadcast == False): #if should be recieved, if connected, listening to provided channel, and if its broadcasted wether listening to that
            await self.ws.send(json.dumps({ #send the message
                "sender": sender.hName,
                "message": message,
                "channel": channel,
                "broadcasted": broadcast
            }))
            return True #success
        else: return False #failure
    
    async def sendMsg(self,message,reciever,channel=""):
        if type(reciever) == str: rcv = activeDnsConnections[reciever] #if hostname provided
        else: rcv = reciever #if connection object provided
        return await rcv.rcvMsg(self,message,channel,False) #send message
    
    async def broadcast(self,message,channel=""): #broadcast message
        for connection in activeDnsConnections: #go through all connections
            await connection.rcvMsg(self,message,channel,True) #broadcast a message to them
        return True #success

class serverConnection(connection): #fake connection, cant recieve messages
    def __init__(self, hostName, key, messageRecievedMethod=None):
        super().__init__(None,hostName,key,False,[""]) #initiate
        self.rcvMethod = messageRecievedMethod #sets the recieving message method

    def rcvMsg(self,sender,message,channel,broadcast): #recieve message
        if self.rcvMethod != None: #if able to recieve messages
            self.rcvMethod(sender,message,channel,broadcast) #do so
            return True #sucess
        else: return False #failure


def verifyDNS(hostName, key): #authenticate connection
    if hostName in activeDnsConnections: #if connection exists
        if activeDnsConnections[hostName].key == key: #if key is valid
            return True #return success
    return False #failure

def registerStaticDNS(hostName): #register a static dns address
    if hostName not in os.listdir("moduleFiles/secureNet"): #if not already taken
        key = standard.randString(standard.settings["secureNetKeyLength"]) #generate a key
        with open("moduleFiles/secureNet/"+hostName,"w") as f: #save the data
            f.write(key) #write the key
        return key #return the key
    else: return False #failure

def connectTempDNS(hostName, websocket, recieveBroadcasts = True, listeningChannelss = []): #register and connect temporary adress
    key = standard.randString(standard.settings["secureNetKeyLength"]) #gen a key
    activeDnsConnections[hostName] = serverConnection(websocket,hostName,key,recieveBroadcasts,listeningChannelss) #connect
    return key #return key

def connectStaticDNS(hostName, key, websocket, recieveBroadcasts = True, listeningChannelss = []): #connect to a static dns address
    if hostName in os.listdir("moduleFiles/secureNet"): #if exists
        with open("moduleFiles/secureNet/"+hostName,"r") as f: #open file
            if f.read() != key: return False #if invalid cancel
        global activeDnsConnections
        activeDnsConnections[hostName] = connection(websocket, hostName, key, recieveBroadcasts, listeningChannelss) #connect the address
        return True #success
    else: return False #failure

def diconnectDNS(hostName,key): #disconnect dns adress
    if verifyDNS(hostName,key): #if valid
        global activeDnsConnections
        del(activeDnsConnections[hostName]) #disconnect the adress
        return True #success
    else: return False #failure



apiCalls = {
}

description = "INCOMPLETE - indirect replacement for rednet, no spoofing, cheaper without modems, and messages sent are private."
documentation = "documentation/secureNet.txt"