# TeleMac 🚀

A personal macOS Telegram client built on top of the official [telegram-macos](https://github.com/TelegramMessenger/telegram-macos) open source codebase.

## Overview
TeleMac is a custom fork of the native macOS Telegram client (Swift/AppKit), focused on:
- Complete UI overhaul with a modern, opinionated design system
- Power-user features
- Personal workflow integrations

## License
This project is a GPL-2.0 fork. All modifications are covered under GPL-2.0.
You must register your own API credentials at https://my.telegram.org

## Key Directories

| Directory | Purpose | Our Work |
|-----------|---------|----------|
| `packages/TGUIKit/` | Core UI framework (all custom views, animations) | 🔥 Primary |
| `packages/ChatUI/` | Chat bubble rendering | 🔥 Primary |
| `packages/ChatListUI/` | Sidebar chat list | 🔥 Primary |
| `packages/ColorPalette/` | App-wide color system | 🔥 Primary |
| `packages/TelegramIconsTheme/` | Icon set | 🔥 Primary |
| `packages/SidebarUI/` | Left panel sidebar | 🔥 Primary |
| `packages/SettingsUI/` | Settings screens | Medium |
| `packages/ComponentsUI/` | Shared UI components | Medium |
| `Telegram-Mac/` | App entry point, AppDelegate | Medium |
| `Resources/` | Fonts, sounds, assets | Medium |
| `packages/AuthUI/` | Login/auth screens | Low |
| `submodules/telegram-ios` | MTProto core (DO NOT TOUCH) | ❌ Skip |
| `submodules/tgcalls` | WebRTC calls (DO NOT TOUCH) | ❌ Skip |
| `submodules/tg_owt` | WebRTC internals (DO NOT TOUCH) | ❌ Skip |
| `core-xprojects/` | C++ build targets | ❌ Skip |

## Planned Changes
- [ ] New color palette & design tokens
- [ ] Redesigned chat list sidebar  
- [ ] Custom message bubble styles
- [ ] Modernized settings UI
- [ ] Custom app icon
- [ ] Own API credentials (my.telegram.org)
