from telegant.method import Method
from telegant.helper import Helper
import aiohttp
import asyncio


class EventHandler(Method, Helper):
    def __init__(self):
        self.chat_id = 0
        self.handlers = {}
        self.message_handlers = {}
        self.command_handlers = {}
        self.callback_handlers = {}
        self.update_handlers = {}

    def add_handler(self, handler_dict, key):
        def decorator(handler):
            handler_dict[key] = handler
            return handler

        return decorator

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

    async def handle_update(self, update):
        tasks = []
        for key in update:
            if (handler := self.handlers.get(key)) is not None:
                for task in handler:
                    if task is not None:
                        tasks.append(asyncio.create_task(task.handle(update)))
        await asyncio.gather(*tasks)