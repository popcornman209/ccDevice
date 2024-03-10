function prnt(str, log) if log then print(str) end end

function download(fileId, currentVersion, log, address, device)
    prnt("id: "..fileId, log)
    prnt("current version: "..currentVersion, log)

    if address == nil or device == nil then
        settings.load("data/serverData")
        address = settings.get("address")
        device = settings.get("device")
    end

    prnt("connecting...", log)
    local ws = http.websocket(address)

    if ws ~= false then 
        ws.send(os.getComputerLabel())
        ws.send("version")
        ws.send(device.."/"..fileId)
        prnt("getting newest version...", log)
        local version = ws.receive()
        if version ~= "goodbye" then
            prnt("newest version: "..version, log)
            if version ~= currentVersion then
                ws.send("download")
                ws.send(device.."/"..fileId)
                local paths = {}
                local data = {}
                local receiving = true
                while receiving do
                    local message = ws.receive()
                    if message ~= "complete" then
                        table.insert(data, message)
                        local path = ws.receive()
                        table.insert(paths, path)
                    else receiving = false end
                end
                prnt("installing...", log)

                for i = 1,table.getn(paths) do
                    local file = fs.open(paths[i],"w")
                    file.write(data[i])
                    file.close()
                    prnt("installed "..paths[i], log)
                end
                prnt("completed.", log)
                ws.send("close")
                prnt("disconnected", log)
                return true, "success"
            else
                prnt("up to date.", log)
                ws.send("close")
                prnt("disconnected", log)
                return false, "up to date"
            end
        else
            prnt("failed: file doesnt exist", log)
            return false, "files doesnt exist"
        end
    else
        prnt("could not connect to server", log)
        return false, "couldnt connect to server"
    end
end
