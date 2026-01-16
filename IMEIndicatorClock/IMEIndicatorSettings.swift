//
//  IMEIndicatorSettings.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/06.
//
//  IMEインジケータ設定データモデル
//  設定はJSONファイルとして ~/Library/Application Support/IMEIndicatorClock/ime_settings.json に保存されます
//

import Foundation
import SwiftUI

// MARK: - IMEインジケータ設定データモデル

/// IMEインジケータの表示設定を管理する構造体
struct IMEIndicatorSettings: Codable {
	
	// MARK: - 基本設定
	
	/// インジケータを表示するかどうか
	var isVisible: Bool = true
	
	// MARK: - 位置設定
	
	/// X座標（画面左からの距離）
	var positionX: CGFloat = 24
	
	/// Y座標（画面下からの距離）
	var positionY: CGFloat = 152
	
	/// ディスプレイインデックス（マルチディスプレイ対応）
	var displayIndex: Int = 0
	
	// MARK: - サイズ設定
	
	/// インジケータのサイズ（30〜200px）
	var indicatorSize: CGFloat = 100

	/// フォントサイズの比率（0.3〜0.8、インジケータサイズに対する比率）
	var fontSizeRatio: CGFloat = 0.5
	
	// MARK: - 外観設定

	/// 背景の不透明度（0.0〜1.0）
	var backgroundOpacity: Double = 0.7

	/// 英語（IME OFF）の色
	var englishColor: ColorComponents = ColorComponents(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)

	/// 日本語の色
	var japaneseColor: ColorComponents = ColorComponents(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)

	/// 中国語（簡体字）の色
	var chineseSimplifiedColor: ColorComponents = ColorComponents(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)

	/// 中国語（繁体字）の色
	var chineseTraditionalColor: ColorComponents = ColorComponents(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)

	/// 韓国語の色
	var koreanColor: ColorComponents = ColorComponents(red: 0.6, green: 0.0, blue: 0.6, alpha: 1.0)

	/// タイ語の色
	var thaiColor: ColorComponents = ColorComponents(red: 0.0, green: 0.6, blue: 0.6, alpha: 1.0)

	/// ベトナム語の色
	var vietnameseColor: ColorComponents = ColorComponents(red: 0.0, green: 0.7, blue: 0.7, alpha: 1.0)

	/// アラビア語の色
	var arabicColor: ColorComponents = ColorComponents(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)

	/// ヘブライ語の色
	var hebrewColor: ColorComponents = ColorComponents(red: 0.85, green: 0.65, blue: 0.0, alpha: 1.0)

	/// ヒンディー語の色
	var hindiColor: ColorComponents = ColorComponents(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)

	/// ロシア語の色
	var russianColor: ColorComponents = ColorComponents(red: 0.7, green: 0.0, blue: 0.3, alpha: 1.0)

	/// ギリシャ語の色
	var greekColor: ColorComponents = ColorComponents(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0)

	/// モンゴル語の色
	var mongolianColor: ColorComponents = ColorComponents(red: 0.3, green: 0.5, blue: 0.7, alpha: 1.0)

	/// ミャンマー語の色
	var myanmarColor: ColorComponents = ColorComponents(red: 0.8, green: 0.6, blue: 0.0, alpha: 1.0)

	/// クメール語の色
	var khmerColor: ColorComponents = ColorComponents(red: 0.2, green: 0.6, blue: 0.4, alpha: 1.0)

	/// ラオス語の色
	var laoColor: ColorComponents = ColorComponents(red: 0.4, green: 0.7, blue: 0.3, alpha: 1.0)

	/// ベンガル語の色
	var bengaliColor: ColorComponents = ColorComponents(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)

	/// タミル語の色
	var tamilColor: ColorComponents = ColorComponents(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)

	/// テルグ語の色
	var teluguColor: ColorComponents = ColorComponents(red: 0.6, green: 0.3, blue: 0.0, alpha: 1.0)

	/// ネパール語の色
	var nepaliColor: ColorComponents = ColorComponents(red: 0.8, green: 0.0, blue: 0.4, alpha: 1.0)

	/// シンハラ語の色
	var sinhalaColor: ColorComponents = ColorComponents(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)

	/// ペルシア語の色
	var persianColor: ColorComponents = ColorComponents(red: 0.0, green: 0.6, blue: 0.3, alpha: 1.0)

	/// ウクライナ語の色
	var ukrainianColor: ColorComponents = ColorComponents(red: 0.0, green: 0.35, blue: 0.7, alpha: 1.0)

	/// その他のIMEの色
	var otherColor: ColorComponents = ColorComponents(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)

	// MARK: - テキスト設定

	/// 英語（IME OFF）の表示テキスト
	var englishText: String = "A"

	/// 日本語の表示テキスト
	var japaneseText: String = "あ"

	/// 中国語（簡体字）の表示テキスト
	var chineseSimplifiedText: String = "简"

	/// 中国語（繁体字）の表示テキスト
	var chineseTraditionalText: String = "繁"

	/// 韓国語の表示テキスト
	var koreanText: String = "한"

	/// タイ語の表示テキスト
	var thaiText: String = "ไ"

