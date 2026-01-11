//
//  IMEIndicatorWindowManager.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/09.
//
//  IMEインジケータウィンドウの管理
//  画面上に表示されるIMEインジケータウィンドウを制御します
//

import SwiftUI
import AppKit

// MARK: - IMEインジケータウィンドウマネージャー

/// IMEインジケータウィンドウを管理するクラス
class IMEIndicatorWindowManager: NSObject {

	// MARK: - シングルトン

	/// シングルトンインスタンス
	static let shared = IMEIndicatorWindowManager()

	// MARK: - プロパティ

	/// インジケータウィンドウ
	private var indicatorWindow: NSWindow?

	/// DraggableHostingView（強参照で保持、ドラッグ機能付き）
	private var hostingView: DraggableHostingView<IMEIndicatorView>?

	/// 現在の入力言語
	private(set) var currentLanguage: InputLanguage = .english

	/// インジケータが表示中かどうか
	private(set) var isVisible: Bool = true

	/// 設定マネージャー（統合設定を使用）
	private var settings: IMEIndicatorSettings {
		return AppSettingsManager.shared.settings.imeIndicator
	}

	/// 後方互換性のため：日本語入力モードかどうか
	var isJapanese: Bool {
		return currentLanguage == .japanese
	}

	// MARK: - 初期化

