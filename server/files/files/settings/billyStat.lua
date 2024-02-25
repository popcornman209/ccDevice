quit = false
while quit == false do
    if settings.load("data/billies") == false then
        settings.clear()
        settings.set("prot","global")
        settings.save("data/billies")
    end


    settings.clear()
    settings.load("data/main")
    bgColor = getSetting("bgColor",colors.cyan)
    txtColor = getSetting("txtColor",colors.white)
    buttonColor = getSetting("buttonColor",colors.blue)
    devMode = getSetting("devMode",false)

    term.setBackgroundColor(bgColor)
    term.setTextColor(txtColor)
    term.clear()
    term.setBackgroundColor(colors.red)
    if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
    term.setCursorPos(1,1)
    term.write("<")
    term.setBackgroundColor(bgColor)
    write("billy stat",2)

    settings.clear()
    settings.load("data/billies")
    paintutils.drawBox(8,4,18,4,buttonColor)
    write("protocol",4)

    going = true
    while going do
        rmv = false
        event, button, x, y = os.pullEvent("mouse_click")
        if x >= 8 and x <= 18 and y == 4 then
            going = false
            term.setBackgroundColor(bgColor)
            term.clear()
            term.setCursorPos(1,1)
            settings.clear()
            settings.load("data/billies")
            prot = settings.get("prot")
            print("protocol (was "..prot.."):")
            prot = read()
            settings.set("prot",prot)
            settings.save("data/billies")
        elseif x == 1 and y == 1 then
            going = false
            quit = turtle
        end
    end
end