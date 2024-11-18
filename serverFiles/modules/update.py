import standard, asyncio, os, json

async def version(websocket,deviceName): #get app version
    message = await websocket.recv() #get app to check
    if os.path.exists("programs/"+message):
        standard.prnt("sending %s version"%(message),"spam", deviceName)
        with open("programs/"+message) as f:
            info = json.load(f) #get app information
        await websocket.send(info["version"]) #send app version
    else:
        standard.prnt("%s does not exsist, disconnecting"%("programs/"+message),"err", deviceName)
        return -1

async def download(websocket,deviceName): #download app files
    message = await websocket.recv() #get app id
    if os.path.exists("programs/"+message): #if app exists
        with open("programs/"+message) as f:
            info = json.load(f) #get app information
        for file in info["files"]: #sends all files of an app
            if os.path.exists(file[0]):
                with open(file[0]) as f:
                    data = f.read()
                await websocket.send(data) #send file data
                await websocket.send(file[1]) #send file location
                standard.prnt("sending "+file[0],"spam", deviceName)
            else:
                standard.prnt("File: %s does not exist!"%(file[0]),"err", deviceName)
                return -1 #file does not exists
        await websocket.send("complete")
        for directory in info["directories"]: #send directories needed for app
            await websocket.send(directory)
            standard.prnt("sending directory "+directory,"spam", deviceName)
        await websocket.send("complete") #message compelte
        standard.prnt("updated "+message,"norm", deviceName)
    else:
        standard.prnt("%s does not exsist, disconnecting"%("programs/"+message),"err", deviceName)
        return -1

async def store(websocket,deviceName): #check app store
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
    "version": version,
    "download": download,
    "store": store
}
description = "for updating & installing files along with app store support"
documentation = "documentation/update.txt"