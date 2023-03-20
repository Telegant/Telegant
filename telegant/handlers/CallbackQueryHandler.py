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
