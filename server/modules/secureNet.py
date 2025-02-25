import standard, os, random

if not os.path.isdir("moduleFiles/secureNet"): os.mkdir("moduleFiles/secureNet")

connectedDevices = []

def registerDns(name):
    if name not in os.listdir("moduleFiles/secureNet"):
        key = str(random.randint(0,standard.settings["secureNetKeyLength"]))
        with open("moduleFiles/bank/"+id,"w") as f:
            f.write(key)
        return key
    else: return False

apiCalls = {
}

description = "INCOMPLETE - indirect replacement for rednet, no spoofing, cheaper without modems, and messages sent are private."
documentation = "documentation/secureNet.txt"