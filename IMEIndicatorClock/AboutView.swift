//
//  AboutView.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/08.
//
//  アプリについての情報画面
//  メニュー「IMEIndicatorClockについて...」または ⌘, で開く
//

import SwiftUI
import AppKit

// MARK: - AboutView（アプリ情報画面）

/// アプリについての情報を表示するビュー
struct AboutView: View {
	var body: some View {
		VStack(spacing: 16) {

			// --- ヘッダー（アイコン + タイトル） ---
			HStack(spacing: 16) {
				Image(systemName: "character.textbox")
					.font(.system(size: 48))
					.foregroundColor(.blue)

				VStack(alignment: .leading, spacing: 4) {
					Text("app_name", tableName: "About")
						.font(.title)
						.fontWeight(.bold)

					Text("version \(Bundle.main.appVersion)", tableName: "About")
						.font(.subheadline)
						.foregroundColor(.secondary)
				}
			}
			.padding(.top, 10)

			// --- 説明文 ---
			Text("description", tableName: "About")
				.font(.body)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)
				.fixedSize(horizontal: false, vertical: true)

			Divider()
				.padding(.vertical, 8)

			// --- 対応言語 ---
			GroupBox {
				ScrollView {
					VStack(alignment: .leading, spacing: 4) {
						languageItem(color: .blue, text: "A", label: "lang_english")
						languageItem(color: .red, text: "あ", label: "lang_japanese")
						languageItem(color: Color(red: 0, green: 0.7, blue: 0), text: "简", label: "lang_chinese_simplified")
						languageItem(color: Color(red: 0, green: 0.5, blue: 0), text: "繁", label: "lang_chinese_traditional")
						languageItem(color: Color(red: 0.6, green: 0, blue: 0.6), text: "한", label: "lang_korean")
						languageItem(color: Color(red: 0, green: 0.6, blue: 0.6), text: "ไ", label: "lang_thai")
						languageItem(color: Color(red: 0, green: 0.7, blue: 0.7), text: "V", label: "lang_vietnamese")
						languageItem(color: Color(red: 1.0, green: 0.5, blue: 0), text: "ع", label: "lang_arabic")
						languageItem(color: Color(red: 0.85, green: 0.65, blue: 0), text: "ע", label: "lang_hebrew")
						languageItem(color: Color(red: 1.0, green: 0.6, blue: 0.2), text: "अ", label: "lang_hindi")
						languageItem(color: Color(red: 0.7, green: 0, blue: 0.3), text: "Я", label: "lang_russian")
						languageItem(color: Color(red: 0, green: 0.4, blue: 0.8), text: "Ω", label: "lang_greek")
						languageItem(color: .gray, text: "?", label: "lang_other")
					}
					.font(.callout)
					.padding(4)
				}
				.frame(height: 180)
			} label: {
				Label {
					Text("supported_languages", tableName: "About")
				} icon: {
					Image(systemName: "globe")
				}
			}

			// --- カスタマイズ ---
			GroupBox {
				VStack(alignment: .leading, spacing: 6) {
					Label {
						Text("ime_settings", tableName: "About")
					} icon: {
						Image(systemName: "character.textbox")
					}
					Label {
						Text("clock_settings", tableName: "About")
					} icon: {
						Image(systemName: "clock")
					}
				}
				.font(.callout)
				.foregroundColor(.secondary)
				.padding(4)
			} label: {
				Label {
					Text("customize", tableName: "About")
				} icon: {
					Image(systemName: "gearshape")
				}
			}

			// --- フッター ---
			VStack(spacing: 4) {
				Text("copyright", tableName: "About")
					.font(.caption)
					.foregroundColor(.secondary)

				Text("customize_hint", tableName: "About")
					.font(.caption2)
					.foregroundStyle(.tertiary)
			}
			.padding(.bottom, 10)
		}
		.padding(24)
		.frame(width: 380, height: 540)
	}

	// MARK: - ヘルパー

	/// 言語アイテム行を生成
	@ViewBuilder
	private func languageItem(color: Color, text: String, label: String) -> some View {
		HStack(spacing: 8) {
			ZStack {
				Circle()
					.fill(color)
					.frame(width: 20, height: 20)
				Text(text)
					.font(.system(size: 10, weight: .bold))
					.foregroundColor(.white)
			}
			Text(LocalizedStringKey(label), tableName: "About")
		}
	}
}

