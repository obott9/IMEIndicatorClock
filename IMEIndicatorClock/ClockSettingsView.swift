//  ClockSettingsView.swift
//  IMEIndicatorClock
//
//  Created on 2025/12/24.
//
//  時計設定ウィンドウのSwiftUI UI
//

import SwiftUI

// MARK: - 時計設定ビュー

struct ClockSettingsView: View {
	
	// settingsManager を監視して直接バインド
	@ObservedObject private var settingsManager = AppSettingsManager.shared
	
	// ウィンドウドラッグ中のフラグ（読み取り専用）
	private var isWindowDragging: Bool {
		settingsManager.isWindowDragging
	}
	
	var body: some View {
		ScrollView {
			VStack(spacing: 0) {
				HStack(spacing: 24) {
					// 左カラム
					VStack(alignment: .leading, spacing: 12) {

						// タイトル + 移動説明
						HStack {
							Image(systemName: "clock.fill")
								.font(.system(size: 24))
								.foregroundColor(.blue)
							Text("title", tableName: "Clock")
								.font(.title2)
								.fontWeight(.bold)
							Spacer()
							Image(systemName: "hand.point.up.left.fill")
								.foregroundColor(.blue)
							Text("drag_hint", tableName: "Clock")
								.font(.caption)
								.foregroundColor(.secondary)
						}
						.padding(.bottom, 4)

						// 基本設定
						GroupBox {
							VStack(alignment: .leading, spacing: 8) {

								// 表示ON/OFF
								Toggle(isOn: $settingsManager.settings.clock.isVisible) {
									Text("show_clock", tableName: "Clock")
								}
								.onChange(of: settingsManager.settings.clock.isVisible) { _, _ in
									saveSettings()
								}

								Divider()

								// スタイル選択
								Picker(selection: $settingsManager.settings.clock.style) {
									ForEach(ClockStyle.allCases, id: \.self) { style in
										Text(LocalizedStringKey(style.localizationKey), tableName: "Clock").tag(style)
									}
								} label: {
									Text("style", tableName: "Clock")
								}
								.onChange(of: settingsManager.settings.clock.style) { oldValue, newValue in
									// アナログスタイルに変更した場合、ウィンドウサイズの最小値をチェック
									if newValue == .analog {
										let minWindowSize = settingsManager.settings.clock.analogClockSize  // パディングなし
										if settingsManager.settings.clock.windowWidth < minWindowSize {
											settingsManager.settings.clock.windowWidth = minWindowSize
										}
										if settingsManager.settings.clock.windowHeight < minWindowSize {
											settingsManager.settings.clock.windowHeight = minWindowSize
										}
									}
									saveSettings()
								}
								
								// 日付・時刻の表示位置
								Picker(selection: $settingsManager.settings.clock.dateTimePosition) {
									ForEach(DateTimePosition.allCases, id: \.self) { position in
										Text(LocalizedStringKey(position.localizationKey), tableName: "Clock").tag(position)
									}
								} label: {
									Text("content", tableName: "Clock")
								}
								.onChange(of: settingsManager.settings.clock.dateTimePosition) { _, _ in
									saveSettings()
								}

								// 秒を表示
								Toggle(isOn: $settingsManager.settings.clock.showSeconds) {
									Text("show_seconds", tableName: "Clock")
								}
								.onChange(of: settingsManager.settings.clock.showSeconds) { _, _ in
									saveSettings()
								}
							}
							.padding(6)
						} label: {
							Label {
								Text("basic", tableName: "Clock")
							} icon: {
								Image(systemName: "gearshape")
							}
						}
						
						// フォント設定
						GroupBox {
							VStack(alignment: .leading, spacing: 6) {
								HStack {
									Text("font_family", tableName: "Clock")
									Picker("", selection: Binding(
										get: { internalFontNameToDisplay(settingsManager.settings.clock.fontName) },
										set: { newValue in
											settingsManager.settings.clock.fontName = fontNameToInternal(newValue)
											saveSettings()
										}
									)) {
										ForEach(availableFonts, id: \.self) { fontName in
											if fontName == systemFontDisplayName {
												Text("system_font", tableName: "Clock").tag(fontName)
											} else {
												Text(fontName)
													.font(.custom(fontName, size: 12))
													.tag(fontName)
											}
										}
									}
									.labelsHidden()
								}
								HStack {
									Text("font_size", tableName: "Clock")
									Slider(value: $settingsManager.settings.clock.fontSize, in: 12...100, step: 1)
										.onChange(of: settingsManager.settings.clock.fontSize) { _, _ in
											if !isWindowDragging { saveSettings() }
										}
									Text("\(Int(settingsManager.settings.clock.fontSize))pt")
										.frame(width: 40, alignment: .trailing)
										.monospacedDigit()
								}
							}
							.padding(6)
						} label: {
							Label {
								Text("font", tableName: "Clock")
							} icon: {
								Image(systemName: "textformat")
							}
						}

						// 日付フォーマット
						GroupBox {
							DateFormatPickerView(
								selectedStyle: $settingsManager.settings.clock.dateFormatStyle,
								customFormat1: $settingsManager.settings.clock.customDateFormat1,
								customFormat2: $settingsManager.settings.clock.customDateFormat2
							)
							.onChange(of: settingsManager.settings.clock.dateFormatStyle) { _, _ in
								saveSettings()
							}
							.onChange(of: settingsManager.settings.clock.customDateFormat1) { _, _ in
								saveSettings()
							}
							.onChange(of: settingsManager.settings.clock.customDateFormat2) { _, _ in
								saveSettings()
							}
							.padding(4)
						} label: {
							Label {
								Text("date_format", tableName: "Clock")
							} icon: {
								Image(systemName: "calendar")
							}
						}

						// 時刻フォーマット
						GroupBox {
							TimeFormatPickerView(
								selectedStyle: $settingsManager.settings.clock.timeFormatStyle,
								customFormat1: $settingsManager.settings.clock.customTimeFormat1,
								customFormat2: $settingsManager.settings.clock.customTimeFormat2
							)
							.onChange(of: settingsManager.settings.clock.timeFormatStyle) { _, _ in
								saveSettings()
							}
							.onChange(of: settingsManager.settings.clock.customTimeFormat1) { _, _ in
								saveSettings()
							}
							.onChange(of: settingsManager.settings.clock.customTimeFormat2) { _, _ in
								saveSettings()
							}
							.padding(4)
						} label: {
							Label {
								Text("time_format", tableName: "Clock")
							} icon: {
								Image(systemName: "clock")
							}
						}
				}
					.frame(maxWidth: .infinity)
					
					// 右カラム
					VStack(alignment: .leading, spacing: 12) {
						
						// 色設定
						GroupBox {
							VStack(alignment: .leading, spacing: 8) {
								// テキスト色・アナログ時計色
								HStack(spacing: 16) {
									Text("text_color", tableName: "Clock")
									ColorPicker("", selection: Binding(
										get: { settingsManager.settings.clock.textColor.color },
										set: { newValue in
											settingsManager.settings.clock.textColor = ColorComponents(nsColor: NSColor(newValue))
											saveSettings()
										}
									))
									.labelsHidden()

									Text("analog_color", tableName: "Clock")
									ColorPicker("", selection: Binding(
										get: { settingsManager.settings.clock.analogColor.color },
										set: { newValue in
											settingsManager.settings.clock.analogColor = ColorComponents(nsColor: NSColor(newValue))
											saveSettings()
										}
									))
									.labelsHidden()
								}

								// 背景色 (OFF/ON) を1行に
								HStack(spacing: 16) {
									Text("background", tableName: "Clock")
									Text("ime_off", tableName: "Clock")
									ColorPicker("", selection: Binding(
										get: { settingsManager.settings.clock.backgroundColorOff.color },
										set: { newValue in
											settingsManager.settings.clock.backgroundColorOff = ColorComponents(nsColor: NSColor(newValue))
											saveSettings()
										}
									))
									.labelsHidden()

									Text("ime_on", tableName: "Clock")
									ColorPicker("", selection: Binding(
										get: { settingsManager.settings.clock.backgroundColorOn.color },
										set: { newValue in
											settingsManager.settings.clock.backgroundColorOn = ColorComponents(nsColor: NSColor(newValue))
											saveSettings()
										}
									))
									.labelsHidden()
								}

								// 背景透過度
								HStack {
									Text("opacity", tableName: "Clock")
									Slider(value: $settingsManager.settings.clock.backgroundOpacity, in: 0...1, step: 0.05)
										.onChange(of: settingsManager.settings.clock.backgroundOpacity) { _, _ in
											saveSettings()
										}
									Text("\(Int(settingsManager.settings.clock.backgroundOpacity * 100))%")
										.frame(width: 40, alignment: .trailing)
										.monospacedDigit()
								}
							}
							.padding(6)
						} label: {
							Label {
								Text("color", tableName: "Clock")
							} icon: {
								Image(systemName: "paintpalette")
							}
						}
						
						// 位置設定
						GroupBox {
							VStack(alignment: .leading, spacing: 6) {
								// X/Y座標 + ディスプレイを1行に
								HStack(spacing: 12) {
									Text("position_x", tableName: "Clock")
									TextField("", text: Binding(
										get: { String(format: "%.0f", settingsManager.settings.clock.positionX) },
										set: { newValue in
											guard !isWindowDragging else { return }
											if let value = Double(newValue) {
												settingsManager.settings.clock.positionX = CGFloat(value)
												saveAndRecreate()
											}
										}
									))
									.textFieldStyle(.roundedBorder)
									.frame(width: 50)
									.multilineTextAlignment(.trailing)

									Text("position_y", tableName: "Clock")
									TextField("", text: Binding(
										get: { String(format: "%.0f", settingsManager.settings.clock.positionY) },
										set: { newValue in
											guard !isWindowDragging else { return }
											if let value = Double(newValue) {
												settingsManager.settings.clock.positionY = CGFloat(value)
												saveAndRecreate()
											}
										}
									))
									.textFieldStyle(.roundedBorder)
									.frame(width: 50)
									.multilineTextAlignment(.trailing)

									Picker("", selection: $settingsManager.settings.clock.displayIndex) {
										ForEach(0..<NSScreen.screens.count, id: \.self) { index in
											Text("display_number \(index + 1)", tableName: "Clock").tag(index)
										}
									}
									.labelsHidden()
									.frame(width: 120)
									.onChange(of: settingsManager.settings.clock.displayIndex) { _, _ in
										saveSettings()
									}
								}

								// プリセット位置ボタン
								HStack(spacing: 8) {
									Button { setPositionBottomLeft() } label: {
										Text("bottom_left", tableName: "Clock")
									}
									Button { setPositionBottomRight() } label: {
										Text("bottom_right", tableName: "Clock")
									}
									Button { setPositionTopLeft() } label: {
										Text("top_left", tableName: "Clock")
									}
									Button { setPositionTopRight() } label: {
										Text("top_right", tableName: "Clock")
									}
								}
								.buttonStyle(.bordered)
								.controlSize(.small)
							}
							.padding(6)
						} label: {
							Label {
								Text("position", tableName: "Clock")
							} icon: {
								Image(systemName: "move.3d")
							}
						}
						
						// サイズ設定
						GroupBox {
							VStack(alignment: .leading, spacing: 6) {
								HStack {
									Text("width", tableName: "Clock")
									Slider(value: $settingsManager.settings.clock.windowWidth, in: 100...500, step: 10)
										.onChange(of: settingsManager.settings.clock.windowWidth) { _, _ in
											if !isWindowDragging { saveAndRecreate() }
										}
									Text("\(Int(settingsManager.settings.clock.windowWidth))")
										.frame(width: 32, alignment: .trailing)
										.monospacedDigit()
								}
								HStack {
									Text("height", tableName: "Clock")
									Slider(value: $settingsManager.settings.clock.windowHeight, in: 100...500, step: 10)
										.onChange(of: settingsManager.settings.clock.windowHeight) { _, _ in
											if !isWindowDragging { saveAndRecreate() }
										}
									Text("\(Int(settingsManager.settings.clock.windowHeight))")
										.frame(width: 32, alignment: .trailing)
										.monospacedDigit()
								}
								HStack {
									Text("analog_size", tableName: "Clock")
									Slider(value: $settingsManager.settings.clock.analogClockSize, in: 40...500, step: 5)
										.onChange(of: settingsManager.settings.clock.analogClockSize) { _, _ in
											if !isWindowDragging { saveSettings() }
										}
									Text("\(Int(settingsManager.settings.clock.analogClockSize))")
										.frame(width: 32, alignment: .trailing)
										.monospacedDigit()
								}
							}
							.padding(6)
						} label: {
							Label {
								Text("size", tableName: "Clock")
							} icon: {
								Image(systemName: "arrow.up.left.and.arrow.down.right")
							}
						}
						
					}
					.frame(maxWidth: .infinity)
				}
				
				Divider()
					.padding(.top, 12)

				// ボタン群
				HStack {
					Spacer()
					Button { resetSettings() } label: {
						Text("reset", tableName: "Clock")
					}
					.buttonStyle(.bordered)
					Spacer()
				}
				.padding(.top, 8)
			}
			.padding(16)
		}
		.frame(minWidth: 600, idealWidth: 700, minHeight: 420, idealHeight: 500)
		.onAppear {
			// 設定画面表示時：移動モードをON
			settingsManager.settings.clock.moveMode = true
			ClockWindowManager.shared.updateMoveModeFromSettings()
		}
		.onDisappear {
			// 設定画面非表示時：移動モードをOFF（メモリ上のみ、保存しない）
			settingsManager.settings.clock.moveMode = false
			ClockWindowManager.shared.updateMoveModeFromSettings()
		}
	}
	
