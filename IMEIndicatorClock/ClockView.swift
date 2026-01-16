//
//  ClockView.swift
//  IMEIndicatorClock
//
//  Created on 2025/12/24.
//
//  時計を表示するSwiftUIビュー
//
//  【表示構造】
//  - 背景: RoundedRectangle（IME状態に応じて色が変わる）
//  - 内容: アナログ時計 or デジタル時計
//
//  【アナログ時計の場合】
//  - アナログ時計の上にテキスト（日付/時刻）をoverlayで重ねる
//  - GeometryReaderでアナログ時計のサイズを取得し、テキストを配置
//  - fixedSize()でテキストの折り返しを防止
//
//  【デジタル時計の場合】
//  - 単純なVStack/HStackでテキストを配置
//

import SwiftUI
import Combine

// MARK: - メイン時計ビュー

/// 時計全体を表示するビュー
struct ClockView: View {

	/// 設定マネージャー（監視して背景色を切り替える）
	@ObservedObject var settingsManager: AppSettingsManager

	/// 設定のスナップショット（初期化時に取得）
	private let settings: ClockSettings

	/// 現在時刻（1秒ごとに更新）
	@State private var currentTime = Date()

	/// Combineタイマー購読のキャンセル用
	@State private var timerCancellable: AnyCancellable?

	/// システムのロケール（タイムゾーン名などのローカライズに使用）
	@Environment(\.locale) var locale
	
	init(settingsManager: AppSettingsManager) {
		self.settingsManager = settingsManager
		self.settings = settingsManager.settings.clock  // スナップショットとして保存
		dbgLog(1, "🔧 ClockView init: style=\(settingsManager.settings.clock.style), position=\(settingsManager.settings.clock.dateTimePosition), analogClockSize=\(settingsManager.settings.clock.analogClockSize)")
	}

	var body: some View {
		ZStack {
			// 背景（IME状態に応じて色を切り替え）
			RoundedRectangle(cornerRadius: 10)
				.fill(currentBackgroundColor)
				.opacity(settings.backgroundOpacity)
			// アニメーションは要らない
			//				.animation(.easeInOut(duration: 0.3), value: settingsManager.isJapaneseInput)
			
			// 時計の内容
			VStack(spacing: 8) {
				clockContent(currentDate: currentTime)
			}
			.padding(16)
		}
		.onAppear {
			// Combineの Timer.publish を使用（SwiftUI推奨パターン）
			timerCancellable = Timer.publish(every: AppConstants.clockUpdateInterval, on: .main, in: .common)
				.autoconnect()
				.sink { _ in
					currentTime = Date()
				}
		}
		.onDisappear {
			// ビューが消える時にタイマー購読をキャンセル
			timerCancellable?.cancel()
			timerCancellable = nil
		}
	}
	
	/// 時計の内容を構築
	///
	/// 【表示パターン】
	/// - アナログ: 時計盤の上に日付/時刻テキストをoverlayで重ねる
	/// - デジタル: テキストのみをVStack/HStackで配置
	///
	/// 【配置パターン】
	/// - vertical: 日付（上）+ 時刻（下）を縦に配置
	/// - horizontal: 日付 + 時刻を横に配置
	/// - dateOnly: 日付のみ
	/// - timeOnly: 時刻のみ（アナログの場合は時計盤）
	///
	@ViewBuilder
	private func clockContent(currentDate: Date) -> some View {
		if settings.style == .analog {
			// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
			// アナログ時計: 時計盤の上にテキストをoverlayで重ねる
			// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
			analogClock(currentDate: currentDate)
				.overlay(
					// GeometryReaderでアナログ時計のサイズを取得
					// このサイズを使ってテキストを中央に配置する
					GeometryReader { geometry in
						// 配置パターンに応じてテキストを配置
						// ZStack + fixedSize() の組み合わせで:
						// - ZStack: テキストをアナログ時計上に重ねる
						// - fixedSize(): テキストの折り返しを防止
						// - frame(): GeometryReaderのサイズに合わせて中央配置
						if settings.dateTimePosition == .vertical {
							// 縦配置: 日付（上）+ 時刻（下）
							ZStack {
								VStack {
									dateText(currentDate: currentDate)
									Spacer()
									timeText(currentDate: currentDate)
								}
								.fixedSize()
							}
							.frame(width: geometry.size.width, height: geometry.size.height)
						} else if settings.dateTimePosition == .horizontal {
							// 横配置: 日付 + 時刻
							ZStack(alignment: .center) {
								HStack {
									dateText(currentDate: currentDate)
									timeText(currentDate: currentDate)
								}
								.fixedSize()
							}
							.frame(width: geometry.size.width, height: geometry.size.height)
						} else if settings.dateTimePosition == .dateOnly {
							// 日付のみ
							ZStack(alignment: .center) {
								dateText(currentDate: currentDate)
									.fixedSize()
							}
							.frame(width: geometry.size.width, height: geometry.size.height)
						} else {
							// 時刻のみ（timeOnly）
							ZStack(alignment: .center) {
								timeText(currentDate: currentDate)
									.fixedSize()
							}
							.frame(width: geometry.size.width, height: geometry.size.height)
						}
					}
				)
		} else {
			// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
			// デジタル時計: テキストのみをシンプルに配置
			// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
			if settings.dateTimePosition == .vertical {
				// 縦配置
				dateText(currentDate: currentDate)
				timeText(currentDate: currentDate)
			} else if settings.dateTimePosition == .horizontal {
				// 横配置
				HStack(spacing: 12) {
					dateText(currentDate: currentDate)
					timeText(currentDate: currentDate)
				}
			} else if settings.dateTimePosition == .dateOnly {
				// 日付のみ
				dateText(currentDate: currentDate)
			} else {
				// 時刻のみ
				timeText(currentDate: currentDate)
			}
		}
	}
	
