//
//  IMEIndicatorSettingsView.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/06.
//
//  IMEインジケータ設定ウィンドウのSwiftUI UI
//

import SwiftUI

// MARK: - IMEインジケータ設定ビュー

struct IMEIndicatorSettingsView: View {

	// 設定マネージャーを監視（リアルタイム反映）
	@ObservedObject private var appSettings = AppSettingsManager.shared

	/// 設定へのショートカット
	private var settings: IMEIndicatorSettings {
		get { appSettings.settings.imeIndicator }
	}

	// 色選択用の一時変数
	@State private var selectedEnglishColor: Color
	@State private var selectedJapaneseColor: Color
	@State private var selectedChineseSimplifiedColor: Color
	@State private var selectedChineseTraditionalColor: Color
	@State private var selectedKoreanColor: Color
	@State private var selectedThaiColor: Color
	@State private var selectedVietnameseColor: Color
	@State private var selectedArabicColor: Color
	@State private var selectedHebrewColor: Color
	@State private var selectedHindiColor: Color
	@State private var selectedRussianColor: Color
	@State private var selectedGreekColor: Color
	@State private var selectedMongolianColor: Color
	@State private var selectedMyanmarColor: Color
	@State private var selectedKhmerColor: Color
	@State private var selectedLaoColor: Color
	@State private var selectedBengaliColor: Color
	@State private var selectedTamilColor: Color
	@State private var selectedTeluguColor: Color
	@State private var selectedNepaliColor: Color
	@State private var selectedSinhalaColor: Color
	@State private var selectedPersianColor: Color
	@State private var selectedUkrainianColor: Color
	@State private var selectedOtherColor: Color

	// 無限ループ防止フラグ
	@State private var isUpdatingFromExternal = false

	init() {
		let imeSettings = AppSettingsManager.shared.settings.imeIndicator
		_selectedEnglishColor = State(initialValue: imeSettings.englishColor.color)
		_selectedJapaneseColor = State(initialValue: imeSettings.japaneseColor.color)
		_selectedChineseSimplifiedColor = State(initialValue: imeSettings.chineseSimplifiedColor.color)
		_selectedChineseTraditionalColor = State(initialValue: imeSettings.chineseTraditionalColor.color)
		_selectedKoreanColor = State(initialValue: imeSettings.koreanColor.color)
		_selectedThaiColor = State(initialValue: imeSettings.thaiColor.color)
		_selectedVietnameseColor = State(initialValue: imeSettings.vietnameseColor.color)
		_selectedArabicColor = State(initialValue: imeSettings.arabicColor.color)
		_selectedHebrewColor = State(initialValue: imeSettings.hebrewColor.color)
		_selectedHindiColor = State(initialValue: imeSettings.hindiColor.color)
		_selectedRussianColor = State(initialValue: imeSettings.russianColor.color)
		_selectedGreekColor = State(initialValue: imeSettings.greekColor.color)
		_selectedMongolianColor = State(initialValue: imeSettings.mongolianColor.color)
		_selectedMyanmarColor = State(initialValue: imeSettings.myanmarColor.color)
		_selectedKhmerColor = State(initialValue: imeSettings.khmerColor.color)
		_selectedLaoColor = State(initialValue: imeSettings.laoColor.color)
		_selectedBengaliColor = State(initialValue: imeSettings.bengaliColor.color)
		_selectedTamilColor = State(initialValue: imeSettings.tamilColor.color)
		_selectedTeluguColor = State(initialValue: imeSettings.teluguColor.color)
		_selectedNepaliColor = State(initialValue: imeSettings.nepaliColor.color)
		_selectedSinhalaColor = State(initialValue: imeSettings.sinhalaColor.color)
		_selectedPersianColor = State(initialValue: imeSettings.persianColor.color)
		_selectedUkrainianColor = State(initialValue: imeSettings.ukrainianColor.color)
		_selectedOtherColor = State(initialValue: imeSettings.otherColor.color)
		dbgLog(1, "🟢 [IMEIndicatorSettingsView] init が呼ばれました")
	}

