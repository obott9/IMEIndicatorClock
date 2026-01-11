//
//  AccessibilityHelper.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/09.
//
//  アクセシビリティ権限のチェックと管理
//

import AppKit

// MARK: - アクセシビリティヘルパー

/// アクセシビリティ権限の確認と管理を行うユーティリティ
enum AccessibilityHelper {

	// MARK: - プロパティ

	/// 現在の権限状態を取得
	static var isEnabled: Bool {
		let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
		return AXIsProcessTrustedWithOptions(options)
	}

	// MARK: - 起動時チェック

	/// アプリ起動時にアクセシビリティ権限をチェック
	/// ユーザーが「次回から表示しない」を選択している場合はスキップ
	static func checkPermissionOnLaunch() {
		// ユーザーが「次回から表示しない」を選択している場合はスキップ
		if UserDefaults.standard.bool(forKey: "hideAccessibilityAlert") {
			return
		}

		// 権限がない場合のみアラートを表示
		if !isEnabled {
			// 起動直後は他のUIが表示されている可能性があるため、少し待つ
			DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
				showPermissionAlert()
			}
		}
	}

	/// 権限確認アラートを表示
	private static func showPermissionAlert() {
		let alert = NSAlert()
		alert.messageText = String(localized: "alert.accessibility.title")
		alert.informativeText = String(localized: "alert.accessibility.message")
		alert.alertStyle = .informational
		alert.addButton(withTitle: String(localized: "alert.accessibility.open_settings"))
		alert.addButton(withTitle: String(localized: "alert.accessibility.continue"))
		alert.addButton(withTitle: String(localized: "alert.accessibility.dont_show"))

		let response = alert.runModal()

		switch response {
		case .alertFirstButtonReturn:
			// システム設定を開く
			openSystemPreferences()
		case .alertThirdButtonReturn:
			// 次回から表示しない
			UserDefaults.standard.set(true, forKey: "hideAccessibilityAlert")
		default:
			// このまま使用
			break
		}
	}

	// MARK: - 再チェック

	/// ユーザーリクエストによる権限状態の確認と表示
	static func checkAndShowStatus() {
		let alert = NSAlert()

		if isEnabled {
			alert.messageText = String(localized: "alert.accessibility.enabled.title")
			alert.informativeText = String(localized: "alert.accessibility.enabled.message")
			alert.alertStyle = .informational
			alert.addButton(withTitle: "OK")
			alert.runModal()
		} else {
			alert.messageText = String(localized: "alert.accessibility.disabled.title")
			alert.informativeText = String(localized: "alert.accessibility.disabled.message")
			alert.alertStyle = .informational
			alert.addButton(withTitle: String(localized: "alert.accessibility.open_settings"))
			alert.addButton(withTitle: "OK")

			let response = alert.runModal()
			if response == .alertFirstButtonReturn {
				openSystemPreferences()
			}
		}
	}

	// MARK: - ヘルパー

	/// システム設定のアクセシビリティページを開く
	private static func openSystemPreferences() {
		NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
	}
}
