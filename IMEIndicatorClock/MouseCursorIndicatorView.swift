//
//  MouseCursorIndicatorView.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/10.
//
//  マウスカーソルに追従するインジケータのSwiftUI View
//

import SwiftUI

// MARK: - マウスカーソルインジケータView

/// マウスカーソルに追従する小さなインジケータ（IMEインジケータの縮小版）
struct MouseCursorIndicatorView: View {

    /// 現在の入力言語（初期値はIMEMonitorから取得）
    @State private var currentLanguage: InputLanguage = IMEMonitor.shared.currentLanguage

    /// 設定マネージャー
    @ObservedObject private var appSettings = AppSettingsManager.shared

    var body: some View {
        ZStack {
            // --- レイヤー1: 外側の円（グロー効果） ---
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            indicatorColor.opacity(0.6),
                            indicatorColor.opacity(0.3),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: indicatorSize * 0.5
                    )
                )
                .frame(width: indicatorSize, height: indicatorSize)

            // --- レイヤー2: 内側の円（メイン表示） ---
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            indicatorColor,
                            indicatorColor.opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: indicatorSize * 0.8, height: indicatorSize * 0.8)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )

            // --- レイヤー3: テキスト ---
            Text(indicatorText)
                .foregroundColor(.white)
                .font(.system(size: indicatorSize * fontSizeRatio, weight: .bold))
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 0.5)
        }
        .frame(width: indicatorSize, height: indicatorSize, alignment: .topLeading)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .opacity(indicatorOpacity)
        .onReceive(NotificationCenter.default.publisher(for: .mouseCursorIndicatorLanguageChanged)) { notification in
            if let language = notification.object as? InputLanguage {
                currentLanguage = language
            }
        }
    }

    // MARK: - 計算プロパティ

    /// インジケータの表示テキスト（IMEインジケータと同じ）
    private var indicatorText: String {
        return appSettings.settings.imeIndicator.text(for: currentLanguage)
    }

    /// インジケータの色（IMEインジケータと同じ）
    private var indicatorColor: Color {
        let colorComponents = appSettings.settings.imeIndicator.color(for: currentLanguage)
        dbgLog(2, "🎨 [MouseCursorIndicator] 言語=%@ テキスト=%@ 色=R%.2f G%.2f B%.2f",
               String(describing: currentLanguage),
               indicatorText,
               colorComponents.red, colorComponents.green, colorComponents.blue)
        return colorComponents.color
    }

    /// インジケータのサイズ
    private var indicatorSize: CGFloat {
        return appSettings.settings.mouseCursorIndicator.size
    }

    /// インジケータの不透明度
    private var indicatorOpacity: Double {
        return appSettings.settings.mouseCursorIndicator.opacity
    }

    /// フォントサイズ比率（IMEインジケータと同じ）
    private var fontSizeRatio: CGFloat {
        return appSettings.settings.imeIndicator.fontSizeRatio
    }
}

// MARK: - プレビュー

#Preview("Japanese") {
    MouseCursorIndicatorView()
        .frame(width: 50, height: 50)
        .background(Color.gray.opacity(0.3))
}

#Preview("English") {
    MouseCursorIndicatorView()
        .frame(width: 50, height: 50)
        .background(Color.gray.opacity(0.3))
}
