<h1 align="center">Telegant</h1>

<p align="center">
  <a href="https://github.com/telegant/telegant/releases"><img src="https://img.shields.io/github/v/release/telegant/telegant?include_prereleases" alt="GitHub release"></a>
  <a href="https://crystal-lang.org/"><img src="https://img.shields.io/badge/built%20with-Crystal-black" alt="Built with Crystal"></a>
  <a href="https://github.com/yourusername/telegant/blob/main/LICENSE"><img src="https://img.shields.io/github/license/telegant/telegant" alt="License"></a>
</p>

<p align="center">Telegant is a feature-rich Telegram bot framework specifically built for Crystal. Built with beauty and scalability in mind, it offers a simple syntax for creating complicated bot interactions while retaining Crystal's efficiency benefits.</p>

## Features

## Installation

## Example
```crystal
require "telegant"

class MyBot < Telegant::Bot
  @[Command("start")]
  def on_start(update, bot)
    bot.reply("Hello! I'm a Telegant bot.")
  end

  @[Command("signup")]
  def start_signup(update, bot)
    bot.start_dialog("registration", "name")
    bot.reply("Let's get you registered! What's your name?")
  end

  @[Dialog("registration")]
  @[Step("name")]
  def get_name(update, bot)
    if text = bot.message_text
      bot.set_dialog_data("name", text)
      bot.next_step("email")
      bot.reply("Nice to meet you, #{text}! What's your email?")
    end
  end

  @[Dialog("registration")]
  @[Step("email")]
  def get_email(update, bot)
    if text = bot.message_text
      bot.set_dialog_data("email", text)
      bot.reply("Registration complete!")
      bot.end_dialog()
    end
  end
end

bot = MyBot.new("YOUR_BOT_TOKEN")
bot.start()
```

## Documentation

## Contribute

## Roadmap
