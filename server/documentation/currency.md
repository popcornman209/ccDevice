# currency api documentation

## terms
`currency` item id, ex "minecraft:diamond"<br />
`amountOfItem` amount of item you get for price<br />
`priceOfItem` price for the amount of items above<br />
`itemValue` amountOfItem/priceOfItem, if amount of item is 2 and price is 4, the value of each is 2$ per item<br />

## api uses
`currency-get` get currency item, diamonds as default<br />
`currency-convertTo` converts money to amount of item (currency)<br />
`currency-convertFrom` converts item (currency) to amount of money


## steps to use ws as client:
connect to websocket
send device name
### send "currency-get"
receive currency, ei "minecraft:diamond"

### send "convertTo"
send amount of money to convert<br />
recive amount of item its worth

### send "convertFrom"
send amount of item to convert<br />
recive amount of money its worth