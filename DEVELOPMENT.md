# 🛠 開発ガイド

## 環境構築

### 必要な環境

- Flutter SDK: 3.24.x以上
- Dart SDK: 3.5.x以上
- Android Studio / Xcode（各プラットフォーム用）

### セットアップ

```bash
# Flutterの確認
flutter doctor

# 依存関係のインストール
flutter pub get

# テストの実行
flutter test

# アプリの起動
flutter run
```

## 開発ガイドライン

### コーディング規約

1. **Dartの命名規則に従う**
   - クラス名: PascalCase
   - 変数・関数名: camelCase
   - ファイル名: snake_case

2. **コメントの書き方**
   - 各クラス・メソッドに説明を追加
   - Flutter初心者向けに丁寧な説明
   - 必要に応じて公式ドキュメントのURLを記載

3. **any型の使用禁止**
   - 型安全性を保つため、適切な型を定義

### Git コミットメッセージ

```
feat: 新機能追加
fix: バグ修正
docs: ドキュメント更新
style: コードスタイルの修正
refactor: リファクタリング
test: テストの追加・修正
```

## 開発フロー

### 1. 新機能の追加

1. テストを先に書く（TDD）
2. 最小限の実装でテストを通す
3. リファクタリング
4. コミット

### 2. バグ修正

1. バグを再現するテストを書く
2. バグを修正
3. テストが通ることを確認
4. コミット

## パッケージ管理

### 現在使用中のパッケージ

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5
  shared_preferences: ^2.5.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

### パッケージの追加

```bash
flutter pub add パッケージ名
```

## ビルドとリリース

### デバッグビルド

```bash
# iOS
flutter build ios --debug

# Android
flutter build apk --debug
```

### リリースビルド

```bash
# iOS
flutter build ios --release

# Android
flutter build appbundle --release
```

## トラブルシューティング

### よくある問題

1. **依存関係の問題**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **iOS関連の問題**
   ```bash
   cd ios
   pod install
   ```

3. **ビルドキャッシュの問題**
   ```bash
   flutter clean
   rm -rf build/
   ```