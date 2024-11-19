import standard, asyncio

async def getCurrency(args): await args["websocket"].send(standard.settings["currency"])

async def convertToCurrency(args):
    money = await args["websocket"].recv()
    await args["websocket"].send(str(float(money)/(standard.settings["amountOfItem"]/standard.settings["priceOfItem"]))) #money/currencyPrice

async def convertFromCurrency(args):
    money = await args["websocket"].recv()
    await args["websocket"].send(str(float(money)*(standard.settings["amountOfItem"]/standard.settings["priceOfItem"]))) #money*currencyPrice

apiCalls = {
    "currency-get": getCurrency,
    "currency-convertTo": convertToCurrency,
    "currency-convertFrom": convertFromCurrency
}
description = "for managing currencies, used for shops and atm's. defines the $ value."
documentation = "documentation/currency.txt"