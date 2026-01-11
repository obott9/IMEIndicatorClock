//
//  IMEIndicatorClockApp.swift
//  IMEIndicatorClock
//
//  Created by obott9 on 2025/12/21.
//
//  IME（Input Method Editor）の状態を画面上に視覚的に表示するmacOSアプリケーション
//  日本語入力時は赤い円に「あ」、英語入力時は青い円に「A」を表示します
//

import SwiftUI
import AppKit

// MARK: - メインアプリケーション構造体

/// アプリケーションのエントリーポイント
/// @mainアトリビュートにより、このアプリの起動時に最初に実行されます
@main
struct IMEIndicatorClockApp: App {
	// NSApplicationDelegateAdaptorを使用して、AppKitのAppDelegateパターンをSwiftUIで利用
	@NSApplicationDelegateAdaptor(AppDelegate.self) var _appDelegate

	/// アプリケーションのシーン構成
	var body: some Scene {
		Settings {
			AboutView()  // アプリ情報画面（⌘, で開く）
		}
	}
}

// MARK: - アプリケーションデリゲート

/// アプリケーションのライフサイクルを管理するクラス
/// 各機能の初期化と連携を担当
class AppDelegate: NSObject, NSApplicationDelegate {

	// MARK: - アプリケーションライフサイクル

	/// アプリケーションの起動が完了した時に呼ばれる
	func applicationDidFinishLaunching(_ notification: Notification) {
		dbgLog(-1, "🚀 [DEBUG] ========================================")
		dbgLog(-1, "🚀 [DEBUG] IME Indicator Clock 起動開始")
		dbgLog(-1, "🚀 [DEBUG] ========================================\n")

		// 1. アクセシビリティ権限のチェック
		dbgLog(1, "1️⃣ [DEBUG] アクセシビリティ権限チェック...")
		AccessibilityHelper.checkPermissionOnLaunch()

		// 2. アクティベーションポリシーを設定（Dockに表示しない）
		dbgLog(1, "2️⃣ [DEBUG] アクティベーションポリシーを設定...")
		NSApplication.shared.setActivationPolicy(.accessory)
		dbgLog(1, "✅ [DEBUG] .accessory モードに設定完了")

		// 3. メニューバーをセットアップ
		dbgLog(1, "3️⃣ [DEBUG] メニューバーをセットアップ...")
		MenuBarManager.shared.setup()
		dbgLog(1, "✅ [DEBUG] メニューバー設定完了")

		// 4. IMEインジケータを初期化
		dbgLog(1, "4️⃣ [DEBUG] IMEインジケータを初期化...")
		IMEIndicatorWindowManager.shared.show()
		dbgLog(1, "✅ [DEBUG] IMEインジケータ初期化完了")

		// 5. IME監視を開始
		dbgLog(1, "5️⃣ [DEBUG] IME監視を開始...")
		IMEMonitor.shared.onLanguageChanged = { [weak self] language in
			self?.handleLanguageChanged(language)
		}
		IMEMonitor.shared.startMonitoring()
		dbgLog(1, "✅ [DEBUG] IME監視開始完了")

		// 6. 時計機能を初期化
		dbgLog(1, "6️⃣ [DEBUG] 時計機能を初期化...")
		ClockWindowManager.shared.show()
		dbgLog(1, "✅ [DEBUG] 時計機能初期化完了")

		// 7. マウスカーソルインジケータを初期化（設定でONの場合のみ）
		let mouseIndicatorVisible = AppSettingsManager.shared.settings.mouseCursorIndicator.isVisible
		dbgLog(-1, "7️⃣ [DEBUG] マウスカーソルインジケータを初期化... isVisible=%@", mouseIndicatorVisible ? "true" : "false")
		if mouseIndicatorVisible {
			MouseCursorIndicatorWindowManager.shared.show()
		}
		dbgLog(-1, "✅ [DEBUG] マウスカーソルインジケータ初期化完了")

		dbgLog(1, "\n🎉 [DEBUG] ========================================")
		dbgLog(1, "🎉 [DEBUG] IME Indicator Clock 起動完了")
		dbgLog(1, "🎉 [DEBUG] ========================================\n")
	}

	// MARK: - 入力言語変更ハンドラ

	/// 入力言語が変更された時の処理
	private func handleLanguageChanged(_ language: InputLanguage) {
		// インジケータを更新
		IMEIndicatorWindowManager.shared.updateLanguage(language)

		// マウスカーソルインジケータを更新
		MouseCursorIndicatorWindowManager.shared.updateLanguage(language)

		// メニューバーの状態表示を更新
		MenuBarManager.shared.updateIMEStatus(language.isIMEOn)

		// 時計の背景色を更新
		AppSettingsManager.shared.updateIMEState(isJapanese: language.isIMEOn)
	}
}