	// MARK: - サブビュー
	
	/// 現在の背景色（IME状態に応じて切り替え）
	private var currentBackgroundColor: Color {
		// IMEインジケータの言語別色を使用する場合
		if settingsManager.settings.clock.useIMEIndicatorColors {
			let currentLanguage = IMEMonitor.shared.currentLanguage
			let colorComponents = settingsManager.settings.imeIndicator.color(for: currentLanguage)
			return colorComponents.color
		}

		// 独自の色設定を使用する場合
		if settingsManager.isJapaneseInput {
			return settings.backgroundColorOn.color
		} else {
			return settings.backgroundColorOff.color
		}
	}
	
	/// 日付テキスト
	private func dateText(currentDate: Date) -> some View {
		Text(formatDate(currentDate))
			.font(customFont)
			.foregroundColor(settings.textColor.color)
	}
	
	/// 時刻テキスト
	private func timeText(currentDate: Date) -> some View {
		Text(formatTime(currentDate))
			.font(customFont)
			.foregroundColor(settings.textColor.color)
	}
	
	/// カスタムフォント
	private var customFont: Font {
		if let nsFont = NSFont(name: settings.fontName, size: settings.fontSize) {
			return Font(nsFont)
		} else {
			return .system(size: settings.fontSize)
		}
	}
	
	/// アナログ時計
	///
	/// **設計ルール**: ウィンドウサイズとアナログ時計サイズは独立
	/// 詳細は `ClockDesignRules.md` を参照
	///
	private func analogClock(currentDate: Date) -> some View {
		GeometryReader { geometry in
			let size = settings.analogClockSize  // 設定サイズをそのまま使用
			let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
			
			ZStack {
				// 時計盤の外枠
				Circle()
					.stroke(settings.analogColor.color, lineWidth: size * 0.02)
				
				// 時刻の目盛り（12時間分）
				ForEach(0..<12) { hour in
					Rectangle()
						.fill(settings.analogColor.color)
						.frame(width: size * 0.02, height: size * 0.1)
						.offset(y: -size * 0.4)
						.rotationEffect(.degrees(Double(hour) * 30))
				}
				
				// 時針
				Rectangle()
					.fill(settings.analogColor.color)
					.frame(width: size * 0.04, height: size * 0.25)
					.offset(y: -size * 0.125)
					.rotationEffect(hourAngle(for: currentDate))
				
				// 分針
				Rectangle()
					.fill(settings.analogColor.color)
					.frame(width: size * 0.03, height: size * 0.35)
					.offset(y: -size * 0.175)
					.rotationEffect(minuteAngle(for: currentDate))
				
				// 秒針
				if settings.showSeconds {
					Rectangle()
						.fill(settings.analogColor.color)
						.frame(width: size * 0.01, height: size * 0.4)
						.offset(y: -size * 0.2)
						.rotationEffect(secondAngle(for: currentDate))
				}
				
				// 中央の円
				Circle()
					.fill(settings.analogColor.color)
					.frame(width: size * 0.06, height: size * 0.06)
			}
			.frame(width: size, height: size)
			.position(center)
		}
		// .clipped() は削除：ウィンドウの背景（RoundedRectangle）が自動的にクリッピングする
	}
	
	// MARK: - フォーマット関数
	
	/// 日付をフォーマット
	private func formatDate(_ date: Date) -> String {
		switch settings.dateFormatStyle {
		case .custom1:
			return DateFormatStyle.formatCustom(date, format: settings.customDateFormat1, locale: locale)
		case .custom2:
			return DateFormatStyle.formatCustom(date, format: settings.customDateFormat2, locale: locale)
		default:
			return settings.dateFormatStyle.format(date, locale: locale)
		}
	}

