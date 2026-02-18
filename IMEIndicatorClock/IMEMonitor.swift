//
//  IMEMonitor.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/09.
//
//  IME状態の監視
//  システムの入力ソース変更を監視し、各言語の入力モードを検出します
//

import Foundation
import Carbon

// MARK: - 入力言語の種別

/// 検出可能な入力言語
enum InputLanguage: String, Codable, CaseIterable {
	case english = "english"                       // 英語（IME OFF）
	case japanese = "japanese"                     // 日本語
	case chineseSimplified = "chinese_simplified"  // 中国語（簡体字）
	case chineseTraditional = "chinese_traditional" // 中国語（繁体字）
	case korean = "korean"                         // 韓国語
	case thai = "thai"                             // タイ語
	case vietnamese = "vietnamese"                 // ベトナム語
	case arabic = "arabic"                         // アラビア語
	case hebrew = "hebrew"                         // ヘブライ語
	case hindi = "hindi"                           // ヒンディー語
	case russian = "russian"                       // ロシア語
	case greek = "greek"                           // ギリシャ語
	case mongolian = "mongolian"                   // モンゴル語
	case myanmar = "myanmar"                       // ミャンマー語
	case khmer = "khmer"                           // クメール語
	case lao = "lao"                               // ラオス語
	case bengali = "bengali"                       // ベンガル語
	case tamil = "tamil"                           // タミル語
	case telugu = "telugu"                         // テルグ語
	case nepali = "nepali"                         // ネパール語
	case sinhala = "sinhala"                       // シンハラ語
	case persian = "persian"                       // ペルシア語
	case ukrainian = "ukrainian"                   // ウクライナ語
	case other = "other"                           // その他のIME

	/// IMEがONかどうか（英語以外はすべてON）
	var isIMEOn: Bool {
		return self != .english
	}

	/// デフォルトの表示テキスト
	var defaultText: String {
		switch self {
		case .english: return "A"
		case .japanese: return "あ"
		case .chineseSimplified: return "简"
		case .chineseTraditional: return "繁"
		case .korean: return "한"
		case .thai: return "ไ"
		case .vietnamese: return "V"
		case .arabic: return "ع"
		case .hebrew: return "ע"
		case .hindi: return "अ"
		case .russian: return "Я"
		case .greek: return "Ω"
		case .mongolian: return "ᠮ"
		case .myanmar: return "မ"
		case .khmer: return "ក"
		case .lao: return "ລ"
		case .bengali: return "ব"
		case .tamil: return "த"
		case .telugu: return "త"
		case .nepali: return "ने"
		case .sinhala: return "සි"
		case .persian: return "ف"
		case .ukrainian: return "У"
		case .other: return "?"
		}
	}

	/// ローカライズ用のキー
	var localizationKey: String {
		return "input_language.\(rawValue)"
	}
}

// MARK: - IMEモニター

/// IME状態の監視を担当するクラス
class IMEMonitor {

	// MARK: - シングルトン

	/// シングルトンインスタンス
	static let shared = IMEMonitor()

	// MARK: - プロパティ

	/// 現在の入力言語
	private(set) var currentLanguage: InputLanguage = .english

	/// 現在の入力ソースID（ログ出力用）
	private var currentSourceID: String = ""

	/// 入力言語が変更された時のコールバック
	var onLanguageChanged: ((InputLanguage) -> Void)?

	/// 後方互換性のため：IME状態が変更された時のコールバック
	var onIMEStateChanged: ((Bool) -> Void)?

	/// ポーリング用タイマー（メモリリーク防止のためプロパティとして保持）
	private var pollingTimer: Timer?

	/// 後方互換性のため：日本語入力モードかどうか
	var isJapanese: Bool {
		return currentLanguage == .japanese
	}

	// MARK: - 初期化

	private init() {}

	deinit {
		// タイマーを停止
		pollingTimer?.invalidate()
		pollingTimer = nil

		// オブザーバーを削除
		DistributedNotificationCenter.default().removeObserver(self)

		dbgLog(1, "🗑️ [IMEMonitor] IMEMonitor が解放されました")
	}

	// MARK: - 監視

	/// IME状態の監視を開始
	func startMonitoring() {
		// 方法1: 入力ソースの変更を監視（システム通知）
		DistributedNotificationCenter.default().addObserver(
			self,
			selector: #selector(inputSourceChanged),
			name: NSNotification.Name("AppleSelectedInputSourcesChangedNotification"),
			object: nil
		)

		// 方法2: タイマーで定期的にチェック（バックアップ）
		// メモリリーク防止のためプロパティに保持
		pollingTimer = Timer.scheduledTimer(withTimeInterval: AppConstants.imePollingInterval, repeats: true) { [weak self] _ in
			self?.checkIMEState()
		}

		// 初回の状態を取得
		checkIMEState()
	}

