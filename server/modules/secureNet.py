import standard, os, random, json

if not os.path.isdir("moduleFiles/secureNet"): os.mkdir("moduleFiles/secureNet")

activeDnsConnections = {}

class connection:
    def __init__(self, websocket, hostName, key, recieveBroadcasts, listeningChannels):
        self.ws = websocket
        self.hName = hostName
        self.key = key
        self.rcvBroad = recieveBroadcasts
        self.channel = listeningChannels
    
    async def rcvMsg(self,sender,message,channel,broadcast):
        if self.ws.connected and (channel in self.channels or self.channels == []) and (self.rcvBroad or broadcast == False):
            await self.ws.send(json.dumps({
                "sender": sender.hName,
                "message": message,
                "channel": channel,
                "broadcasted": broadcast
            }))
            return True
        else: return False
    
    async def sendMsg(self,message,reciever,channel=""):
        if type(reciever) == str: rcv = activeDnsConnections[reciever]
        else: rcv = reciever
        return await rcv.rcvMsg(self,message,channel,False)
    
    async def broadcast(self,message,channel=""):
        for connection in activeDnsConnections:
            await connection.rcvMsg(self,message,channel,True)
        return True

class serverConnection(connection):
    def __init__(self, hostName, key):
        self.ws = None
        self.hName = hostName
        self.key = key
        self.rcvBroad = False
        self.channels = None
    def rcvMsg(self, sender, message, channel, broadcast): return False

def verifyDNS(hostName, key):
    if hostName in activeDnsConnections:
        if activeDnsConnections[hostName].key == key:
            return True
    return False

def registerStaticDNS(hostName):
    if hostName not in os.listdir("moduleFiles/secureNet"):
        key = str(random.randint(0,standard.settings["secureNetKeyLength"]))
        with open("moduleFiles/secureNet/"+hostName,"w") as f:
            f.write(key)
        return key
    else: return False

def registerDynamicDNS(hostName, websocket, recieveBroadcasts = True, listeningChannelss = []):
    key = str(random.randint(0,standard.settings["secureNetKeyLength"]))
    activeDnsConnections[hostName] = serverConnection(websocket,hostName,key,recieveBroadcasts,listeningChannelss)
    return key

def connectStaticDNS(hostName, key, websocket, recieveBroadcasts = True, listeningChannelss = []):
    if hostName in os.listdir("moduleFiles/secureNet"):
        with open("moduleFiles/secureNet/"+hostName,"r") as f:
            if f.read() != key: return False
        global activeDnsConnections
        activeDnsConnections[hostName] = connection(websocket, hostName, key, recieveBroadcasts, listeningChannelss)
        return True
    else: return False

def shutdownDNS(hostName,key):
    if verifyDNS(hostName,key):
        global activeDnsConnections
        del(activeDnsConnections[hostName])
        return True
    else: return False

apiCalls = {
}

description = "INCOMPLETE - indirect replacement for rednet, no spoofing, cheaper without modems, and messages sent are private."
documentation = "documentation/secureNet.txt"