//
//  MouseCursorIndicatorSettingsView.swift
//  IMEIndicatorClock
//
//  Created on 2026/01/10.
//
//  マウスカーソルインジケータ設定ウィンドウのSwiftUI UI
//

import SwiftUI

// MARK: - マウスカーソルインジケータ設定ビュー

struct MouseCursorIndicatorSettingsView: View {

    // 設定マネージャーを監視（リアルタイム反映）
    @ObservedObject private var appSettings = AppSettingsManager.shared

    var body: some View {
        VStack(spacing: 20) {
            // タイトル
            HStack {
                Image(systemName: "cursorarrow.rays")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                Text("title", tableName: "MouseCursorIndicator")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.bottom, 5)

            // 基本設定
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    // 表示ON/OFF
                    Toggle(isOn: $appSettings.settings.mouseCursorIndicator.isVisible) {
                        Text("show_indicator", tableName: "MouseCursorIndicator")
                    }
                    .onChange(of: appSettings.settings.mouseCursorIndicator.isVisible) { _, _ in
                        saveSettings()
                    }

                    // 説明文
                    Text("settings_note", tableName: "MouseCursorIndicator")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
            } label: {
                Label {
                    Text("basic", tableName: "MouseCursorIndicator")
                } icon: {
                    Image(systemName: "gearshape")
                }
            }

            // サイズ・位置設定
            GroupBox {
                VStack(alignment: .leading, spacing: 16) {
                    // サイズ
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("size", tableName: "MouseCursorIndicator")
                            Spacer()
                            Text("\(Int(appSettings.settings.mouseCursorIndicator.size)) px")
                                .monospacedDigit()
                                .foregroundColor(.secondary)
                        }

                        Slider(value: $appSettings.settings.mouseCursorIndicator.size, in: 12...32, step: 1)
                            .onChange(of: appSettings.settings.mouseCursorIndicator.size) { _, _ in
                                saveSettings()
                            }

                        // プリセットボタン
                        HStack(spacing: 8) {
                            Button {
                                appSettings.settings.mouseCursorIndicator.size = 16
                                saveSettings()
                            } label: {
                                Text("size_small", tableName: "MouseCursorIndicator")
                            }
                            .buttonStyle(.bordered)
                            Button {
                                appSettings.settings.mouseCursorIndicator.size = 20
                                saveSettings()
                            } label: {
                                Text("size_medium", tableName: "MouseCursorIndicator")
                            }
                            .buttonStyle(.bordered)
                            Button {
                                appSettings.settings.mouseCursorIndicator.size = 28
                                saveSettings()
                            } label: {
                                Text("size_large", tableName: "MouseCursorIndicator")
                            }
                            .buttonStyle(.bordered)
                        }
                        .font(.caption)
                    }

                    Divider()

                    // オフセット
                    VStack(alignment: .leading, spacing: 8) {
                        Text("offset", tableName: "MouseCursorIndicator")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 20) {
                            // X方向（正=右、負=左）
                            HStack {
                                Text("X:")
                                    .frame(width: 20)
                                Slider(value: $appSettings.settings.mouseCursorIndicator.offsetX, in: -30...30, step: 1)
                                    .frame(width: 100)
                                    .onChange(of: appSettings.settings.mouseCursorIndicator.offsetX) { _, _ in
                                        saveSettings()
                                    }
                                Text(String(format: "%+.0f", appSettings.settings.mouseCursorIndicator.offsetX))
                                    .frame(width: 35)
                                    .monospacedDigit()
                                    .foregroundColor(.secondary)
                            }

                            // Y方向（正=下、負=上）
                            HStack {
                                Text("Y:")
                                    .frame(width: 20)
                                Slider(value: $appSettings.settings.mouseCursorIndicator.offsetY, in: -30...30, step: 1)
                                    .frame(width: 100)
                                    .onChange(of: appSettings.settings.mouseCursorIndicator.offsetY) { _, _ in
                                        saveSettings()
                                    }
                                Text(String(format: "%+.0f", appSettings.settings.mouseCursorIndicator.offsetY))
                                    .frame(width: 35)
                                    .monospacedDigit()
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(8)
            } label: {
                Label {
                    Text("size_position", tableName: "MouseCursorIndicator")
                } icon: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                }
            }

            // 外観設定
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    // 不透明度
                    HStack {
                        Text("opacity", tableName: "MouseCursorIndicator")
                        Spacer()
                        Slider(value: $appSettings.settings.mouseCursorIndicator.opacity, in: 0.1...1.0, step: 0.05)
                            .frame(width: 150)
                            .onChange(of: appSettings.settings.mouseCursorIndicator.opacity) { _, _ in
                                saveSettings()
                            }
                        Text("\(Int(appSettings.settings.mouseCursorIndicator.opacity * 100))%")
                            .frame(width: 45, alignment: .trailing)
                            .monospacedDigit()
                            .foregroundColor(.secondary)
                    }
                }
                .padding(8)
            } label: {
                Label {
                    Text("appearance", tableName: "MouseCursorIndicator")
                } icon: {
                    Image(systemName: "paintpalette")
                }
            }

            // リセットボタン
            HStack {
                Button {
                    resetSettings()
                } label: {
                    Text("reset", tableName: "MouseCursorIndicator")
                }
                .buttonStyle(.bordered)
            }

            // 上詰めにするためのスペーサー
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - ヘルパー

    /// 設定を保存して通知
    private func saveSettings() {
        let settings = appSettings.settings.mouseCursorIndicator
        dbgLog(-1, "💾 [MouseCursorIndicatorSettings] saveSettings: offsetX=%.0f, offsetY=%.0f, size=%.0f, opacity=%.0f%%",
               settings.offsetX,
               settings.offsetY,
               settings.size,
               settings.opacity * 100)
        appSettings.save()
        NotificationCenter.default.post(
            name: NSNotification.Name("MouseCursorIndicatorSettingsChanged"),
            object: nil
        )
    }

    /// 設定をリセット
    private func resetSettings() {
        appSettings.settings.mouseCursorIndicator = MouseCursorIndicatorSettings()
        saveSettings()
    }
}

// MARK: - プレビュー

/// プレビュー用の言語切り替えラッパー
private struct MouseCursorIndicatorSettingsPreview: View {
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
            MouseCursorIndicatorSettingsView()
                .environment(\.locale, Locale(identifier: selectedLocale))
        }
    }
}

#Preview("Mouse Cursor Indicator Settings") {
    MouseCursorIndicatorSettingsPreview()
}
