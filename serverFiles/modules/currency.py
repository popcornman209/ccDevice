import standard, asyncio

async def getCurrency(websocket,deviceName): await websocket.send(standard.settings["currency"])

async def convertToCurrency(websocket,deviceName):
    money = await websocket.recv()
    await websocket.send(str(float(money)/(standard.settings["amountOfItem"]/standard.settings["priceOfItem"]))) #money/currencyPrice

async def convertFromCurrency(websocket,deviceName):
    money = await websocket.recv()
    await websocket.send(str(float(money)*(standard.settings["amountOfItem"]/standard.settings["priceOfItem"]))) #money*currencyPrice

apiCalls = {
    "currency-get": getCurrency,
    "currency-convertTo": convertToCurrency,
    "currency-convertFrom": convertFromCurrency
}
description = "for managing currencies, used for shops and atm's. defines the $ value."
documentation = "documentation/currency.txt"