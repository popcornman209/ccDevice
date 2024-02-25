--args = { ... }
--if args ~= {} then
--    fileId = args[1]
--    currentVersion = args[2]
--    log = args[3]
--    restart = args[4]
--end

function prnt(str) if log then print(str) end end

prnt("id: "..fileId)
prnt("current version: "..currentVersion)

settings.load("data/serverData")
address = settings.get("address")
device = settings.get("device")

prnt("connecting...")
ws = http.websocket(address)

if ws ~= false then 
    ws.send(os.getComputerLabel())
    ws.send("version")
    ws.send(device.."/"..fileId)
    prnt("getting newest version...")
    version = ws.receive()
    if version ~= "goodbye" then
        prnt("newest version: "..version)
        if version ~= currentVersion then
            ws.send("download")
            ws.send(device.."/"..fileId)
            paths = {}
            data = {}
            receiving = true
            while receiving do
                message = ws.receive()
                if message ~= "complete" then
                    table.insert(data, message)
                    path = ws.receive()
                    table.insert(paths, path)
                else receiving = false end
            end
            prnt("installing...")

            for i = 1,table.getn(paths) do
                file = fs.open(paths[i],"w")
                file.write(data[i])
                file.close()
                prnt("installed "..paths[i])
            end
            prnt("completed.")
            if restart then os.reboot() end
        else prnt("up to date.") end
        ws.send("close")
        prnt("disconnected")
    else prnt("failed: file doesnt exsist") end
else prnt("could not connect to server")
end