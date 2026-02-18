//
//  dbgLog.swift
//  IMEIndicatorClock
//
//  デバッグログ出力ユーティリティ
//  レベル制御とファイル出力機能を提供
//
//  Created by obott9 on 2025/12/22.
//

import Foundation

// MARK: - 設定

/// パス表示スタイル
enum PathStyle {
	case fileOnly      // ファイル名のみ
	case parent1       // 親ディレクトリ付き
	case parent2       // 親親ディレクトリ付き
	case fullPath      // フルパス
}

/// デバッグレベル設定
/// - 0: 何も表示しない
/// - 1〜99: 指定レベル以上を表示（コンソールのみ）
/// - -1〜-99: 指定レベル（絶対値）以上をファイルに出力 + コンソールにも出力
///
/// リリースビルドでは自動的に0（無効）になります
#if DEBUG
private let DEBUG_LEVEL: Int = 1
#else
private let DEBUG_LEVEL: Int = 0
#endif

/// パス表示スタイル設定
private let PATH_STYLE: PathStyle = .parent2

/// ログファイルURLのキャッシュ
/// nilなら初回（ディレクトリ未作成）、値があれば作成済み
private var cachedLogFileURL: URL?
/// cachedLogFileURL へのアクセスを保護するロック
private let cachedLogFileURLLock = NSLock()

/// タイムスタンプ用のDateFormatterキャッシュ（パフォーマンス最適化）
private let timestampFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
	return formatter
}()


// MARK: - ログファイルパス取得

/// ログファイル保存先を環境から取得（キャッシュあり）
private func getLogFilePath() -> URL {
	cachedLogFileURLLock.lock()
	defer { cachedLogFileURLLock.unlock() }

	// キャッシュがあればそれを返す
	if let cached = cachedLogFileURL {
		return cached
	}
	// キャッシュがない場合は生成
	let fileManager = FileManager.default
	let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!

	// Bundle IDに基づいてディレクトリ名を決定（デバッグとリリースで分離）
	let bundleId = Bundle.main.bundleIdentifier ?? "IMEIndicatorClock"
	let directoryName: String
	if bundleId.hasSuffix(".debug") {
		directoryName = "IMEIndicatorClock-Debug"
	} else {
		directoryName = "IMEIndicatorClock"
	}
	let appDirectory = appSupport.appendingPathComponent(directoryName)
	let logFile = appDirectory.appendingPathComponent("debug.log")
	// キャッシュに保存
	cachedLogFileURL = logFile
	// ログファイルのフルパスを出力（サンドボックス環境でも確認できるように）
	print("[dbgLog] ログファイルパス: \(logFile.path)")
	return logFile
}

/// ログディレクトリを確保する（初回のみ + 念のため存在チェック）
private func ensureLogDirectory() {
	// cachedLogFileURLがあれば既にディレクトリ確保済み
	cachedLogFileURLLock.lock()
	let alreadyCached = cachedLogFileURL != nil
	cachedLogFileURLLock.unlock()
	if alreadyCached {
		return
	}

	let fileURL = getLogFilePath()  // これでcachedLogFileURLも設定される
	let directory = fileURL.deletingLastPathComponent()

	// 念のため存在チェック
	if !FileManager.default.fileExists(atPath: directory.path) {
		print("[dbgLog] ログディレクトリを作成: \(directory.path)")
		do {
			try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
			print("[dbgLog] ディレクトリ作成成功")
			// cachedLogFileURLは既にgetLogFilePath()で設定済み
		} catch {
			print("[dbgLog] エラー: ディレクトリ作成失敗 - \(error)")
			cachedLogFileURLLock.lock()
			cachedLogFileURL = nil  // 失敗したらキャッシュをクリア（次回再試行）
			cachedLogFileURLLock.unlock()
		}
	} else {
		print("[dbgLog] ログディレクトリ既に存在: \(directory.path)")
		// cachedLogFileURLは既にgetLogFilePath()で設定済み
	}
}

