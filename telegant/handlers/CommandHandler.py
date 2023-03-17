class CommandHandler():
    def __init__(self, event_handler):
        self.event_handler = event_handler

    async def handle(self, update):
        handled = False
        self.event_handler.chat_id = update["message"]["from"]["id"]
        message_text = update["message"]["text"]

        if handled is not True:
            if message_text.startswith('/'):
                command, *args = message_text[1:].split()
                handler = self.event_handler.command_handlers.get(command)
                if handler:
                    await handler(self.event_handler, update, args)
                    handled = True
                    return