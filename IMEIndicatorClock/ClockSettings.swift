//
//  ClockSettings.swift
//  IMEIndicatorClock
//
//  Created on 2025/12/24.
//
//  時計機能の設定データモデル
//  設定はJSONファイルとして ~/Library/Application Support/IMEIndicatorClock/settings.json に保存されます
//

import Foundation
import SwiftUI

// MARK: - 時計設定データモデル

/// 時計の表示設定を管理する構造体
/// Codableプロトコルにより、JSONとの相互変換が可能
struct ClockSettings: Codable {
	
	// MARK: - 基本設定
	
	/// 時計を表示するかどうか
	var isVisible: Bool = true
	
	/// 時計のスタイル（アナログ/デジタル）
	var style: ClockStyle = .analog
	
	// MARK: - 位置設定
	
	/// X座標（画面左からの距離）
	var positionX: CGFloat = 2869
	
	/// Y座標（画面下からの距離）
	var positionY: CGFloat = 310
	
	/// どのディスプレイに表示するか（0: メイン、1以降: サブディスプレイ）
	var displayIndex: Int = 0
	
	// MARK: - 外観設定
	
	/// フォント名
	var fontName: String = "Helvetica"
	
	/// フォントサイズ
	var fontSize: CGFloat = 24
	
	/// テキストカラー（RGBA）
	var textColor: ColorComponents = ColorComponents(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
	
	/// アナログ時計カラー（RGBA）
	var analogColor: ColorComponents = ColorComponents(red: 0.9994240403, green: 0.9855536819, blue: 0.0, alpha: 1.0)
	
	/// 背景カラー - IME OFF時（RGBA）
	var backgroundColorOff: ColorComponents = ColorComponents(red: 0.0, green: 0.5898008943, blue: 1.0, alpha: 1.0)
	
	/// 背景カラー - IME ON時（RGBA）
	var backgroundColorOn: ColorComponents = ColorComponents(red: 1.0, green: 0.1491314173, blue: 0.0, alpha: 1.0)
	
	/// 背景の透過度（0.0〜1.0）
	var backgroundOpacity: Double = 0.6

	/// IMEインジケータの言語別色を使用するかどうか
	var useIMEIndicatorColors: Bool = false

	/// 下位互換性のための計算プロパティ
	@available(*, deprecated, message: "backgroundColorOff または backgroundColorOn を使用してください")
	var backgroundColor: ColorComponents {
		get { backgroundColorOff }
		set { backgroundColorOff = newValue }
	}
	
	// MARK: - 表示内容設定
	
	/// 秒を表示するかどうか
	var showSeconds: Bool = true
	
	/// 日付と時刻の表示位置
	var dateTimePosition: DateTimePosition = .dateTimeVertical
	
	// MARK: - インタラクション設定
	
	/// 移動モード（ドラッグで移動可能）
	/// 注: この値はファイルに保存されません（一時的な状態）
	var moveMode: Bool = false
	
	// MARK: - Codable（moveModeを除外）
	
	enum CodingKeys: String, CodingKey {
		case isVisible
		case positionX
		case positionY
		case displayIndex
		case style
		case textColor
		case analogColor
		case backgroundColorOff
		case backgroundColorOn
		case backgroundOpacity
		case useIMEIndicatorColors
		case fontName
		case showSeconds
		case dateTimePosition
		case windowWidth
		case windowHeight
		case analogClockSize
		case fontSize
		case dateFormatStyle
		case timeFormatStyle
		case customDateFormat1
		case customDateFormat2
		case customTimeFormat1
		case customTimeFormat2
		// moveMode は除外（保存しない）
	}
	
	// MARK: - サイズ設定（新規追加）
	
	/// ウィンドウの幅
	var windowWidth: CGFloat = 320
	
	/// ウィンドウの高さ
	var windowHeight: CGFloat = 220
	
	/// アナログ時計のサイズ
	var analogClockSize: CGFloat = 200
	
	// MARK: - 書式設定（新規追加）

	/// 日付の書式スタイル
	var dateFormatStyle: DateFormatStyle = .complete

	/// 時刻の書式スタイル
	var timeFormatStyle: TimeFormatStyle = .standard

	// MARK: - カスタムフォーマット

	/// カスタム日付フォーマット1
	var customDateFormat1: String = "yyyy/MM/dd E"

	/// カスタム日付フォーマット2
	var customDateFormat2: String = "M/d (EEE)"

	/// カスタム時刻フォーマット1
	var customTimeFormat1: String = "HH:mm:ss"

	/// カスタム時刻フォーマット2
	var customTimeFormat2: String = "H:mm"
}

// MARK: - 時計スタイル

/// 時計の表示スタイル
enum ClockStyle: String, Codable, CaseIterable {
	case analog = "analog"
	case digital = "digital"

