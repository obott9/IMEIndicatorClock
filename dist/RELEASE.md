# IMEIndicatorClock リリース手順

## ビルド環境

- macOS 14.0 以降
- Xcode 15.0 以降

## リリースビルド作成

### 1. バージョン番号を更新

`IMEIndicatorClock.xcodeproj/project.pbxproj` 内の `MARKETING_VERSION` を全箇所（6箇所）更新する。

### 2. アーカイブビルド

```bash
cd /path/to/IMEIndicatorClock
xcodebuild archive \
  -project IMEIndicatorClock.xcodeproj \
  -scheme IMEIndicatorClock \
  -archivePath build/release/IMEIndicatorClock.xcarchive
```

### 3. ZIPファイル作成

xcarchive 内の .app を直接ZIP化する（READMEは同梱しない）。

```bash
cd build/release
mkdir _tmp_zip
cp -R IMEIndicatorClock.xcarchive/Products/Applications/IMEIndicatorClock.app _tmp_zip/
cd _tmp_zip
zip -r ../IMEIndicatorClock_vX.X.X.zip IMEIndicatorClock.app
cd ..
rm -rf _tmp_zip
```

### 4. gitタグ作成・push

```bash
git tag vX.X.X
git push origin vX.X.X
git push origin main
```

### 5. GitHub Releaseを作成

```bash
gh release create vX.X.X \
  --draft \
  --title "vX.X.X" \
  --notes "リリースノート（5言語）"

gh release upload vX.X.X build/release/IMEIndicatorClock_vX.X.X.zip
```

動作確認後にドラフトを公開：

```bash
gh release edit vX.X.X --draft=false
```

### リリースノートのフォーマット

5言語（English / 日本語 / 한국어 / 简体中文 / 繁體中文）で記載する。
過去のリリースを参考にすること: `gh release view vX.X.X`

## ファイル構成

```
リポジトリ内（コミット対象）:
  dist/
    ├── RELEASE.md          # この手順書
    ├── README.txt          # 配布用（日本語）
    ├── README_EN.txt       # 配布用（English）
    ├── README_ko.txt       # 配布用（한국어）
    ├── README_zh-CN.txt    # 配布用（简体中文）
    └── README_zh-TW.txt    # 配布用（繁體中文）

作業用（.gitignoreで除外）:
  build/
    └── release/
        ├── IMEIndicatorClock.xcarchive/
        └── IMEIndicatorClock_vX.X.X.zip

GitHub Releases（最終配布先）:
  └── IMEIndicatorClock_vX.X.X.zip
```

## README.txt 必須記載事項

同梱するREADMEには以下を必ず記載すること：

- **ソフトの概要** - アプリの利用目的・機能
- **作者への連絡先** - メールアドレス、GitHub等（作者に管理権限があること）
- **取り扱い種別** - フリーソフト/シェアウェア等
- **動作環境** - macOSバージョン、必要な権限
- **インストール方法** - 手順を明記
- **アンインストール方法** - ファイル削除のみでも必ず記載

## リリースチェックリスト

- [ ] バージョン番号を更新（project.pbxproj の MARKETING_VERSION 6箇所）
- [ ] Release構成でアーカイブビルド
- [ ] アプリが正常に起動するか確認
- [ ] dist/README.txt の内容が最新か確認
- [ ] dist/README.txt と README_EN.txt の動作環境がプロジェクト設定（MACOSX_DEPLOYMENT_TARGET）と一致しているか確認
- [ ] gitタグを作成・push
- [ ] GitHub Releasesにドラフト作成・ZIPアップロード
- [ ] 動作確認後にドラフトを公開
- [ ] IMEIndicatorZ にも同じ修正を同期・バージョン更新
