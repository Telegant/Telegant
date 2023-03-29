import re


class Method:
    def __getattr__(self, name):
        async def wrapper(**params):
            camel_case_name = re.sub(r'_([a-z])', lambda m: m.group(1).upper(), name)
            return await self.request(camel_case_name, params)
        return wrapper