settings.clear()
settings.load("data/main")
bgColor = settings.get("bgColor")
txtColor = settings.get("txtColor")
buttonColor = settings.get("buttonColor")

term.setBackgroundColor(bgColor)
term.setTextColor(txtColor)

term.clear()
term.setCursorPos(1,1)
print("listening...")

while true do
    sender,message,port = rednet.receive()
    print(tostring(sender).." ("..tostring(port).."): "..message)
end