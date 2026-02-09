# IMEIndicatorClock

[日本語](README_ja.md) | [繁體中文](README_zh-Hant.md) | [简体中文](README_zh-Hans.md) | [한국어](README_ko.md)

A macOS utility app that visually displays IME (Input Method Editor) status, shows it near the mouse cursor, and provides a customizable desktop clock.

## Screenshots

### Desktop Clock with IME Status
| IME OFF (English) | IME ON (Japanese) |
|:-----------------:|:-----------------:|
| ![IME OFF](docs/images/clock_ime_off.jpg) | ![IME ON](docs/images/clock_ime_on.jpg) |

### Settings
| IME Indicator | Clock | Mouse Cursor Indicator |
|:-------------:|:-----:|:----------------------:|
| ![IME Settings](docs/images/settings_ime_indicator.png) | ![Clock Settings](docs/images/settings_clock.png) | ![Cursor Settings](docs/images/settings_cursor_indicator.png) |

### Multi-language UI
| Japanese (日本語) | Traditional Chinese (繁體中文) |
|:-----------------:|:-----------------------------:|
| ![About Japanese](docs/images/about_ja.png) | ![About Chinese](docs/images/about_zh-Hant.png) |

## Vision

**Our goal is to support IMEs from around the world.**

We aim to help IME users see their current input mode at a glance.

## Features

### IME Indicator
- Visually displays the current input method status on screen

| Japanese | Korean | Chinese (Traditional) | Chinese (Simplified) | English |
|:--------:|:------:|:---------------------:|:--------------------:|:-------:|
| <img src="docs/images/ime_ja.png" width="48"> | <img src="docs/images/ime_ko.png" width="48"> | <img src="docs/images/ime_zh_hant.png" width="48"> | <img src="docs/images/ime_zh_hans.png" width="48"> | <img src="docs/images/ime_en.png" width="48"> |
| Red "あ" | Purple "가" | Dark Green "繁" | Green "简" | Blue "A" |

- Customizable position, size, background color, font, font color, and opacity

### Desktop Clock
- Floating clock supporting both analog and digital modes
- Date display support
- Background color changes based on IME status
- Fully customizable window size, font size, and colors

### Mouse Cursor Indicator
- Displays IME status near the mouse cursor
- Shows a smaller version of the IME indicator
- Convenient for text input

### Unified Settings & Quick Access
- Tabbed settings window for managing all features in one place
- Right-click context menu on each window for quick access to settings

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

- macOS 14.0 (Sonoma) or later
- Apple Silicon / Intel Mac supported

## Installation

### Download Release (Recommended)

1. Download the latest release from [Releases](https://github.com/obott9/IMEIndicatorClock/releases)
2. Unzip the downloaded file
3. Move `IMEIndicatorClock.app` to your Applications folder
4. Launch the app

### Build from Source

```bash
git clone https://github.com/obott9/IMEIndicatorClock.git
cd IMEIndicatorClock
open IMEIndicatorClock.xcodeproj
```

## Usage

1. Launch the app - an icon appears in the menu bar
2. Access settings from the menu bar icon
3. Drag the clock or indicator to your preferred position while the settings window is open

## Required Permissions

- **Accessibility**: Required for IME status monitoring. You'll be prompted to grant permission on first launch.

## Development

This project was developed in collaboration with [Claude AI](https://claude.ai/) by Anthropic.

Claude assisted with:
- Architecture design and code implementation
- Multi-language localization
- Documentation and README creation

## Support

If you find this app useful, consider buying me a coffee!

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/obott9)

## Contributing

We welcome contributions! Especially:
- Translation error checking
- Bug reports and feature requests

## License

MIT License - See [LICENSE](LICENSE) file for details.
