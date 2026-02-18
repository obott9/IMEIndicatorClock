//
//  MouseCursorIndicatorWindow.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/10.
//
//  マウスカーソルに追従するインジケータウィンドウの管理
//

import SwiftUI
import AppKit

// MARK: - マウスカーソルインジケータウィンドウマネージャー

/// マウスカーソルに追従するインジケータウィンドウを管理するクラス
class MouseCursorIndicatorWindowManager {

    /// シングルトンインスタンス
    static let shared = MouseCursorIndicatorWindowManager()

    /// インジケータウィンドウ
    private var indicatorWindow: NSWindow?

    /// マウス移動監視（グローバル）
    private var globalMouseMonitor: Any?

    /// マウス移動監視（ローカル：自アプリ内）
    private var localMouseMonitor: Any?

    /// タイマーベースの位置更新（バックアップ）
    private var positionUpdateTimer: Timer?

    /// 設定変更監視
    private var settingsObserver: NSObjectProtocol?

    /// 現在の入力言語
    private var currentLanguage: InputLanguage = .english

    // MARK: - 初期化

    private init() {
        dbgLog(-1, "🖱️ [MouseCursorIndicator] WindowManager初期化開始")
        // 設定変更の監視
        settingsObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("MouseCursorIndicatorSettingsChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            dbgLog(-1, "🔔 [MouseCursorIndicator] 設定変更通知を受信")
            self?.handleSettingsChanged()
        }
        dbgLog(-1, "🖱️ [MouseCursorIndicator] 設定変更オブザーバー登録完了")
    }

    deinit {
        if let observer = settingsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        stopMonitoring()
    }

    // MARK: - 表示制御

    /// インジケータを表示
    func show() {
        guard indicatorWindow == nil else {
            dbgLog(1, "ℹ️ [MouseCursorIndicator] 既に表示されています")
            return
        }

        // 現在のIME状態を取得してから表示
        currentLanguage = IMEMonitor.shared.currentLanguage
        dbgLog(-1, "🖱️ [MouseCursorIndicator] createWindow呼び出し前")
        createWindow()
        dbgLog(-1, "🖱️ [MouseCursorIndicator] createWindow完了、startMonitoring呼び出し")
        startMonitoring()

        // 現在のIME状態をViewに通知（正しい色を表示するため）
        NotificationCenter.default.post(
            name: NSNotification.Name("MouseCursorIndicatorLanguageChanged"),
            object: currentLanguage
        )

        dbgLog(-1, "✅ [MouseCursorIndicator] 表示を開始しました（言語: %@）", String(describing: currentLanguage))
    }

    /// インジケータを非表示
    func hide() {
        stopMonitoring()
        indicatorWindow?.orderOut(nil)
        indicatorWindow = nil
        dbgLog(1, "✅ [MouseCursorIndicator] 非表示にしました")
    }

    /// 表示/非表示を切り替え
    func toggle() {
        if indicatorWindow != nil {
            hide()
        } else {
            show()
        }
    }

    /// 表示中かどうか
    var isVisible: Bool {
        return indicatorWindow != nil
    }

    // MARK: - ウィンドウ作成

