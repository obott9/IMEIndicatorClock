# IMEIndicatorClock

[English](README.md) | [日本語](README_ja.md) | [繁體中文](README_zh-Hant.md) | [한국어](README_ko.md)

一款 macOS 工具应用程序，可视化显示输入法（IME）状态、在鼠标光标附近显示，并提供可自定义的桌面时钟。

## 屏幕截图

### 输入法状态联动桌面时钟
| IME OFF（英文） | IME ON（日文） |
|:--------------:|:-------------:|
| ![IME OFF](docs/images/clock_ime_off.jpg) | ![IME ON](docs/images/clock_ime_on.jpg) |

### 设置界面
| 输入法指示器 | 时钟 | 鼠标光标指示器 |
|:----------:|:----:|:-------------:|
| ![IME设置](docs/images/settings_ime_indicator.png) | ![时钟设置](docs/images/settings_clock.png) | ![光标设置](docs/images/settings_cursor_indicator.png) |

### 多语言 UI
| 日语 | 繁体中文 |
|:----:|:-------:|
| ![About 日语](docs/images/about_ja.png) | ![About 中文](docs/images/about_zh-Hant.png) |

## 愿景

**我们的目标是支持全球各种输入法。**

我们希望帮助输入法用户能够一目了然地确认当前的输入模式。

## 功能

### 输入法指示器
- 在屏幕上可视化显示当前输入法状态
- 日文输入：红色圆圈显示「あ」
- 英文输入：蓝色圆圈显示「A」
- 可自定义位置、大小和透明度

### 桌面时钟
- 支持模拟和数字模式的浮动时钟
- 支持日期显示
- 根据输入法状态切换背景颜色
- 可自由自定义窗口大小、字体大小和颜色

### 鼠标光标指示器
- 在鼠标光标附近显示输入法状态
- 方便文字输入时使用

## 语言支持

### 完整支持（输入法检测 + UI）
| 语言 | 输入法检测 | UI 翻译 |
|------|:----------:|:-------:|
| 日文 | ✅ | ✅ |
| 英文 | ✅ | ✅ |
| 简体中文 | ✅ | ✅ |
| 繁体中文 | ✅ | ✅ |
| 韩文 | ✅ | ✅ |

### 输入法检测 + 基本 UI
| 语言 | 输入法检测 | UI 翻译 |
|------|:----------:|:-------:|
| 泰文 | ✅ | ✅ |
| 越南文 | ✅ | ✅ |
| 阿拉伯文 | ✅ | ✅ |
| 希伯来文 | ✅ | ✅ |
| 印地文 | ✅ | ✅ |
| 俄文 | ✅ | ✅ |
| 希腊文 | ✅ | ✅ |

*这些语言的 UI 翻译为机器翻译，可能需要改进。欢迎贡献！*

## 系统要求

- macOS 14.0 (Sonoma) 或更高版本
- 支持 Apple Silicon / Intel Mac

## 安装

### 下载发布版（推荐）

1. 从 [Releases](https://github.com/obott9/IMEIndicatorClock/releases) 下载最新版本
2. 解压下载的文件
3. 将 `IMEIndicatorClock.app` 移动到「应用程序」文件夹
4. 启动应用程序

### 从源码构建

```bash
git clone https://github.com/obott9/IMEIndicatorClock.git
cd IMEIndicatorClock
open IMEIndicatorClock.xcodeproj
```

## 使用方法

1. 启动应用程序后，菜单栏会出现图标
2. 从菜单栏图标访问各种设置
3. 时钟或指示器可在设置窗口打开时拖拽到您喜欢的位置

## 所需权限

- **辅助功能**：用于监控输入法状态。首次启动时会提示授予权限。

## 开发

此项目与 Anthropic 的 [Claude AI](https://claude.ai/) 共同开发。

Claude 协助了：
- 架构设计和代码实现
- 多语言本地化
- 文档和 README 创建

## 支持

如果您觉得这个应用程序有用，请考虑请我喝杯咖啡！

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/obott9)

## 贡献

欢迎贡献！特别是：
- 翻译错误确认
- 错误报告和功能请求

## 许可证

MIT License - 详情请参阅 [LICENSE](LICENSE) 文件。
