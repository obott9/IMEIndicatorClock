//
//  TimeFormatPickerView.swift
//  IMEIndicatorClock
//
//  時刻フォーマット選択ビュー
//  2段階展開UI：選択中のみ表示 → 全展開 → カスタム編集
//

import SwiftUI
import Combine

// MARK: - TimeFormatPickerView

/// 時刻フォーマット選択ビュー（折りたたみ式）
struct TimeFormatPickerView: View {
	@Binding var selectedStyle: TimeFormatStyle
	@Binding var customFormat1: String
	@Binding var customFormat2: String

	/// 環境からロケールを取得
	@Environment(\.locale) var locale

	/// 展開状態
	@State private var isExpanded = false

	/// カスタム編集の展開状態
	@State private var editingCustom: TimeFormatStyle? = nil

	/// 現在時刻（プレビュー用）
	@State private var currentDate = Date()

	/// タイマー（1秒ごとに更新）
	private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

	/// よく使うカスタムフォーマット
	private let customExamples = [
		"HH:mm",
		"HH:mm:ss z",
		"H:mm",
		"h:mm a",
		"h:mm:ss a",
		"HH:mm:ss.SSS",
		"H時mm分",
		"H時mm分ss秒",
		"HH:mm zzzz",
		"HH:mm:ss zzz",
	]

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			if isExpanded {
				// 展開時：全オプション表示
				expandedView
			} else {
				// 折りたたみ時：選択中のみ
				collapsedView
			}
		}
		.onReceive(timer) { _ in
			currentDate = Date()
		}
		.animation(.easeInOut(duration: 0.2), value: isExpanded)
		.animation(.easeInOut(duration: 0.2), value: editingCustom)
	}

	// MARK: - 折りたたみ状態

	private var collapsedView: some View {
		HStack {
			Image(systemName: "circle.inset.filled")
				.foregroundColor(.accentColor)
				.font(.system(size: 14))

			Text(LocalizedStringKey(selectedStyle.localizationKey), tableName: "Clock")

			Spacer()

			Text(previewForStyle(selectedStyle))
				.font(.system(.body, design: .monospaced))
				.foregroundColor(.secondary)

			Image(systemName: "chevron.down")
				.foregroundColor(.secondary)
				.font(.system(size: 12))
		}
		.padding(.vertical, 6)
		.padding(.horizontal, 8)
		.background(Color.secondary.opacity(0.1))
		.cornerRadius(6)
		.contentShape(Rectangle())
		.onTapGesture {
			isExpanded = true
		}
	}

	// MARK: - 展開状態

	private var expandedView: some View {
		VStack(alignment: .leading, spacing: 4) {
			// ヘッダー（タップで閉じる）
			HStack {
				Text("time_format", tableName: "Clock")
					.font(.caption)
					.foregroundColor(.secondary)
				Spacer()
				Button {
					isExpanded = false
					editingCustom = nil
				} label: {
					Image(systemName: "chevron.up")
						.foregroundColor(.secondary)
				}
				.buttonStyle(.plain)
			}
			.padding(.bottom, 4)

			// 標準フォーマット
			ForEach(TimeFormatStyle.standardCases, id: \.self) { style in
				standardFormatRow(style)
			}

			Divider()
				.padding(.vertical, 4)

			// カスタムフォーマット
			customFormatRow(.custom1, format: $customFormat1)
			customFormatRow(.custom2, format: $customFormat2)
		}
		.padding(8)
		.background(Color.secondary.opacity(0.05))
		.cornerRadius(6)
	}

	// MARK: - 標準フォーマット行

	@ViewBuilder
	private func standardFormatRow(_ style: TimeFormatStyle) -> some View {
		HStack {
			Image(systemName: selectedStyle == style ? "circle.inset.filled" : "circle")
				.foregroundColor(selectedStyle == style ? .accentColor : .secondary)
				.font(.system(size: 14))

			Text(LocalizedStringKey(style.localizationKey), tableName: "Clock")
				.frame(width: 80, alignment: .leading)

			Spacer()

			Text(style.format(currentDate, locale: locale))
				.font(.system(.body, design: .monospaced))
				.foregroundColor(.secondary)
		}
		.padding(.vertical, 2)
		.contentShape(Rectangle())
		.onTapGesture {
			selectedStyle = style
			isExpanded = false
			editingCustom = nil
		}
	}

	// MARK: - カスタムフォーマット行

	@ViewBuilder
	private func customFormatRow(_ style: TimeFormatStyle, format: Binding<String>) -> some View {
		VStack(alignment: .leading, spacing: 4) {
			HStack {
				Image(systemName: selectedStyle == style ? "circle.inset.filled" : "circle")
					.foregroundColor(selectedStyle == style ? .accentColor : .secondary)
					.font(.system(size: 14))

				Text(LocalizedStringKey(style.localizationKey), tableName: "Clock")
					.frame(width: 80, alignment: .leading)

				Spacer()

				Text(TimeFormatStyle.formatCustom(currentDate, format: format.wrappedValue, locale: locale))
					.font(.system(.body, design: .monospaced))
					.foregroundColor(.secondary)

				// 編集ボタン
				Button {
					if editingCustom == style {
						editingCustom = nil
					} else {
						editingCustom = style
						selectedStyle = style
					}
				} label: {
					Text(editingCustom == style ? "close" : "edit", tableName: "Clock")
						.font(.caption)
				}
				.buttonStyle(.bordered)
				.controlSize(.mini)
			}
			.padding(.vertical, 2)
			.contentShape(Rectangle())
			.onTapGesture {
				selectedStyle = style
			}

			// インライン編集（展開時）
			if editingCustom == style {
				inlineEditor(format: format)
			}
		}
	}

	// MARK: - インライン編集

	@ViewBuilder
	private func inlineEditor(format: Binding<String>) -> some View {
		VStack(alignment: .leading, spacing: 6) {
			// 入力欄 + プレビュー
			HStack {
				TextField("HH:mm:ss", text: format)
					.textFieldStyle(.roundedBorder)
					.font(.system(.body, design: .monospaced))
					.frame(width: 140)

				Text("→")
					.foregroundColor(.secondary)

				Text(TimeFormatStyle.formatCustom(currentDate, format: format.wrappedValue, locale: locale))
					.font(.system(.body, design: .monospaced))
					.foregroundColor(.blue)
					.fontWeight(.medium)
			}

			// 書式ヘルプ
			VStack(alignment: .leading, spacing: 2) {
				Text("time_format_help_codes", tableName: "Clock")
					.font(.caption)
					.foregroundColor(.secondary)
				Text("format_help_separator", tableName: "Clock")
					.font(.caption)
					.foregroundColor(.secondary)
			}

			// 例
			Text("format_examples", tableName: "Clock")
				.font(.caption)
				.foregroundColor(.secondary)

			ScrollView(.vertical) {
				VStack(spacing: 6) {
					ForEach(customExamples, id: \.self) { example in
						Button {
							format.wrappedValue = example
						} label: {
							HStack(spacing: 2) {
								Text(example)
									.font(.system(.caption2, design: .monospaced))
								Text(TimeFormatStyle.formatCustom(currentDate, format: example, locale: locale))
									.font(.caption2)
									.foregroundColor(.secondary)
							}
							.padding(.horizontal, 6)
							.padding(.vertical, 4)
						}
						.buttonStyle(.bordered)
						.controlSize(.mini)
					}
				}
			}
			.frame(maxHeight: 90)
		}
		.padding(8)
		.background(Color.green.opacity(0.05))
		.cornerRadius(6)
	}

	// MARK: - ヘルパー

	private func previewForStyle(_ style: TimeFormatStyle) -> String {
		switch style {
		case .custom1:
			return TimeFormatStyle.formatCustom(currentDate, format: customFormat1, locale: locale)
		case .custom2:
			return TimeFormatStyle.formatCustom(currentDate, format: customFormat2, locale: locale)
		default:
			return style.format(currentDate, locale: locale)
		}
	}
}

// MARK: - プレビュー

#Preview("TimeFormatPicker") {
	struct PreviewWrapper: View {
		@State private var style: TimeFormatStyle = .standard
		@State private var custom1 = "HH:mm:ss"
		@State private var custom2 = "H:mm"
		@State private var selectedLocale = "ja"

		var body: some View {
			VStack {
				// ロケール切り替え
				Picker("Locale", selection: $selectedLocale) {
					Text("日本語").tag("ja")
					Text("English").tag("en")
					Text("简体中文").tag("zh-Hans")
				}
				.pickerStyle(.segmented)
				.padding(.horizontal)

				GroupBox("時刻フォーマット") {
					TimeFormatPickerView(
						selectedStyle: $style,
						customFormat1: $custom1,
						customFormat2: $custom2
					)
				}
				.padding()

				Spacer()
			}
			.frame(width: 420, height: 500)
			.environment(\.locale, Locale(identifier: selectedLocale))
		}
	}

	return PreviewWrapper()
}