    /// インジケータウィンドウを作成
    private func createWindow() {
        let settings = AppSettingsManager.shared.settings.mouseCursorIndicator
        let size = settings.size

        // SwiftUI Viewを作成
        let view = MouseCursorIndicatorView()
        let hostingView = NSHostingView(rootView: view)

        // ウィンドウを作成（サイズはインジケータと同じ）
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: size, height: size),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.level = .screenSaver  // 最前面（スクリーンセーバーレベル）
        window.ignoresMouseEvents = true  // マウスイベントを無視（クリック妨害防止）
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]  // 全画面で表示
        window.contentView = hostingView

        // 初期位置をマウス位置に設定
        updateWindowPosition(window: window)

        window.orderFront(nil)
        self.indicatorWindow = window
    }

    // MARK: - マウス監視

    /// マウス移動の監視を開始
    private func startMonitoring() {
        dbgLog(-1, "🖱️ [MouseCursorIndicator] startMonitoring開始 globalMouseMonitor=%@",
               globalMouseMonitor == nil ? "nil" : "exists")
        guard globalMouseMonitor == nil else {
            dbgLog(-1, "⚠️ [MouseCursorIndicator] 既に監視中のためスキップ")
            return
        }

        // グローバル監視（他のアプリでのマウス移動）
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]
        ) { [weak self] _ in
            self?.handleMouseMoved()
        }

        // ローカル監視（自アプリ内でのマウス移動）
        localMouseMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]
        ) { [weak self] event in
            self?.handleMouseMoved()
            return event
        }

        // タイマーベースのバックアップ（スクロール等でイベントが来ない場合用）
        // メインスレッドのRunLoopに明示的に追加
        let timer = Timer(timeInterval: 0.3, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.handleMouseMoved()
        }
        RunLoop.main.add(timer, forMode: .common)
        positionUpdateTimer = timer

        // 即座に一度呼び出してテスト
        DispatchQueue.main.async { [weak self] in
            self?.handleMouseMoved()
        }

        dbgLog(-1, "🖱️ [MouseCursorIndicator] マウス監視を開始しました globalMonitor=%@, localMonitor=%@, timer=%@",
               globalMouseMonitor != nil ? "OK" : "nil",
               localMouseMonitor != nil ? "OK" : "nil",
               positionUpdateTimer != nil ? "OK" : "nil")
    }

    /// マウス移動の監視を停止
    private func stopMonitoring() {
        if let monitor = globalMouseMonitor {
            NSEvent.removeMonitor(monitor)
            globalMouseMonitor = nil
        }

        if let monitor = localMouseMonitor {
            NSEvent.removeMonitor(monitor)
            localMouseMonitor = nil
        }

        positionUpdateTimer?.invalidate()
        positionUpdateTimer = nil

        dbgLog(1, "🖱️ [MouseCursorIndicator] マウス監視を停止しました")
    }

    /// 初回ログ用フラグ
    private static var firstMouseMoveLogged = false

    /// マウス移動時の処理
    private func handleMouseMoved() {
        guard let window = indicatorWindow else {
            if !Self.firstMouseMoveLogged {
                dbgLog(-1, "⚠️ [MouseCursorIndicator] handleMouseMoved: indicatorWindow=nil")
                Self.firstMouseMoveLogged = true
            }
            return
        }
        if !Self.firstMouseMoveLogged {
            dbgLog(-1, "✅ [MouseCursorIndicator] handleMouseMoved: 初回呼び出しOK")
            Self.firstMouseMoveLogged = true
        }
        updateWindowPosition(window: window)
    }

    /// 前回のカーソル名（ログ出力用）
    private static var lastCursorLog: String = ""

    /// カーソルの種類を判定
    private func cursorTypeName(_ cursor: NSCursor) -> String {
        if cursor == NSCursor.arrow { return "arrow" }
        if cursor == NSCursor.iBeam { return "iBeam" }
        if cursor == NSCursor.pointingHand { return "pointingHand" }
        if cursor == NSCursor.crosshair { return "crosshair" }
        if cursor == NSCursor.openHand { return "openHand" }
        if cursor == NSCursor.closedHand { return "closedHand" }
        if cursor == NSCursor.resizeLeft { return "resizeLeft" }
        if cursor == NSCursor.resizeRight { return "resizeRight" }
        if cursor == NSCursor.resizeUp { return "resizeUp" }
        if cursor == NSCursor.resizeDown { return "resizeDown" }
        if cursor == NSCursor.resizeLeftRight { return "resizeLeftRight" }
        if cursor == NSCursor.resizeUpDown { return "resizeUpDown" }
        if cursor == NSCursor.disappearingItem { return "disappearingItem" }
        if cursor == NSCursor.iBeamCursorForVerticalLayout { return "iBeamVertical" }
        if cursor == NSCursor.operationNotAllowed { return "notAllowed" }
        if cursor == NSCursor.dragLink { return "dragLink" }
        if cursor == NSCursor.dragCopy { return "dragCopy" }
        if cursor == NSCursor.contextualMenu { return "contextualMenu" }
        return "unknown"
    }

    /// ウィンドウ位置を更新
    private func updateWindowPosition(window: NSWindow) {
        let settings = AppSettingsManager.shared.settings.mouseCursorIndicator
        let mouseLocation = NSEvent.mouseLocation

        // カーソルの右下に配置
        let x = mouseLocation.x + settings.offsetX
        let y = mouseLocation.y - settings.size - settings.offsetY

        window.setFrameOrigin(NSPoint(x: x, y: y))
    }

    // MARK: - 言語更新

    /// 入力言語を更新（IME状態変更時に呼ばれる）
    func updateLanguage(_ language: InputLanguage) {
        let changed = currentLanguage != language
        currentLanguage = language

        // ウィンドウが表示中の場合のみViewに通知
        if indicatorWindow != nil && changed {
            dbgLog(1, "🔤 [MouseCursorIndicator] 言語変更: %@", String(describing: language))
            NotificationCenter.default.post(
                name: NSNotification.Name("MouseCursorIndicatorLanguageChanged"),
                object: language
            )
        }
    }

    // MARK: - 設定変更ハンドラー

    /// 設定変更時の処理
    private func handleSettingsChanged() {
        let settings = AppSettingsManager.shared.settings.mouseCursorIndicator
        dbgLog(-1, "🔔 [MouseCursorIndicator] handleSettingsChanged: isVisible=%@, indicatorWindow=%@, offsetX=%.0f, offsetY=%.0f, size=%.0f",
               settings.isVisible ? "true" : "false",
               indicatorWindow != nil ? "exists" : "nil",
               settings.offsetX,
               settings.offsetY,
               settings.size)

        // 表示設定が変更された場合
        if settings.isVisible && indicatorWindow == nil {
            dbgLog(-1, "🔔 [MouseCursorIndicator] show()を呼び出します")
            show()
        } else if !settings.isVisible && indicatorWindow != nil {
            dbgLog(-1, "🔔 [MouseCursorIndicator] hide()を呼び出します")
            hide()
        }

        // ウィンドウサイズを更新
        if let window = indicatorWindow {
            let size = settings.size
            window.setContentSize(NSSize(width: size, height: size))
        }
    }
}