	// MARK: - ヘルパー

	/// システムフォントの表示名キー（Pickerのtagとして使用）
	private let systemFontDisplayName = "__system_font__"

	/// 利用可能なフォント一覧（数字と日本語が表示できるもののみ）
	private var availableFonts: [String] {
		let fontFamilies = NSFontManager.shared.availableFontFamilies

		// テスト文字列（数字、英語、日本語）
		let testString = "0123456789 AaBbCc あいうえお"

		// 数字と日本語が表示できるフォントのみをフィルタ
		let filteredFonts = fontFamilies.filter { familyName in
			// フォントを取得
			guard let font = NSFont(name: familyName, size: 12) else { return false }

			// すべての文字が表示できるかチェック
			for unicodeScalar in testString.unicodeScalars {
				if !font.coveredCharacterSet.contains(unicodeScalar) {
					return false
				}
			}
			return true
		}.sorted()

		// システムフォントを先頭に追加
		return [systemFontDisplayName] + filteredFonts
	}

	/// フォント名を内部名に変換
	private func fontNameToInternal(_ displayName: String) -> String {
		return displayName == systemFontDisplayName ? ".AppleSystemUIFont" : displayName
	}

	/// 内部フォント名を表示名に変換
	private func internalFontNameToDisplay(_ internalName: String) -> String {
		return internalName == ".AppleSystemUIFont" ? systemFontDisplayName : internalName
	}
	
