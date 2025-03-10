from datetime import datetime
import string,random,re

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

def randString(length):
  characters = string.ascii_letters + string.digits
  return ''.join(random.choice(characters) for i in range(length))

def usernameCheck(username):
    if not (3 <= len(username) <= 32):
        return False

    # Match allowed pattern
    pattern = r"^[a-zA-Z0-9](?:[a-zA-Z0-9._-]*[a-zA-Z0-9])?$"
    if not re.fullmatch(pattern, username):
        return False

    # Prevent consecutive special characters
    if re.search(r"[._-]{2,}", username):
        return False

    return True

def prnt(message, type, device): #printing function for logs and stuff
    if type != "spam" or settings["showSpam"]:
        now = datetime.now()
        print(f"{colors[type]}[{now.strftime("%H:%M:%S")}] {device}> {message}")