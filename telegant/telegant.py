from telegant.handlers import EventHandler
from telegant.decorators import *
import re
import aiohttp
import asyncio


class Bot:
    def __init__(self, token):
        self.token = token
        self.event_handler = EventHandler()
        self.event_handler.base_url = f"https://api.telegram.org/bot{self.token}/"

        handlers = {}
        for name, data in decorators.items():
            handler_class = handler_classes.get(data["handler"].__class__)
            if handler_class is not None:
                handlers[name] = {
                    "type": data["type"],
                    "handler": handler_class(self.event_handler),
                    "handlers": data["handlers"]
                }

        self.decorators = handlers

    async def start_polling(self):
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

    def __getattr__(self, name):
        def wrapper(value): 
            data = self.decorators[name]
            is_plural = bool(re.search(r's$|es$|ies$', name))

            if is_plural:
                return self.process_many_events(
                    value,
                    data["type"],
                    data["handler"],
                    data["handlers"],
                )

            return self.process_event_handler(
                value,
                data["type"],
                data["handler"],
                data["handlers"],
            )
            
        return wrapper