	/// ローカライズ用キー（Clock.stringsで使用）
	var localizationKey: String {
		switch self {
		case .analog: return "style_analog"
		case .digital: return "style_digital"
		}
	}
}

// MARK: - 日付・時刻の表示位置

/// 日付と時刻の配置方向
enum DateTimePosition: String, Codable, CaseIterable {
	case dateTimeVertical = "date_time_vertical"     // 日付＋時刻（縦）
	case dateTimeHorizontal = "date_time_horizontal" // 日付＋時刻（横）
	case timeDateVertical = "time_date_vertical"     // 時刻＋日付（縦）
	case timeDateHorizontal = "time_date_horizontal" // 時刻＋日付（横）
	case dateOnly = "date_only"                      // 日付のみ
	case timeOnly = "time_only"                      // 時刻のみ

	// 旧値からのマイグレーション用
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let rawValue = try container.decode(String.self)
		switch rawValue {
		case "vertical", "date_time_vertical":
			self = .dateTimeVertical
		case "horizontal", "date_time_horizontal":
			self = .dateTimeHorizontal
		case "time_date_vertical":
			self = .timeDateVertical
		case "time_date_horizontal":
			self = .timeDateHorizontal
		case "date_only":
			self = .dateOnly
		case "time_only":
			self = .timeOnly
		default:
			self = .dateTimeVertical
		}
	}

	/// ローカライズ用キー（Clock.stringsで使用）
	var localizationKey: String {
		switch self {
		case .dateTimeVertical: return "position_date_time_vertical"
		case .dateTimeHorizontal: return "position_date_time_horizontal"
		case .timeDateVertical: return "position_time_date_vertical"
		case .timeDateHorizontal: return "position_time_date_horizontal"
		case .dateOnly: return "position_date_only"
		case .timeOnly: return "position_time_only"
		}
	}
}

// MARK: - 日付の書式スタイル

/// DateFormatterのキャッシュ（毎秒の時計更新で再生成を防ぐ）
private enum DateFormatterCache {
	/// dateStyle/timeStyle ベースのフォーマッターキャッシュ
	/// キー: "date_{rawValue}" または "time_{rawValue}"
	private static var styleCache: [String: DateFormatter] = [:]

	/// カスタムフォーマット文字列ベースのフォーマッターキャッシュ
	/// キー: "{locale}_{formatString}"
	private static var customCache: [String: DateFormatter] = [:]

	/// dateStyle指定のフォーマッターを取得（キャッシュあり）
	static func formatter(dateStyle: DateFormatter.Style, locale: Locale) -> DateFormatter {
		let key = "date_\(dateStyle.rawValue)_\(locale.identifier)"
		if let cached = styleCache[key] { return cached }
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.dateStyle = dateStyle
		styleCache[key] = formatter
		return formatter
	}

	/// timeStyle指定のフォーマッターを取得（キャッシュあり）
	static func formatter(timeStyle: DateFormatter.Style, locale: Locale) -> DateFormatter {
		let key = "time_\(timeStyle.rawValue)_\(locale.identifier)"
		if let cached = styleCache[key] { return cached }
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.timeStyle = timeStyle
		styleCache[key] = formatter
		return formatter
	}

	/// カスタムフォーマット文字列のフォーマッターを取得（キャッシュあり）
	static func formatter(customFormat: String, locale: Locale) -> DateFormatter {
		let key = "\(locale.identifier)_\(customFormat)"
		if let cached = customCache[key] { return cached }
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.dateFormat = customFormat
		customCache[key] = formatter
		return formatter
	}
}

/// 日付の表示書式（標準4種 + カスタム2種）
enum DateFormatStyle: String, Codable, CaseIterable {
	case numeric = "numeric"           // 数値のみ
	case abbreviated = "abbreviated"   // 省略形
	case long = "long"                 // 長い形式
	case complete = "complete"         // 完全形式
	case custom1 = "custom1"           // カスタム1
	case custom2 = "custom2"           // カスタム2

	/// ローカライズ用キー
	var localizationKey: String {
		switch self {
		case .numeric: return "date_format_numeric"
		case .abbreviated: return "date_format_abbreviated"
		case .long: return "date_format_long"
		case .complete: return "date_format_complete"
		case .custom1: return "date_format_custom1"
		case .custom2: return "date_format_custom2"
		}
	}

	/// 標準フォーマットかどうか
	var isStandard: Bool {
		switch self {
		case .numeric, .abbreviated, .long, .complete:
			return true
		case .custom1, .custom2:
			return false
		}
	}

	/// 標準フォーマットのみ
	static var standardCases: [DateFormatStyle] {
		[.numeric, .abbreviated, .long, .complete]
	}

	/// カスタムフォーマットのみ
	static var customCases: [DateFormatStyle] {
		[.custom1, .custom2]
	}

