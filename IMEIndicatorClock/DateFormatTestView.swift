//
//  DateFormatTestView.swift
//  IMEIndicatorClock
//
//  開発用：DateFormatterのカスタムフォーマットをテストするビュー
//  Xcodeのプレビューで各ロケールでの表示を確認できます
//

import SwiftUI

struct DateFormatTestView: View {
	@State private var customDateFormat = "yyyy/MM/dd E"
	@State private var customTimeFormat = "HH:mm:ss"
	@State private var selectedLocale = "ja"

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

	/// Menuラベル用：メイン3言語以外の場合はその名前を表示
	private var otherLocaleLabel: String {
		let mainLocales = ["ja", "en", "zh-Hans"]
		if mainLocales.contains(selectedLocale) {
			return "その他"
		}
		return locales.first { $0.id == selectedLocale }?.name ?? "その他"
	}

	private let dateFormatExamples = [
		("yyyy/MM/dd", "2026/01/09"),
		("yyyy/MM/dd E", "2026/01/09 金"),
		("yyyy年M月d日", "2026年1月9日"),
		("yyyy年M月d日(E)", "2026年1月9日(金)"),
		("M/d (EEE)", "1/9 (金)"),
		("EEEE", "金曜日"),
		// 月の文字列形式
		("yyyy MMM d", "2026 Jan 9 / 2026 1月 9"),
		("yyyy MMMM d", "2026 January 9 / 2026 1月 9"),
		("d MMM yyyy", "9 Jan 2026"),
		("MMMM d, yyyy", "January 9, 2026"),
	]

