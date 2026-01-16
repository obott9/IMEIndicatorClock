//
//  UnifiedSettingsView.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/14.
//
//  統合設定ビュー
//  全ての設定画面をタブで切り替え可能にする
//

import SwiftUI

// MARK: - 設定タブの種類

/// 設定画面のタブを表す列挙型
enum SettingsTab: Int, CaseIterable {
	case imeIndicator = 0
	case clock = 1
	case mouseCursor = 2
	case about = 3

	/// タブのタイトル（ローカライズキー）
	var titleKey: String {
		switch self {
		case .imeIndicator: return "tab.ime_indicator"
		case .clock: return "tab.clock"
		case .mouseCursor: return "tab.mouse_cursor"
		case .about: return "tab.about"
		}
	}

	/// タブのタイトル（ローカライズ済み）
	var title: String {
		return String(localized: String.LocalizationValue(titleKey), table: "Settings")
	}

	/// タブのアイコン
	var icon: String {
		switch self {
		case .imeIndicator: return "character.textbox"
		case .clock: return "clock"
		case .mouseCursor: return "cursorarrow"
		case .about: return "info.circle"
		}
	}
}

// MARK: - 統合設定ビュー

/// 全ての設定画面を統合したタブビュー
struct UnifiedSettingsView: View {

	/// 現在選択されているタブ
	@State private var selectedTab: SettingsTab = .imeIndicator

	/// 外部から初期タブを指定するためのイニシャライザ
	init(initialTab: SettingsTab = .imeIndicator) {
		_selectedTab = State(initialValue: initialTab)
	}

	var body: some View {
		TabView(selection: $selectedTab) {
			// IMEインジケータ設定
			IMEIndicatorSettingsView()
				.tabItem {
					Image(systemName: SettingsTab.imeIndicator.icon)
					Text(SettingsTab.imeIndicator.title)
				}
				.tag(SettingsTab.imeIndicator)

			// 時計設定
			ClockSettingsView()
				.tabItem {
					Image(systemName: SettingsTab.clock.icon)
					Text(SettingsTab.clock.title)
				}
				.tag(SettingsTab.clock)

			// マウスカーソルインジケータ設定
			MouseCursorIndicatorSettingsView()
				.tabItem {
					Image(systemName: SettingsTab.mouseCursor.icon)
					Text(SettingsTab.mouseCursor.title)
				}
				.tag(SettingsTab.mouseCursor)

			// アプリについて
			AboutView()
				.tabItem {
					Image(systemName: SettingsTab.about.icon)
					Text(SettingsTab.about.title)
				}
				.tag(SettingsTab.about)
		}
		.frame(minWidth: 800, minHeight: 600)
	}
}

// MARK: - プレビュー

#Preview("統合設定 - IME") {
	UnifiedSettingsView(initialTab: .imeIndicator)
		.frame(width: 900, height: 700)
}

#Preview("統合設定 - 時計") {
	UnifiedSettingsView(initialTab: .clock)
		.frame(width: 900, height: 700)
}

#Preview("統合設定 - カーソル") {
	UnifiedSettingsView(initialTab: .mouseCursor)
		.frame(width: 900, height: 700)
}

#Preview("統合設定 - About") {
	UnifiedSettingsView(initialTab: .about)
		.frame(width: 900, height: 700)
}
