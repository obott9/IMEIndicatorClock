//
//  DateFormatEditorView.swift
//  IMEIndicatorClock
//
//  カスタム日付フォーマット編集ビュー
//  シートとして表示し、フォーマット文字列を編集
//

import SwiftUI
import Combine

// MARK: - DateFormatEditorView

/// カスタム日付フォーマット編集ビュー
struct DateFormatEditorView: View {
	@Environment(\.dismiss) private var dismiss

	/// 編集中のフォーマット文字列
	@Binding var formatString: String

	/// ビューのタイトル
	let title: String

	/// 編集用の一時変数
	@State private var editingFormat: String = ""

	/// 現在時刻（プレビュー用）
	@State private var currentDate = Date()

	/// タイマー
	private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

	/// よく使う日付フォーマット例
	private let dateExamples: [(format: String, description: String)] = [
		("yyyy/MM/dd", "2026/01/09"),
		("yyyy/MM/dd E", "2026/01/09 木"),
		("yyyy/MM/dd (E)", "2026/01/09 (木)"),
		("yyyy/MM/dd (EEEE)", "2026/01/09 (木曜日)"),
		("yyyy-MM-dd", "2026-01-09"),
		("yyyy-MM-dd E", "2026-01-09 木"),
		("M/d", "1/9"),
		("M/d (E)", "1/9 (木)"),
		("M/d (EEE)", "1/9 (Thu)"),
		("yyyy年M月d日", "2026年1月9日"),
		("yyyy年M月d日 E", "2026年1月9日 木"),
		("yyyy年M月d日(EEEE)", "2026年1月9日(木曜日)"),
		("d MMM yyyy", "9 Jan 2026"),
		("MMM d, yyyy", "Jan 9, 2026"),
		("MMMM d, yyyy", "January 9, 2026"),
		("EEEE, MMMM d", "Thursday, January 9"),
	]

	var body: some View {
		VStack(spacing: 16) {
			// ヘッダー
			Text(title)
				.font(.headline)

			// フォーマット入力
			HStack {
				Text("format_string", tableName: "Clock")
				TextField("yyyy/MM/dd E", text: $editingFormat)
					.textFieldStyle(.roundedBorder)
					.frame(width: 200)
			}

			// プレビュー
			HStack {
				Text("preview", tableName: "Clock")
				Text(formatPreview)
					.font(.system(.title3, design: .monospaced))
					.fontWeight(.bold)
					.padding(.horizontal, 12)
					.padding(.vertical, 6)
					.background(Color.blue.opacity(0.15))
					.cornerRadius(8)
			}

			Divider()

			// よく使うパターン
			VStack(alignment: .leading, spacing: 4) {
				Text("common_patterns", tableName: "Clock")
					.font(.caption)
					.foregroundColor(.secondary)

				ScrollView {
					VStack(spacing: 2) {
						ForEach(dateExamples, id: \.format) { example in
							HStack {
								Text(example.format)
									.font(.system(.body, design: .monospaced))
									.frame(width: 180, alignment: .leading)

								Text("→")
									.foregroundColor(.secondary)

								Text(formatDate(example.format))
									.frame(width: 150, alignment: .leading)

								Spacer()

								Button {
									editingFormat = example.format
								} label: {
									Text("use", tableName: "Clock")
								}
								.buttonStyle(.bordered)
								.controlSize(.small)
							}
							.padding(.vertical, 2)
						}
					}
				}
				.frame(height: 200)
			}

			Divider()

			// ボタン
			HStack {
				Button {
					dismiss()
				} label: {
					Text("cancel", tableName: "Clock")
				}
				.keyboardShortcut(.escape)

				Spacer()

				Button {
					formatString = editingFormat
					dismiss()
				} label: {
					Text("save", tableName: "Clock")
				}
				.keyboardShortcut(.return)
				.buttonStyle(.borderedProminent)
			}
		}
		.padding(20)
		.frame(width: 500, height: 450)
		.onAppear {
			editingFormat = formatString
		}
		.onReceive(timer) { _ in
			currentDate = Date()
		}
	}

