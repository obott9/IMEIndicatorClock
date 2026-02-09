# IMEIndicatorClock リリース手順

## ビルド環境

- macOS 14.0 以降
- Xcode 15.0 以降

## リリースビルド作成

### 1. Xcodeでアーカイブ

```
Product > Archive
```

または、コマンドラインで：

```bash
xcodebuild -project IMEIndicatorClock.xcodeproj \
  -scheme IMEIndicatorClock \
  -configuration Release \
  -archivePath build/IMEIndicatorClock.xcarchive \
  archive
```

### 2. アプリをエクスポート

Organizer から「Distribute App」→「Copy App」でエクスポート

### 3. ZIPファイル作成

```bash
# 作業ディレクトリを作成（.gitignoreに追加済み）
mkdir -p build/release/IMEIndicatorClock

# アプリをコピー（エクスポート先のパスを指定）
cp -r /path/to/exported/IMEIndicatorClock.app build/release/IMEIndicatorClock/

# READMEをコピー
cp dist/README.txt build/release/IMEIndicatorClock/
cp dist/README_EN.txt build/release/IMEIndicatorClock/
cp dist/README_ko.txt build/release/IMEIndicatorClock/
cp dist/README_zh-CN.txt build/release/IMEIndicatorClock/
cp dist/README_zh-TW.txt build/release/IMEIndicatorClock/

# ZIPを作成
cd build/release
zip -r IMEIndicatorClock_vX.X.X.zip IMEIndicatorClock
```

### 4. GitHub Releasesにアップロード

1. GitHubでタグを作成（例: `v1.0.0`）
2. Releases → Draft a new release
3. 作成したZIPファイルをアップロード
4. リリースノートを記載して公開

## ファイル構成

```
リポジトリ内（コミット対象）:
  dist/
    ├── RELEASE.md          # この手順書
    ├── README.txt          # ZIPに同梱（日本語）
    ├── README_EN.txt       # ZIPに同梱（English）
    ├── README_ko.txt       # ZIPに同梱（한국어）
    ├── README_zh-CN.txt    # ZIPに同梱（简体中文）
    └── README_zh-TW.txt    # ZIPに同梱（繁體中文）

作業用（.gitignoreで除外）:
  build/
    └── release/
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

- [ ] バージョン番号を更新（Info.plist）
- [ ] Release構成でビルド
- [ ] アプリが正常に起動するか確認
- [ ] dist/README.txt の内容が最新か確認
- [ ] dist/README.txt と README_EN.txt の動作環境がプロジェクト設定（MACOSX_DEPLOYMENT_TARGET）と一致しているか確認
- [ ] GitHubにタグを作成
- [ ] GitHub Releasesに ZIPをアップロード
