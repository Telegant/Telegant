import re


class TextHandler:
    def __init__(self, event_handler):
        self.event_handler = event_handler

    async def handle(self, update):
        if update.get("message"):
            self.event_handler.chat_id = update["message"]["from"]["id"]
            
            if update["message"].get("text"):
                message_text = update["message"]["text"]

                for pattern, handler in self.event_handler.message_handlers.items():
                    if re.fullmatch(pattern, message_text):
                        await handler(self.event_handler, update)
                        return
