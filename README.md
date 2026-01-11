# IMEIndicatorClock

[日本語](README_ja.md) | [繁體中文](README_zh-Hant.md) | [简体中文](README_zh-Hans.md) | [한국어](README_ko.md)

A macOS utility app that visually displays IME (Input Method Editor) status with a customizable desktop clock.

## Screenshots

### Desktop Clock with IME Status
| IME OFF (English) | IME ON (Japanese) |
|:-----------------:|:-----------------:|
| ![IME OFF](docs/images/clock_ime_off.png) | ![IME ON](docs/images/clock_ime_on.png) |

### Settings
| IME Indicator | Clock | Mouse Cursor Indicator |
|:-------------:|:-----:|:----------------------:|
| ![IME Settings](docs/images/settings_ime_indicator.png) | ![Clock Settings](docs/images/settings_clock.png) | ![Cursor Settings](docs/images/settings_cursor_indicator.png) |

## Vision

**Our goal is to support IMEs from around the world.**

We aim to help users who switch between multiple languages see their current input method at a glance.

## Features

### IME Indicator
- Visually displays the current input method status on screen
- Japanese: Red circle with "あ"
- English: Blue circle with "A"
- Customizable position, size, and opacity

### Desktop Clock
- Floating clock supporting both analog and digital modes
- Date display support
- Background color changes based on IME status
- Fully customizable window size, font size, and colors

### Mouse Cursor Indicator
- Displays IME status near the mouse cursor
- Convenient for text input

## Language Support

### Full Support (IME Detection + UI)
| Language | IME Detection | UI Localization |
|----------|:-------------:|:---------------:|
| Japanese | ✅ | ✅ |
| English | ✅ | ✅ |
| Chinese (Simplified) | ✅ | ✅ |
| Chinese (Traditional) | ✅ | ✅ |
| Korean | ✅ | ✅ |

### IME Detection + Basic UI
| Language | IME Detection | UI Localization |
|----------|:-------------:|:---------------:|
| Thai | ✅ | ✅ |
| Vietnamese | ✅ | ✅ |
| Arabic | ✅ | ✅ |
| Hebrew | ✅ | ✅ |
| Hindi | ✅ | ✅ |
| Russian | ✅ | ✅ |
| Greek | ✅ | ✅ |

*UI translations for these languages are machine-translated and may need improvement. Contributions welcome!*

## System Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon / Intel Mac supported

## Installation

1. Clone this repository
2. Open the project in Xcode
3. Build and run

```bash
git clone https://github.com/obott9/IMEIndicatorClock.git
cd IMEIndicatorClock
open IMEIndicatorClock.xcodeproj
```

## Usage

1. Launch the app - an icon appears in the menu bar
2. Access settings from the menu bar icon
3. Drag the clock or indicator to your preferred position

## Required Permissions

- **Accessibility**: Required for IME status monitoring. You'll be prompted to grant permission on first launch.

## Development

This project was developed in collaboration with [Claude AI](https://claude.ai/) by Anthropic.

Claude assisted with:
- Architecture design and code implementation
- Multi-language localization
- Documentation and README creation

## Contributing

We welcome contributions! Especially:
- UI translations for additional languages
- Support for more IME types
- Bug reports and feature requests

## License

MIT License - See [LICENSE](LICENSE) file for details.
