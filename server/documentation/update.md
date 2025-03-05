# updating api documentation

## terms:
`app id` device/app, for example "all/CraftOS" or "phone/bank"<br />
`device` just the device being used, by default "phone","computer", and "all"

## api uses:
`version` getting app version,<br />
`download` for downloading files and directories needed<br />
`store` getting all devices in the store for a device

## steps to using as client - not going to finish converting to md as im going to change this.
connect to websocket<br />
send device name
### send "version"
send app id, ex: all/apt<br />
recieve version or "goodbye" if app doesnt exist
### send "download"
send app id
if app exists
    for each file:
        if file exists
            recieve fileData
            recieve fileSavePath
        else
            recieve "goodbye"
            connection close
    recieve "complete"

    for each required directories
        recieve folderPath
    recieve "complete"

### send "store"
send device
    for each app for device
        recieve name
        recieve id
        recieve description
    recieve "complete"