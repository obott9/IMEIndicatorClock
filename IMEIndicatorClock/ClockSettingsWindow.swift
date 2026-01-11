//
//  ClockSettingsWindow.swift
//  IMEIndicatorClock
//
//  Created on 2025/12/24.
//
//  時計設定ウィンドウの管理
//

import SwiftUI
import AppKit

// MARK: - 時計設定ウィンドウマネージャー

/// 時計設定ウィンドウを管理するクラス
class ClockSettingsWindowManager {
	
	/// シングルトンインスタンス
	static let shared = ClockSettingsWindowManager()
	
	/// 設定ウィンドウへの参照（強参照を保持してクラッシュを防ぐ）
	private var settingsWindow: NSWindow?
	
	private init() {}
	
	/// 設定ウィンドウを開く
	func openSettings() {
		// 既存のウィンドウがあればそれを前面に表示
		if let window = settingsWindow {
			window.makeKeyAndOrderFront(nil)
			NSApp.activate(ignoringOtherApps: true)
			return
		}
		
		// 新しいウィンドウを作成
		let settingsView = ClockSettingsView()
		let hostingView = NSHostingView(rootView: settingsView)
		
		let window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 950, height: 700),
			styleMask: [.titled, .closable, .miniaturizable, .resizable],
			backing: .buffered,
			defer: false
		)
		
		window.title = String(localized: "title", table: "Clock")
		window.contentView = hostingView
		window.center()
		window.isReleasedWhenClosed = false
		window.level = .floating  // 最前面に表示
		window.minSize = NSSize(width: 800, height: 600)  // 最小サイズ
		window.maxSize = NSSize(width: 1400, height: 1000)  // 最大サイズ
		
		// ウィンドウが閉じられたときの通知を監視
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(windowWillClose(_:)),
			name: NSWindow.willCloseNotification,
			object: window
		)
		
		// ウィンドウを表示
		window.makeKeyAndOrderFront(nil)
		NSApp.activate(ignoringOtherApps: true)
		
		// 参照を保持
		self.settingsWindow = window

		dbgLog(1, "⚙️ [ClockSettingsWindow] 設定ウィンドウを開きました")
	}
	
	/// ウィンドウが閉じられる時
	@objc private func windowWillClose(_ notification: Notification) {
		if let window = notification.object as? NSWindow,
		   window == settingsWindow {
			settingsWindow = nil
			dbgLog(1, "⚙️ [ClockSettingsWindow] 設定ウィンドウが閉じられました")
		}
	}
	
	/// 設定ウィンドウを閉じる（プログラムから呼び出す用）
	func closeSettings() {
		if let window = settingsWindow {
			window.close()
			settingsWindow = nil
			dbgLog(1, "⚙️ [ClockSettingsWindow] 設定ウィンドウをプログラムから閉じました")
		}
	}
}

// MARK: - プレビュー

// プレビューは一時的に無効化（Xcodeクラッシュ対策）
#Preview {
//	ClockSettingsWindowManager()
//		.frame(width: 300, height: 200)
}