	// MARK: - ヘルパー

	/// プレビュー文字列
	private var formatPreview: String {
		formatDate(editingFormat)
	}

	/// 環境からロケールを取得
	@Environment(\.locale) var locale

	/// 日付をフォーマット
	private func formatDate(_ format: String) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		formatter.locale = locale
		return formatter.string(from: currentDate)
	}
}

// MARK: - プレビュー用ビュー（dismiss不要版）

/// プレビュー用：dismissを使わない日付フォーマットエディタ
private struct DateFormatEditorPreview: View {
	@Binding var formatString: String
	let title: String

	@Environment(\.locale) var locale
	@State private var editingFormat: String = ""
	@State private var currentDate = Date()

	private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

	private let dateExamples: [(format: String, description: String)] = [
		("yyyy/MM/dd", "2026/01/09"),
		("yyyy/MM/dd E", "2026/01/09 木"),
		("yyyy/MM/dd (E)", "2026/01/09 (木)"),
		("yyyy-MM-dd", "2026-01-09"),
		("M/d (EEE)", "1/9 (Thu)"),
		("yyyy年M月d日", "2026年1月9日"),
		("yyyy年M月d日 E", "2026年1月9日 木"),
		("d MMM yyyy", "9 Jan 2026"),
		("MMM d, yyyy", "Jan 9, 2026"),
		("MMMM d, yyyy", "January 9, 2026"),
	]

	var body: some View {
		VStack(spacing: 16) {
			Text(title)
				.font(.headline)

			HStack {
				Text("format_string", tableName: "Clock")
				TextField("yyyy/MM/dd E", text: $editingFormat)
					.textFieldStyle(.roundedBorder)
					.frame(width: 200)
			}

			HStack {
				Text("preview", tableName: "Clock")
				Text(formatDate(editingFormat))
					.font(.system(.title3, design: .monospaced))
					.fontWeight(.bold)
					.padding(.horizontal, 12)
					.padding(.vertical, 6)
					.background(Color.blue.opacity(0.15))
					.cornerRadius(8)
			}

			Divider()

			ScrollView {
				VStack(spacing: 2) {
					ForEach(dateExamples, id: \.format) { example in
						HStack {
							Text(example.format)
								.font(.system(.body, design: .monospaced))
								.frame(width: 160, alignment: .leading)
							Text("→")
								.foregroundColor(.secondary)
							Text(formatDate(example.format))
								.frame(width: 140, alignment: .leading)
							Spacer()
							Button("使用") {
								editingFormat = example.format
							}
							.buttonStyle(.bordered)
							.controlSize(.small)
						}
					}
				}
			}
			.frame(height: 200)
		}
		.padding(20)
		.frame(width: 480, height: 400)
		.onAppear { editingFormat = formatString }
		.onReceive(timer) { _ in currentDate = Date() }
		.onChange(of: editingFormat) { _, new in formatString = new }
	}

	private func formatDate(_ format: String) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		formatter.locale = locale
		return formatter.string(from: currentDate)
	}
}

// MARK: - プレビュー

#Preview("DateFormatEditor") {
	struct PreviewWrapper: View {
		@State private var format = "yyyy/MM/dd E"
		@State private var selectedLocale = "ja"

		var body: some View {
			VStack(spacing: 0) {
				Picker("Locale", selection: $selectedLocale) {
					Text("日本語").tag("ja")
					Text("English").tag("en")
					Text("简体中文").tag("zh-Hans")
				}
				.pickerStyle(.segmented)
				.padding(8)

				DateFormatEditorPreview(
					formatString: $format,
					title: "カスタム1"
				)
				.environment(\.locale, Locale(identifier: selectedLocale))
			}
		}
	}

	return PreviewWrapper()
}