	/// 時刻をフォーマット
	private func formatTime(_ date: Date) -> String {
		switch settings.timeFormatStyle {
		case .custom1:
			return TimeFormatStyle.formatCustom(date, format: settings.customTimeFormat1, locale: locale)
		case .custom2:
			return TimeFormatStyle.formatCustom(date, format: settings.customTimeFormat2, locale: locale)
		default:
			return settings.timeFormatStyle.format(date, locale: locale)
		}
	}
	
	// MARK: - アナログ時計の角度計算
	
	/// 時針の角度
	private func hourAngle(for date: Date) -> Angle {
		let calendar = Calendar.current
		let hour = calendar.component(.hour, from: date)
		let minute = calendar.component(.minute, from: date)
		let degrees = Double(hour % 12) * 30 + Double(minute) * 0.5
		return .degrees(degrees)
	}
	
	/// 分針の角度
	private func minuteAngle(for date: Date) -> Angle {
		let calendar = Calendar.current
		let minute = calendar.component(.minute, from: date)
		let degrees = Double(minute) * 6
		return .degrees(degrees)
	}
	
	/// 秒針の角度
	private func secondAngle(for date: Date) -> Angle {
		let calendar = Calendar.current
		let second = calendar.component(.second, from: date)
		let degrees = Double(second) * 6
		return .degrees(degrees)
	}
}

// MARK: - プレビュー


//// アナログ時計 - 縦配置

#Preview("アナログ-縦") {
	ClockView(settingsManager: {
		let manager = AppSettingsManager.forPreview()
		manager.settings.clock.style = .analog
		manager.settings.clock.dateTimePosition = .vertical
		manager.settings.clock.analogClockSize = 200
		manager.settings.clock.fontSize = 82
		manager.settings.clock.timeFormatStyle = .complete
		manager.isJapaneseInput = false
		return manager
	}())
	.frame(width: 400, height: 300)
	//	.previewDisplayName("アナログ-縦配置")
}

#Preview("アナログ-横") {
	// アナログ時計 - 横配置
	ClockView(settingsManager: {
		let manager = AppSettingsManager.forPreview()
		manager.settings.clock.style = .analog
		manager.settings.clock.dateTimePosition = .horizontal
		manager.settings.clock.analogClockSize = 200
		manager.isJapaneseInput = false
		return manager
	}())
	.frame(width: 400, height: 300)
}
#Preview("アナログ-日") {
	// アナログ時計 - 日付のみ
	ClockView(settingsManager: {
		let manager = AppSettingsManager.forPreview()
		manager.settings.clock.style = .analog
		manager.settings.clock.dateTimePosition = .dateOnly
		manager.settings.clock.analogClockSize = 200
		manager.isJapaneseInput = false
		return manager
	}())
	.frame(width: 400, height: 300)
}

#Preview("アナログ-時") {
	// アナログ時計 - 時刻のみ
	ClockView(settingsManager: {
		let manager = AppSettingsManager.forPreview()
		manager.settings.clock.style = .analog
		manager.settings.clock.dateTimePosition = .timeOnly
		manager.settings.clock.analogClockSize = 200
		manager.isJapaneseInput = false
		return manager
	}())
	.frame(width: 400, height: 300)
}

#Preview("デジタル-縦") {
	// デジタル時計 - 縦配置
	ClockView(settingsManager: {
		let manager = AppSettingsManager.forPreview()
		manager.settings.clock.style = .digital
		manager.settings.clock.dateTimePosition = .vertical
		manager.settings.clock.fontSize = 56
		manager.isJapaneseInput = true
		return manager
	}())
	.frame(width: 500, height: 150)
}

#Preview("デジタル-横") {
	// デジタル時計 - 横配置
	ClockView(settingsManager: {
		let manager = AppSettingsManager.forPreview()
		manager.settings.clock.style = .digital
		manager.settings.clock.dateTimePosition = .horizontal
		manager.settings.clock.fontSize = 26
		manager.isJapaneseInput = false
		return manager
	}())
	.frame(width: 400, height: 100)
}

#Preview("デジタル-日") {
	// デジタル時計 - 日付のみ
	ClockView(settingsManager: {
		let manager = AppSettingsManager.forPreview()
		manager.settings.clock.style = .digital
		manager.settings.clock.dateTimePosition = .dateOnly
		manager.settings.clock.fontSize = 26
		manager.isJapaneseInput = true
		return manager
	}())
	.frame(width: 300, height: 150)
}

#Preview("デジタル-時") {
	// デジタル時計 - 時刻のみ
	ClockView(settingsManager: {
		let manager = AppSettingsManager.forPreview()
		manager.settings.clock.style = .digital
		manager.settings.clock.dateTimePosition = .timeOnly
		manager.settings.clock.fontSize = 26
		manager.isJapaneseInput = false
		return manager
	}())
	.frame(width: 400, height: 100)
}
