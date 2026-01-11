//
//  ClockWindow.swift
//  IMEIndicatorClock
//
//  Created on 2025/12/24.
//
//  時計ウィンドウの管理
//  デスクトップに常時表示される時計ウィンドウを制御します
//

import SwiftUI
import AppKit

// MARK: - 時計ウィンドウマネージャー

/// 時計ウィンドウを管理するクラス
class ClockWindowManager: NSObject, NSWindowDelegate {
	
	/// シングルトンインスタンス
	static let shared = ClockWindowManager()
	
	/// 時計ウィンドウ
	private var clockWindow: NSWindow?
	
	/// NSHostingView（強参照で保持）
	private var hostingView: NSHostingView<ClockView>?
	
	/// NotificationCenterのオブザーバートークン
	private var windowMoveObserver: NSObjectProtocol?
	private var windowResizeObserver: NSObjectProtocol?  // リサイズ用のオブザーバーを追加
	private var windowDidEndLiveResizeObserver: NSObjectProtocol?  // リサイズ終了用のオブザーバー
	
	/// 設定マネージャー
	private let settingsManager = AppSettingsManager.shared
	
	// MARK: - 初期化
	
	private override init() {
		// 設定変更の通知は使用しない（手動で recreate() を呼ぶ）
	}
	
	deinit {
		// オブザーバーを削除
		if let observer = windowMoveObserver {
			NotificationCenter.default.removeObserver(observer)
			windowMoveObserver = nil
		}
		if let observer = windowResizeObserver {
			NotificationCenter.default.removeObserver(observer)
			windowResizeObserver = nil
		}
		if let observer = windowDidEndLiveResizeObserver {
			NotificationCenter.default.removeObserver(observer)
			windowDidEndLiveResizeObserver = nil
		}
		
		// ウィンドウをクリーンアップ
		hostingView = nil
		clockWindow?.close()
		clockWindow = nil
		
		dbgLog(1, "🗑️ [ClockWindow] ClockWindowManager が解放されました")
	}
	
	// MARK: - ウィンドウ管理
	
