import re


class TextHandler:
    def __init__(self, event_handler):
        self.event_handler = event_handler

    async def handle(self, update):
        self.event_handler.chat_id = update["message"]["from"]["id"]
        message_text = update["message"]["text"]

        for pattern, handler in self.event_handler.message_handlers.items():
            if re.fullmatch(pattern, message_text):
                await handler(self.event_handler, update)
                return
