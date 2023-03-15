import aiohttp  

class Method:
    async def request(self, action, params=None):
        async with aiohttp.ClientSession() as session:
            try:
                url = f"{self.base_url}{action}"
                if not params.get("chat_id"): 
                    params["chat_id"] = self.chat_id
                response = await session.post(url, params=params)
                return await response.json()
            except Exception as e:
                print(f"Error sending request: {e}")

    async def sendMessage(self, **params):
        return await self.request("sendMessage", params)

    async def sendDice(self, **params):  
        return await self.request("sendDice", params)