	/// 時計ウィンドウを作成・表示
	func show() {
		dbgLog(1, "▶️ [ClockWindow] show開始")
		
		// 既存のウィンドウがある場合のみ閉じる
		if clockWindow != nil {
			dbgLog(1, "▶️ [ClockWindow] 既存ウィンドウを閉じる")
			hide()
		}
		
		dbgLog(1, "▶️ [ClockWindow] オブザーバーをクリーン中...")
		// 既存のオブザーバーを削除（念のため）
		if let observer = windowMoveObserver {
			NotificationCenter.default.removeObserver(observer)
			windowMoveObserver = nil
		}
		if let observer = windowResizeObserver {
			NotificationCenter.default.removeObserver(observer)
			windowResizeObserver = nil
		}
		if let observer = windowDidEndLiveResizeObserver {
			NotificationCenter.default.removeObserver(observer)
			windowDidEndLiveResizeObserver = nil
		}
		
		dbgLog(1, "▶️ [ClockWindow] 設定を取得中...")
		let settings = settingsManager.settings.clock
		
		// ウィンドウサイズを計算
		let windowSize = calculateWindowSize(for: settings)
		
		// 表示位置を計算（マルチディスプレイ対応）
		let screen = getTargetScreen(index: settings.displayIndex)
		let windowOrigin = CGPoint(x: settings.positionX, y: settings.positionY)
		
		// ウィンドウの矩形を定義
		let windowRect = NSRect(
			x: screen.frame.origin.x + windowOrigin.x,
			y: screen.frame.origin.y + windowOrigin.y,
			width: windowSize.width,
			height: windowSize.height
		)
		
		// ウィンドウを作成
		// 移動モード時はリサイズも可能にする
		let styleMask: NSWindow.StyleMask = settings.moveMode 
			? [.borderless, .nonactivatingPanel, .resizable]
			: [.borderless, .nonactivatingPanel]
		
		let window = NSWindow(
			contentRect: windowRect,
			styleMask: styleMask,
			backing: .buffered,
			defer: false
		)
		
		// ウィンドウのプロパティ設定
		window.isOpaque = false
		window.backgroundColor = .clear
		window.level = .floating
		window.collectionBehavior = [
			.canJoinAllSpaces,    // 全仮想デスクトップに表示
			.stationary,
			.ignoresCycle
		]
		
		// ウィンドウサイズの制限を設定
		// 詳細は ClockDesignRules.md を参照
		window.minSize = NSSize(width: 100, height: 100)
		window.maxSize = NSSize(width: 500, height: 500)
		
		// アニメーションを完全に無効化（クラッシュ防止）
		window.animationBehavior = .none
		
		// 移動モードに応じてマウスイベントを制御
		if settings.moveMode {
			// 移動モード：ドラッグで移動可能
			window.ignoresMouseEvents = false
			window.isMovableByWindowBackground = true
			window.isMovable = true  // 追加：これが重要！
		} else {
			// 通常モード：マウスイベントを無視
			window.ignoresMouseEvents = true
			window.isMovableByWindowBackground = false
			window.isMovable = false
		}
		window.hasShadow = true
		
		// デリゲートを設定（リサイズ制限のため）
		window.delegate = self
		
		dbgLog(1, "▶️ [ClockWindow] ClockViewを作成中...")
		// SwiftUIビューを設定
		let clockView = ClockView(settingsManager: settingsManager)
		dbgLog(1, "▶️ [ClockWindow] NSHostingViewを作成中...")
		let newHostingView = NSHostingView(rootView: clockView)
		self.hostingView = newHostingView  // 強参照で保持
		dbgLog(1, "▶️ [ClockWindow] contentViewを設定中...")
		window.contentView = newHostingView
		
		dbgLog(1, "▶️ [ClockWindow] ウィンドウを表示中...")
		// ウィンドウを表示
		if settings.isVisible {
			window.orderFrontRegardless()
		}
		
		dbgLog(1, "▶️ [ClockWindow] オブザーバーを登録中...")
		
		// ウィンドウの位置が変更されたときの監視（移動モードの時のみ）
		if settings.moveMode {
			// 移動の監視
			windowMoveObserver = NotificationCenter.default.addObserver(
				forName: NSWindow.didMoveNotification,
				object: window,
				queue: .main
			) { [weak self] notification in
				self?.handleWindowDidMove(notification)
			}
			
			// リサイズの監視
			windowResizeObserver = NotificationCenter.default.addObserver(
				forName: NSWindow.didResizeNotification,
				object: window,
				queue: .main
			) { [weak self] notification in
				self?.handleWindowDidResize(notification)
			}
			
			// リサイズ終了の監視
			windowDidEndLiveResizeObserver = NotificationCenter.default.addObserver(
				forName: NSWindow.didEndLiveResizeNotification,
				object: window,
				queue: .main
			) { [weak self] notification in
				self?.handleWindowDidEndLiveResize(notification)
			}
			
			dbgLog(1, "▶️ [ClockWindow] オブザーバー登録完了（移動モード）")
		}
		
		self.clockWindow = window
		
		dbgLog(1, "🕐 [ClockWindow] 時計ウィンドウを作成しました")
		dbgLog(1, "▶️ [ClockWindow] show完了")
	}
	
	/// 時計ウィンドウを非表示
	func hide() {
		guard let window = clockWindow else {
			dbgLog(1, "🕐 [ClockWindow] 既にウィンドウは存在しません")
			return
		}
		
		dbgLog(1, "🕐 [ClockWindow] hide開始")
		
		// オブザーバーを削除
		if let observer = windowMoveObserver {
			NotificationCenter.default.removeObserver(observer)
			windowMoveObserver = nil
			dbgLog(1, "🕐 [ClockWindow] 移動オブザーバー削除完了")
		}
		if let observer = windowResizeObserver {
			NotificationCenter.default.removeObserver(observer)
			windowResizeObserver = nil
			dbgLog(1, "🕐 [ClockWindow] リサイズオブザーバー削除完了")
		}
		if let observer = windowDidEndLiveResizeObserver {
			NotificationCenter.default.removeObserver(observer)
			windowDidEndLiveResizeObserver = nil
			dbgLog(1, "🕐 [ClockWindow] リサイズ終了オブザーバー削除完了")
		}
		
		// アニメーションを完全に無効化
		window.animationBehavior = .none
		
		// ウィンドウを非表示にする
		window.orderOut(nil)
		
		// ウィンドウのコンテンツビューをクリア
		window.contentView = nil
		
		// 参照をクリア（これでウィンドウは自動的に解放される）
		self.clockWindow = nil
		self.hostingView = nil
		
		// window.close() は呼ばない！
		// 参照がなくなれば自動的に解放される
		
		dbgLog(1, "🕐 [ClockWindow] ウィンドウを非表示にしました")
	}
	
