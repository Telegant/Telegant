
<h1 align="center">
    <code>Telegant</code>
</h1>
<p align="center">
    <a href="https://github.com/psf/black">
        <img alt="Code style: black" src="https://img.shields.io/badge/code%20style-black-000000.svg">
    </a>
    <a href="https://t.me/telegant_group">
        <img src="https://img.shields.io/badge/Telegram-Group-blue.svg?logo=telegram">
    </a>
    <a href="https://t.me/telegant_official">
        <img src="https://img.shields.io/badge/Telegram-Channel-blue.svg?logo=telegram">
    </a> 
    <a href="https://pypistats.org/packages/telegant">
        <img src="https://img.shields.io/pypi/dm/telegant.svg">
    </a>
</p>



# Telegant 
Telegant is an elegant modern bot framework for Python, designed to provide developers with simple and elegant access to the Telegram bot API.
This project is now in Beta phase. 
All Telegram bot api methods are now supported automatically.

# Features and highlights
* Automated coverage of all Telegram bot api methods
* Support of snake_case and PascalCase for calling methods
* Asynchronous bot
* Lightweight (Less than 20kb at the moment!)
* Simple usage
* Bot Helpers 

# Installation 
To install the project, simply run:

```python 
pip install telegant
```

# Example 

```python
from telegant import Bot
import asyncio

bot = Bot("YOUR_BOT_TOKEN_HERE")

@bot.hears("hello")
async def say_hello(bot, update): 
    await bot.send_message(text="What's up?")

#Your code here (Recommended to write your functions in order)

asyncio.run(bot.start_polling())
```

# Usage 

## On text 

If you need your bot to respond to specified text just use @bot.hears()

```python 
@bot.hears("hello")
async def say_hello(bot, update): 
    await bot.send_message(text="What's up?")
```

Ability to use both snake_case and PascalCase style methods

## PascalCase 

```python 
@bot.hears("hello")
async def say_hello(bot, update): 
    await bot.sendMessage(text="What's up?")
```

## snake_case

```python 
@bot.hears("hello")
async def say_hello(bot, update): 
    await bot.send_message(text="What's up?")
```

## Sending bot with buttons

### Inline buttons example
```python 
@bot.hears("hello")
async def say_hello(bot, update): 
 
    buttons = [
        {"text": "Option 1 (inline)", "data": "option1"},  
    ]

    #snake_case example
    await bot.send_message(text="What's up?", reply_markup=bot.create_reply_markup(buttons))
```

### Reply buttons example

```python 
@bot.hears("hello")
async def say_hello(bot, update): 
 
    buttons = [
        {"text": "Option 1 (reply)"},  
    ]

    await bot.send_message(text="What's up?", reply_markup=bot.create_reply_markup(buttons))
```

Bot always detects your buttons type automatically by data key. 
If you want to use inline buttons you have to write text and data values for each button.
As it is detects your inline button when you have "data" key in your button.
Otherwise, it will detect as reply keyboard.

## Commands

You can assign to one function one command or many commands as needed.
For single command use @bot.command() decorator.

```python 
@bot.command("start")
async def say_hello(bot, update):  
    await bot.send_message(text="Sup I'm start")
```
For several commands use @bot.commands() decorator.

```python 
@bot.commands(['help', 'ask'])
async def say_hello(bot, update):  
    await bot.send_message(text="You've reached for help")
```

Export data after command by your keys

```python 
@bot.commands(['usernameandage'])
@bot.with_args(['username', 'age'])
async def handler(bot, update, data): 
    await bot.send_message(text=f"Hello {data['username']}, you are {data['age']} years old.")
```

## Callbacks
Telegant also offers to you simply detect your callbacks where you able to assign many or one callback to your function

### Many callbacks example 

```python 
@bot.callbacks(['option1', 'option2'])
async def say_hello(bot, update):  
    await bot.send_message(text="Callbacks are perfect!")
```

### Single callback example

```python 
@bot.callback('option1')
async def say_hello(bot, update):  
    await bot.send_message(text="Callback is perfect")
```
