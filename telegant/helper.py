import json


class Helper:
    def create_inline_keyboard(self, buttons):
        return [
            [{"text": b["text"], "callback_data": b.get("data", "")}] for b in buttons
        ]

    def create_reply_keyboard(self, buttons):
        return [[{"text": b["text"]}] for b in buttons if "data" not in b]

    def create_reply_markup(self, buttons):
        return json.dumps(
            {
                "inline_keyboard": self.create_inline_keyboard(buttons),
                "keyboard": self.create_reply_keyboard(buttons),
                "one_time_keyboard": True,
            }
        )

    @staticmethod
    def with_args(keys):
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
