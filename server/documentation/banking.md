# banking api documentation

## terms
`id` random numbers, the username of an account<br />
`key` private key, also random numbers but is used for identification and should be kept private<br />
`admin account` has infinite balance, for atm's primarily<br />
`account dictionary` how the accounts are stored, example below:
```python
{
    "name": "testing",      #display name for account
    "key": "7708134",       #key for account, like a password
    "balance": 0,           #account balance
    "admin": false,         #wether account is admin or not
    "notifAccounts": [],    #accounts to send notifications to
    "transactions": []      #list of transactions, all strings
}
```

## websocket api calls
`bank-create` creating bank accounts<br />
`bank-load` loading bank account information<br />
`bank-nameChange` changing bank account name<br />
`bank-transfer` transfering money between accounts

## python library methods
`transferMoney(senderId,senderKey,reciverId,amount)`<br />
sends money between accounts<br />
returns "success" if worked, otherwise will return string of reason why

`createAccount(name)`<br />
creates bank account, name is the account display name<br />
returns {"id":id,"key":key}

`loadAccount(id,key)`<br />
loads bank account information<br />
returns account dictionary if success, otherwise returns nothing


## steps to use ws as client:
connect to websocket
send device name
### send "bank-create"
send account name
recieve JSON {"id":id, "key":key}

### send "bank-load"
send JSON {"id":id, "key":key}
recieve JSON account dictionary if success, otherwise "invalid login info!"

### send "bank-nameChange"
send JSON {"id":id, "key":key, "name":newName}
recieve "success" or "invalid login info!"

### send "bank-transfer"
send JSON {"id":senderId, "key":senderKey, "reciever":recieverId, "amount": amountToSend}
if all info valid recieve "success", otherwise recieve string for reason of failure