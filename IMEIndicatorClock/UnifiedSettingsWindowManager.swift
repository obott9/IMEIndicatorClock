//
//  UnifiedSettingsWindowManager.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/14.
//
//  統合設定ウィンドウの管理
//  全ての設定画面を1つのタブ付きウィンドウで表示する
//

import SwiftUI
import AppKit

// MARK: - 統合設定ウィンドウマネージャー

/// 統合設定ウィンドウを管理するクラス
class UnifiedSettingsWindowManager: NSObject {

	// MARK: - シングルトン

	/// シングルトンインスタンス
	static let shared = UnifiedSettingsWindowManager()

	// MARK: - プロパティ

	/// 設定ウィンドウへの参照（強参照を保持してクラッシュを防ぐ）
	private var settingsWindow: NSWindow?

	/// 現在表示中のタブ
	private var currentTab: SettingsTab = .imeIndicator

	/// 設定ウィンドウが開いているかどうか
	var isOpen: Bool {
		return settingsWindow != nil
	}

	// MARK: - 初期化

	private override init() {
		super.init()
	}

	// MARK: - ウィンドウ管理

	/// 設定ウィンドウを開く（指定タブで）
	/// - Parameter tab: 開くタブ（デフォルトは前回のタブ）
	func openSettings(tab: SettingsTab? = nil) {
		let targetTab = tab ?? currentTab
		currentTab = targetTab

		dbgLog(1, "🔧 [UnifiedSettings] 設定ウィンドウを開きます... tab=\(targetTab)")

		// 既にウィンドウが開いている場合は前面に表示
		if let window = settingsWindow {
			window.makeKeyAndOrderFront(nil)
			NSApp.activate(ignoringOtherApps: true)
			
			// 時計ウィンドウの移動モードをON（念のため）
			AppSettingsManager.shared.settings.clock.moveMode = true
			ClockWindowManager.shared.updateMoveModeFromSettings()
			
			dbgLog(1, "✅ [UnifiedSettings] 既存のウィンドウを前面に表示しました（時計移動モードON）")
			return
		}

		// 新しいウィンドウを作成（システムの優先言語に基づいたLocaleを適用）
		let preferredLocale = Locale(identifier: Locale.preferredLanguages.first ?? "en")
		let settingsView = UnifiedSettingsView(initialTab: targetTab)
			.environment(\.locale, preferredLocale)
		let hostingView = NSHostingView(rootView: AnyView(settingsView))

		let window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 950, height: 700),
			styleMask: [.titled, .closable, .miniaturizable, .resizable],
			backing: .buffered,
			defer: false
		)

		window.title = String(localized: "settings.window_title", table: "Settings")
		window.contentView = hostingView
		window.center()
		window.setFrameAutosaveName("UnifiedSettings")
		window.isReleasedWhenClosed = false  // クラッシュ防止
		window.level = .floating  // 最前面に固定
		window.minSize = NSSize(width: 800, height: 600)
		window.maxSize = NSSize(width: 1400, height: 1000)

		// ウィンドウが閉じられたときの通知を監視
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(windowWillClose(_:)),
			name: NSWindow.willCloseNotification,
			object: window
		)

		self.settingsWindow = window
		window.makeKeyAndOrderFront(nil)
		NSApp.activate(ignoringOtherApps: true)

		// 時計ウィンドウの移動モードをON
		AppSettingsManager.shared.settings.clock.moveMode = true
		ClockWindowManager.shared.updateMoveModeFromSettings()

		dbgLog(1, "✅ [UnifiedSettings] 新しいウィンドウを作成しました（最前面固定、時計移動モードON）")
	}

	/// IMEインジケータ設定を開く
	func openIMEIndicatorSettings() {
		openSettings(tab: .imeIndicator)
	}

	/// 時計設定を開く
	func openClockSettings() {
		openSettings(tab: .clock)
	}

	/// マウスカーソルインジケータ設定を開く
	func openMouseCursorIndicatorSettings() {
		openSettings(tab: .mouseCursor)
	}

	/// アプリについてを開く
	func openAbout() {
		openSettings(tab: .about)
	}

	/// 設定ウィンドウを閉じる
	func closeSettings() {
		// IMEインジケータの移動モードをOFF（既存動作を維持）
		AppSettingsManager.shared.settings.imeIndicator.moveMode = false

		// 時計ウィンドウの移動モードをOFF
		AppSettingsManager.shared.settings.clock.moveMode = false
		ClockWindowManager.shared.updateMoveModeFromSettings()

		// 少し待ってから通知を送信（確実に反映させる）
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
			NotificationCenter.default.post(
				name: .imeIndicatorSettingsChanged,
				object: nil
			)
		}

		settingsWindow?.close()
		settingsWindow = nil
		dbgLog(1, "✅ [UnifiedSettings] ウィンドウを閉じました（移動モードOFF）")
	}

	// MARK: - 通知ハンドラー

	/// ウィンドウが閉じられた時
	@objc private func windowWillClose(_ notification: Notification) {
		if let window = notification.object as? NSWindow,
		   window == settingsWindow {

			// オブザーバーを解除（リーク防止）
			NotificationCenter.default.removeObserver(self, name: NSWindow.willCloseNotification, object: window)

			// IMEインジケータの移動モードをOFF（既存動作を維持）
			AppSettingsManager.shared.settings.imeIndicator.moveMode = false

			// 時計ウィンドウの移動モードをOFF
			AppSettingsManager.shared.settings.clock.moveMode = false
			ClockWindowManager.shared.updateMoveModeFromSettings()

			// 少し待ってから通知を送信（確実に反映させる）
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
				NotificationCenter.default.post(
					name: .imeIndicatorSettingsChanged,
					object: nil
				)
			}

			settingsWindow = nil
			dbgLog(1, "🔧 [UnifiedSettings] ウィンドウが閉じられました（移動モードOFF）")
		}
	}
}
