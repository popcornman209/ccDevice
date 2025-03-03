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
sends money between accounts
returns "success" if worked, otherwise will return string of reason why

`createAccount(name)`<br />
creates bank account, name is the account display name
returns {"id":id,"key":key}

`loadAccount(id,key)`<br />
loads bank account information
returns account dictionary if success, otherwise returns nothing


steps to use as client:
connect to websocket
    send "bank-create"
        send account name
        recieve JSON {"id":id, "key":key}

    send "bank-load"
        send JSON {"id":id, "key":key}
        if valid login
            recieve JSON account dictionary
        else
            recieve "invalid login info!"

    send "bank-nameChange"
        send JSON {"id":id, "key":key, "name":newName}
        
        if valid login 
            recieve "success"
        else
            recieve "invalid login info!"

    send "bank-transfer"
        send JSON {"id":senderId, "key":senderKey, "reciever":recieverId, "amount": amountToSend}
        if all info valid:
            recieve "success"
        else
            recieve reasoning behind failure (string)