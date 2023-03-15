from telegant.method import Method
from telegant.helper import Helper
import re
import aiohttp

class EventHandler: 
    def add_handler(self, handler_dict, key):
        def decorator(handler):
            handler_dict[key] = handler
            return handler
        return decorator

    async def handle_update(self, update):
        handlers = {
            "message": MessageHandler,
            "callback_query": CallbackQueryHandler,
        }
        
        for key in update:
            if (handler := handlers.get(key)) is not None:
                await handler(self).handle(update)

class MessageHandler:
    def __init__(self, event_handler):
        self.event_handler = event_handler

    async def handle(self, update):
        self.event_handler.chat_id = update["message"]["from"]["id"]
        message_text = update["message"]["text"]

        if message_text.startswith('/'):
            command, *args = message_text[1:].split()
            handler = self.event_handler.command_handlers.get(command)
            if handler:
                await handler(self.event_handler, update, args)
                return

        for pattern, handler in self.event_handler.message_handlers.items():
            if re.fullmatch(pattern, message_text):
                await handler(self.event_handler, update)
                return

class CallbackQueryHandler:
    def __init__(self, event_handler):
        self.event_handler = event_handler

    async def handle(self, update):
        self.event_handler.chat_id = update["callback_query"]["from"]["id"]
        callback_data = update["callback_query"]["data"]
        message = update["callback_query"].get("message")

        handler = self.event_handler.callback_handlers.get(callback_data)
        if handler is not None:    
            await handler(self.event_handler, update, message)

        await self.answer_callback_query(update["callback_query"]["id"])

    async def answer_callback_query(self, callback_query_id): 
        method = "answerCallbackQuery"
        params = {"callback_query_id": callback_query_id}
        await self.event_handler.request(method, params)

class Bot(Method, Helper, EventHandler):
    def __init__(self, token):
        self.message_handlers = {}
        self.command_handlers = {}
        self.callback_handlers = {}
        self.token = token
        self.base_url = f"https://api.telegram.org/bot{self.token}/"
        self.chat_id = 0
        self.user_dialogues = {}

    async def start_polling(self):
        last_update_id = 0
        async with aiohttp.ClientSession() as session:
            while True:
                response_json, last_update_id = await self.get_updates(session, last_update_id)
                if not response_json.get("ok"):
                    print("Error: Response is not OK")
                    continue

                for update in response_json["result"]:
                    await self.handle_update(update)

    async def get_updates(self, session, last_update_id):
        try:
            response = await session.get(f"{self.base_url}getUpdates", params={"offset": last_update_id, "timeout": 60})
            if response.status != 200:
                print(f"Error: {response.status}")
                return None, last_update_id

            response_json = await response.json()
            for update in response_json["result"]:
                last_update_id = max(last_update_id, update["update_id"] + 1)

            return response_json, last_update_id

        except Exception as e:
            print(f"Error polling for updates: {e}")
            return None, last_update_id

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

    def hears(self, pattern):
        return self.add_handler(self.message_handlers, pattern) 

    def command(self, command_str):
        return self.add_handler(self.command_handlers, command_str) 

    def callback(self, callback_data):
        return self.add_handler(self.callback_handlers, callback_data)

    def commands(self, commands_list):
        def decorator(handler_func):
            for command in commands_list:
                self.add_handler(self.command_handlers, command)(handler_func)
            def wrapper(*args, **kwargs):
                return handler_func(*args, **kwargs)
            return wrapper
        return decorator 

    def callbacks(self, callbacks_list):
        def decorator(handler_func):
            for callback in callbacks_list:
                self.add_handler(self.callback_handlers, callback)(handler_func)
            def wrapper(*args, **kwargs):
                return handler_func(*args, **kwargs)
            return wrapper
        return decorator 