	/// ウィンドウを再作成（設定変更時）
	func recreate() {
		dbgLog(1, "🔄 [ClockWindow] recreate開始")
		
		let settings = settingsManager.settings.clock
		
		// ウィンドウが存在しない場合は新規作成
		guard let window = clockWindow, let hostingView = hostingView else {
			dbgLog(1, "🔄 [ClockWindow] ウィンドウが存在しないため、新規作成")
			if settings.isVisible {
				show()
			}
			dbgLog(1, "🔄 [ClockWindow] recreate完了")
			return
		}
		
		dbgLog(1, "🔄 [ClockWindow] 既存ウィンドウを更新")
		
		// ウィンドウサイズの制限を設定
		// 詳細は ClockDesignRules.md を参照
		window.minSize = NSSize(width: 100, height: 100)
		window.maxSize = NSSize(width: 500, height: 500)
		
		// 表示/非表示の切り替え
		if settings.isVisible {
			window.orderFrontRegardless()
		} else {
			window.orderOut(nil)
			dbgLog(1, "🔄 [ClockWindow] recreate完了")
			return
		}
		
		// ウィンドウサイズを更新
		let windowSize = calculateWindowSize(for: settings)
		
		// 最大サイズ制限（500px）を確実に適用
		let clampedWidth = min(windowSize.width, 500)
		let clampedHeight = min(windowSize.height, 500)
		let clampedSize = NSSize(width: clampedWidth, height: clampedHeight)
		
		var frame = window.frame
		frame.size = clampedSize
		window.setFrame(frame, display: true, animate: false)
		
		// 位置の更新（ウィンドウドラッグ中は更新しない）
		if !settingsManager.isWindowDragging {
			// 位置を更新（マルチディスプレイ対応）
			let screen = getTargetScreen(index: settings.displayIndex)
			let newOrigin = CGPoint(
				x: screen.frame.origin.x + settings.positionX,
				y: screen.frame.origin.y + settings.positionY
			)
			frame.origin = newOrigin
			window.setFrameOrigin(newOrigin)
			
			dbgLog(1, "📐 [ClockWindow] ウィンドウサイズを更新: %dx%d 位置(%d, %d)", Int(clampedWidth), Int(clampedHeight), Int(settings.positionX), Int(settings.positionY))
		} else {
			dbgLog(1, "📐 [ClockWindow] ウィンドウサイズを更新: %dx%d (ドラッグ中のため位置更新スキップ)", Int(clampedWidth), Int(clampedHeight))
		}
		
		// 移動モードの更新
		if settings.moveMode {
			window.styleMask.insert(.resizable)  // リサイズを有効化
			window.ignoresMouseEvents = false
			window.isMovableByWindowBackground = true
			window.isMovable = true
			
			// オブザーバーがまだ登録されていない場合のみ登録
			if windowMoveObserver == nil {
				windowMoveObserver = NotificationCenter.default.addObserver(
					forName: NSWindow.didMoveNotification,
					object: window,
					queue: .main
				) { [weak self] notification in
					self?.handleWindowDidMove(notification)
				}
				dbgLog(1, "🔄 [ClockWindow] 移動オブザーバー登録（移動モード ON）")
			}
			
			if windowResizeObserver == nil {
				windowResizeObserver = NotificationCenter.default.addObserver(
					forName: NSWindow.didResizeNotification,
					object: window,
					queue: .main
				) { [weak self] notification in
					self?.handleWindowDidResize(notification)
				}
				dbgLog(1, "🔄 [ClockWindow] リサイズオブザーバー登録（移動モード ON）")
			}
			
			if windowDidEndLiveResizeObserver == nil {
				windowDidEndLiveResizeObserver = NotificationCenter.default.addObserver(
					forName: NSWindow.didEndLiveResizeNotification,
					object: window,
					queue: .main
				) { [weak self] notification in
					self?.handleWindowDidEndLiveResize(notification)
				}
				dbgLog(1, "🔄 [ClockWindow] リサイズ終了オブザーバー登録（移動モード ON）")
			}
		} else {
			window.styleMask.remove(.resizable)  // リサイズを無効化
			window.ignoresMouseEvents = true
			window.isMovableByWindowBackground = false
			window.isMovable = false
			
			// 移動モード OFF ならオブザーバーを削除
			if let observer = windowMoveObserver {
				NotificationCenter.default.removeObserver(observer)
				windowMoveObserver = nil
				dbgLog(1, "🔄 [ClockWindow] 移動オブザーバー削除（移動モード OFF）")
			}
			if let observer = windowResizeObserver {
				NotificationCenter.default.removeObserver(observer)
				windowResizeObserver = nil
				dbgLog(1, "🔄 [ClockWindow] リサイズオブザーバー削除（移動モード OFF）")
			}
			if let observer = windowDidEndLiveResizeObserver {
				NotificationCenter.default.removeObserver(observer)
				windowDidEndLiveResizeObserver = nil
				dbgLog(1, "🔄 [ClockWindow] リサイズ終了オブザーバー削除（移動モード OFF）")
			}
		}
		
		// ビューの内容を更新（これが重要！）
		let newClockView = ClockView(settingsManager: settingsManager)
		hostingView.rootView = newClockView
		
		dbgLog(1, "🔄 [ClockWindow] ウィンドウ更新完了")
		dbgLog(1, "🔄 [ClockWindow] recreate完了")
	}
	
