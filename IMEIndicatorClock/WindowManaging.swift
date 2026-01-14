//
//  WindowManaging.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/14.
//
//  ウィンドウマネージャーの共通プロトコル定義
//

import AppKit

// MARK: - ウィンドウ管理プロトコル

/// ウィンドウマネージャーの共通インターフェース
///
/// このプロトコルは以下のクラスで実装されます:
/// - ClockWindowManager
/// - IMEIndicatorWindowManager
/// - MouseCursorIndicatorWindowManager
protocol WindowManaging: AnyObject {

	/// ウィンドウを作成・表示する
	func show()

	/// ウィンドウを非表示にする
	func hide()

	/// ウィンドウを再作成する（設定変更時など）
	func recreate()

	/// ビューの内容を更新する（ウィンドウの再作成なし）
	func updateView()
}

// MARK: - デフォルト実装

extension WindowManaging {

	/// ウィンドウの表示/非表示を切り替える
	func toggle(isVisible: Bool) {
		if isVisible {
			show()
		} else {
			hide()
		}
	}
}
