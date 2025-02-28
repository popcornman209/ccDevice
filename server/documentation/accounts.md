# accounts api documentation

## terms
`id` username, string<br />
`password` string of password, should be encrypted client side using sha256<br />
`account dictionary` how account information is storedd
```python
    {
        "pass":password,        #account password
        "notifications":{},     #list of notifications
        "ownedApps":[]          #list of owned apps
    }
```
`notifications dictionary` how notifications are stored
```python
{
    "notification id": {
        "text": "text for notification",
        "app": "app accociated with notification"
    }
}
```

## websocket api calls
`accounts-create` creates account<br />
`accounts-load` loads account information and sends to client<br />
`accounts-changePass` changes account password<br />
`accounts-sendNotif` send notification to account<br />
`accounts-readNotif` read notification (removes from list)<br />
`accounts-getNotifList` get list of notifications (better for lua interperitation)

## library functions
`createAccount(username,password)` creates account, returns True or False

`saveAccount(username,account)` saves account data, returns nothing

`loadAccount(username,password,byPassPassword = False)` loads account dictionary, byPassPassword ignores password check, returns account dicionary if success, otherwise False, 1 if password incorrect or 2 for username incorrect

`changePassword(username,password,NewPassword)` changes account password, returns True or False

`sendNotification(username,password,notification,app,byPassPassword=False)` sends notification to account, notification is the text, app is a string, "none" for none, returns notification id

`readNotification(username,password,notificationId)` removes notification from notifications list. returns True or False, 1 for notif not exist, and 2 for ident failed


## steps to use ws as client:
connect to websocket
send device name
### send "accounts-create"
send JSON {"username":username, "password":password}<br />
recive "success" or failure reason

### send "accounts-load"
send JSON {"username":username, "password":password}<br />
recieve JSON account dictionary or "failed"

### send "accounts-changePass"
send JSON {"username":username, "password":password, "newPassword":newPass}<br />
recieve "success" or "failed"

### send "accounts-sendNotif"
send JSON {"username":username, "password":password,"notification":notification text, "app": app id or "none"}<br />
recive notification id or "failed"

### send "accounts-readNotif"
send JSON {"username":username, "password":password,"notification":notification id}<br />
recieve "success" or "failed"

### send "accounts-getNotifList"
send JSON {"username":username, "password":password}
recive json
```json
[
    {
        "id": notification id,
        "text": notif texy,
        "app": app for notification
    }
] 
```
or "failed"