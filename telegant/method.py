import re
import json

class Method:
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

    def __getattr__(self, name):
        async def wrapper(**params):
            camel_case_name = re.sub(r'_([a-z])', lambda m: m.group(1).upper(), name)
            return await self.request(camel_case_name, params)
        return wrapper