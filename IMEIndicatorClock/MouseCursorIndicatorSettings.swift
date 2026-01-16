//
//  MouseCursorIndicatorSettings.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/10.
//
//  マウスカーソルインジケータ設定データモデル
//  マウスカーソルに追従する小さなインジケータの設定を管理
//

import Foundation
import SwiftUI

// MARK: - マウスカーソルインジケータ設定データモデル

/// マウスカーソルインジケータの表示設定を管理する構造体
struct MouseCursorIndicatorSettings: Codable {

    // MARK: - 基本設定

    /// インジケータを表示するかどうか
    var isVisible: Bool = true

    // MARK: - サイズ・位置設定

    /// インジケータのサイズ（12〜32px）
    var size: CGFloat = 20

    /// カーソルからのX方向オフセット（-30〜+30px、正=右、負=左）
    var offsetX: CGFloat = 16

    /// カーソルからのY方向オフセット（-30〜+30px、正=下、負=上）
    var offsetY: CGFloat = 8

    // MARK: - 外観設定

    /// 不透明度（0.5〜1.0）
    var opacity: Double = 0.8

    /// IMEインジケータと同じ色を使用するかどうか
    var useSameColorAsIMEIndicator: Bool = true

    /// 独自の英語（IME OFF）の色（useSameColorAsIMEIndicator=false時に使用）
    var englishColor: ColorComponents = ColorComponents(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)

    /// 独自の日本語の色（useSameColorAsIMEIndicator=false時に使用）
    var japaneseColor: ColorComponents = ColorComponents(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)

    /// 独自の中国語（簡体字）の色
    var chineseSimplifiedColor: ColorComponents = ColorComponents(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)

    /// 独自の中国語（繁体字）の色
    var chineseTraditionalColor: ColorComponents = ColorComponents(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)

    /// 独自の韓国語の色
    var koreanColor: ColorComponents = ColorComponents(red: 0.6, green: 0.0, blue: 0.6, alpha: 1.0)

    /// 独自のタイ語の色
    var thaiColor: ColorComponents = ColorComponents(red: 0.0, green: 0.6, blue: 0.6, alpha: 1.0)

    /// 独自のベトナム語の色
    var vietnameseColor: ColorComponents = ColorComponents(red: 0.0, green: 0.7, blue: 0.7, alpha: 1.0)

    /// 独自のアラビア語の色
    var arabicColor: ColorComponents = ColorComponents(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)

    /// 独自のヘブライ語の色
    var hebrewColor: ColorComponents = ColorComponents(red: 0.85, green: 0.65, blue: 0.0, alpha: 1.0)

    /// 独自のヒンディー語の色
    var hindiColor: ColorComponents = ColorComponents(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)

    /// 独自のロシア語の色
    var russianColor: ColorComponents = ColorComponents(red: 0.7, green: 0.0, blue: 0.3, alpha: 1.0)

    /// 独自のギリシャ語の色
    var greekColor: ColorComponents = ColorComponents(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0)

    /// 独自のモンゴル語の色
    var mongolianColor: ColorComponents = ColorComponents(red: 0.3, green: 0.5, blue: 0.7, alpha: 1.0)

    /// 独自のミャンマー語の色
    var myanmarColor: ColorComponents = ColorComponents(red: 0.8, green: 0.6, blue: 0.0, alpha: 1.0)

    /// 独自のクメール語の色
    var khmerColor: ColorComponents = ColorComponents(red: 0.2, green: 0.6, blue: 0.4, alpha: 1.0)

    /// 独自のラオス語の色
    var laoColor: ColorComponents = ColorComponents(red: 0.4, green: 0.7, blue: 0.3, alpha: 1.0)

    /// 独自のベンガル語の色
    var bengaliColor: ColorComponents = ColorComponents(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)

    /// 独自のタミル語の色
    var tamilColor: ColorComponents = ColorComponents(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)

    /// 独自のテルグ語の色
    var teluguColor: ColorComponents = ColorComponents(red: 0.6, green: 0.3, blue: 0.0, alpha: 1.0)

    /// 独自のネパール語の色
    var nepaliColor: ColorComponents = ColorComponents(red: 0.8, green: 0.0, blue: 0.4, alpha: 1.0)

    /// 独自のシンハラ語の色
    var sinhalaColor: ColorComponents = ColorComponents(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)

    /// 独自のペルシア語の色
    var persianColor: ColorComponents = ColorComponents(red: 0.0, green: 0.6, blue: 0.3, alpha: 1.0)

    /// 独自のウクライナ語の色
    var ukrainianColor: ColorComponents = ColorComponents(red: 0.0, green: 0.35, blue: 0.7, alpha: 1.0)

    /// 独自のその他のIMEの色
    var otherColor: ColorComponents = ColorComponents(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)

    // MARK: - ヘルパーメソッド

    /// 指定した言語の色を取得（IMEインジケータと共有または独自色）
    func color(for language: InputLanguage, imeSettings: IMEIndicatorSettings) -> ColorComponents {
        if useSameColorAsIMEIndicator {
            return imeSettings.color(for: language)
        } else {
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
    }
}
