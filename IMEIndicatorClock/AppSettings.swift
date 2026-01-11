//
//  AppSettings.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/07.
//
//  アプリ全体の設定を統合管理するデータモデル
//
//  【設定ファイルの保存先】
//  ~/Library/Application Support/IMEIndicatorClock/app_settings.json
//
//  【初期化の流れ】
//  1. Application Supportディレクトリを取得
//  2. IMEIndicatorClockフォルダを作成（なければ）
//  3. app_settings.jsonが存在しない場合、旧ファイルから移行
//     - ime_settings.json（旧IME設定）
//     - settings.json（旧時計設定）
//  4. 設定を読み込み（失敗時はデフォルト値）
//

import Foundation
import SwiftUI
import Combine

// MARK: - アプリ設定データモデル

/// アプリ全体の設定を統合管理する構造体
struct AppSettings: Codable {
	/// IMEインジケータの設定
	var imeIndicator: IMEIndicatorSettings

	/// 時計の設定
	var clock: ClockSettings

	/// マウスカーソルインジケータの設定
	var mouseCursorIndicator: MouseCursorIndicatorSettings

	/// デフォルト値で初期化
	init() {
		self.imeIndicator = IMEIndicatorSettings()
		self.clock = ClockSettings()
		self.mouseCursorIndicator = MouseCursorIndicatorSettings()
	}

	/// 既存の設定で初期化
	init(imeIndicator: IMEIndicatorSettings, clock: ClockSettings, mouseCursorIndicator: MouseCursorIndicatorSettings = MouseCursorIndicatorSettings()) {
		self.imeIndicator = imeIndicator
		self.clock = clock
		self.mouseCursorIndicator = mouseCursorIndicator
	}
}

// MARK: - 統合設定マネージャー

/// アプリ全体の設定を管理するシングルトンクラス
class AppSettingsManager: ObservableObject {
	
	// MARK: - シングルトン
	
	/// 共有インスタンス
	static let shared = AppSettingsManager()
	
	// MARK: - プロパティ
	
	/// 設定データ
	@Published var settings: AppSettings
	
	/// 設定ファイルのURL
	private let settingsFileURL: URL
	
	/// IME状態（日本語入力かどうか）
	@Published var isJapaneseInput: Bool = false
	
	/// ウィンドウドラッグ中のフラグ
	@Published var isWindowDragging: Bool = false
	
	/// ウィンドウからの位置更新中フラグ（無限ループ防止）
	///
	/// 【無限ループ防止の仕組み】
	/// 1. ユーザーがウィンドウをドラッグ → 位置が変わる
	/// 2. updatePositionFromWindow()が呼ばれる → isUpdatingFromWindow = true
	/// 3. @Publishedの変更通知が発火 → ビューが更新しようとする
	/// 4. isUpdatingFromWindowがtrueなので、再度の位置更新をスキップ
	/// 5. 処理完了後 → isUpdatingFromWindow = false
	var isUpdatingFromWindow = false
	
	// MARK: - 初期化
	
	private init() {
		// アプリケーションサポートディレクトリのパスを取得
		guard let appSupportURL = FileManager.default.urls(
			for: .applicationSupportDirectory,
			in: .userDomainMask
		).first else {
			fatalError("Application Support directory not found")
		}
		let appDirectory = appSupportURL.appendingPathComponent("IMEIndicatorClock")
		
		// ディレクトリが存在しない場合は作成
		try? FileManager.default.createDirectory(
			at: appDirectory,
			withIntermediateDirectories: true,
			attributes: nil
		)
		
		// 設定ファイルのパス
		self.settingsFileURL = appDirectory.appendingPathComponent("app_settings.json")
		
		// 旧ファイルから移行（初回のみ）
		if !FileManager.default.fileExists(atPath: settingsFileURL.path) {
			dbgLog(1, "📦 [AppSettings] 旧設定ファイルから移行します...")
			Self.migrateOldSettings(to: settingsFileURL, appDirectory: appDirectory)
		}

		// 設定を読み込み（失敗時はデフォルト値）
		self.settings = Self.loadSettings(from: settingsFileURL) ?? AppSettings()

		dbgLog(1, "📁 [AppSettings] 設定ファイルパス: %@", settingsFileURL.path)
		dbgLog(1, "✅ [AppSettings] 設定読み込み完了")
	}
	
	// MARK: - 設定の読み込み
	
	/// JSONファイルから設定を読み込む
	private static func loadSettings(from url: URL) -> AppSettings? {
		guard let data = try? Data(contentsOf: url) else {
			dbgLog(1, "⚠️ [AppSettings] 設定ファイルが見つかりません")
			return nil
		}

		do {
			let decoder = JSONDecoder()
			let settings = try decoder.decode(AppSettings.self, from: data)
			dbgLog(1, "✅ [AppSettings] 設定ファイルを読み込みました")
			return settings
		} catch {
			dbgLog(-1, "❌ [AppSettings] 設定ファイルの読み込みエラー: %@", error.localizedDescription)
			return nil
		}
	}
	
