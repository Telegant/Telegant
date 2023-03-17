import aiohttp  

class Method:
    async def sendMessage(self, **params):
        return await self.request("sendMessage", params)

    async def sendDice(self, **params):  
        return await self.request("sendDice", params)

'''
class EventHandler: 
    def add_handler(self, handler_dict, key):
        def decorator(handler):
            if key not in handler_dict:
                # create a new list for multiple handlers
                handler_dict[key] = []
            handler_dict[key].append(handler)
            return handler
        return decorator

    async def handle_update(self, update):
        for key in update:
            if (handlers := self.handlers.get(key)) is not None:
                # loop through all the handlers under the same key
                for handler in handlers:
                    await handler(self).handle(update)


class Bot(Method, Helper, EventHandler):
    def __init__(self, token):
        self.handlers = {}
        self.token = token
        self.base_url = f"https://api.telegram.org/bot{self.token}/"
        self.chat_id = 0
        self.user_dialogues = {}

    ... 

    def hears(self, pattern):
        # use EventHandler.add_handler instead of self.add_handler
        return EventHandler.add_handler(self, self.handlers, 'message')(MessageHandler)(pattern)

    def command(self, command_str):
        # use EventHandler.add_handler instead of self.add_handler
        return EventHandler.add_handler(self, self.handlers, 'message')(CommandHandler)(command_str)
'''