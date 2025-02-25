import standard, os, random

if not os.path.isdir("moduleFiles/secureNet"): os.mkdir("moduleFiles/secureNet")

activeDnsConnections = {}

def registerDns(hostName):
    if hostName not in os.listdir("moduleFiles/secureNet"):
        key = str(random.randint(0,standard.settings["secureNetKeyLength"]))
        with open("moduleFiles/secureNet/"+hostName,"w") as f:
            f.write(key)
        return key
    else: return False

def connectDns(hostName, key, websocket):
    if hostName in os.listdir("moduleFiles/secureNet"):
        with open("moduleFiles/secureNet/"+hostName,"r") as f:
            if f.read() != key: return False
        global activeDnsConnections
        activeDnsConnections[hostName] = websocket
        return True
    else: return False

apiCalls = {
}

description = "INCOMPLETE - indirect replacement for rednet, no spoofing, cheaper without modems, and messages sent are private."
documentation = "documentation/secureNet.txt"