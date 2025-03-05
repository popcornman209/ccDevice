# secureNet api documentation

## terms:
`hostname/dns address` the name devices will get called by, like sNet.send("hostname", message), its address<br />
`static connection` registered once, key will never change. for reserving host names for specific people
`temp/dynamic connection` registered at connection, and deleted after diconnecting.<br />
`key` key used for authentication<br />
`channel` channel to listen to, formatted as a list of strings, if a message is sent on a channel not being listened to it wont be recieved.<br />
`recieveBroadcasts` wether to recieve broadcasts or not, if False broadcasts will be ignored and will only recieve direct messages<br />
`activeDnsConnections` a dictionary of hostname: connection (the class)

## api uses
`snet-registerStatic` for registering a static dns address.<br />
`snet-connectTemp` registering and connecting to a temporary dns address<br />
`snet-connectStatic` connecting to a already registered static dns address<br />
`snet-disconnect` disconnect a hostname connection<br />
`snet-removeStatic` remove a static dns address<br />
`snet-sendMsg` send a message to a hostname address on a channel<br />
`snet-broadcast` broadcast a message to an entire channel

## classes:
### connection(websocket, hostName, key, recieveBroadcasts, listeningChannels)
a connection, put into the list activeDnsConnections<br />
`.ws` = the websocket connection to send to<br />
`.hName` = the hostname, a string and index in activeDnsConnections<br />
`.key` = the key used for authenticating<br />
`.rcvBroad` = wether to recieve broadcasts or not<br />
`.channels` = channels to listen to<br />
`.rcvMsg(self,sender,message,channel,broadcast)` for recieving messages<br />
`.sendMsg(self,message,reciever,channel="")` for sending messages to other clients<br />
`.broadcast(self,message,channel="")` broadcast message to entire channel

### serverConnection(hostName, key, recieveBroadcasts, listeningChannels, messageRecievedMethod=None):
a connection based class, same variable names. used for server based things.<br />
`.ws` = None, no websocket to be sent to.<br />
`.rcvMethod(sender,message,channel,broadcast)` if provided will handle incomming messages, is messageRecievedMethod in `__init__` arguments

## python library methods
`verifyDNS(hostName, key)`<br />
validates a hostname and checks if its connected<br />
returns True or False if the information is correct.

`registerStaticDNS(hostName)`<br />
    registers a static hostname<br />
    returns validation key if successful, False if hostname already exists

`removeStaticDNS(hostName, key)`<br />
    deletes a static address<br />
    returns True or False if successful

`connectTempDNS(hostName, websocket, recieveBroadcasts = True, listeningChannelss = [])`<br />
    registers and connects to temp dynmaic hostname<br />
    returns authentication key if successful, False if failure

`connectStaticDNS(hostName, key, websocket, recieveBroadcasts = True, listeningChannelss = [])`<br />
    connect to a static already existing hostname<br />
    returns True or False if successful

`diconnectDNS(hostName,key)`<br />
    disconnects a connected hostname<br />
    if said hostname is temporary, this removes its authentication key forever. hostname will have to be registered again.<br />
    returns True or False if successful


## steps to use as client:
connect to websocket<br />
send device name
### send "snet-registerStatic"
send hostname<br />
recieve key or `"failure"`
### send "snet-connectTemp"
send hostname<br />
recieve key or `"failure"`
### send "snet-connectStatic"
send json:
```json
{
    "hostName": "hostName",
    "key": "authKey",
    "recieveBroadcasts": true/false,
    "channels": ["channels","to","listen","to"]
}
```
recieve `"success"` or `"failure"`
### send "snet-disconnect"
send json `{"hostName": hostName, "key": authKey}`<br />
recieve `"success"` or `"failure"`
### send "snet-removeStatic"
send json `{"hostName": hostName, "key": authKey}`<br />
recieve `"success"` or `"failure"`
### send "snet-sendMsg"
send json:
```json
{
    "hostName": "hostName",
    "key": "authKey",
    "message": "messageToSend",
    "reciever": "reciever hostName",
    "channel": "channel"
}
```
recieve `"success"` or `"failure"`
### send "snet-broadcast"
send json:
```json
{
    "hostName": "hostName",
    "key": "authKey",
    "message": "messageToSend",
    "channel": "channel"
}
```
recieve `"success"` or `"failure"`