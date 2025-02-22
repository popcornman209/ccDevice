from datetime import datetime

settings = {}
with open("config.txt","r") as f:
    for line in f.readlines():
        line = line.replace("\n","")
        if line != "":
            temp = line.split(": ")
            settings[temp[0]] = eval(temp[1])

colors = { #terminal colors
    "err": "\033[31m",
    "con": "\033[93m",
    "spam": "\033[37m",
    "norm": "\033[0m"
}

def prnt(message, type, device): #printing function for logs and stuff
    if type != "spam" or settings["showSpam"]:
        now = datetime.now()
        print("%s[%s] %s> %s"%(colors[type], now.strftime("%H:%M:%S"), device, message))