// MARK: - ログ出力関数

/// デバッグログを出力する
/// - Parameters:
///   - level: ログレベル（1〜99）
///   - format: フォーマット文字列（Swift標準書式）
///   - args: 可変長引数
///   - file: 呼び出し元ファイル（自動取得）
///   - line: 呼び出し元行番号（自動取得）
///   - column: 呼び出し元桁数（自動取得）
///   - function: 呼び出し元関数名（自動取得）
func dbgLog(
	_ level: Int,
	_ format: String,
	_ args: CVarArg...,
	file: String = #file,
	line: Int = #line,
	column: Int = #column,
	function: String = #function
) {
	// レベル0の場合は何もしない
	guard DEBUG_LEVEL != 0 else { return }
	
	// レベルチェック（絶対値で比較）
	let threshold = abs(DEBUG_LEVEL)
	guard abs(level) <= threshold else { return }
	
	// ファイル出力が必要か判定
	// levelが負ならファイル出力
	let shouldWriteToFile = level < 0
	
	// ファイルパスを整形
	let filePath = formatFilePath(file)
	
	// メッセージを整形
	let message = String(format: format, arguments: args)
	
	// ログメッセージを構築
	let logMessage = "[\(filePath):\(line):\(column) (\(function))] \(message)"
	
	// コンソールに出力
	print(logMessage)
	
	// ファイルに出力（必要な場合）
	if shouldWriteToFile {
		writeToFile(logMessage)
	}
}

// MARK: - プライベート関数

/// ファイルパスを指定されたスタイルで整形
private func formatFilePath(_ fullPath: String) -> String {
	let url = URL(fileURLWithPath: fullPath)
	
	switch PATH_STYLE {
	case .fileOnly:
		// ファイル名のみ
		return url.lastPathComponent
		
	case .parent1:
		// 親ディレクトリ + ファイル名
		let parent = url.deletingLastPathComponent().lastPathComponent
		return "\(parent)/\(url.lastPathComponent)"
		
	case .parent2:
		// 親親ディレクトリ + 親ディレクトリ + ファイル名
		let dirName = url.deletingLastPathComponent()
		let parent2 = dirName.deletingLastPathComponent().lastPathComponent
		let parent1 = dirName.lastPathComponent
		return "\(parent2)/\(parent1)/\(url.lastPathComponent)"
		
	case .fullPath:
		// フルパス
		return fullPath
	}
}

/// ログをファイルに書き込む
private func writeToFile(_ message: String) {
	// ディレクトリを確保（初回のみ + 存在チェック）
	ensureLogDirectory()
	
	// ログファイルのURLを取得
	let fileURL = getLogFilePath()
//	let fileURL = cachedLogFileURL
	// タイムスタンプ付きメッセージ
#if true
	let timestamp = timestampFormatter.string(from: Date())
#elseif false
	let formatter = DateFormatter()
	formatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS" // .SSS がミリ秒
	let timestamp = formatter.string(from: Date())
#else
		let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
#endif
	let logLine = "[\(timestamp)] \(message)\n"


	// ファイルに追記
	guard let data = logLine.data(using: .utf8) else {
		print("[dbgLog] エラー: データ変換失敗")
		return
	}
	
	do {
		if FileManager.default.fileExists(atPath: fileURL.path) {
			// ファイルが存在する場合は追記
			let fileHandle = try FileHandle(forWritingTo: fileURL)
			fileHandle.seekToEndOfFile()
			fileHandle.write(data)
			fileHandle.closeFile()
			print("[dbgLog] ログ追記成功: \(fileURL.path)")
		} else {
			// ファイルが存在しない場合は新規作成
			try data.write(to: fileURL)
			print("[dbgLog] ログファイル新規作成: \(fileURL.path)")
		}
	} catch {
		print("[dbgLog] エラー: ファイル書き込み失敗 - \(error)")
	}
}
