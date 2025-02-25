import standard, os, random

if not os.path.isdir("moduleFiles/secureNet"): os.mkdir("moduleFiles/secureNet")

activeDnsConnections = {}

class connection:
    def __init__(self, websocket, key, recieveBroadcasts, listeningChannels):
        self.ws = websocket
        self.key = key
        self.rcvBroad = recieveBroadcasts
        self.channel = listeningChannels
    
    async def sendMsg(self,message,channel,broadcast):
        if self.ws.connected and (channel in self.channels or self.channels == []) and (self.rcvBroad or broadcast == False):
            await self.ws.send(message)
            return True
        else: return False

def registerStaticDNS(hostName):
    if hostName not in os.listdir("moduleFiles/secureNet"):
        key = str(random.randint(0,standard.settings["secureNetKeyLength"]))
        with open("moduleFiles/secureNet/"+hostName,"w") as f:
            f.write(key)
        return key
    else: return False

def connectStaticDNS(hostName, key, websocket, recieveBroadcasts = True, listeningChannelss = []):
    if hostName in os.listdir("moduleFiles/secureNet"):
        with open("moduleFiles/secureNet/"+hostName,"r") as f:
            if f.read() != key: return False
        global activeDnsConnections
        activeDnsConnections[hostName] = connection(websocket, recieveBroadcasts, listeningChannelss)
        return True
    else: return False

def modifyDNS(hostName, key, channels = None, rcvBroad = None):
    if hostName in activeDnsConnections:
        if activeDnsConnections[hostName].key == key:
            if channels: activeDnsConnections[hostName].channels = channels
            if rcvBroad: activeDnsConnections[hostName].rcvBroad = rcvBroad

apiCalls = {
}

description = "INCOMPLETE - indirect replacement for rednet, no spoofing, cheaper without modems, and messages sent are private."
documentation = "documentation/secureNet.txt"