	/// 設定を保存してビューを更新
	private func saveSettings() {
		// 保存
		settingsManager.save()
		
		// ビューの内容だけを更新（軽量、オブザーバーは保持）
		ClockWindowManager.shared.updateView()
	}
	
	/// 設定を保存してウィンドウを再作成（サイズ変更時）
	private func saveAndRecreate() {
		// 保存
		settingsManager.save()
		
		// ウィンドウを再作成（サイズ変更を反映）
		ClockWindowManager.shared.recreate()
	}
	
	/// 設定をリセット
	private func resetSettings() {
		settingsManager.reset()
		ClockWindowManager.shared.recreate()
	}
	
	/// 位置プリセット: 左下
	private func setPositionBottomLeft() {
		let displayIndex = settingsManager.settings.clock.displayIndex
		guard displayIndex < NSScreen.screens.count else { return }
		_ = NSScreen.screens[displayIndex]
		
		settingsManager.settings.clock.positionX = 0
		settingsManager.settings.clock.positionY = 0
		saveAndRecreate()
	}
	
	/// 位置プリセット: 右下
	private func setPositionBottomRight() {
		let displayIndex = settingsManager.settings.clock.displayIndex
		guard displayIndex < NSScreen.screens.count else { return }
		let screen = NSScreen.screens[displayIndex]
		
		settingsManager.settings.clock.positionX = screen.frame.width - settingsManager.settings.clock.windowWidth
		settingsManager.settings.clock.positionY = 0
		saveAndRecreate()
	}
	
