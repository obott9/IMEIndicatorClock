//
//  IMEIndicatorSettingsWindowManager.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/06.
//
//  IMEインジケータ設定ウィンドウの管理
//

import SwiftUI
import AppKit

// MARK: - IMEインジケータ設定ウィンドウマネージャー

/// IMEインジケータ設定ウィンドウの表示・管理を担当するクラス
class IMEIndicatorSettingsWindowManager {
	
	/// シングルトンインスタンス
	static let shared = IMEIndicatorSettingsWindowManager()
	
	/// 設定ウィンドウ（強参照を保持してクラッシュを防ぐ）
	private var settingsWindow: NSWindow?
	
	// MARK: - 初期化
	
	private init() {}
	
	// MARK: - ウィンドウ管理
	
	/// 設定ウィンドウを開く
	func openSettings() {
		dbgLog(1, "🔧 [IMEIndicatorSettingsWindow] 設定ウィンドウを開きます...")
		
		// 既にウィンドウが開いている場合は前面に表示
		if let window = settingsWindow {
			window.makeKeyAndOrderFront(nil)
			NSApp.activate(ignoringOtherApps: true)
			dbgLog(1, "✅ [IMEIndicatorSettingsWindow] 既存のウィンドウを前面に表示しました")
			return
		}
		
		// 新しいウィンドウを作成
		let settingsView = IMEIndicatorSettingsView()
		let hostingView = NSHostingView(rootView: settingsView)
		
		let window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
			styleMask: [.titled, .closable, .miniaturizable],
			backing: .buffered,
			defer: false
		)
		
		window.title = String(localized: "title", table: "IMEIndicator")
		window.contentView = hostingView
		window.center()
		window.setFrameAutosaveName("IMEIndicatorSettings")
		window.isReleasedWhenClosed = false  // クラッシュ防止：ウィンドウを自動解放しない
		window.level = .floating  // 最前面に固定
		
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
		
		dbgLog(1, "✅ [IMEIndicatorSettingsWindow] 新しいウィンドウを作成しました（最前面固定）")
	}
	
	/// 設定ウィンドウを閉じる
	func closeSettings() {
		// 移動モードをOFF（メモリ上のみ、保存しない）
		AppSettingsManager.shared.settings.imeIndicator.moveMode = false
		
		// 少し待ってから通知を送信（確実に反映させる）
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
			NotificationCenter.default.post(name: .imeIndicatorSettingsChanged, object: nil)
		}
		
		settingsWindow?.close()
		settingsWindow = nil
		dbgLog(1, "✅ [IMEIndicatorSettingsWindow] ウィンドウを閉じました（移動モードOFF）")
	}
	
	// MARK: - 通知ハンドラー
	
	/// ウィンドウが閉じられた時
	@objc private func windowWillClose(_ notification: Notification) {
		if let window = notification.object as? NSWindow,
		   window == settingsWindow {
			// 移動モードをOFF（メモリ上のみ、保存しない）
			AppSettingsManager.shared.settings.imeIndicator.moveMode = false
			
			// 少し待ってから通知を送信（確実に反映させる）
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
				NotificationCenter.default.post(name: .imeIndicatorSettingsChanged, object: nil)
			}
			
			settingsWindow = nil
			dbgLog(1, "🔧 [IMEIndicatorSettingsWindow] ウィンドウが閉じられました（移動モードOFF）")
		}
	}
}
