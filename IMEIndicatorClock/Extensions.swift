//
//  Extensions.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/14.
//
//  共通のExtension定義
//

import Foundation

// MARK: - NSNotification.Name Extension

extension NSNotification.Name {
	/// IMEインジケータ設定変更通知
	static let imeIndicatorSettingsChanged = NSNotification.Name("IMEIndicatorSettingsChanged")
	/// マウスカーソルインジケータ設定変更通知
	static let mouseCursorIndicatorSettingsChanged = NSNotification.Name("MouseCursorIndicatorSettingsChanged")
	/// マウスカーソルインジケータ言語変更通知
	static let mouseCursorIndicatorLanguageChanged = NSNotification.Name("MouseCursorIndicatorLanguageChanged")
	/// Apple入力ソース変更通知
	static let appleSelectedInputSourcesChanged = NSNotification.Name("AppleSelectedInputSourcesChangedNotification")
}

// MARK: - Array Extension

extension Array {
	/// 安全なインデックスアクセス（範囲外の場合はnilを返す）
	subscript(safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