	/// ベトナム語の表示テキスト
	var vietnameseText: String = "V"

	/// アラビア語の表示テキスト
	var arabicText: String = "ع"

	/// ヘブライ語の表示テキスト
	var hebrewText: String = "ע"

	/// ヒンディー語の表示テキスト
	var hindiText: String = "अ"

	/// ロシア語の表示テキスト
	var russianText: String = "Я"

	/// ギリシャ語の表示テキスト
	var greekText: String = "Ω"

	/// モンゴル語の表示テキスト
	var mongolianText: String = "ᠮ"

	/// ミャンマー語の表示テキスト
	var myanmarText: String = "မ"

	/// クメール語の表示テキスト
	var khmerText: String = "ក"

	/// ラオス語の表示テキスト
	var laoText: String = "ລ"

	/// ベンガル語の表示テキスト
	var bengaliText: String = "ব"

	/// タミル語の表示テキスト
	var tamilText: String = "த"

	/// テルグ語の表示テキスト
	var teluguText: String = "త"

	/// ネパール語の表示テキスト
	var nepaliText: String = "ने"

	/// シンハラ語の表示テキスト
	var sinhalaText: String = "සි"

	/// ペルシア語の表示テキスト
	var persianText: String = "ف"

	/// ウクライナ語の表示テキスト
	var ukrainianText: String = "У"

	/// その他のIMEの表示テキスト
	var otherText: String = "?"

	/// フォント名（システムフォントから選択）
	var fontName: String = "MyricaM M"
	
	// MARK: - インタラクション設定（保存しない）
	
	/// 移動モード（ドラッグで移動可能）
	/// 注: この値はファイルに保存されません（一時的な状態）
	var moveMode: Bool = false
	
	// MARK: - Codable（moveModeを除外）
	
	enum CodingKeys: String, CodingKey {
		case isVisible
		case positionX
		case positionY
		case displayIndex
		case indicatorSize
		case fontSizeRatio
		case backgroundOpacity
		// 色設定
		case englishColor
		case japaneseColor
		case chineseSimplifiedColor
		case chineseTraditionalColor
		case koreanColor
		case thaiColor
		case vietnameseColor
		case arabicColor
		case hebrewColor
		case hindiColor
		case russianColor
		case greekColor
		case mongolianColor
		case myanmarColor
		case khmerColor
		case laoColor
		case bengaliColor
		case tamilColor
		case teluguColor
		case nepaliColor
		case sinhalaColor
		case persianColor
		case ukrainianColor
		case otherColor
		// テキスト設定
		case englishText
		case japaneseText
		case chineseSimplifiedText
		case chineseTraditionalText
		case koreanText
		case thaiText
		case vietnameseText
		case arabicText
		case hebrewText
		case hindiText
		case russianText
		case greekText
		case mongolianText
		case myanmarText
		case khmerText
		case laoText
		case bengaliText
		case tamilText
		case teluguText
		case nepaliText
		case sinhalaText
		case persianText
		case ukrainianText
		case otherText
		case fontName
		// moveMode は除外（保存しない）
	}

	// MARK: - ヘルパーメソッド

	/// 指定した言語の色を取得
	func color(for language: InputLanguage) -> ColorComponents {
		switch language {
		case .english: return englishColor
		case .japanese: return japaneseColor
		case .chineseSimplified: return chineseSimplifiedColor
		case .chineseTraditional: return chineseTraditionalColor
		case .korean: return koreanColor
		case .thai: return thaiColor
		case .vietnamese: return vietnameseColor
		case .arabic: return arabicColor
		case .hebrew: return hebrewColor
		case .hindi: return hindiColor
		case .russian: return russianColor
		case .greek: return greekColor
		case .mongolian: return mongolianColor
		case .myanmar: return myanmarColor
		case .khmer: return khmerColor
		case .lao: return laoColor
		case .bengali: return bengaliColor
		case .tamil: return tamilColor
		case .telugu: return teluguColor
		case .nepali: return nepaliColor
		case .sinhala: return sinhalaColor
		case .persian: return persianColor
		case .ukrainian: return ukrainianColor
		case .other: return otherColor
		}
	}

	/// 指定した言語のテキストを取得
	func text(for language: InputLanguage) -> String {
		switch language {
		case .english: return englishText
		case .japanese: return japaneseText
		case .chineseSimplified: return chineseSimplifiedText
		case .chineseTraditional: return chineseTraditionalText
		case .korean: return koreanText
		case .thai: return thaiText
		case .vietnamese: return vietnameseText
		case .arabic: return arabicText
		case .hebrew: return hebrewText
		case .hindi: return hindiText
		case .russian: return russianText
		case .greek: return greekText
		case .mongolian: return mongolianText
		case .myanmar: return myanmarText
		case .khmer: return khmerText
		case .lao: return laoText
		case .bengali: return bengaliText
		case .tamil: return tamilText
		case .telugu: return teluguText
		case .nepali: return nepaliText
		case .sinhala: return sinhalaText
		case .persian: return persianText
		case .ukrainian: return ukrainianText
		case .other: return otherText
		}
	}
}