	/// ウィンドウの表示内容だけを更新（軽量な処理、オブザーバーは保持）
	func updateView() {
		guard let hostingView = self.hostingView else {
			dbgLog(1, "⚠️ [ClockWindow] hostingViewが存在しないため、ビュー更新をスキップ")
			return
		}
		
		// ビューの内容だけを更新（ウィンドウサイズやオブザーバーはそのまま）
		let newClockView = ClockView(settingsManager: settingsManager)
		hostingView.rootView = newClockView
		
		dbgLog(1, "🔄 [ClockWindow] ビューの内容を更新しました（軽量）")
	}
	
	/// 移動モードを設定から更新（設定ウィンドウの開閉時に呼ばれる）
	func updateMoveModeFromSettings() {
		guard let window = clockWindow else {
			dbgLog(1, "⚠️ [ClockWindow] ウィンドウが存在しないため、移動モード更新をスキップ")
			return
		}
		
		let settings = settingsManager.settings.clock
		
		dbgLog(1, "🔄 [ClockWindow] updateMoveModeFromSettings: moveMode = %@", settings.moveMode ? "true" : "false")
		
		if settings.moveMode {
			// 移動モード ON
			window.styleMask.insert(.resizable)
			window.ignoresMouseEvents = false
			window.isMovableByWindowBackground = true
			window.isMovable = true
			
			// オブザーバーがまだ登録されていない場合のみ登録
			if windowMoveObserver == nil {
				windowMoveObserver = NotificationCenter.default.addObserver(
					forName: NSWindow.didMoveNotification,
					object: window,
					queue: .main
				) { [weak self] notification in
					self?.handleWindowDidMove(notification)
				}
				dbgLog(1, "🔄 [ClockWindow] 移動オブザーバー登録（移動モード ON）")
			}
			
			if windowResizeObserver == nil {
				windowResizeObserver = NotificationCenter.default.addObserver(
					forName: NSWindow.didResizeNotification,
					object: window,
					queue: .main
				) { [weak self] notification in
					self?.handleWindowDidResize(notification)
				}
				dbgLog(1, "🔄 [ClockWindow] リサイズオブザーバー登録（移動モード ON）")
			}
			
			if windowDidEndLiveResizeObserver == nil {
				windowDidEndLiveResizeObserver = NotificationCenter.default.addObserver(
					forName: NSWindow.didEndLiveResizeNotification,
					object: window,
					queue: .main
				) { [weak self] notification in
					self?.handleWindowDidEndLiveResize(notification)
				}
				dbgLog(1, "🔄 [ClockWindow] リサイズ終了オブザーバー登録（移動モード ON）")
			}
			
			dbgLog(1, "🔄 [ClockWindow] 移動モード ON（設定ウィンドウ表示中）")
		} else {
			// 移動モード OFF
			window.styleMask.remove(.resizable)
			window.ignoresMouseEvents = true
			window.isMovableByWindowBackground = false
			window.isMovable = false
			
			// オブザーバーを削除
			if let observer = windowMoveObserver {
				NotificationCenter.default.removeObserver(observer)
				windowMoveObserver = nil
				dbgLog(1, "🔄 [ClockWindow] 移動オブザーバー削除（移動モード OFF）")
			}
			
			if let observer = windowResizeObserver {
				NotificationCenter.default.removeObserver(observer)
				windowResizeObserver = nil
				dbgLog(1, "🔄 [ClockWindow] リサイズオブザーバー削除（移動モード OFF）")
			}
			
			if let observer = windowDidEndLiveResizeObserver {
				NotificationCenter.default.removeObserver(observer)
				windowDidEndLiveResizeObserver = nil
				dbgLog(1, "🔄 [ClockWindow] リサイズ終了オブザーバー削除（移動モード OFF）")
			}
			
			dbgLog(1, "🔄 [ClockWindow] 移動モード OFF（設定ウィンドウ非表示）")
		}
	}
	