	var body: some View {
		ScrollView {
			VStack(spacing: 0) {
				HStack(alignment: .top, spacing: 40) {
					// 左カラム
					VStack(alignment: .leading, spacing: 20) {

						// タイトル
						HStack {
							Image(systemName: "character.textbox")
								.font(.system(size: 30))
								.foregroundColor(.blue)
							Text("title", tableName: "IMEIndicator")
								.font(.title)
								.fontWeight(.bold)
						}
						.padding(.bottom, 10)

						// 基本設定
						GroupBox {
							VStack(alignment: .leading, spacing: 12) {

								// 表示ON/OFF
								Toggle(isOn: $appSettings.settings.imeIndicator.isVisible) {
									Text("show_indicator", tableName: "IMEIndicator")
								}
								.onChange(of: appSettings.settings.imeIndicator.isVisible) { _, _ in
									saveSettings()
								}

								// 移動モードの説明
								HStack {
									Image(systemName: "hand.point.up.left.fill")
										.foregroundColor(.blue)
									Text("drag_hint", tableName: "IMEIndicator")
										.font(.callout)
										.foregroundColor(.secondary)
								}
								.padding(.vertical, 4)
							}
							.padding(8)
						} label: {
							Label {
								Text("basic", tableName: "IMEIndicator")
							} icon: {
								Image(systemName: "gearshape")
							}
						}

						// サイズ設定
						GroupBox {
							VStack(alignment: .leading, spacing: 12) {

								// インジケータサイズ（無段階）
								VStack(alignment: .leading, spacing: 8) {
									HStack {
										Text("indicator_size", tableName: "IMEIndicator")
										Spacer()
										Text("\(Int(appSettings.settings.imeIndicator.indicatorSize)) px")
											.monospacedDigit()
											.foregroundColor(.secondary)
									}

									Slider(value: $appSettings.settings.imeIndicator.indicatorSize, in: 30...200, step: 5)
									.onChange(of: appSettings.settings.imeIndicator.indicatorSize) { _, _ in
										saveSettings()
									}

									// プリセットボタン
									HStack(spacing: 8) {
										Button {
											appSettings.settings.imeIndicator.indicatorSize = 40
											saveSettings()
										} label: {
											Text("size_small", tableName: "IMEIndicator")
										}
										.buttonStyle(.bordered)
										Button {
											appSettings.settings.imeIndicator.indicatorSize = 60
											saveSettings()
										} label: {
											Text("size_medium", tableName: "IMEIndicator")
										}
										.buttonStyle(.bordered)
										Button {
											appSettings.settings.imeIndicator.indicatorSize = 80
											saveSettings()
										} label: {
											Text("size_large", tableName: "IMEIndicator")
										}
										.buttonStyle(.bordered)
										Button {
											appSettings.settings.imeIndicator.indicatorSize = 100
											saveSettings()
										} label: {
											Text("size_xlarge", tableName: "IMEIndicator")
										}
										.buttonStyle(.bordered)
									}
									.font(.caption)
								}

								Divider()
									.padding(.vertical, 4)

								// フォントサイズ（比率）
								VStack(alignment: .leading, spacing: 8) {
									HStack {
										Text("text_size", tableName: "IMEIndicator")
										Spacer()
										Text("\(Int(appSettings.settings.imeIndicator.fontSizeRatio * 100))%")
											.monospacedDigit()
											.foregroundColor(.secondary)
									}

									Slider(value: $appSettings.settings.imeIndicator.fontSizeRatio, in: 0.3...0.8, step: 0.05)
									.onChange(of: appSettings.settings.imeIndicator.fontSizeRatio) { _, _ in
										saveSettings()
									}

									// プリセットボタン
									HStack(spacing: 8) {
										Button {
											appSettings.settings.imeIndicator.fontSizeRatio = 0.4
											saveSettings()
										} label: {
											Text("text_small", tableName: "IMEIndicator")
										}
										.buttonStyle(.bordered)
										Button {
											appSettings.settings.imeIndicator.fontSizeRatio = 0.5
											saveSettings()
										} label: {
											Text("text_normal", tableName: "IMEIndicator")
										}
										.buttonStyle(.bordered)
										Button {
											appSettings.settings.imeIndicator.fontSizeRatio = 0.6
											saveSettings()
										} label: {
											Text("text_large", tableName: "IMEIndicator")
										}
										.buttonStyle(.bordered)
									}
									.font(.caption)
								}
							}
							.padding(8)
						} label: {
							Label {
								Text("size", tableName: "IMEIndicator")
							} icon: {
								Image(systemName: "arrow.up.left.and.arrow.down.right")
							}
						}

						// 位置設定
						GroupBox {
							VStack(alignment: .leading, spacing: 12) {

								// X座標
								HStack {
									Text("position_x", tableName: "IMEIndicator")
										.frame(width: 80, alignment: .leading)
									TextField("", text: Binding(
										get: { String(format: "%.0f", appSettings.settings.imeIndicator.positionX) },
										set: { newValue in
											guard !isUpdatingFromExternal else { return }
											if let value = Double(newValue) {
												appSettings.settings.imeIndicator.positionX = CGFloat(value)
												saveSettings()
											}
										}
									))
									.textFieldStyle(.roundedBorder)
									.frame(width: 100)
									Text("unit_pixels", tableName: "IMEIndicator")
										.foregroundColor(.secondary)
								}

								// Y座標
								HStack {
									Text("position_y", tableName: "IMEIndicator")
										.frame(width: 80, alignment: .leading)
									TextField("", text: Binding(
										get: { String(format: "%.0f", appSettings.settings.imeIndicator.positionY) },
										set: { newValue in
											guard !isUpdatingFromExternal else { return }
											if let value = Double(newValue) {
												appSettings.settings.imeIndicator.positionY = CGFloat(value)
												saveSettings()
											}
										}
									))
									.textFieldStyle(.roundedBorder)
									.frame(width: 100)
									Text("unit_pixels", tableName: "IMEIndicator")
										.foregroundColor(.secondary)
								}

								// ディスプレイ選択
								HStack {
									Text("display", tableName: "IMEIndicator")
										.frame(width: 80, alignment: .leading)
									Picker("", selection: $appSettings.settings.imeIndicator.displayIndex) {
										ForEach(0..<NSScreen.screens.count, id: \.self) { index in
											Text("display_number \(index + 1)", tableName: "IMEIndicator").tag(index)
										}
									}
									.labelsHidden()
									.onChange(of: appSettings.settings.imeIndicator.displayIndex) { _, _ in
										// ディスプレイ変更時は左下に配置
										setPositionBottomLeft()
									}
								}

								// プリセット位置ボタン
								HStack(spacing: 10) {
									Button { setPositionBottomLeft() } label: {
										Text("bottom_left", tableName: "IMEIndicator")
									}
									.buttonStyle(.bordered)
									Button { setPositionBottomRight() } label: {
										Text("bottom_right", tableName: "IMEIndicator")
									}
									.buttonStyle(.bordered)
									Button { setPositionTopLeft() } label: {
										Text("top_left", tableName: "IMEIndicator")
									}
									.buttonStyle(.bordered)
									Button { setPositionTopRight() } label: {
										Text("top_right", tableName: "IMEIndicator")
									}
									.buttonStyle(.bordered)
								}
							}
							.padding(8)
						} label: {
							Label {
								Text("position", tableName: "IMEIndicator")
							} icon: {
								Image(systemName: "move.3d")
							}
						}
					}
					.frame(maxWidth: .infinity)

					// 右カラム
					VStack(alignment: .leading, spacing: 20) {

						// 言語別設定（テキストと色）
						GroupBox {
							VStack(alignment: .leading, spacing: 8) {

								// ヘッダー行
								HStack {
									Text("")
										.frame(width: 140, alignment: .leading)
									Text("text_label", tableName: "IMEIndicator")
										.font(.caption)
										.foregroundColor(.secondary)
										.frame(width: 50)
									Text("color_label", tableName: "IMEIndicator")
										.font(.caption)
										.foregroundColor(.secondary)
										.frame(width: 50)
								}

								Divider()

								// 言語リスト（スクロール可能）
								ScrollView {
									VStack(alignment: .leading, spacing: 6) {
										// 英語
										languageRow(
											label: "lang_english",
											text: $appSettings.settings.imeIndicator.englishText,
											color: $selectedEnglishColor,
											onColorChange: { appSettings.settings.imeIndicator.englishColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// 日本語
										languageRow(
											label: "lang_japanese",
											text: $appSettings.settings.imeIndicator.japaneseText,
											color: $selectedJapaneseColor,
											onColorChange: { appSettings.settings.imeIndicator.japaneseColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// 中国語（簡体字）
										languageRow(
											label: "lang_chinese_simplified",
											text: $appSettings.settings.imeIndicator.chineseSimplifiedText,
											color: $selectedChineseSimplifiedColor,
											onColorChange: { appSettings.settings.imeIndicator.chineseSimplifiedColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// 中国語（繁体字）
										languageRow(
											label: "lang_chinese_traditional",
											text: $appSettings.settings.imeIndicator.chineseTraditionalText,
											color: $selectedChineseTraditionalColor,
											onColorChange: { appSettings.settings.imeIndicator.chineseTraditionalColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// 韓国語
										languageRow(
											label: "lang_korean",
											text: $appSettings.settings.imeIndicator.koreanText,
											color: $selectedKoreanColor,
											onColorChange: { appSettings.settings.imeIndicator.koreanColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// タイ語
										languageRow(
											label: "lang_thai",
											text: $appSettings.settings.imeIndicator.thaiText,
											color: $selectedThaiColor,
											onColorChange: { appSettings.settings.imeIndicator.thaiColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// ベトナム語
										languageRow(
											label: "lang_vietnamese",
											text: $appSettings.settings.imeIndicator.vietnameseText,
											color: $selectedVietnameseColor,
											onColorChange: { appSettings.settings.imeIndicator.vietnameseColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// アラビア語
										languageRow(
											label: "lang_arabic",
											text: $appSettings.settings.imeIndicator.arabicText,
											color: $selectedArabicColor,
											onColorChange: { appSettings.settings.imeIndicator.arabicColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// ヘブライ語
										languageRow(
											label: "lang_hebrew",
											text: $appSettings.settings.imeIndicator.hebrewText,
											color: $selectedHebrewColor,
											onColorChange: { appSettings.settings.imeIndicator.hebrewColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// ヒンディー語
										languageRow(
											label: "lang_hindi",
											text: $appSettings.settings.imeIndicator.hindiText,
											color: $selectedHindiColor,
											onColorChange: { appSettings.settings.imeIndicator.hindiColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// ロシア語
										languageRow(
											label: "lang_russian",
											text: $appSettings.settings.imeIndicator.russianText,
											color: $selectedRussianColor,
											onColorChange: { appSettings.settings.imeIndicator.russianColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// ギリシャ語
										languageRow(
											label: "lang_greek",
											text: $appSettings.settings.imeIndicator.greekText,
											color: $selectedGreekColor,
											onColorChange: { appSettings.settings.imeIndicator.greekColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// モンゴル語
										languageRow(
											label: "lang_mongolian",
											text: $appSettings.settings.imeIndicator.mongolianText,
											color: $selectedMongolianColor,
											onColorChange: { appSettings.settings.imeIndicator.mongolianColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// ミャンマー語
										languageRow(
											label: "lang_myanmar",
											text: $appSettings.settings.imeIndicator.myanmarText,
											color: $selectedMyanmarColor,
											onColorChange: { appSettings.settings.imeIndicator.myanmarColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// クメール語
										languageRow(
											label: "lang_khmer",
											text: $appSettings.settings.imeIndicator.khmerText,
											color: $selectedKhmerColor,
											onColorChange: { appSettings.settings.imeIndicator.khmerColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// ラオス語
										languageRow(
											label: "lang_lao",
											text: $appSettings.settings.imeIndicator.laoText,
											color: $selectedLaoColor,
											onColorChange: { appSettings.settings.imeIndicator.laoColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// ベンガル語
										languageRow(
											label: "lang_bengali",
											text: $appSettings.settings.imeIndicator.bengaliText,
											color: $selectedBengaliColor,
											onColorChange: { appSettings.settings.imeIndicator.bengaliColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// タミル語
										languageRow(
											label: "lang_tamil",
											text: $appSettings.settings.imeIndicator.tamilText,
											color: $selectedTamilColor,
											onColorChange: { appSettings.settings.imeIndicator.tamilColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// テルグ語
										languageRow(
											label: "lang_telugu",
											text: $appSettings.settings.imeIndicator.teluguText,
											color: $selectedTeluguColor,
											onColorChange: { appSettings.settings.imeIndicator.teluguColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// ネパール語
										languageRow(
											label: "lang_nepali",
											text: $appSettings.settings.imeIndicator.nepaliText,
											color: $selectedNepaliColor,
											onColorChange: { appSettings.settings.imeIndicator.nepaliColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// シンハラ語
										languageRow(
											label: "lang_sinhala",
											text: $appSettings.settings.imeIndicator.sinhalaText,
											color: $selectedSinhalaColor,
											onColorChange: { appSettings.settings.imeIndicator.sinhalaColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// ペルシア語
										languageRow(
											label: "lang_persian",
											text: $appSettings.settings.imeIndicator.persianText,
											color: $selectedPersianColor,
											onColorChange: { appSettings.settings.imeIndicator.persianColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// ウクライナ語
										languageRow(
											label: "lang_ukrainian",
											text: $appSettings.settings.imeIndicator.ukrainianText,
											color: $selectedUkrainianColor,
											onColorChange: { appSettings.settings.imeIndicator.ukrainianColor = ColorComponents(nsColor: NSColor($0)) }
										)

										// その他のIME
										languageRow(
											label: "lang_other",
											text: $appSettings.settings.imeIndicator.otherText,
											color: $selectedOtherColor,
											onColorChange: { appSettings.settings.imeIndicator.otherColor = ColorComponents(nsColor: NSColor($0)) }
										)
									}
								}
								// ウィンドウサイズに追従（最小高さを設定）
								.frame(minHeight: 150, maxHeight: .infinity)

								Divider()
									.padding(.vertical, 4)

								// フォント選択
								HStack {
									Text("font", tableName: "IMEIndicator")
										.frame(width: 140, alignment: .leading)
									Picker("", selection: $appSettings.settings.imeIndicator.fontName) {
										Text("system_font", tableName: "IMEIndicator").tag(".AppleSystemUIFont")
										Divider()
										ForEach(availableJapaneseFonts(), id: \.self) { fontName in
											Text(fontName)
												.font(.custom(fontName, size: 12))
												.tag(fontName)
										}
									}
									.labelsHidden()
									.frame(maxWidth: 180)
									.onChange(of: appSettings.settings.imeIndicator.fontName) { _, _ in
										saveSettings()
									}
								}
							}
							.padding(8)
						} label: {
							Label {
								Text("language_settings", tableName: "IMEIndicator")
							} icon: {
								Image(systemName: "globe")
							}
						}

						// 外観設定
						GroupBox {
							VStack(alignment: .leading, spacing: 12) {
								// 不透明度
								HStack {
									Text("opacity", tableName: "IMEIndicator")
										.frame(width: 100, alignment: .leading)
									Slider(value: $appSettings.settings.imeIndicator.backgroundOpacity, in: 0.1...1, step: 0.05)
									.onChange(of: appSettings.settings.imeIndicator.backgroundOpacity) { _, _ in
										saveSettings()
									}
									Text("\(Int(appSettings.settings.imeIndicator.backgroundOpacity * 100))%")
										.frame(width: 50, alignment: .trailing)
										.monospacedDigit()
								}
							}
							.padding(8)
						} label: {
							Label {
								Text("color", tableName: "IMEIndicator")
							} icon: {
								Image(systemName: "paintpalette")
							}
						}
					}
					.frame(maxWidth: .infinity)
				}

				Divider()
					.padding(.top, 20)

				// リセットボタンのみ
				HStack {
					Button {
						resetSettings()
					} label: {
						Text("reset", tableName: "IMEIndicator")
					}
					.buttonStyle(.bordered)
				}
				.padding(.top, 10)
			}
			.padding(20)
		}
		.frame(minWidth: 700, idealWidth: 800, minHeight: 500, idealHeight: 600)
		.onAppear {
			// 設定画面表示時：移動モードをON
			appSettings.settings.imeIndicator.moveMode = true
			NotificationCenter.default.post(name: .imeIndicatorSettingsChanged, object: nil)
			dbgLog(1, "📱 [IMEIndicatorSettingsView] 表示：移動モードON")
		}
		.onDisappear {
			// 設定画面非表示時：移動モードをOFF（メモリ上のみ、保存しない）
			appSettings.settings.imeIndicator.moveMode = false
			// 設定を明示的に保存
			appSettings.save()
			NotificationCenter.default.post(name: .imeIndicatorSettingsChanged, object: nil)
			dbgLog(1, "📱 [IMEIndicatorSettingsView] 非表示：移動モードOFF、設定保存完了")
		}
	}

	// MARK: - ヘルパー

	/// 言語別設定行を生成
	@ViewBuilder
	private func languageRow(
		label: String,
		text: Binding<String>,
		color: Binding<Color>,
		onColorChange: @escaping (Color) -> Void
	) -> some View {
		HStack {
			Text(LocalizedStringKey(label), tableName: "IMEIndicator")
				.frame(width: 140, alignment: .leading)
			TextField("", text: text)
				.textFieldStyle(.roundedBorder)
				.frame(width: 50)
				.onChange(of: text.wrappedValue) { _, _ in
					saveSettings()
				}
			ColorPicker("", selection: color)
				.labelsHidden()
				.onChange(of: color.wrappedValue) { _, newValue in
					onColorChange(newValue)
					saveSettings()
				}
		}
	}

	/// 日本語が使えるフォントのリストを取得
	private func availableJapaneseFonts() -> [String] {
		let fontFamilies = NSFontManager.shared.availableFontFamilies

		// 日本語テキスト設定値を使って判定（デフォルトは「あ」）
		let testString = appSettings.settings.imeIndicator.japaneseText.isEmpty ? "あ" : appSettings.settings.imeIndicator.japaneseText

		// 設定されたテキストが表示できるフォントのみをフィルタ
		return fontFamilies.filter { familyName in
			// フォントを取得
			guard let font = NSFont(name: familyName, size: 12) else { return false }

			// 設定されたテキストの最初の文字が表示できるかチェック
			guard let unicodeScalar = testString.unicodeScalars.first else { return false }

			// フォントが指定文字をサポートしているか確認
			return font.coveredCharacterSet.contains(unicodeScalar)
		}.sorted()
	}

	/// 設定を保存して通知（リアルタイム保存）
	private func saveSettings() {
		// 無限ループ防止：外部からの更新中はスキップ
		guard !appSettings.isWindowDragging else { return }

		// 設定を保存
		appSettings.save()

		// AppDelegateに通知して表示を更新
		NotificationCenter.default.post(name: .imeIndicatorSettingsChanged, object: nil)
	}

	/// 設定をリセット
	private func resetSettings() {
		appSettings.settings.imeIndicator = IMEIndicatorSettings()
		appSettings.save()
		// 全言語の色をリセット
		selectedEnglishColor = appSettings.settings.imeIndicator.englishColor.color
		selectedJapaneseColor = appSettings.settings.imeIndicator.japaneseColor.color
		selectedChineseSimplifiedColor = appSettings.settings.imeIndicator.chineseSimplifiedColor.color
		selectedChineseTraditionalColor = appSettings.settings.imeIndicator.chineseTraditionalColor.color
		selectedKoreanColor = appSettings.settings.imeIndicator.koreanColor.color
		selectedThaiColor = appSettings.settings.imeIndicator.thaiColor.color
		selectedVietnameseColor = appSettings.settings.imeIndicator.vietnameseColor.color
		selectedArabicColor = appSettings.settings.imeIndicator.arabicColor.color
		selectedHebrewColor = appSettings.settings.imeIndicator.hebrewColor.color
		selectedHindiColor = appSettings.settings.imeIndicator.hindiColor.color
		selectedRussianColor = appSettings.settings.imeIndicator.russianColor.color
		selectedGreekColor = appSettings.settings.imeIndicator.greekColor.color
		selectedMongolianColor = appSettings.settings.imeIndicator.mongolianColor.color
		selectedMyanmarColor = appSettings.settings.imeIndicator.myanmarColor.color
		selectedKhmerColor = appSettings.settings.imeIndicator.khmerColor.color
		selectedLaoColor = appSettings.settings.imeIndicator.laoColor.color
		selectedBengaliColor = appSettings.settings.imeIndicator.bengaliColor.color
		selectedTamilColor = appSettings.settings.imeIndicator.tamilColor.color
		selectedTeluguColor = appSettings.settings.imeIndicator.teluguColor.color
		selectedNepaliColor = appSettings.settings.imeIndicator.nepaliColor.color
		selectedSinhalaColor = appSettings.settings.imeIndicator.sinhalaColor.color
		selectedPersianColor = appSettings.settings.imeIndicator.persianColor.color
		selectedUkrainianColor = appSettings.settings.imeIndicator.ukrainianColor.color
		selectedOtherColor = appSettings.settings.imeIndicator.otherColor.color
		saveSettings()
	}

	/// 位置プリセット: 左下
	private func setPositionBottomLeft() {
		let displayIndex = appSettings.settings.imeIndicator.displayIndex
		guard displayIndex < NSScreen.screens.count else { return }
		let screen = NSScreen.screens[displayIndex]
		let visible = screen.visibleFrame
		let margin: CGFloat = 20

		appSettings.settings.imeIndicator.positionX = (visible.origin.x - screen.frame.origin.x) + margin
		appSettings.settings.imeIndicator.positionY = (visible.origin.y - screen.frame.origin.y) + margin
		saveSettings()
	}

	/// 位置プリセット: 右下
	private func setPositionBottomRight() {
		let displayIndex = appSettings.settings.imeIndicator.displayIndex
		guard displayIndex < NSScreen.screens.count else { return }
		let screen = NSScreen.screens[displayIndex]
		let visible = screen.visibleFrame
		let margin: CGFloat = 20

		appSettings.settings.imeIndicator.positionX = (visible.origin.x - screen.frame.origin.x) + visible.width - appSettings.settings.imeIndicator.indicatorSize - margin
		appSettings.settings.imeIndicator.positionY = (visible.origin.y - screen.frame.origin.y) + margin
		saveSettings()
	}

	/// 位置プリセット: 左上
	private func setPositionTopLeft() {
		let displayIndex = appSettings.settings.imeIndicator.displayIndex
		guard displayIndex < NSScreen.screens.count else { return }
		let screen = NSScreen.screens[displayIndex]
		let visible = screen.visibleFrame
		let margin: CGFloat = 20

		appSettings.settings.imeIndicator.positionX = (visible.origin.x - screen.frame.origin.x) + margin
		appSettings.settings.imeIndicator.positionY = (visible.origin.y - screen.frame.origin.y) + visible.height - appSettings.settings.imeIndicator.indicatorSize - margin
		saveSettings()
	}

	/// 位置プリセット: 右上
	private func setPositionTopRight() {
		let displayIndex = appSettings.settings.imeIndicator.displayIndex
		guard displayIndex < NSScreen.screens.count else { return }
		let screen = NSScreen.screens[displayIndex]
		let visible = screen.visibleFrame
		let margin: CGFloat = 20

		appSettings.settings.imeIndicator.positionX = (visible.origin.x - screen.frame.origin.x) + visible.width - appSettings.settings.imeIndicator.indicatorSize - margin
		appSettings.settings.imeIndicator.positionY = (visible.origin.y - screen.frame.origin.y) + visible.height - appSettings.settings.imeIndicator.indicatorSize - margin
		saveSettings()
	}
}

// MARK: - プレビュー

/// プレビュー用の言語切り替えラッパー
private struct IMEIndicatorSettingsPreview: View {
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
			IMEIndicatorSettingsView()
				.environment(\.locale, Locale(identifier: selectedLocale))
		}
		.frame(width: 800, height: 680)
	}
}

#Preview("IME Indicator Settings") {
	IMEIndicatorSettingsPreview()
}
