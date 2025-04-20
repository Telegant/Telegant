<h1 align="center">Telegant</h1>

<p align="center">
  <a href="https://github.com/telegant/telegant/releases"><img src="https://img.shields.io/github/v/release/telegant/telegant?include_prereleases" alt="GitHub release"></a>
  <a href="https://crystal-lang.org/"><img src="https://img.shields.io/badge/built%20with-Crystal-black" alt="Built with Crystal"></a>
  <a href="https://github.com/yourusername/telegant/blob/main/LICENSE"><img src="https://img.shields.io/github/license/telegant/telegant" alt="License"></a>
</p>

<p align="center">Telegant is a feature-rich Telegram bot framework specifically built for Crystal. Built with beauty and scalability in mind, it offers a simple syntax for creating complicated bot interactions while retaining Crystal's efficiency benefits.</p>

## 🧩 Features
- ✨ **Elegant annotation-based API** - Define handlers with Crystal annotations
- 🛡️ **Middleware system** - Add customized logic, such as rate limitation, logging, or access restriction
- 🔌 **Attachable middleware** - Add middleware to specified handlers
- 📊 **Context** - Easy access to the current update properties and API calls
- 🔑 **State management** - Integrated user state management for complicated interactions
- 📑 **Dialog management** - Create multi-step conversations with built-in state management

## 🔨 Installation
Add Telegant to your `shard.yml`:

```yaml
dependencies:
  telegant:
    github: telegant/telegant
    branch: release/v0.0.1
```

Then run:

```bash
shards install
```

## 💡 Example
```crystal
require "telegant"

class MyBot < Telegant::Bot
  @[Hears("hi", "hello")]
  def on_greet(update, bot)
    bot.reply("Hey there!")
  end

bot = MyBot.new("YOUR_BOT_TOKEN")
bot.start()
```

## 📖 Documentation
To-do

## ❤️ Contribute
To-do

## 🗺️ Roadmap
To-do

## 🌐 Community
- [Join our Discord](https://discord.gg/nzjSdbjE)
- [Telegram Group](https://t.me/telegant_group)
- [Telegram Channel](https://t.me/telegant_official)
