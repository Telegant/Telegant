class Method:
    def __getattr__(self, name):
        async def wrapper(**params):
            pascal_case_name = "".join(word.capitalize() for word in name.split("_"))
            return await self.request(pascal_case_name, params)

        return wrapper
