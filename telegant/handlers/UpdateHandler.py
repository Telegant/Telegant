class UpdateHandler:
    def __init__(self, event_handler):
        self.event_handler = event_handler

    async def handle(self, update):
        raise NotImplementedError("This function has not been implemented yet")
