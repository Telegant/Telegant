from telegant.handlers import TextHandler
from telegant.handlers import CommandHandler
from telegant.handlers import CallbackQueryHandler
from telegant.handlers import UpdateHandler

handler_classes = {
    TextHandler: TextHandler,
    CommandHandler: CommandHandler,
    CallbackQueryHandler: CallbackQueryHandler
}

decorators = {
    "hear": { 
        "type": "message",
        "handler": TextHandler(''),
        "handlers": "message_handlers"
    },

    "hears": { 
        "type": "message",
        "handler": TextHandler(''),
        "handlers": "message_handlers"
    },

    "command": { 
        "type": "message",
        "handler": CommandHandler(''),
        "handlers": "command_handlers"
    },

    "callback": { 
        "type": "callback_query",
        "handler": CallbackQueryHandler(''),
        "handlers": "callback_handlers"
    },

    "commands": { 
        "type": "message",
        "handler": CommandHandler(''),
        "handlers": "command_handlers"
    },

    "callbacks": { 
        "type": "callback_query",
        "handler": CallbackQueryHandler(''),
        "handlers": "callback_handlers"
    },
}