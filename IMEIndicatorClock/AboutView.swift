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

	#if DEBUG
	/// デバッグ用: 現在選択されている言語
	@State private var selectedLanguage: String = {
		// 現在のAppleLanguages設定を取得（なければシステム言語）
		if let languages = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String],
		   let first = languages.first {
			return first
		}
		return Locale.current.language.languageCode?.identifier ?? "en"
	}()
	#endif

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
						// 東アジア
						languageItem(color: .blue, text: "A", label: "lang_english")
						languageItem(color: .red, text: "あ", label: "lang_japanese")
						languageItem(color: Color(red: 0, green: 0.7, blue: 0), text: "简", label: "lang_chinese_simplified")
						languageItem(color: Color(red: 0, green: 0.5, blue: 0), text: "繁", label: "lang_chinese_traditional")
						languageItem(color: Color(red: 0.6, green: 0, blue: 0.6), text: "한", label: "lang_korean")
						languageItem(color: Color(red: 0.3, green: 0.5, blue: 0.7), text: "ᠮ", label: "lang_mongolian")
						// 東南アジア
						languageItem(color: Color(red: 0, green: 0.6, blue: 0.6), text: "ไ", label: "lang_thai")
						languageItem(color: Color(red: 0, green: 0.7, blue: 0.7), text: "V", label: "lang_vietnamese")
						languageItem(color: Color(red: 0.8, green: 0.2, blue: 0.2), text: "မ", label: "lang_myanmar")
						languageItem(color: Color(red: 0.4, green: 0.6, blue: 0.8), text: "ក", label: "lang_khmer")
						languageItem(color: Color(red: 0.2, green: 0.6, blue: 0.4), text: "ລ", label: "lang_lao")
						// 南アジア
						languageItem(color: Color(red: 1.0, green: 0.6, blue: 0.2), text: "अ", label: "lang_hindi")
						languageItem(color: Color(red: 0.2, green: 0.6, blue: 0.2), text: "বা", label: "lang_bengali")
						languageItem(color: Color(red: 0.8, green: 0.4, blue: 0.0), text: "த", label: "lang_tamil")
						languageItem(color: Color(red: 0.6, green: 0.4, blue: 0.2), text: "తె", label: "lang_telugu")
						languageItem(color: Color(red: 0.5, green: 0.3, blue: 0.6), text: "ने", label: "lang_nepali")
						languageItem(color: Color(red: 0.7, green: 0.5, blue: 0.0), text: "සි", label: "lang_sinhala")
						// 中東
						languageItem(color: Color(red: 1.0, green: 0.5, blue: 0), text: "ع", label: "lang_arabic")
						languageItem(color: Color(red: 0.4, green: 0.7, blue: 0.4), text: "ف", label: "lang_persian")
						languageItem(color: Color(red: 0.85, green: 0.65, blue: 0), text: "ע", label: "lang_hebrew")
						// 東欧
						languageItem(color: Color(red: 0.0, green: 0.4, blue: 0.8), text: "У", label: "lang_ukrainian")
						languageItem(color: Color(red: 0.7, green: 0, blue: 0.3), text: "Я", label: "lang_russian")
						// その他
						languageItem(color: Color(red: 0, green: 0.4, blue: 0.8), text: "Ω", label: "lang_greek")
						languageItem(color: .gray, text: "?", label: "lang_other")
					}
					.font(.callout)
					.padding(4)
				}
				// ウィンドウサイズに追従（最小高さを設定）
				.frame(minHeight: 100, maxHeight: .infinity)
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
					Label {
						Text("mouse_cursor_indicator_settings", tableName: "About")
					} icon: {
						Image(systemName: "cursorarrow")
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

			#if DEBUG
			// --- デバッグ用: ロケール選択 ---
			Divider()
			debugLocaleSelector
			#endif
		}
		.padding(24)
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
	}

	// MARK: - デバッグ用ロケール選択

	#if DEBUG
	/// 対応言語リスト（23言語）
	private static let supportedLanguages: [(code: String, name: String)] = [
		// 東アジア
		("en", "English"),
		("ja", "日本語"),
		("zh-Hans", "简体中文"),
		("zh-Hant", "繁體中文"),
		("ko", "한국어"),
		("mn", "Монгол"),
		// 東南アジア
		("th", "ไทย"),
		("vi", "Tiếng Việt"),
		("my", "မြန်မာ"),
		("km", "ភាសាខ្មែរ"),
		("lo", "ລາວ"),
		// 南アジア
		("hi", "हिन्दी"),
		("bn", "বাংলা"),
		("ta", "தமிழ்"),
		("te", "తెలుగు"),
		("ne", "नेपाली"),
		("si", "සිංහල"),
		// 中東
		("ar", "العربية"),
		("fa", "فارسی"),
		("he", "עברית"),
		// 東欧
		("uk", "Українська"),
		("ru", "Русский"),
		// その他
		("el", "Ελληνικά")
	]

	/// デバッグ用ロケール選択UI
	@ViewBuilder
	private var debugLocaleSelector: some View {
		GroupBox {
			VStack(alignment: .leading, spacing: 8) {
				HStack {
					Text("🔧 Debug: Language Override")
						.font(.caption)
						.fontWeight(.semibold)

					Spacer()

					// 現在の設定状態を表示
					if UserDefaults.standard.array(forKey: "AppleLanguages") != nil {
						Text("(Override Active)")
							.font(.caption2)
							.foregroundColor(.orange)
					}
				}

				Picker("Language", selection: $selectedLanguage) {
					ForEach(Self.supportedLanguages, id: \.code) { lang in
						Text("\(lang.name) (\(lang.code))").tag(lang.code)
					}
				}
				.labelsHidden()

				HStack {
					Button("Apply & Restart") {
						applyLanguageAndRestart()
					}
					.buttonStyle(.borderedProminent)
					.controlSize(.small)

					Button("Reset to System") {
						resetToSystemLanguage()
					}
					.buttonStyle(.bordered)
					.controlSize(.small)
				}

				Text("※ Changes require app restart")
					.font(.caption2)
					.foregroundColor(.secondary)
			}
			.padding(4)
		} label: {
			Label("Developer Options", systemImage: "hammer.fill")
				.font(.caption)
				.foregroundColor(.orange)
		}
	}

	/// 言語を適用してアプリを再起動
	private func applyLanguageAndRestart() {
		dbgLog(1, "🔧 [Debug] Applying language: \(selectedLanguage)")

		// UserDefaultsに言語設定を保存
		UserDefaults.standard.set([selectedLanguage], forKey: "AppleLanguages")
		UserDefaults.standard.synchronize()

		// アプリを再起動
		restartApp()
	}

	/// システム言語にリセット
	private func resetToSystemLanguage() {
		dbgLog(1, "🔧 [Debug] Resetting to system language")

		// AppleLanguagesをクリア
		UserDefaults.standard.removeObject(forKey: "AppleLanguages")
		UserDefaults.standard.synchronize()

		// アプリを再起動
		restartApp()
	}

	/// アプリを再起動
	private func restartApp() {
		let url = URL(fileURLWithPath: Bundle.main.bundlePath)
		let configuration = NSWorkspace.OpenConfiguration()
		configuration.createsNewApplicationInstance = true

		NSWorkspace.shared.openApplication(at: url, configuration: configuration) { _, error in
			if let error = error {
				dbgLog(1, "❌ [Debug] Restart failed: \(error)")
			} else {
				dbgLog(1, "✅ [Debug] Restarting app...")
				DispatchQueue.main.async {
					NSApp.terminate(nil)
				}
			}
		}
	}
	#endif

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
		// 東アジア
		("en", "English"),
		("ja", "日本語"),
		("zh-Hans", "简体中文"),
		("zh-Hant", "繁體中文"),
		("ko", "한국어"),
		("mn", "Монгол"),
		// 東南アジア
		("th", "ไทย"),
		("vi", "Tiếng Việt"),
		("my", "မြန်မာ"),
		("km", "ភាសាខ្មែរ"),
		("lo", "ລາວ"),
		// 南アジア
		("hi", "हिन्दी"),
		("bn", "বাংলা"),
		("ta", "தமிழ்"),
		("te", "తెలుగు"),
		("ne", "नेपाली"),
		("si", "සිංහල"),
		// 中東
		("ar", "العربية"),
		("fa", "فارسی"),
		("he", "עברית"),
		// 東欧
		("uk", "Українська"),
		("ru", "Русский"),
		// その他
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