	// MARK: - ヘルパーメソッド
	
	/// ウィンドウサイズを計算
	private func calculateWindowSize(for settings: ClockSettings) -> NSSize {
		// 設定から直接サイズを取得
		return NSSize(width: settings.windowWidth, height: settings.windowHeight)
	}
	
	/// 対象のスクリーンを取得（マルチディスプレイ対応）
	private func getTargetScreen(index: Int) -> NSScreen {
		let screens = NSScreen.screens
		if index < screens.count {
			return screens[index]
		} else {
			return NSScreen.main ?? screens[0]
		}
	}
	
	// MARK: - 通知ハンドラ
	
	/// ウィンドウが移動された時（移動モード時に位置を保存）
	private func handleWindowDidMove(_ notification: Notification) {
		// 安全性チェック：clockWindow が nil でないことを確認
		guard let clockWindow = self.clockWindow,
			  let window = notification.object as? NSWindow,
			  window == clockWindow,
			  settingsManager.settings.clock.moveMode else {
			return
		}
		
		// 現在のウィンドウ位置を取得
		let frame = window.frame
		let screen = window.screen ?? NSScreen.main ?? NSScreen.screens[0]
		
		// スクリーン座標系での相対位置を計算
		let relativeX = frame.origin.x - screen.frame.origin.x
		let relativeY = frame.origin.y - screen.frame.origin.y
		
		// 無限ループ防止：設定が既に同じ値なら更新しない
		let currentX = settingsManager.settings.clock.positionX
		let currentY = settingsManager.settings.clock.positionY
		
		// 10px 以下の差は無視（微小な変動を防ぐ）
		guard abs(relativeX - currentX) > 10 || abs(relativeY - currentY) > 10 else {
			return
		}
		
		// 専用メソッドで位置を更新（フラグ付き）
		settingsManager.updatePositionFromWindow(x: relativeX, y: relativeY)
		
		dbgLog(1, "🖱️ [ClockWindow] ドラッグで位置を更新: (%d, %d)", Int(relativeX), Int(relativeY))
	}
	
