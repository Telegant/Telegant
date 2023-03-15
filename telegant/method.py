import aiohttp  

class Method:
    async def test():
        print("I can be used without issues at all")

    async def sendMessage(self, **params):
        return await self.request("sendMessage", params)

    async def sendDice(self, **params):  
        return await self.request("sendDice", params)