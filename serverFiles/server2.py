import sys
sys.dont_write_bytecode = True #fix some stupid ass pycache shit (i dont feel like fixing it)
import asyncio, os, random, traceback, json, importlib.util, standard
from websockets.server import serve
from datetime import datetime

modules = {} #dictionary of modules "moduleName": class
apiCallMethods = {} #dictionary of "apicall": moduleId
apiCallNames = {} #dictionary of "apicall": "module used"

for file in os.listdir("modules"): #import all modules in modules folder
    path = os.path.join("modules", file)
    spec = importlib.util.spec_from_file_location(file[:-3], path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    modules[file[:-3]] = module

for module in modules: #go through each module and get the api calls on each
    for call in modules[module].apiCalls:
        if call not in apiCallMethods: #conflicts
            apiCallMethods[call] = modules[module].apiCalls[call] #sets apicall method
            apiCallNames[call] = module
        else:
            print(standard.colors["err"]+"conflict between module '{}', and '{}', they both use the api call '{}'".format(module,apiCallNames[call],call))
            sys.exit(1)

# standard.balls = 'no work' #shared variables
# modules[0].testing()
# print(standard.balls)

#█░█░█ █▀   █░█ ▄▀█ █▄░█ █▀▄ █░░ █▀▀ █▀█
#▀▄▀▄▀ ▄█   █▀█ █▀█ █░▀█ █▄▀ █▄▄ ██▄ █▀▄
async def echo(websocket):
    try:
        deviceName = await websocket.recv() #get device name
        if standard.settings["showConnections"]: standard.prnt("device connected. (%s)"%(deviceName),"con", deviceName)

        async for message in websocket:
            if message == "close": #closing websocket
                if standard.settings["showConnections"]: standard.prnt("device disconnected. (%s)"%(deviceName),"con", deviceName)
                await websocket.send("goodbye")
                return
            
            elif message in apiCallMethods:
                result = await apiCallMethods[message](websocket,deviceName)
                if result == -1: #error, cancell request
                    await websocket.send("goodbye")
                    return

            else: #api call not recognized
                standard.prnt("%s is not recognized, disconnecting (%s)"%(message,deviceName),"err", deviceName)
                await websocket.send("goodbye") #tell client to disconnect
                return

    except Exception as e: #error handling
        if str(e) != "no close frame received or sent":
            now = datetime.now()
            name = now.strftime("%H_%M_%S")
            standard.prnt("ERROR OCCURED! saved error to logs/(%s)"%(name),"err", deviceName)
            with open("logs/"+name+".txt","w") as f: #save log to file
                tb = traceback.format_exc()
                f.write(str(e)+"\n-----traceback-----\n"+str(tb))
        elif standard.settings["showConnections"]: standard.prnt("device not properly disconnected","err", deviceName) #device shut off mid connection
        return

#█▀▄▀█ ▄▀█ █ █▄░█   █░░ █▀█ █▀█ █▀█
#█░▀░█ █▀█ █ █░▀█   █▄▄ █▄█ █▄█ █▀▀
async def main():
    print("\033c\033[3J\033[95m----ccPhone server 3.0.0----")
    for setting in standard.settings: print(str(setting)+": "+str(standard.settings[setting]))

    print("\n---modules---")
    for module in modules: print("{}:\n\t{} api calls\n\tdesc: {}\n\tdocs: {}".format(module,len(modules[module].apiCalls),modules[module].description,modules[module].documentation))
    print("-------------\n")

    async with serve(echo, "", standard.settings["port"], compression=None):
        await asyncio.Future()

asyncio.run(main())