	private let timeFormatExamples = [
		("HH:mm", "14:30"),
		("HH:mm:ss", "14:30:45"),
		("H:mm", "14:30"),
		("h:mm a", "2:30 PM"),
		("h:mm:ss a", "2:30:45 PM"),
		// タイムゾーン
		("HH:mm z", "14:30 JST"),
		("HH:mm:ss z", "14:30:45 JST"),
		("HH:mm zzzz", "14:30 Japan Standard Time"),
		("HH:mm Z", "14:30 +0900"),
		("HH:mm:ss OOOO", "14:30:45 GMT+09:00"),
	]

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {

				// タイトル
				Text("DateFormatter テスト")
					.font(.title)
					.fontWeight(.bold)

				// ロケール選択
				GroupBox("ロケール選択") {
					HStack {
						// メイン言語（セグメント）
						Picker("Locale", selection: $selectedLocale) {
							Text("日本語").tag("ja")
							Text("English").tag("en")
							Text("简体中文").tag("zh-Hans")
						}
						.pickerStyle(.segmented)

						// その他の言語（メニュー）
						Menu {
							Button("繁體中文") { selectedLocale = "zh-Hant" }
							Button("한국어") { selectedLocale = "ko" }
							Divider()
							Button("ไทย") { selectedLocale = "th" }
							Button("Tiếng Việt") { selectedLocale = "vi" }
							Button("العربية") { selectedLocale = "ar" }
							Button("עברית") { selectedLocale = "he" }
							Button("हिन्दी") { selectedLocale = "hi" }
							Button("Русский") { selectedLocale = "ru" }
							Button("Ελληνικά") { selectedLocale = "el" }
						} label: {
							Label(otherLocaleLabel, systemImage: "globe")
						}
					}
				}

				// 選択中のロケール表示
				HStack {
					Text("Locale:")
						.foregroundColor(.secondary)
					Text(locales.first { $0.id == selectedLocale }?.name ?? selectedLocale)
						.fontWeight(.bold)
				}

				// 日付フォーマット
				GroupBox("日付フォーマット") {
					VStack(alignment: .leading, spacing: 12) {

						HStack {
							// カスタム入力
							HStack {
								Text("フォーマット:")
								TextField("yyyy/MM/dd E", text: $customDateFormat)
									.textFieldStyle(.roundedBorder)
									.frame(width: 200)
							}
							
							// プレビュー
							HStack {
								Text("プレビュー:")
								Text(formatDate(format: customDateFormat))
									.fontWeight(.bold)
									.padding(.horizontal, 12)
									.padding(.vertical, 4)
									.background(Color.blue.opacity(0.15))
									.cornerRadius(6)
							}
						}

						Divider()

						// 例一覧
						Text("よく使うパターン:")
							.font(.caption)
							.foregroundColor(.secondary)

						ScrollView {
							ForEach(dateFormatExamples, id: \.0) { example in
								HStack {
									Text(example.0)
										.font(.system(.body, design: .monospaced))
										.frame(width: 150, alignment: .leading)
									Text("→")
										.foregroundColor(.secondary)
									Text(formatDate(format: example.0))
										.fontWeight(.medium)
									Spacer()
									Button("使用") {
										customDateFormat = example.0
									}
									.buttonStyle(.bordered)
									.controlSize(.small)
								}
							}
						}
						.frame(height: 80)
					}
					.padding(4)
				}

				// 時刻フォーマット
				GroupBox("時刻フォーマット") {
					VStack(alignment: .leading, spacing: 12) {

						HStack {
							// カスタム入力
							HStack {
								Text("フォーマット:")
								TextField("HH:mm:ss", text: $customTimeFormat)
									.textFieldStyle(.roundedBorder)
									.frame(width: 200)
							}
							
							// プレビュー
							HStack {
								Text("プレビュー:")
								Text(formatDate(format: customTimeFormat))
									.fontWeight(.bold)
									.padding(.horizontal, 12)
									.padding(.vertical, 4)
									.background(Color.green.opacity(0.15))
									.cornerRadius(6)
							}
						}

						Divider()

						// 例一覧
						Text("よく使うパターン:")
							.font(.caption)
							.foregroundColor(.secondary)

						ScrollView {
							ForEach(timeFormatExamples, id: \.0) { example in
								HStack {
									Text(example.0)
										.font(.system(.body, design: .monospaced))
										.frame(width: 150, alignment: .leading)
									Text("→")
										.foregroundColor(.secondary)
									Text(formatDate(format: example.0))
										.fontWeight(.medium)
									Spacer()
									Button("使用") {
										customTimeFormat = example.0
									}
									.buttonStyle(.bordered)
									.controlSize(.small)
								}
							}
						}
						.frame(height: 80)
					}
					.padding(4)
				}

				// ロケール比較（英語 vs 選択ロケール）
				GroupBox("ロケール比較") {
					VStack(alignment: .leading, spacing: 4) {
						let format = "\(customDateFormat) \(customTimeFormat)"

						// 英語
						HStack {
							Text("English")
								.frame(width: 100, alignment: .leading)
							Text(formatDateWithLocale(format: format, localeId: "en"))
								.font(.system(.body, design: .monospaced))
						}

						// 選択中のロケール（英語以外の場合のみ表示）
						if selectedLocale != "en" {
							HStack {
								Text(locales.first { $0.id == selectedLocale }?.name ?? selectedLocale)
									.frame(width: 100, alignment: .leading)
								Text(formatDateWithLocale(format: format, localeId: selectedLocale))
									.font(.system(.body, design: .monospaced))
							}
						}
					}
					.padding(4)
				}
			}
			.padding()
		}
//		.frame(width: 600, height: 800)
	}

	// MARK: - ヘルパー

	private func formatDate(format: String) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		formatter.locale = Locale(identifier: selectedLocale)
		return formatter.string(from: Date())
	}

	private func formatDateWithLocale(format: String, localeId: String) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		formatter.locale = Locale(identifier: localeId)
		return formatter.string(from: Date())
	}
}

// MARK: - プレビュー

#Preview("DateFormat Test") {
	DateFormatTestView()
		.frame(width: 600, height: 720)
}