	// MARK: - 設定の保存
	
	/// 設定をJSONファイルに保存
	func save() {
		do {
			let encoder = JSONEncoder()
			encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
			let data = try encoder.encode(settings)
			try data.write(to: settingsFileURL)
			dbgLog(1, "💾 [AppSettings] 設定を保存しました")
		} catch {
			dbgLog(-1, "❌ [AppSettings] 設定の保存エラー: %@", error.localizedDescription)
		}
	}
	
	// MARK: - IME状態の更新
	
	/// IME状態を更新（時計の背景色切り替え用）
	func updateIMEState(isJapanese: Bool) {
		DispatchQueue.main.async {
			self.isJapaneseInput = isJapanese
		}
	}
	
	// MARK: - ウィンドウからの更新
	
	/// ウィンドウの位置が変更された時に設定を更新
	func updatePositionFromWindow(x: CGFloat, y: CGFloat) {
		guard !isUpdatingFromWindow else { return }
		isUpdatingFromWindow = true
		
		settings.clock.positionX = x
		settings.clock.positionY = y
		
		// UserDefaults に直接保存（save()を呼ばない）
		do {
			let encoder = JSONEncoder()
			encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
			let data = try encoder.encode(settings)
			try data.write(to: settingsFileURL)
			dbgLog(1, "💾 [AppSettings] 位置を保存しました: (%d, %d)", Int(x), Int(y))
		} catch {
			dbgLog(-1, "❌ [AppSettings] 保存エラー: %@", error.localizedDescription)
		}

		DispatchQueue.main.async {
			self.isUpdatingFromWindow = false
		}
	}

	/// ウィンドウのサイズが変更された時に設定を更新
	func updateWindowSize(width: CGFloat, height: CGFloat) {
		guard !isUpdatingFromWindow else { return }
		isUpdatingFromWindow = true

		settings.clock.windowWidth = width
		settings.clock.windowHeight = height

		// UserDefaults に直接保存（save()を呼ばない）
		do {
			let encoder = JSONEncoder()
			encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
			let data = try encoder.encode(settings)
			try data.write(to: settingsFileURL)
			dbgLog(1, "💾 [AppSettings] サイズを保存しました: (%dx%d)", Int(width), Int(height))
		} catch {
			dbgLog(-1, "❌ [AppSettings] 保存エラー: %@", error.localizedDescription)
		}
		
		DispatchQueue.main.async {
			self.isUpdatingFromWindow = false
		}
	}
	
	// MARK: - 旧設定ファイルからの移行
	
	/// 旧設定ファイルから新しい統合ファイルに移行
	private static func migrateOldSettings(to newURL: URL, appDirectory: URL) {
		// 旧ファイルのパス
		let oldIMEURL = appDirectory.appendingPathComponent("ime_settings.json")
		let oldClockURL = appDirectory.appendingPathComponent("settings.json")
		
		var imeSettings: IMEIndicatorSettings? = nil
		var clockSettings: ClockSettings? = nil
		
		// 旧IME設定を読み込み
		if let data = try? Data(contentsOf: oldIMEURL) {
			imeSettings = try? JSONDecoder().decode(IMEIndicatorSettings.self, from: data)
			dbgLog(1, "📦 [AppSettings] 旧IME設定を読み込みました")
		}

		// 旧時計設定を読み込み
		if let data = try? Data(contentsOf: oldClockURL) {
			clockSettings = try? JSONDecoder().decode(ClockSettings.self, from: data)
			dbgLog(1, "📦 [AppSettings] 旧時計設定を読み込みました")
		}
		
		// 統合設定を作成（読み込めなかった場合はデフォルト値）
		let appSettings = AppSettings(
			imeIndicator: imeSettings ?? IMEIndicatorSettings(),
			clock: clockSettings ?? ClockSettings()
		)
		
		// 新しいファイルに保存
		do {
			let encoder = JSONEncoder()
			encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
			let data = try encoder.encode(appSettings)
			try data.write(to: newURL)
			dbgLog(1, "✅ [AppSettings] 設定を統合ファイルに移行しました")

			// 旧ファイルを削除
			try? FileManager.default.removeItem(at: oldIMEURL)
			try? FileManager.default.removeItem(at: oldClockURL)
			dbgLog(1, "🗑️ [AppSettings] 旧設定ファイルを削除しました")
		} catch {
			dbgLog(-1, "❌ [AppSettings] 移行エラー: %@", error.localizedDescription)
		}
	}

	// MARK: - リセット

	/// 設定をデフォルト値にリセット
	func reset() {
		settings = AppSettings()
		save()
		dbgLog(1, "🔄 [AppSettings] 設定をリセットしました")
	}
	
	// MARK: - プレビュー用ヘルパー
	
	/// プレビュー用の一時的なマネージャーを作成（テスト・プレビュー専用）
	static func forPreview() -> AppSettingsManager {
		let manager = AppSettingsManager.shared
		// プレビュー用の設定を返す（実際のファイルは変更しない）
		return manager
	}
}
