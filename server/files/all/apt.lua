args = {...}

aptVersion = "1.0.0"

settings.clear()
settings.load("data/serverData")

server = "main"
servers = settings.get("servers")
device = settings.get("device")
forceDevice = false

current = 1
skip = false
for arg = 1,#args do
    if skip == false then
        if string.sub(args[arg],1,1) == "-" then
            if args[arg] == "-m" or args[arg] == "--mirror" then
                if args[arg+1] ~= nil then
                    server = args[arg+1]
                    skip = true
                else error("no mirror given!") end
            elseif args[arg] == "-d" or args[arg] == "--device" then
                if args[arg+1] ~= nil then
                    device = args[arg+1]
                    skip = true
                    forceDevice = true
                else error("no device given!") end
            elseif args[arg] == "-h" or args[arg] == "--help" then
                print("usage:\napt [install/update/remove/list/search/view] [program]\n\ninstall: install new program\nupdate : update program, or whole system\nremove : delete a program\nlist   : list installed programs\nsearch : search available programs\nview   : view programs description\n\n-h --help  : open this menu\n-m --mirror: change mirror (main is default)\n-d --device: change device")
            end
        else
            if current == 1 then --install/update/remove
                option = args[arg]
                current = 2
            elseif current == 2 then
                program = args[arg]
                current = 3
            else error("could not recognize "..args[arg]) end
        end
    else skip = true end
end

require("/modules/update")

if option == "install" then
    if program ~= nil then
        print("install "..program.."? [y/n] ")
        if read() == "y" then download(program,"nil",true,servers[server],device) end
    else error("no program given!") end
elseif option == "update" then
    if program == nil then
        print("update system? [y/n] ")
        if read() == "y" then
            files = fs.list("programs")
            for i,file in pairs(files) do
                settings.clear()
                settings.load("programs/"..file)
                tempDevice = device
                if forceDevice == false and settings.get("device") ~= nil then tempDevice = settings.get("device") end
                download(settings.get("id"),settings.get("version"),true,servers[server],tempDevice)
            end
        end
    else
        if fs.exists("programs/"..program) then
            print("update "..program.."? [y/n] ")
            if read() == "y" then
                settings.clear()
                settings.load("programs/"..program)
                tempDevice = device
                if forceDevice == false and settings.get("device") ~= nil then tempDevice = settings.get("device") end
                download(settings.get("id"),settings.get("version"),true,servers[server],tempDevice)
            end
        else error(program.." wasnt found.") end
    end
elseif option == "remove" then
    if program ~= nil then
        if fs.exists("uninstall/"..program) then
            print("delete "..program.."? [y/n] ")
            if read() == "y" then
                settings.clear()
                settings.load("uninstall/"..program)
                files = settings.get("files")
                for i = 1,table.getn(files) do
                    fs.delete(files[i])
                end
            end
        else error(program.." wasnt found.") end
    else error("you didnt give a program") end
elseif option == "list" then
    for i, item in pairs(fs.list("programs")) do print(item) end
elseif option == "search" then
    if program == nil then program = "" end
    ws = http.websocket(servers[server])
    ws.send(os.getComputerLabel)
    ws.send("store")
    ws.send(device)
    names = {}
    ids = {}
    receiving = true
    while receiving do
        name = ws.receive()
        if name ~= "complete" and name ~= "goodbye" then
            id = ws.receive()
            ws.receive()
            table.insert(ids,id)
            table.insert(names,name)
        elseif name == "goodbye" then error("failed, wrong device maybe?")
        else receiving = false end
    end
    for i,name in pairs(names) do
        if string.find(name,program) or string.find(ids[i],program) then print(ids[i]..": "..name) end
    end
    ws.send("close")
end