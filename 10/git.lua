local tArgs, gUser, gRepo, gPath, gBranch = {...}, nil, nil, "", "master"
local usage = [[
 github <user> <repo> [path] [remote path] [branch]
 Remote path defaults to the root of the repo.
 Path defaults to the download folder.
 Branch defaults to master.
 If you want to leave an option empty use a dot.
 Example: github johnsmith hello-world . foo
 Everything inside the directory foo will be 
 downloaded to downloads/hello-world/.
  ]]
local blackList = [[
@blacklistedfile
]]
 
local title = "Github Repo Downloader"
local fileList = {dirs={},files={}}
local x , y = term.getSize()

function removeSubstring(str, substr)
    local startIndex, endIndex = string.find(str, substr)
    if startIndex and endIndex then
        local prefix = string.sub(str, 1, startIndex - 1)
        local suffix = string.sub(str, endIndex + 1)
        return prefix .. suffix
    end
    return str
end

function printUsage()
    local str = "Press space key to continue"
    term.setCursorPos(1,y/2-4)
    print(usage)
    term.setCursorPos((x-str:len())/2,y/2+7)
    print(str)
    while true do
        local event, param1 = os.pullEvent("key")
        if param1 == 57 then
            sleep(0)
            break
        end
    end
    term.setCursorPos(1,1)
end
 
-- Download File
function downloadFile( path, url, name )
    print("Downloading File: "..name)
    dirPath = path:gmatch('([%w%_%.% %-%+%,%;%:%*%#%=%/]+)/'..name..'$')()
    if dirPath ~= nil and not fs.isDir(dirPath) then fs.makeDir(dirPath) end
    local content = http.get(url)
    local file = fs.open(path,"w")
    file.write(content.readAll())
    file.close()
end
 
-- Get Directory Contents
function getGithubContents( path )
    local pType, pPath, pName, checkPath = {}, {}, {}, {}
    local response = http.get("https://api.github.com/repos/"..gUser.."/"..gRepo.."/contents/"..path.."/?ref="..gBranch)
    if response then
        response = response.readAll()
        if response ~= nil then
            for str in response:gmatch('"type":"(%w+)"') do table.insert(pType, str) end
            for str in response:gmatch('"path":"([^\"]+)"') do table.insert(pPath, str) end
            for str in response:gmatch('"name":"([^\"]+)"') do table.insert(pName, str) end
        end
    else
        print( "Error: Can't resolve URL" )
        sleep(2)
        term.setCursorPos(1,1)
        error()
    end
    return pType, pPath, pName
end
 
-- Blacklist Function
function isBlackListed( path )
    if blackList:gmatch("@"..path)() ~= nil then
        return true
    end
end
 
-- Download Manager
function downloadManager( path )
    local fType, fPath, fName = getGithubContents( path )
    for i,data in pairs(fType) do
        if data == "file" then
            checkPath = http.get("https://raw.github.com/"..gUser.."/"..gRepo.."/"..gBranch.."/"..fPath[i])
            if checkPath == nil then
                fPath[i] = fPath[i].."/"..fName[i]
            end
            local path = "downloads/"..gRepo.."/"..fPath[i]
            if gPath ~= "" then path = gPath.."/"..removeSubstring(fPath[i], tArgs[4]) end
            if not fileList.files[path] and not isBlackListed(fPath[i]) then
                fileList.files[path] = {"https://raw.github.com/"..gUser.."/"..gRepo.."/"..gBranch.."/"..fPath[i],fName[i]}
            end
        end
    end
    for i, data in pairs(fType) do
        if data == "dir" then
            local path = "downloads/"..gRepo.."/"..fPath[i]
            if gPath ~= "" then path = gPath.."/"..removeSubstring(fPath[i], tArgs[4]) end
            if not fileList.dirs[path] then 
                print("Listing directory: "..fName[i])
                fileList.dirs[path] = {"https://raw.github.com/"..gUser.."/"..gRepo.."/"..gBranch.."/"..fPath[i],fName[i]}
                downloadManager( fPath[i] )
            end
        end
    end
end
 
-- Main Function
function main( path )
    print("Connecting to Github")
    downloadManager(path)
    for i, data in pairs(fileList.files) do
        downloadFile( i, data[1], data[2] )
    end
    print("Download completed")
    sleep(2,5)
    term.setCursorPos(1,1)
end
 
-- Parse User Input
function parseInput( user, repo , dldir, path, branch )
    if path == nil then path = "" end
    if branch ~= nil then gBranch = branch end
    if repo == nil then printUsage()
    else
        gUser = user
        gRepo = repo
        if dldir ~= nil then gPath = dldir end
        main( path ) 
    end
end
 
if not http then
    print("You need to enable the HTTP API!")
    sleep(3)
    term.setCursorPos(1,1)
else
    for i=1, 5, 1 do
        if tArgs[i] == "." then tArgs[i] = nil end
    end 
    parseInput( tArgs[1], tArgs[2], tArgs[3], tArgs[4], tArgs[5] )
end