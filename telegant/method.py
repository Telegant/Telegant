import aiohttp  

class Method:
    async def sendMessage(self, **params):
        return await self.request("sendMessage", params)

    async def sendDice(self, **params):  
        return await self.request("sendDice", params)