// MARK: - Bundle拡張

extension Bundle {
	/// アプリバージョン（例: "1.0"）
	var appVersion: String {
		infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
	}
}

// MARK: - AboutWindowManager

/// Aboutウィンドウを管理するシングルトン
class AboutWindowManager {

	/// シングルトンインスタンス
	static let shared = AboutWindowManager()

	/// ウィンドウへの参照
	private var aboutWindow: NSWindow?

	private init() {}

	/// Aboutウィンドウを開く
	func openAbout() {
		// 既存のウィンドウがあれば前面に
		if let window = aboutWindow, window.isVisible {
			window.makeKeyAndOrderFront(nil)
			NSApp.activate(ignoringOtherApps: true)
			return
		}

		// 新しいウィンドウを作成
		let window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 380, height: 440),
			styleMask: [.titled, .closable],
			backing: .buffered,
			defer: false
		)

		window.title = String(localized: "window_title", table: "About")
		window.center()
		window.contentView = NSHostingView(rootView: AboutView())
		window.isReleasedWhenClosed = false

		window.makeKeyAndOrderFront(nil)
		NSApp.activate(ignoringOtherApps: true)

		self.aboutWindow = window
	}
}

// MARK: - プレビュー

/// プレビュー用の言語切り替えラッパー
private struct AboutViewPreview: View {
	@State private var selectedLocale = "ja"

	private let locales: [(id: String, name: String)] = [
		("ja", "日本語"),
		("en", "English"),
		("zh-Hans", "简体中文"),
		("zh-Hant", "繁體中文"),
		("ko", "한국어")
	]

	var body: some View {
		VStack(spacing: 0) {
			// 言語切り替えPicker
			Picker("Locale", selection: $selectedLocale) {
				ForEach(locales, id: \.id) { locale in
					Text(locale.name).tag(locale.id)
				}
			}
			.pickerStyle(.segmented)
			.padding(8)

			// 本体
			AboutView()
				.environment(\.locale, Locale(identifier: selectedLocale))
		}
	}
}

#Preview("About") {
	AboutViewPreview()
		.frame(width: 500, height: 700)
}

/// 全ロケール一覧プレビュー
private struct AboutViewAllLocalesPreview: View {
	private let locales: [(id: String, name: String)] = [
		("ja", "日本語"),
		("en", "English"),
		("zh-Hans", "简体中文"),
		("zh-Hant", "繁體中文"),
		("ko", "한국어"),
		("th", "ไทย"),
		("vi", "Tiếng Việt"),
		("ar", "العربية"),
		("he", "עברית"),
		("hi", "हिन्दी"),
		("ru", "Русский"),
		("el", "Ελληνικά")
	]

	var body: some View {
		ScrollView(.horizontal) {
			HStack(alignment: .top, spacing: 16) {
				ForEach(locales, id: \.id) { locale in
					VStack(spacing: 4) {
						Text(locale.name)
							.font(.headline)
							.padding(.horizontal, 8)
							.padding(.vertical, 4)
							.background(Color.blue.opacity(0.2))
							.cornerRadius(4)

						AboutView()
							.environment(\.locale, Locale(identifier: locale.id))
							.border(Color.gray.opacity(0.3))
					}
				}
			}
			.padding()
		}
	}
}

#Preview("All Locales") {
	AboutViewAllLocalesPreview()
		.frame(height: 700)
}
