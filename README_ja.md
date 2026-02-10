[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-red?logo=github)](https://github.com/sponsors/obott9)

# IMEIndicatorClock

[English](README.md) | [繁體中文](README_zh-Hant.md) | [简体中文](README_zh-Hans.md) | [한국어](README_ko.md)

IME（入力メソッドエディタ）の状態表示とそれをマウスカーソルのそばに表示、カスタマイズ可能なデスクトップ時計を視覚的に表示するmacOSユーティリティアプリです。

## スクリーンショット

### IME状態連動デスクトップ時計
| IME OFF（英語） | IME ON（日本語） |
|:--------------:|:---------------:|
| ![IME OFF](docs/images/clock_ime_off.jpg) | ![IME ON](docs/images/clock_ime_on.jpg) |

### 設定画面
| IMEインジケータ | 時計 | マウスカーソルインジケータ |
|:-------------:|:----:|:------------------------:|
| ![IME設定](docs/images/settings_ime_indicator.png) | ![時計設定](docs/images/settings_clock.png) | ![カーソル設定](docs/images/settings_cursor_indicator.png) |

### 多言語UI
| 日本語 | 繁體中文 |
|:------:|:-------:|
| ![About 日本語](docs/images/about_ja.png) | ![About 中文](docs/images/about_zh-Hant.png) |

## ビジョン

**目標は、世界中のIMEに対応すること。**

IMEを使用するユーザーが、現在の入力モードを一目で確認できるようにすることを目指しています。

## 機能

### IMEインジケータ
- 入力メソッド（IME）の状態を画面上に視覚的に表示

| 日本語 | 韓国語 | 中国語（繁体字） | 中国語（簡体字） | 英語 |
|:------:|:------:|:---------------:|:---------------:|:----:|
| <img src="docs/images/ime_ja.png" width="48"> | <img src="docs/images/ime_ko.png" width="48"> | <img src="docs/images/ime_zh_hant.png" width="48"> | <img src="docs/images/ime_zh_hans.png" width="48"> | <img src="docs/images/ime_en.png" width="48"> |
| 赤「あ」 | 紫「가」 | 濃緑「繁」 | 緑「简」 | 青「A」 |

- 表示位置、サイズ、背景色、フォント、フォント色、不透明度をカスタマイズ可能

### デスクトップ時計
- アナログ/デジタル両対応のフローティング時計
- 日付表示対応
- IME状態に応じた背景色切り替え機能
- ウィンドウサイズ、フォントサイズ、色を自由にカスタマイズ

### マウスカーソルインジケータ
- マウスカーソル付近にIME状態を表示
- IMEインジケータを小さく表示
- テキスト入力時に便利

### 統合設定 & クイックアクセス
- タブ切替の統合設定ウインドウで全機能を一括管理
- 各ウインドウの右クリックメニューから設定に素早くアクセス

## 言語サポート

### 完全対応（IME検出 + UI）
| 言語 | IME検出 | UI翻訳 |
|------|:-------:|:------:|
| 日本語 | ✅ | ✅ |
| 英語 | ✅ | ✅ |
| 中国語（簡体字） | ✅ | ✅ |
| 中国語（繁体字） | ✅ | ✅ |
| 韓国語 | ✅ | ✅ |

### IME検出 + 基本UI
| 言語 | IME検出 | UI翻訳 |
|------|:-------:|:------:|
| タイ語 | ✅ | ✅ |
| ベトナム語 | ✅ | ✅ |
| アラビア語 | ✅ | ✅ |
| ヘブライ語 | ✅ | ✅ |
| ヒンディー語 | ✅ | ✅ |
| ロシア語 | ✅ | ✅ |
| ギリシャ語 | ✅ | ✅ |

*これらの言語のUI翻訳は機械翻訳のため、改善が必要な場合があります。貢献歓迎！*

## 動作環境

- macOS 14.0 (Sonoma) 以降
- Apple Silicon / Intel Mac 対応

## インストール

### リリースをダウンロード（推奨）

1. [Releases](https://github.com/obott9/IMEIndicatorClock/releases) から最新版をダウンロード
2. ダウンロードしたファイルを解凍
3. `IMEIndicatorClock.app` をアプリケーションフォルダに移動
4. アプリを起動

### ソースからビルド

```bash
git clone https://github.com/obott9/IMEIndicatorClock.git
cd IMEIndicatorClock
open IMEIndicatorClock.xcodeproj
```

## 使い方

1. アプリを起動するとメニューバーにアイコンが表示されます
2. メニューバーのアイコンから各種設定にアクセスできます
3. 時計やインジケータは設定ウィンドウが表示されている時にドラッグで好きな位置に移動できます

## 必要な権限

- **アクセシビリティ**: IME状態の監視に必要です。初回起動時に許可を求められます。

## 開発

このプロジェクトは Anthropic の [Claude AI](https://claude.ai/) との共同作業で開発されました。

Claudeは以下をサポートしました：
- アーキテクチャ設計とコード実装
- 多言語ローカライズ
- ドキュメントとREADMEの作成

## サポート

このアプリが役に立ったら、コーヒーをおごってください！

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/obott9)

## 貢献

貢献を歓迎します！特に：
- 翻訳のミス確認
- バグ報告と機能リクエスト

## ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照してください。