	/// ウィンドウがリサイズされた時（移動モード時にサイズを保存）
	private func handleWindowDidResize(_ notification: Notification) {
		// 安全性チェック：clockWindow が nil でないことを確認
		guard let clockWindow = self.clockWindow,
			  let window = notification.object as? NSWindow,
			  window == clockWindow,
			  settingsManager.settings.clock.moveMode else {
			return
		}
		
		// 現在のウィンドウ情報を取得
		let frame = window.frame
		let windowSize = frame.size
		let windowOrigin = frame.origin
		
		// マウス位置を取得
		let mouseLocation = NSEvent.mouseLocation
		
		// 制限に達しているかチェック（500pxまたは100px）
		let isAtMaxLimit = windowSize.width >= 500 || windowSize.height >= 500
		let isAtMinLimit = windowSize.width <= 100 || windowSize.height <= 100
		
		// 制限に達している時のみログ出力
		if isAtMaxLimit || isAtMinLimit {
			// マウスが要求しているサイズを推測（実際のサイズより大きい可能性）
			// ※正確な要求サイズはwindowWillResizeでしか取得できない
			dbgLog(1, "🔒 ドラッグ中: マウス位置(%d, %d) ウィンドウ(%dx%d) 位置(%d, %d)", Int(mouseLocation.x), Int(mouseLocation.y), Int(windowSize.width), Int(windowSize.height), Int(windowOrigin.x), Int(windowOrigin.y))
		}
	}
	
	/// ウィンドウのリサイズが終了した時（ドラッグ終了後に1回だけ保存）
	private func handleWindowDidEndLiveResize(_ notification: Notification) {
		// 安全性チェック：clockWindow が nil でないことを確認
		guard let clockWindow = self.clockWindow,
			  let window = notification.object as? NSWindow,
			  window == clockWindow,
			  settingsManager.settings.clock.moveMode else {
			return
		}
		
		// リサイズ終了時にウィンドウの最終情報を取得
		let frame = window.frame
		let newWidth = frame.size.width
		let newHeight = frame.size.height
		let windowOrigin = frame.origin
		
		// 画面座標からスクリーン相対座標に変換
		let screen = window.screen ?? NSScreen.main ?? NSScreen.screens[0]
		let relativeX = windowOrigin.x - screen.frame.origin.x
		let relativeY = windowOrigin.y - screen.frame.origin.y
		
		// 1. UserDefaults に直接保存
		var updatedSettings = settingsManager.settings
		updatedSettings.clock.windowWidth = newWidth
		updatedSettings.clock.windowHeight = newHeight
		updatedSettings.clock.positionX = relativeX
		updatedSettings.clock.positionY = relativeY
		
		if let encoded = try? JSONEncoder().encode(updatedSettings) {
			UserDefaults.standard.set(encoded, forKey: "appSettings")
			dbgLog(1, "💾 リサイズ終了: ウィンドウ(%dx%d) 位置(%d, %d)", Int(newWidth), Int(newHeight), Int(relativeX), Int(relativeY))
		}
		
		// 2. @Publishedを更新（設定画面のテキストフィールド更新のため）
		// ※ isUpdatingFromWindow フラグでsave()の再呼び出しを防ぐ
		settingsManager.isUpdatingFromWindow = true
		settingsManager.settings.clock.windowWidth = newWidth
		settingsManager.settings.clock.windowHeight = newHeight
		settingsManager.settings.clock.positionX = relativeX
		settingsManager.settings.clock.positionY = relativeY
		
		DispatchQueue.main.async {
			self.settingsManager.isUpdatingFromWindow = false
		}
		
		dbgLog(1, "✅ リサイズ完了: 設定画面を更新しました")
	}
	
	// MARK: - NSWindowDelegate
	
	/// リサイズ中にサイズを制限（500x500まで）
	func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
		// マウス位置を取得
		let mouseLocation = NSEvent.mouseLocation
		
		// 最大サイズ制限を適用
		let clampedWidth = min(frameSize.width, 500)
		let clampedHeight = min(frameSize.height, 500)
		
		// 最小サイズ制限も適用
		let finalWidth = max(clampedWidth, 100)
		let finalHeight = max(clampedHeight, 100)
		
		// ウィンドウ位置
		let windowOrigin = sender.frame.origin
		
		// 制限が適用された場合のみログ
		if frameSize.width > 500 || frameSize.height > 500 || frameSize.width < 100 || frameSize.height < 100 {
			dbgLog(1, "🔒 リサイズ制限: マウス位置(%d, %d) 要求(%dx%d) → ウィンドウ(%dx%d) 位置(%d, %d)", Int(mouseLocation.x), Int(mouseLocation.y), Int(frameSize.width), Int(frameSize.height), Int(finalWidth), Int(finalHeight), Int(windowOrigin.x), Int(windowOrigin.y))
		}
		
		return NSSize(width: finalWidth, height: finalHeight)
	}
}
