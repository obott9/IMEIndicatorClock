# IMEIndicatorClock

[English](README.md) | [日本語](README_ja.md) | [简体中文](README_zh-Hans.md) | [한국어](README_ko.md)

一款 macOS 工具應用程式，可視化顯示輸入法（IME）狀態，並提供可自訂的桌面時鐘。

## 螢幕截圖

### 輸入法狀態連動桌面時鐘
| IME OFF（英文） | IME ON（日文） |
|:--------------:|:-------------:|
| ![IME OFF](docs/images/clock_ime_off.png) | ![IME ON](docs/images/clock_ime_on.png) |

### 設定畫面
| 輸入法指示器 | 時鐘 | 滑鼠游標指示器 |
|:----------:|:----:|:-------------:|
| ![IME設定](docs/images/settings_ime_indicator.png) | ![時鐘設定](docs/images/settings_clock.png) | ![游標設定](docs/images/settings_cursor_indicator.png) |

## 願景

**我們的目標是支援全球各種輸入法。**

我們希望幫助使用多種語言的用戶能夠一目了然地確認當前的輸入模式。

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

- macOS 13.0 (Ventura) 或更高版本
- 支援 Apple Silicon / Intel Mac

## 安裝

1. 複製此儲存庫
2. 在 Xcode 中開啟專案
3. 建置並執行

```bash
git clone https://github.com/obott9/IMEIndicatorClock.git
cd IMEIndicatorClock
open IMEIndicatorClock.xcodeproj
```

## 使用方法

1. 啟動應用程式後，選單列會出現圖示
2. 從選單列圖示存取各種設定
3. 拖曳時鐘或指示器到您喜歡的位置

## 所需權限

- **輔助使用**：用於監控輸入法狀態。首次啟動時會提示授予權限。

## 開發

此專案與 Anthropic 的 [Claude AI](https://claude.ai/) 共同開發。

Claude 協助了：
- 架構設計和程式碼實作
- 多語言本地化
- 文件和 README 建立

## 貢獻

歡迎貢獻！特別是：
- 其他語言的 UI 翻譯
- 支援更多輸入法類型
- 錯誤報告和功能請求

## 授權

MIT License - 詳情請參閱 [LICENSE](LICENSE) 檔案。