	private override init() {
		super.init()

		// 設定変更の通知を監視
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(settingsChanged),
			name: NSNotification.Name("IMEIndicatorSettingsChanged"),
			object: nil
		)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
		hostingView = nil
		indicatorWindow?.close()
		indicatorWindow = nil
	}

	// MARK: - ウィンドウ管理

	/// インジケータウィンドウを作成・表示
	func show() {
		dbgLog(1, "▶️ [IMEIndicator] show開始")

		// 既存のウィンドウがある場合は閉じる
		if indicatorWindow != nil {
			hide()
		}

		// 設定を取得
		let settings = settings
		isVisible = settings.isVisible

		// 表示設定がOFFの場合は作成しない
		guard isVisible else {
			dbgLog(1, "▶️ [IMEIndicator] 表示設定がOFFのためスキップ")
			return
		}

		// 選択されたディスプレイを取得
		let displayIndex = settings.displayIndex
		guard displayIndex < NSScreen.screens.count else {
			dbgLog(-1, "⚠️ [IMEIndicator] 無効なディスプレイインデックス: %d", displayIndex)
			return
		}
		let screen = NSScreen.screens[displayIndex]

		// ウィンドウの位置とサイズを計算
		let globalX = screen.frame.origin.x + settings.positionX
		let globalY = screen.frame.origin.y + settings.positionY
		let windowRect = NSRect(
			x: globalX,
			y: globalY,
			width: settings.indicatorSize,
			height: settings.indicatorSize
		)

		// ウィンドウを作成
		let window = NSWindow(
			contentRect: windowRect,
			styleMask: [.borderless],
			backing: .buffered,
			defer: false
		)

		// ウィンドウのプロパティを設定
		window.isOpaque = false
		window.backgroundColor = .clear
		window.level = .floating
		window.collectionBehavior = [
			.canJoinAllSpaces,
			.stationary,
			.ignoresCycle
		]
		window.isMovableByWindowBackground = settings.moveMode
		window.ignoresMouseEvents = false
		window.hasShadow = true

		// SwiftUIビューを作成（DraggableHostingViewでドラッグ機能を有効化）
		let contentView = createIndicatorView(settings: settings)
		let newHostingView = DraggableHostingView(rootView: contentView)
		self.hostingView = newHostingView
		window.contentView = newHostingView
		dbgLog(1, "🖱️ [IMEIndicator] DraggableHostingView作成（ドラッグ機能有効）")

		// ウィンドウを表示
		window.orderFrontRegardless()
		self.indicatorWindow = window

		dbgLog(1, "✅ [IMEIndicator] ウィンドウを作成しました")
	}

	/// インジケータウィンドウを非表示
	func hide() {
		guard let window = indicatorWindow else { return }

		window.orderOut(nil)
		window.contentView = nil
		self.indicatorWindow = nil
		self.hostingView = nil

		dbgLog(1, "✅ [IMEIndicator] ウィンドウを非表示にしました")
	}

	/// ウィンドウを再作成（設定変更時）
	func recreate() {
		dbgLog(1, "🔄 [IMEIndicator] recreate開始")

		let settings = settings
		isVisible = settings.isVisible

		// 表示設定に応じて処理
		if isVisible {
			// 一度閉じて再作成
			hide()
			show()
		} else {
			hide()
		}

		dbgLog(1, "🔄 [IMEIndicator] recreate完了")
	}

	/// ビューの内容を更新
	func updateView() {
		guard let hostingView = self.hostingView else { return }

		// レイアウト再帰を防ぐため非同期で更新
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			let settings = self.settings
			let newView = self.createIndicatorView(settings: settings)
			hostingView.rootView = newView
			dbgLog(1, "🔄 [IMEIndicator] ビューを更新しました")
		}
	}

	/// アニメーション付きで表示を更新
	func updateWithAnimation() {
		guard let window = indicatorWindow else { return }

		// 点滅アニメーション
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = 0.1
			window.animator().alphaValue = 0.3
		}, completionHandler: {
			NSAnimationContext.runAnimationGroup({ context in
				context.duration = 0.1
				window.animator().alphaValue = 1.0
			}, completionHandler: {
				self.updateView()
			})
		})
	}

	/// 入力言語を更新
	func updateLanguage(_ newLanguage: InputLanguage) {
		guard newLanguage != currentLanguage else { return }

		currentLanguage = newLanguage
		updateWithAnimation()
	}

	/// IME状態を更新（後方互換性のため）
	func updateIMEState(_ newIsJapanese: Bool) {
		let newLanguage: InputLanguage = newIsJapanese ? .japanese : .english
		updateLanguage(newLanguage)
	}

	/// 表示/非表示を切り替え
	func toggleVisibility() {
		isVisible.toggle()

		// 設定を更新
		AppSettingsManager.shared.settings.imeIndicator.isVisible = isVisible
		AppSettingsManager.shared.save()

		if isVisible {
			if indicatorWindow == nil {
				show()
			} else {
				indicatorWindow?.orderFrontRegardless()
			}
		} else {
			indicatorWindow?.orderOut(nil)
		}

		dbgLog(1, "🔍 [IMEIndicator] isVisible = %@", isVisible ? "true" : "false")
	}

	// MARK: - ヘルパー

	/// IMEIndicatorViewを作成
	private func createIndicatorView(settings: IMEIndicatorSettings) -> IMEIndicatorView {
		return IMEIndicatorView(
			language: currentLanguage,
			size: settings.indicatorSize,
			opacity: settings.backgroundOpacity,
			color: settings.color(for: currentLanguage),
			text: settings.text(for: currentLanguage),
			moveMode: settings.moveMode,
			fontSizeRatio: settings.fontSizeRatio,
			fontName: settings.fontName
		)
	}

	// MARK: - 通知ハンドラ

	/// 設定変更通知を受け取った時の処理
	@objc private func settingsChanged() {
		dbgLog(1, "🔔 [IMEIndicator] 設定変更通知を受信")

		let settings = settings

		// 位置やサイズが変わった場合はウィンドウを再作成
		if let window = indicatorWindow {
			let currentFrame = window.frame
			let screen = NSScreen.screens[safe: settings.displayIndex] ?? NSScreen.main ?? NSScreen.screens[0]
			let expectedX = screen.frame.origin.x + settings.positionX
			let expectedY = screen.frame.origin.y + settings.positionY

			let needsRecreate = (currentFrame.width != settings.indicatorSize ||
								 currentFrame.origin.x != expectedX ||
								 currentFrame.origin.y != expectedY)

			if needsRecreate {
				recreate()
			} else {
				// 表示状態の更新
				isVisible = settings.isVisible
				if isVisible {
					indicatorWindow?.orderFrontRegardless()
				} else {
					indicatorWindow?.orderOut(nil)
				}
				updateView()
			}
		} else if settings.isVisible {
			// ウィンドウがない場合は新規作成
			show()
		}

		// 移動モードの更新
		indicatorWindow?.isMovableByWindowBackground = settings.moveMode

		dbgLog(1, "✅ [IMEIndicator] 設定の適用完了")
	}
}

// MARK: - Array Extension

private extension Array {
	subscript(safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
