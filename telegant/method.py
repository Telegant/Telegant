import aiohttp  

class Method:
    def __getattr__(self, name):
        async def wrapper(**params):
            return await self.request(name, params)
        return wrapper