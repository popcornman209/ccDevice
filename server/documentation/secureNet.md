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

## classes for other modules:
    connection:
        a connection, put into the list activeDnsConnections
        .ws = the websocket connection to send to
        .hName = the hostname, a string and index in activeDnsConnections
        .key = the key used for authenticating
        .rcvBroad = wether to recieve broadcasts or not
    
    serverConnection:
        a connection based class, same variable names. used for server based things, can only send and not recieve (for now).
        .ws = None, no websocket to be sent to.
        .rcvBroad = False, wont recieve any broadcasts.
        .channels = [], will not recieve anything on any channel

functions for other modules:
    verifyDNS(hostName, key):
        validates a hostname and checks if its connected
        returns True or False if the information is correct.

    registerStaticDNS(hostName):
        registers a static hostname
        returns validation key if successful, False if hostname already exists

    removeStaticDNS(hostName, key):
        deletes a static ip address
        returns True or False if successful

    connectTempDNS(hostName, websocket, recieveBroadcasts = True, listeningChannelss = []):
        registers and connects to temp dynmaic hostname
        returns authentication key if successful, False if failure

    connectStaticDNS(hostName, key, websocket, recieveBroadcasts = True, listeningChannelss = []):
        connect to a static already existing hostname
        returns True or False if successful

    diconnectDNS(hostName,key):
        disconnects a connected hostname
        if said hostname is temporary, this removes its authentication key forever. hostname will have to be registered again.
        returns True or False if successful


steps to use as client:
connect to websocket
    send device name

    send "snet-registerStatic"
    
    send "snet-connectTemp"
    
    send "snet-connectStatic"
    
    send "snet-disconnect"
    
    send "snet-removeStatic"
    
    send "snet-sendMsg"
    
    send "snet-broadcast"