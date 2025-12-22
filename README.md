<div align="center">

<h2>Get notified when new Flutter SDK versions are released!</h2>

[![Telegram Bot](https://img.shields.io/badge/Telegram-@FlutterNotifyBot-blue?logo=telegram)](https://t.me/FlutterNotifyBot)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Dart](https://img.shields.io/badge/Dart-100%25-0175C2?logo=dart)](https://dart.dev)

[Try the Bot](https://t.me/FlutterNotifyBot) • [Report Bug](https://github.com/minhqdao/flutter_notify/issues) • [Request Feature](https://github.com/minhqdao/flutter_notify/issues)

</div>

## 📖 About

Never miss a Flutter SDK update again! This Telegram bot monitors Flutter's official release channel and sends you notifications when new versions are available. No more manually running `flutter upgrade` or checking `fvm releases` to see what's new.

### ✨ Features

- 🚀 **Instant notifications** when new Flutter SDK versions are detected
- 🎯 **Simple commands** - `/start`, `/stop`, `/status`, `/help`
- 🔒 **Privacy-focused** - only stores your chat ID and notification preferences
- 💯 **100% Dart** - entire stack written in Dart
- ⚡ **Fast & reliable** - checks for updates every 10 minutes
- 🆓 **Free & open source** - MIT licensed

## 🤖 Using the Bot

### Quick Start

1. Follow this [link](https://t.me/FlutterNotifyBot) or open Telegram and search for [@FlutterNotifyBot](https://t.me/FlutterNotifyBot)
2. Send `/start` to enable notifications
3. That's it! You'll receive alerts when new Flutter versions drop

### Available Commands

| Command | Description |
|---------|-------------|
| `/start` | Enable notifications for Flutter SDK releases |
| `/stop` | Disable notifications |
| `/status` | Check your current notification status |
| `/help` | Show available commands |

## 🛠️ Tech Stack

This project is built entirely in Dart and currently consists of two main components:

### Backend (Globe.dev)
- **[Shelf](https://pub.dev/packages/shelf)** – Web server framework
- **[Drift](https://pub.dev/packages/drift)** – Type-safe SQLite database wrapper
- Handles webhook requests from Telegram
- Manages user subscriptions
- Deployed on [Globe.dev](https://globe.dev)

### Release Checker (GitHub Actions)
- Scheduled cron job (every 10 minutes)
- Monitors Flutter's official releases endpoint:
https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json
- Compares ETags to detect changes efficiently
- Notifies subscribed users via a backend API

## 💭 Future Ideas

Things that could help improve the bot:

- 🌍 Support for multiple release channels (`stable`, `beta`)
- 📢 Support for the `main` channel
- 🎯 Support for Dart SDK release notifications
- 📋 `/check` command to view the latest versions across all channels
- 🔍 Detailed mode with changelogs and commit diffs
- ⏰ Weekly summaries
- 🔗 Integration with Discord, Slack, and other platforms
- 😬 Tests

## 🐛 Bug Reports & Feature Requests

Found a bug or have a feature idea? Please [open an issue](https://github.com/minhqdao/flutter_notify/issues) with:
- A clear description of the issue/feature
- Steps to reproduce (for bugs)
- Expected vs actual behavior
- Your environment details

## 📮 Support

If you find this project helpful, please consider:
- 🔔 Subscribing to the [Telegram bot](https://t.me/FlutterNotifyBot)
- ⭐ Starring the repository
- 💡 Suggesting new features
- 🐛 Reporting bugs
- 🤝 Contributing code


## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">

Made with 🩵 and Dart

</div>
