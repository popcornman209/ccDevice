binds = {
    ["up"] = 265,
    ["down"] = 264,
    ["enter"] = 257
}

if os.about ~= nil then -- if using craft os pc emulator
    binds = {
        ["up"] = 200,
        ["down"] = 208,
        ["enter"] = 28
    }
end

resX, resY = term.getSize()
function clear()
    term.setBackgroundColor(colors.black)
    term.clear()
    paintutils.drawBox(1,1,resX,1,colors.gray)
    term.setCursorPos(resX/2-9,1)
    term.write("CCDevice Bootloader")
    term.setCursorPos(1,resY)
    term.setBackgroundColor(colors.black)
    term.write("(up/down/enter): navigate")
end

if settings.get("defaultBoot") ~= nil then
    if fs.exists(settings.get("defaultBoot")) then
        shell.run(settings.get("defaultBoot"))
        return
    end
end

if fs.exists("boot") then drives = {"boot"} else drives = {} end

peripherals = peripheral.getNames()
for i=1,#peripherals do
    if peripheral.getType(peripherals[i]) == "drive" then
        table.insert(drives,disk.getMountPath(peripherals[i]))
    end
end

mountPoints = {}
bootNames = {}
for drive=1,#drives do
    mounts = fs.list(drives[drive])
    for mount = 1,#mounts do
        table.insert(mountPoints, drives[drive].."/"..mounts[mount])
        table.insert(bootNames, mounts[mount])
    end
end

function drawBoot(scroll)
    clear()
    for i = 1+scroll,math.min(#bootNames,(resY-4)+scroll) do
        term.setCursorPos(4,i+2-scroll)
        print(bootNames[i])
        term.setCursorPos(resX/2,i+2-scroll)
        print(mountPoints[i])
    end
end

cursorPos = 1
scroll = 0

drawBoot(scroll)
going = true
while going do
    paintutils.drawBox(2,3,2,resY-2)
    term.setCursorPos(2,cursorPos+2-scroll)
    print(">")
    event, key = os.pullEvent("key")
    if key == binds["up"] then
        cursorPos = math.max(cursorPos-1,1)
        if cursorPos < 1+scroll then
            scroll = scroll-1
            drawBoot(scroll)
        end
    elseif key == binds["down"] then
        cursorPos = math.min(cursorPos+1,#bootNames)
        if cursorPos > (resY-4)+scroll then
            scroll = scroll+1
            drawBoot(scroll)
        end
    elseif key == binds["enter"] then
        going = false
    end
end
term.clear()
term.setCursorPos(1,1)
shell.run(mountPoints[cursorPos])