from telegant.handlers import (
    EventHandler,
    TextHandler,
    CommandHandler,
    CallbackQueryHandler,
    UpdateHandler,
)

from .method import *
import re
import aiohttp
import asyncio


class Bot:
    def __init__(self, token):
        self.token = "6107480665:AAGV5JNUnh6ALI53-JZpjkft-7g2cL1BSGA"
        self.event_handler = EventHandler()
        self.base_url = f"https://api.telegram.org/bot{self.token}/"
        self.event_handler.base_url = self.base_url 
        self.user_state = {}  

    async def polling(self):
        last_update_id = 0
        async with aiohttp.ClientSession() as session:
            while True:
                response_json, last_update_id = await self.get_updates(
                    session, last_update_id
                )
                if not response_json.get("ok"):
                    print("Error: Response is not OK")
                    continue

                for update in response_json["result"]:
                    await self.event_handler.handle_update(update)

    async def get_updates(self, session, last_update_id):
        try:
            response = await session.get(
                f"{self.event_handler.base_url}getUpdates",
                params={"offset": last_update_id, "timeout": 30},
            )
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

    def start_polling(self):
        asyncio.run(self.polling())

    def process_event_handler(self, value, key, handler, handlers):
        handlers = getattr(self.event_handler, handlers)

        if key not in self.event_handler.handlers:
            self.event_handler.handlers[key] = []

        if type(handler) in (type(h) for h in self.event_handler.handlers[key]):
            return self.event_handler.add_handler(handlers, value)

        self.event_handler.handlers[key].extend([handler])
        return self.event_handler.add_handler(handlers, value)

    def process_many_events(
        self, events_list, event_type, handler_cls, handler_list_attr
    ):
        def decorator(handler_func):
            for event in events_list:
                self.process_event_handler(
                    event, event_type, handler_cls, handler_list_attr
                )(handler_func)
            return handler_func

        return decorator

    def with_args(self, keys):
        def decorator(handler_func):
            async def wrapper(bot, update, data):
                message = update.get("message")
                if message:
                    message_text = message.get("text", "")
                    args = message_text.split()[1:]
                    data = {
                        k: args[i] if i < len(args) else "" for i, k in enumerate(keys)
                    }
                    await handler_func(bot, update, data)

            return wrapper

        return decorator

    def init(self):
        def decorator(handler_func):
            async def decorated_func(EventHandler): 
                await handler_func(EventHandler)
            return decorated_func
        return decorator

    def on(self, value): 
        return self.process_event_handler(
            value, value, UpdateHandler(self.event_handler), "update_handlers"
        )

    def hear(self, value): 
        return self.process_event_handler(
            value, "message", TextHandler(self.event_handler), "message_handlers"
        )

    def hears(self, value): 
        return self.process_many_events(
            value, "message", TextHandler(self.event_handler), "message_handlers"
        )

    def command(self, value):
        return self.process_event_handler(
            value, "message", CommandHandler(self.event_handler), "command_handlers"
        )

    def callback(self, value):
        return self.process_event_handler(
            value,
            "callback_query",
            CallbackQueryHandler(self.event_handler),
            "callback_handlers",
        )

    def commands(self, commands_list):
        return self.process_many_events(
            commands_list,
            "message",
            CommandHandler(self.event_handler),
            "command_handlers",
        )

    def callbacks(self, callbacks_list):
        return self.process_many_events(
            callbacks_list,
            "callback_query",
            CallbackQueryHandler(self.event_handler),
            "callback_handlers",
        )

    def dialogue(self, value):
        def decorator(handler_func):
            async def wrapper(bot, update): 
                print(f"Dialogue {value} was detected.")
                return await handler_func(bot, update)
            return wrapper
        return decorator

    def step(self, value):
        def decorator(handler_func):
            async def wrapper(bot, update): 
                print(f"Dialogue step {value} was detected.")      
                return await handler_func(bot, update)
            return wrapper  
        return decorator

    async def request(self, action, params=None):
        async with aiohttp.ClientSession() as session:
            try:
                url = f"{self.base_url}{action}"
                if not params.get("chat_id"):
                    params["chat_id"] = self.chat_id
                if params.get("reply_markup"):
                    params["reply_markup"] = self.create_keyboard(params["reply_markup"])
                response = await session.post(url, params=params)
                return await response.json()
            except Exception as e:
                print(f"Error sending request: {e}")

    def __getattr__(self, name):
        async def wrapper(**params):
            camel_case_name = re.sub(r"_([a-z])", lambda m: m.group(1).upper(), name)
            return await self.request(camel_case_name, params)
        return wrapper