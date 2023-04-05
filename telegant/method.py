import re
import json


class Method:
    def modify_keyboard(self, buttons, inline=False):
        new_buttons = []
        for row in buttons:
            new_row = []
            for button in row:
                if isinstance(button, dict):
                    if inline and "callback_data" in button:
                        new_row.append(button)
                    elif not inline and "callback_data" not in button:
                        new_row.append(button)
                elif not inline:
                    new_row.append(button)
            if new_row:
                new_buttons.append(new_row)
        return new_buttons

    def create_keyboard(self, buttons):
        return json.dumps(
            {
                "inline_keyboard": self.modify_keyboard(buttons, inline=True),
                "keyboard": self.modify_keyboard(buttons, inline=False),
                "one_time_keyboard": True,
            }
        )

    def __getattr__(self, name):
        async def wrapper(**params):
            camel_case_name = re.sub(r"_([a-z])", lambda m: m.group(1).upper(), name)
            return await self.request(camel_case_name, params)

        return wrapper
