import standard, os, json

async def fetchData(args): #get app version
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    appId = await websocket.recv().replace("%","/") #get app to check
    if os.path.exists("packages/"+appId):
        standard.prnt("sending %s version"%(appId),"spam", deviceName)
        with open("packages/"+appId) as f:
            info = f.read() #get app information
        await websocket.send(info) #send app version
    else:
        standard.prnt("%s does not exsist, disconnecting"%("programs/"+appId),"err", deviceName)
        return -1


async def download(args): #download app files
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    appId = await websocket.recv().replace("%","/") #get app id
    if os.path.exists("packages/"+appId): #if app exists
        with open("packages/"+appId) as f: 
            rawData = f.read() # get app info
        await websocket.send(rawData)
        data = json.loads(rawData)
        for file in data["files"]: #sends all files of an app
            if os.path.exists(file[0]):
                with open(file[0]) as f:
                    fileData = f.read()
                await websocket.send(json.dumps({
                    "message": "file",
                    "fileName": file[1],
                    "data": fileData
                }))
                standard.prnt("sending "+file[0],"spam", deviceName)
            else:
                standard.prnt("File: %s does not exist!"%(file[0]),"err", deviceName)
                return -1 #file does not exists

        await websocket.send(json.dumps({
            "message": "complete"
        }))
        standard.prnt("updated "+appId,"norm", deviceName)
    else:
        standard.prnt("%s does not exsist, disconnecting"%("packages/"+appId),"err", deviceName)
        return -1

async def store(args): #check app store
    websocket = args["websocket"]
    deviceName = args["deviceName"]

    device = await websocket.recv() #get device
    if os.path.exists("moduleFiles/store/"+device):
        for file in os.listdir("moduleFiles/store/"+device): #loop through all apps for device
            with open("moduleFiles/store/"+device+"/"+file) as f:
                data = json.load(f) #load app data
            await websocket.send(data["name"]) #send app name
            await websocket.send(data["id"]) #send app id
            await websocket.send(data["desc"]) #send app description
        standard.prnt("sending %s apps"%(device),"norm", deviceName)
        await websocket.send("complete")
    else:
        standard.prnt("%s does not exsist, disconnecting"%("moduleFiles/store/"+device),"err", deviceName)
        return -1
    
apiCalls = {
    "package-fetchData": fetchData,
    "package-download": download,
    "package-store": store
}
description = "for updating & installing files along with app store support"
documentation = "documentation/update.txt"
