//
//  Constants.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/14.
//
//  アプリ全体で使用する定数定義
//

import Foundation

// MARK: - アプリ定数

enum AppConstants {

	// MARK: - ウィンドウサイズ

	/// 時計ウィンドウの最小サイズ（幅・高さ共通）
	static let clockWindowMinSize: CGFloat = 100

	/// 時計ウィンドウの最大サイズ（幅・高さ共通）
	static let clockWindowMaxSize: CGFloat = 500

	// MARK: - IMEインジケータ

	/// IMEインジケータの最小サイズ
	static let imeIndicatorMinSize: CGFloat = 30

	/// IMEインジケータの最大サイズ
	static let imeIndicatorMaxSize: CGFloat = 200

	// MARK: - タイマー間隔

	/// IME状態のポーリング間隔（秒）
	static let imePollingInterval: TimeInterval = 0.3

	/// 時計の更新間隔（秒）
	static let clockUpdateInterval: TimeInterval = 1.0

	// MARK: - ウィンドウ位置

	/// ウィンドウ移動時の最小変化量（これ以下の変化は無視）
	static let windowPositionThreshold: CGFloat = 10
}
