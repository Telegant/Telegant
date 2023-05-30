class UpdateHandler:
    def __init__(self, event_handler):
        self.event_handler = event_handler

    async def handle(self, update):
        for pattern, handler in self.event_handler.update_handlers.items(): 
            await handler(self.event_handler, update)
            return

