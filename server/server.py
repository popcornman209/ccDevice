import asyncio, os, random, traceback
from websockets.server import serve
from datetime import datetime

colors = {
    "err": "\033[31m",
    "con": "\033[93m",
    "spam": "\033[37m",
    "norm": "\033[0m"
}

def prnt(message, type, device):
    if type != "spam" or settings["showSpam"]:
        now = datetime.now()
        print("%s[%s] %s> %s"%(colors[type], now.strftime("%H:%M:%S"), device, message))

settings = {}
with open("config.txt","r") as f:
    for line in f.readlines():
        line = line.replace("\n","")
        if line != "":
            temp = line.split(": ")
            settings[temp[0]] = eval(temp[1])



async def echo(websocket):
    try:
        deviceName = await websocket.recv()
        if settings["showConnections"]: prnt("device connected. (%s)"%(deviceName),"con", deviceName)
        async for message in websocket:
            if message == "version":
                message = await websocket.recv()
                if os.path.exists("programs/"+message):
                    prnt("sending %s version"%(message),"spam", deviceName)
                    with open("programs/"+message) as f:
                        info = eval(f.read())
                    await websocket.send(info["version"])
                else:
                    prnt("%s does not exsist, disconnecting"%("programs/"+message),"err", deviceName)
                    await websocket.send("goodbye")
                    return

            elif message == "download":
                message = await websocket.recv()
                if os.path.exists("programs/"+message):
                    with open("programs/"+message) as f:
                        info = eval(f.read())
                    for file in info["files"]:
                        if os.path.exists(file[0]):
                            with open(file[0]) as f:
                                data = f.read()
                            await websocket.send(data)
                            await websocket.send(file[1])
                            prnt("sending "+file[0],"spam", deviceName)
                    await websocket.send("complete")
                    prnt("updated "+message,"norm", deviceName)
                else:
                    prnt("%s does not exsist, disconnecting"%("programs/"+message),"err", deviceName)
                    await websocket.send("goodbye")
                    return
            
            elif message == "store":
                device = await websocket.recv()
                if os.path.exists("store/"+device):
                    for file in os.listdir("store/"+device):
                        with open("store/"+device+"/"+file) as f:
                            data = eval(f.read())
                        await websocket.send(data["name"])
                        await websocket.send(data["id"])
                        await websocket.send(data["desc"])
                    prnt("sending %s apps"%(device),"norm", deviceName)
                    await websocket.send("complete")
                else:
                    prnt("%s does not exsist, disconnecting"%("store/"+device),"err", deviceName)
                    await websocket.send("goodbye")
                    return
            
            elif message == "createBank":
                displayName = await websocket.recv()
                id = str(random.randint(0,settings["idMaxNumber"]))
                key = str(random.randint(0,settings["keyMaxNumber"]))
                await websocket.send(id)
                await websocket.send(key)
                account = {"name":displayName,"key":key,"balance":0,"admin":False}
                with open("bank/"+id,"w") as f:
                    f.write(str(account))
                prnt("created bank account: %s"%(displayName),"norm", deviceName)
            
            elif message == "accountLoad":
                id = await websocket.recv()
                key = await websocket.recv()
                if os.path.exists("bank/%s"%(id)):
                    with open("bank/%s"%(id),"r") as f:
                        details = eval(f.read())
                    if details["key"] == key:
                        if details["admin"]: await websocket.send("999999")
                        else: await websocket.send(str(details["balance"]))
                        await websocket.send(str(details["name"]))
                        prnt("sent bank account %s info"%(id),"spam", deviceName)
                    else:
                        await websocket.send("invalid")
                        prnt("attemped to get balance: wrong key","err", deviceName)
                else:
                    await websocket.send("invalid")
                    prnt("attemped to get balance: wrong id","err", deviceName)
            
            elif message == "accountNameChange":
                id = await websocket.recv()
                key = await websocket.recv()
                name = await websocket.recv()
                if os.path.exists("bank/%s"%(id)):
                    with open("bank/%s"%(id),"r") as f:
                        details = eval(f.read())
                    if details["key"] == key:
                        details["name"] = name
                        with open("bank/"+id,"w") as f:
                            f.write(str(details))
                        prnt("changed account %s name."%(id),"norm", deviceName)
                    else:
                        await websocket.send("invalid")
                        prnt("attemped to get balance: wrong key","err", deviceName)
                else:
                    await websocket.send("invalid")
                    prnt("attemped to get balance: wrong id","err", deviceName)

            elif message == "transferMoney":
                id = await websocket.recv()
                key = await websocket.recv()
                reciever = await websocket.recv()
                amount = float(await websocket.recv())
                if amount >= 0:
                    if os.path.exists("bank/%s"%(id)) and os.path.exists("bank/%s"%(reciever)):
                        with open("bank/%s"%(id),"r") as f:
                            details = eval(f.read())
                        if details["key"] == key:
                            if details["balance"] >= amount or details["admin"]:
                                if details["admin"] == False:
                                    details["balance"] -= amount
                                    with open("bank/%s"%(id),"w") as f:
                                        f.write(str(details))
                                with open("bank/%s"%(reciever),"r") as f:
                                    details = eval(f.read())
                                details["balance"] += amount
                                with open("bank/%s"%(reciever),"w") as f:
                                    f.write(str(details))
                                await websocket.send("success")
                                prnt("sent $%s from %s to %s."%(str(amount),id,reciever),"norm", deviceName)
                            else:
                                await websocket.send("not enough money!")
                                prnt("attemped send money: no money","err", deviceName)
                        else:
                            await websocket.send("invalid login info!")
                            prnt("attemped send money: wrong key","err", deviceName)
                    else:
                        await websocket.send("invalid login info!")
                        prnt("attemped send money: wrong id","err", deviceName)
                else:
                    await websocket.send("no negative amounts!")
                    prnt("attemped send money: invalid price","err", deviceName)
            
            elif message == "getCurrency": await websocket.send(settings["currency"])
            elif message == "convertToCurrency":
                money = await websocket.recv()
                await websocket.send(str(float(money)/(settings["amountOfItem"]/settings["priceOfCurrency"])))
            elif message == "convertFromCurrency":
                money = await websocket.recv()
                await websocket.send(str(float(money)*(settings["amountOfItem"]/settings["priceOfCurrency"])))
                
            elif message == "close":
                if settings["showConnections"]: prnt("device disconnected. (%s)"%(deviceName),"con", deviceName)
                await websocket.send("goodbye")
                return

            else:
                prnt("%s is not recognized, disconnecting (%s)"%(message,deviceName),"err", deviceName)
                await websocket.send("goodbye")
                return
    except Exception as e:
        if str(e) != "no close frame received or sent":
            now = datetime.now()
            name = now.strftime("%H_%M_%S")
            prnt("ERROR OCCURED! saved error to logs/(%s)"%(name),"err", deviceName)
            with open("logs/"+name+".txt","w") as f:
                tb = traceback.format_exc()
                f.write(str(e)+"\n-----traceback-----\n"+str(tb))
        elif settings["showConnections"]: prnt("device not properly disconnected","err", deviceName)
        return

async def main():
    print("\033c\033[3J\033[95m----ccPhone server 2.0.0----\n\033[35mport: %s\ncurrency: %s"%(settings["port"],settings["currency"]))
    async with serve(echo, "", settings["port"], compression=None):
        await asyncio.Future()

asyncio.run(main())