	/// 位置プリセット: 左上
	private func setPositionTopLeft() {
		let displayIndex = settingsManager.settings.clock.displayIndex
		guard displayIndex < NSScreen.screens.count else { return }
		let screen = NSScreen.screens[displayIndex]
		
		settingsManager.settings.clock.positionX = 0
		settingsManager.settings.clock.positionY = screen.frame.height - settingsManager.settings.clock.windowHeight
		saveAndRecreate()
	}
	
	/// 位置プリセット: 右上
	private func setPositionTopRight() {
		let displayIndex = settingsManager.settings.clock.displayIndex
		guard displayIndex < NSScreen.screens.count else { return }
		let screen = NSScreen.screens[displayIndex]
		
		settingsManager.settings.clock.positionX = screen.frame.width - settingsManager.settings.clock.windowWidth
		settingsManager.settings.clock.positionY = screen.frame.height - settingsManager.settings.clock.windowHeight
		saveAndRecreate()
	}
}

// MARK: - プレビュー

#Preview("Japanese") {
	ClockSettingsView()
		.frame(width: 700, height: 500)
		.environment(\.locale, Locale(identifier: "ja"))
}

#Preview("English") {
	ClockSettingsView()
		.frame(width: 700, height: 500)
		.environment(\.locale, Locale(identifier: "en"))
}

#Preview("Chinese Simplified") {
	ClockSettingsView()
		.frame(width: 700, height: 500)
		.environment(\.locale, Locale(identifier: "zh-Hans"))
}

#Preview("Chinese Traditional") {
	ClockSettingsView()
		.frame(width: 700, height: 500)
		.environment(\.locale, Locale(identifier: "zh-Hant"))
}

#Preview("Korean") {
	ClockSettingsView()
		.frame(width: 700, height: 500)
		.environment(\.locale, Locale(identifier: "ko"))
}
