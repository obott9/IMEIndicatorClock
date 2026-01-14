//
//  Extensions.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/14.
//
//  共通のExtension定義
//

import Foundation

// MARK: - Array Extension

extension Array {
	/// 安全なインデックスアクセス（範囲外の場合はnilを返す）
	subscript(safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
