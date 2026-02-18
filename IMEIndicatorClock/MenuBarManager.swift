//
//  MenuBarManager.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/09.
//
//  メニューバーの管理
//  メニューバーアイコンとメニュー項目を制御します
//

import AppKit

// MARK: - メニューバーマネージャー

/// メニューバーアイコンとメニューを管理するクラス
class MenuBarManager: NSObject, NSMenuDelegate {

	// MARK: - シングルトン

	/// シングルトンインスタンス
	static let shared = MenuBarManager()

	// MARK: - プロパティ

	/// メニューバーに表示されるアイテム
	private var statusItem: NSStatusItem?

	// MARK: - 初期化

	private override init() {
		super.init()
	}

	// MARK: - セットアップ

	/// メニューバーをセットアップ
	func setup() {
		dbgLog(1, "🔧 [MenuBar] ========== setup 開始 ==========")

		// システムのメニューバーにステータスアイテムを作成
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

		// アイコンを設定
		if let button = statusItem?.button {
			button.image = NSImage(systemSymbolName: "character.textbox", accessibilityDescription: "IME Indicator")
			button.image?.size = NSSize(width: 18, height: 18)
		}

		// メニューを作成
		let menu = NSMenu()
		menu.delegate = self

		// --- アプリ情報 ---
		let aboutTitle: String
		#if DEBUG
		aboutTitle = String(localized: "menu.about_app")
			.replacingOccurrences(of: "IMEIndicatorClock", with: "IMEIndicatorClock(dbg)")
		#else
		aboutTitle = String(localized: "menu.about_app")
		#endif
		let aboutItem = NSMenuItem(
			title: aboutTitle,
			action: #selector(openAbout),
			keyEquivalent: ""
		)
		aboutItem.target = self
		menu.addItem(aboutItem)

		menu.addItem(NSMenuItem.separator())

		// --- 表示トグル ---
		let toggleItem = NSMenuItem(
			title: String(localized: "menu.show_ime_indicator"),
			action: #selector(toggleIndicator),
			keyEquivalent: ""
		)
		toggleItem.target = self
		toggleItem.state = IMEIndicatorWindowManager.shared.isVisible ? .on : .off
		menu.addItem(toggleItem)

		let clockSettings = AppSettingsManager.shared.settings.clock
		let toggleClockItem = NSMenuItem(
			title: String(localized: "menu.show_clock"),
			action: #selector(toggleClock),
			keyEquivalent: ""
		)
		toggleClockItem.target = self
		toggleClockItem.state = clockSettings.isVisible ? .on : .off
		menu.addItem(toggleClockItem)

		let mouseCursorSettings = AppSettingsManager.shared.settings.mouseCursorIndicator
		let toggleMouseCursorItem = NSMenuItem(
			title: String(localized: "menu.show_mouse_cursor_indicator"),
			action: #selector(toggleMouseCursorIndicator),
			keyEquivalent: ""
		)
		toggleMouseCursorItem.target = self
		toggleMouseCursorItem.state = mouseCursorSettings.isVisible ? .on : .off
		menu.addItem(toggleMouseCursorItem)

		menu.addItem(NSMenuItem.separator())

		// --- 設定（統合ウィンドウ） ---
		let settingsItem = NSMenuItem(
			title: String(localized: "menu.settings"),
			action: #selector(openSettings),
			keyEquivalent: ","
		)
		settingsItem.target = self
		menu.addItem(settingsItem)

		menu.addItem(NSMenuItem.separator())

		// --- システム ---
		let accessibilityItem = NSMenuItem(
			title: String(localized: "menu.check_accessibility"),
			action: #selector(recheckAccessibility),
			keyEquivalent: ""
		)
		accessibilityItem.target = self
		menu.addItem(accessibilityItem)

		menu.addItem(NSMenuItem.separator())

		// --- 終了 ---
		let quitItem = NSMenuItem(
			title: String(localized: "menu.quit"),
			action: #selector(quitApp),
			keyEquivalent: "q"
		)
		quitItem.target = self
		menu.addItem(quitItem)

		// メニューをステータスアイテムに設定
		statusItem?.menu = menu

		dbgLog(1, "✅ [MenuBar] メニュー項目数: \(menu.items.count)")
		dbgLog(1, "✅ [MenuBar] ========== setup 完了 ==========\n")
	}

