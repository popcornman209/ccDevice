resX, resY = term.getSize()
shell.run("wget", "https://raw.githubusercontent.com/popcornman209/computerCraft-git/main/git.lua")

function clear(text)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,resY)
    term.write(text)
    paintutils.drawBox(1,1,resX,1,colors.gray)
    term.setCursorPos(resX/2-9,1)
    term.write("CCDevice installer")
    term.setBackgroundColor(colors.black)
end

function drawChoices(scroll,choices)
    clear("(up/down/enter): navigate")
    for i = 1+scroll,math.min(#choices,(resY-4)+scroll) do
        term.setCursorPos(4,i+2-scroll)
        print(choices[i])
    end
end

function getChoice(choices)
    cursorPos = 1
    scroll = 0
    drawChoices(scroll,choices)
    going = true
    while going do
        paintutils.drawBox(2,3,2,resY-2)
        term.setCursorPos(2,cursorPos+2-scroll)
        print(">")
        event, key = os.pullEvent("key")
        if key == 265 then
            cursorPos = math.max(cursorPos-1,1)
            if cursorPos < 1+scroll then
                scroll = scroll-1
                drawChoices(scroll,choices)
            end
        elseif key == 264 then
            cursorPos = math.min(cursorPos+1,#choices)
            if cursorPos > (resY-4)+scroll then
                scroll = scroll+1
                drawChoices(scroll,choices)
            end
        elseif key == 257 then
            going = false
            return cursorPos
        end
    end
end


choice = getChoice({"phone"})
if choice == 1 then
    term.clear()
    term.setCursorPos(1,1)
    shell.run("git", "popcornman209", "ccPhone2", "/", "phone")

    clear("enter to continue.")
    term.setCursorPos(1,2)
    print("server ip (default: ws://127.0.0.1:42069/): ")
    address = read()
    if address == "" then address = "ws://127.0.0.1:42069/" end
    settings.set("address", address)
    settings.set("device", "phone")

    settings.save("data/serverData")
    os.reboot()
end