	/// 日付をフォーマット（標準形式用）
	func format(_ date: Date, locale: Locale = .current) -> String {
		switch self {
		case .numeric:
			// 2026/1/9 (en: 1/9/26)
			return DateFormatterCache.formatter(dateStyle: .short, locale: locale).string(from: date)
		case .abbreviated:
			// Jan 9, 2026 (ja: 2026/01/09)
			return DateFormatterCache.formatter(dateStyle: .medium, locale: locale).string(from: date)
		case .long:
			// January 9, 2026 (ja: 2026年1月9日)
			return DateFormatterCache.formatter(dateStyle: .long, locale: locale).string(from: date)
		case .complete:
			// Thursday, January 9, 2026 (ja: 2026年1月9日木曜日)
			return DateFormatterCache.formatter(dateStyle: .full, locale: locale).string(from: date)
		case .custom1, .custom2:
			// カスタムはClockSettingsから取得する必要があるため空文字
			return ""
		}
	}

	/// カスタムフォーマット文字列で日付をフォーマット
	static func formatCustom(_ date: Date, format: String, locale: Locale = .current) -> String {
		return DateFormatterCache.formatter(customFormat: format, locale: locale).string(from: date)
	}
}

// MARK: - 時刻の書式スタイル

/// 時刻の表示書式（標準3種 + カスタム2種）
enum TimeFormatStyle: String, Codable, CaseIterable {
	case standard = "standard"        // 秒あり (12:34:56)
	case shortened = "shortened"      // 秒なし (12:34)
	case complete = "complete"        // タイムゾーン付き
	case custom1 = "custom1"          // カスタム1
	case custom2 = "custom2"          // カスタム2

	/// ローカライズ用キー
	var localizationKey: String {
		switch self {
		case .standard: return "time_format_standard"
		case .shortened: return "time_format_shortened"
		case .complete: return "time_format_complete"
		case .custom1: return "time_format_custom1"
		case .custom2: return "time_format_custom2"
		}
	}

	/// 標準フォーマットかどうか
	var isStandard: Bool {
		switch self {
		case .standard, .shortened, .complete:
			return true
		case .custom1, .custom2:
			return false
		}
	}

	/// 標準フォーマットのみ
	static var standardCases: [TimeFormatStyle] {
		[.standard, .shortened, .complete]
	}

	/// カスタムフォーマットのみ
	static var customCases: [TimeFormatStyle] {
		[.custom1, .custom2]
	}

	/// 時刻をフォーマット（標準形式用）
	func format(_ date: Date, locale: Locale = .current) -> String {
		switch self {
		case .standard:
			// 12:34:56
			return DateFormatterCache.formatter(timeStyle: .medium, locale: locale).string(from: date)
		case .shortened:
			// 12:34
			return DateFormatterCache.formatter(timeStyle: .short, locale: locale).string(from: date)
		case .complete:
			// 12:34:56 JST
			return DateFormatterCache.formatter(timeStyle: .long, locale: locale).string(from: date)
		case .custom1, .custom2:
			// カスタムはClockSettingsから取得する必要があるため空文字
			return ""
		}
	}

	/// カスタムフォーマット文字列で時刻をフォーマット
	static func formatCustom(_ date: Date, format: String, locale: Locale = .current) -> String {
		return DateFormatterCache.formatter(customFormat: format, locale: locale).string(from: date)
	}
}

// MARK: - カラーコンポーネント

/// 色情報をJSON保存可能な形式で保持する構造体
struct ColorComponents: Codable {
	var red: Double
	var green: Double
	var blue: Double
	var alpha: Double
	
	/// SwiftUIのColorに変換
	var color: Color {
		Color(red: red, green: green, blue: blue, opacity: alpha)
	}
	
	/// NSColorから生成
	init(nsColor: NSColor) {
		// NSColorをRGBカラースペースに変換
		guard let rgbColor = nsColor.usingColorSpace(.deviceRGB) ?? nsColor.usingColorSpace(.genericRGB) else {
			// 変換失敗時はデフォルト値（白）
			self.red = 1.0
			self.green = 1.0
			self.blue = 1.0
			self.alpha = 1.0
			return
		}
		
		self.red = Double(rgbColor.redComponent)
		self.green = Double(rgbColor.greenComponent)
		self.blue = Double(rgbColor.blueComponent)
		self.alpha = Double(rgbColor.alphaComponent)
	}
	
	/// RGBA値で直接初期化
	init(red: Double, green: Double, blue: Double, alpha: Double) {
		self.red = red
		self.green = green
		self.blue = blue
		self.alpha = alpha
	}
	
	/// NSColorに変換
	var nsColor: NSColor {
		NSColor(red: red, green: green, blue: blue, alpha: alpha)
	}
}