	/// IME状態表示を更新
	func updateIMEStatus(_ isJapanese: Bool) {
		guard let menu = statusItem?.menu else { return }

		let statusPrefix = String(localized: "menu.status_prefix")
		for item in menu.items {
			if item.title.starts(with: statusPrefix) {
				item.title = isJapanese
					? String(localized: "menu.status_japanese")
					: String(localized: "menu.status_english")
			}
		}
	}

	/// インジケータの表示状態メニューを更新
	func updateIndicatorMenuState() {
		guard let menu = statusItem?.menu else { return }

		for item in menu.items {
			if item.action == #selector(toggleIndicator) {
				item.state = IMEIndicatorWindowManager.shared.isVisible ? .on : .off
			}
		}
	}

	/// 時計の表示状態メニューを更新
	func updateClockMenuState() {
		guard let menu = statusItem?.menu else { return }

		let clockSettings = AppSettingsManager.shared.settings.clock
		for item in menu.items {
			if item.action == #selector(toggleClock) {
				item.state = clockSettings.isVisible ? .on : .off
			}
		}
	}

	/// マウスカーソルインジケータの表示状態メニューを更新
	func updateMouseCursorIndicatorMenuState() {
		guard let menu = statusItem?.menu else { return }

		let mouseCursorSettings = AppSettingsManager.shared.settings.mouseCursorIndicator
		for item in menu.items {
			if item.action == #selector(toggleMouseCursorIndicator) {
				item.state = mouseCursorSettings.isVisible ? .on : .off
			}
		}
	}

	// MARK: - メニューアクション

	/// アプリについてのウィンドウを開く
	@objc func openAbout() {
		dbgLog(1, "ℹ️ [MenuBar] Aboutウィンドウを開きます...")
		UnifiedSettingsWindowManager.shared.openAbout()
	}

	/// インジケータの表示/非表示を切り替え
	@objc func toggleIndicator() {
		dbgLog(1, "👆 [MenuBar] toggleIndicator が呼ばれました")
		IMEIndicatorWindowManager.shared.toggleVisibility()
		updateIndicatorMenuState()
	}

	/// 設定ウィンドウを開く
	@objc func openSettings() {
		dbgLog(1, "⚙️ [MenuBar] 設定ウィンドウを開きます...")
		UnifiedSettingsWindowManager.shared.openSettings()
	}

	/// 時計の表示/非表示を切り替え
	@objc func toggleClock() {
		dbgLog(1, "👆 [MenuBar] toggleClock が呼ばれました")

		let settingsManager = AppSettingsManager.shared
		settingsManager.settings.clock.isVisible.toggle()
		settingsManager.save()
		ClockWindowManager.shared.recreate()

		updateClockMenuState()
		dbgLog(1, "🔍 [MenuBar] clock.isVisible = \(settingsManager.settings.clock.isVisible)")
	}

	/// マウスカーソルインジケータの表示/非表示を切り替え
	@objc func toggleMouseCursorIndicator() {
		dbgLog(1, "👆 [MenuBar] toggleMouseCursorIndicator が呼ばれました")

		let settingsManager = AppSettingsManager.shared
		settingsManager.settings.mouseCursorIndicator.isVisible.toggle()
		settingsManager.save()

		// 通知を送信（WindowManagerがハンドリング）
		NotificationCenter.default.post(
			name: .mouseCursorIndicatorSettingsChanged,
			object: nil
		)

		updateMouseCursorIndicatorMenuState()
		dbgLog(1, "🔍 [MenuBar] mouseCursorIndicator.isVisible = \(settingsManager.settings.mouseCursorIndicator.isVisible)")
	}

	/// アクセシビリティ権限を再確認
	@objc func recheckAccessibility() {
		AccessibilityHelper.checkAndShowStatus()
	}

	/// アプリを終了
	@objc func quitApp() {
		dbgLog(1, "🚪 [MenuBar] quitApp が呼ばれました - アプリを終了します")
		NSApplication.shared.terminate(nil)
	}

	// MARK: - NSMenuDelegate

	/// メニューが開かれる直前に呼ばれる
	func menuWillOpen(_ menu: NSMenu) {
		dbgLog(1, "📂 [MenuBar] ========== メニューが開かれます ==========")
		dbgLog(1, "🔍 [MenuBar] メニュー項目数: \(menu.items.count)")
	}

	/// メニューが閉じられた直後に呼ばれる
	func menuDidClose(_ menu: NSMenu) {
		dbgLog(1, "📁 [MenuBar] ========== メニューが閉じられました ==========\n")
	}
}
