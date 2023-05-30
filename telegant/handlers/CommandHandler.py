class CommandHandler:
    def __init__(self, event_handler):
        self.event_handler = event_handler

    async def handle(self, update): 
        if update.get("message"):
            self.event_handler.chat_id = update["message"]["from"]["id"]
            if update["message"].get("text"):
                message_text = update["message"]["text"]

                command, *args = message_text[1:].split()
                handler = self.event_handler.command_handlers.get(command)
                if handler:
                    await handler(self.event_handler, update, args)
                    return 