	/// 入力ソースが変更された時に呼ばれる
	@objc private func inputSourceChanged() {
		if Thread.isMainThread {
			checkIMEState()
		} else {
			DispatchQueue.main.async { [weak self] in
				self?.checkIMEState()
			}
		}
	}

	/// 現在のIME状態をチェックして更新
	private func checkIMEState() {
		let inputSource = TISCopyCurrentKeyboardInputSource().takeRetainedValue()

		guard let sourceIDPointer = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID) else {
			return
		}

		let sourceID = Unmanaged<CFString>.fromOpaque(sourceIDPointer).takeUnretainedValue() as String

		// 言語を判定
		let newLanguage = detectLanguage(from: sourceID)

		// デバッグ: 入力ソースIDが変わった場合はログ出力（同じ言語でも出力）
		if sourceID != currentSourceID {
			dbgLog(1, "🔤 [IMEMonitor] 入力ソース変更: %@ → 言語=%@", sourceID, String(describing: newLanguage))
			currentSourceID = sourceID
		}

		// 状態が変わった場合のみコールバック
		if newLanguage != currentLanguage {
			let oldLanguage = currentLanguage
			currentLanguage = newLanguage

			dbgLog(1, "🔤 [IMEMonitor] 言語変更: %@ → %@", String(describing: oldLanguage), String(describing: newLanguage))

			// 新しいコールバック
			onLanguageChanged?(newLanguage)

			// 後方互換性のためのコールバック（IME ON/OFFが変わった場合）
			if oldLanguage.isIMEOn != newLanguage.isIMEOn {
				onIMEStateChanged?(newLanguage.isIMEOn)
			}
		}
	}

	/// 入力ソースIDから言語を判定
	private func detectLanguage(from sourceID: String) -> InputLanguage {
		// 日本語
		if sourceID.contains("Japanese") ||
		   sourceID.contains("Hiragana") ||
		   sourceID.contains("Katakana") ||
		   sourceID.contains("com.apple.inputmethod.Japanese") ||
		   sourceID.contains("com.google.inputmethod.Japanese") {
			return .japanese
		}

		// 中国語（繁体字）- TCIM/TYIMを先に判定（TCIM.Pinyinの誤判定を防ぐ）
		if sourceID.contains("TCIM") ||
		   sourceID.contains("TYIM") ||
		   sourceID.contains("Zhuyin") ||
		   sourceID.contains("Cangjie") ||
		   sourceID.contains("TraditionalChinese") {
			return .chineseTraditional
		}

		// 中国語（簡体字）- ピンイン、五筆など
		if sourceID.contains("SCIM") ||
		   sourceID.contains("Pinyin") ||
		   sourceID.contains("Wubi") ||
		   sourceID.contains("PinyinIM") {
			return .chineseSimplified
		}

		// 韓国語
		if sourceID.contains("Korean") ||
		   sourceID.contains("Hangul") ||
		   sourceID.contains("com.apple.inputmethod.Korean") {
			return .korean
		}

		// タイ語
		if sourceID.contains("Thai") ||
		   sourceID.contains("com.apple.inputmethod.Thai") {
			return .thai
		}

		// ベトナム語
		if sourceID.contains("Vietnamese") ||
		   sourceID.contains("Viet") ||
		   sourceID.contains("UniKey") ||
		   sourceID.contains("com.apple.inputmethod.Vietnamese") {
			return .vietnamese
		}

		// アラビア語
		if sourceID.contains("Arabic") ||
		   sourceID.contains("com.apple.keylayout.Arabic") ||
		   sourceID.contains("TransliterationIM.ar") {
			return .arabic
		}

		// ヘブライ語
		if sourceID.contains("Hebrew") ||
		   sourceID.contains("com.apple.keylayout.Hebrew") {
			return .hebrew
		}

		// テルグ語（ヒンディー語より先に判定）
		if sourceID.contains("Telugu") ||
		   sourceID.contains("com.apple.keylayout.Telugu") ||
		   sourceID.contains("TransliterationIM.te") {
			return .telugu
		}

		// タミル語
		if sourceID.contains("Tamil") ||
		   sourceID.contains("com.apple.keylayout.Tamil") ||
		   sourceID.contains("TransliterationIM.ta") {
			return .tamil
		}

		// ベンガル語
		if sourceID.contains("Bengali") ||
		   sourceID.contains("Bangla") ||
		   sourceID.contains("com.apple.keylayout.Bengali") ||
		   sourceID.contains("TransliterationIM.bn") {
			return .bengali
		}

		// ネパール語
		if sourceID.contains("Nepali") ||
		   sourceID.contains("com.apple.keylayout.Nepali") ||
		   sourceID.contains("TransliterationIM.ne") {
			return .nepali
		}

		// シンハラ語
		if sourceID.contains("Sinhala") ||
		   sourceID.contains("com.apple.keylayout.Sinhala") ||
		   sourceID.contains("TransliterationIM.si") {
			return .sinhala
		}

		// ヒンディー語（デーヴァナーガリー）
		if sourceID.contains("Hindi") ||
		   sourceID.contains("Devanagari") ||
		   sourceID.contains("com.apple.keylayout.Devanagari") ||
		   sourceID.contains("com.apple.inputmethod.Hindi") ||
		   sourceID.contains("TransliterationIM.hi") {
			return .hindi
		}

		// ミャンマー語
		if sourceID.contains("Myanmar") ||
		   sourceID.contains("Burmese") ||
		   sourceID.contains("com.apple.keylayout.Myanmar") {
			return .myanmar
		}

		// クメール語（カンボジア語）
		if sourceID.contains("Khmer") ||
		   sourceID.contains("Cambodian") ||
		   sourceID.contains("com.apple.keylayout.Khmer") {
			return .khmer
		}

		// ラオス語
		if sourceID.contains("Lao") ||
		   sourceID.contains("com.apple.keylayout.Lao") {
			return .lao
		}

		// モンゴル語
		if sourceID.contains("Mongolian") ||
		   sourceID.contains("com.apple.keylayout.Mongolian") {
			return .mongolian
		}

		// ペルシア語（ファルシ語）
		if sourceID.contains("Persian") ||
		   sourceID.contains("Farsi") ||
		   sourceID.contains("com.apple.keylayout.Persian") ||
		   sourceID.contains("TransliterationIM.fa") {
			return .persian
		}

		// ウクライナ語
		if sourceID.contains("Ukrainian") ||
		   sourceID.contains("com.apple.keylayout.Ukrainian") {
			return .ukrainian
		}

		// ロシア語（キリル文字）
		if sourceID.contains("Russian") ||
		   sourceID.contains("Cyrillic") ||
		   sourceID.contains("com.apple.keylayout.Russian") {
			return .russian
		}

		// ギリシャ語
		if sourceID.contains("Greek") ||
		   sourceID.contains("com.apple.keylayout.Greek") {
			return .greek
		}

		// 英語キーボード（ABC、US、Britishなど）
		// 注: .Roman を含むものは各IMEの「英数」モード（例: Kotoeri.KanaTyping.Roman）
		if sourceID.contains("com.apple.keylayout.ABC") ||
		   sourceID.contains("com.apple.keylayout.US") ||
		   sourceID.contains("com.apple.keylayout.British") ||
		   sourceID.contains("com.apple.keylayout.Australian") ||
		   sourceID.contains("com.apple.keylayout.Canadian") ||
		   sourceID.contains("com.apple.keylayout.Irish") ||
		   sourceID.contains(".Roman") ||
		   sourceID.contains("USInternational") ||
		   sourceID.contains("Dvorak") ||
		   sourceID.contains("Colemak") ||
		   sourceID.contains("QWERTY") {
			return .english
		}

		// その他のラテン文字キーボード（ドイツ語、フランス語、スペイン語など）
		// これらは通常IMEを使用しないため英語扱い
		if sourceID.contains("German") ||
		   sourceID.contains("French") ||
		   sourceID.contains("Spanish") ||
		   sourceID.contains("Italian") ||
		   sourceID.contains("Portuguese") ||
		   sourceID.contains("Dutch") ||
		   sourceID.contains("Swedish") ||
		   sourceID.contains("Norwegian") ||
		   sourceID.contains("Danish") ||
		   sourceID.contains("Finnish") ||
		   sourceID.contains("Polish") ||
		   sourceID.contains("Czech") ||
		   sourceID.contains("Hungarian") ||
		   sourceID.contains("Romanian") ||
		   sourceID.contains("Turkish") {
			return .english
		}

		// inputmethod を含む場合は「その他のIME」として扱う
		if sourceID.contains("inputmethod") {
			return .other
		}

		// それ以外は英語（IME OFF）として扱う
		return .english
	}
}
