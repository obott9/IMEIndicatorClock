# IMEIndicatorClock

[English](README.md) | [日本語](README_ja.md) | [简体中文](README_zh-Hans.md) | [한국어](README_ko.md)

一款 macOS 工具應用程式，可視化顯示輸入法（IME）狀態、在滑鼠游標附近顯示，並提供可自訂的桌面時鐘。

## 螢幕截圖

### 輸入法狀態連動桌面時鐘
| IME OFF（英文） | IME ON（日文） |
|:--------------:|:-------------:|
| ![IME OFF](docs/images/clock_ime_off.png) | ![IME ON](docs/images/clock_ime_on.png) |

### 設定畫面
| 輸入法指示器 | 時鐘 | 滑鼠游標指示器 |
|:----------:|:----:|:-------------:|
| ![IME設定](docs/images/settings_ime_indicator.png) | ![時鐘設定](docs/images/settings_clock.png) | ![游標設定](docs/images/settings_cursor_indicator.png) |

### 多語言 UI
| 日語 | 繁體中文 |
|:----:|:-------:|
| ![About 日語](docs/images/about_ja.png) | ![About 中文](docs/images/about_zh-Hant.png) |

## 願景

**我們的目標是支援全球各種輸入法。**

我們希望幫助輸入法用戶能夠一目了然地確認當前的輸入模式。

## 功能

### 輸入法指示器
- 在螢幕上視覺化顯示當前輸入法狀態
- 日文輸入：紅色圓圈顯示「あ」
- 英文輸入：藍色圓圈顯示「A」
- 可自訂位置、大小和透明度

### 桌面時鐘
- 支援類比和數位模式的浮動時鐘
- 支援日期顯示
- 根據輸入法狀態切換背景顏色
- 可自由自訂視窗大小、字型大小和顏色

### 滑鼠游標指示器
- 在滑鼠游標附近顯示輸入法狀態
- 方便文字輸入時使用

## 語言支援

### 完整支援（輸入法檢測 + UI）
| 語言 | 輸入法檢測 | UI 翻譯 |
|------|:----------:|:-------:|
| 日文 | ✅ | ✅ |
| 英文 | ✅ | ✅ |
| 簡體中文 | ✅ | ✅ |
| 繁體中文 | ✅ | ✅ |
| 韓文 | ✅ | ✅ |

### 輸入法檢測 + 基本 UI
| 語言 | 輸入法檢測 | UI 翻譯 |
|------|:----------:|:-------:|
| 泰文 | ✅ | ✅ |
| 越南文 | ✅ | ✅ |
| 阿拉伯文 | ✅ | ✅ |
| 希伯來文 | ✅ | ✅ |
| 印地文 | ✅ | ✅ |
| 俄文 | ✅ | ✅ |
| 希臘文 | ✅ | ✅ |

*這些語言的 UI 翻譯為機器翻譯，可能需要改進。歡迎貢獻！*

## 系統需求

- macOS 14.0 (Sonoma) 或更高版本
- 支援 Apple Silicon / Intel Mac

## 安裝

### 下載發佈版（推薦）

1. 從 [Releases](https://github.com/obott9/IMEIndicatorClock/releases) 下載最新版本
2. 解壓縮下載的檔案
3. 將 `IMEIndicatorClock.app` 移動到「應用程式」資料夾
4. 啟動應用程式

### 從原始碼建置

```bash
git clone https://github.com/obott9/IMEIndicatorClock.git
cd IMEIndicatorClock
open IMEIndicatorClock.xcodeproj
```

## 使用方法

1. 啟動應用程式後，選單列會出現圖示
2. 從選單列圖示存取各種設定
3. 時鐘或指示器可在設定視窗開啟時拖曳到您喜歡的位置

## 所需權限

- **輔助使用**：用於監控輸入法狀態。首次啟動時會提示授予權限。

## 開發

此專案與 Anthropic 的 [Claude AI](https://claude.ai/) 共同開發。

Claude 協助了：
- 架構設計和程式碼實作
- 多語言本地化
- 文件和 README 建立

## 支持

如果您覺得這個應用程式有用，請考慮請我喝杯咖啡！

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/obott9)

## 貢獻

歡迎貢獻！特別是：
- 翻譯錯誤確認
- 錯誤報告和功能請求

## 授權

MIT License - 詳情請參閱 [LICENSE](LICENSE) 檔案。
