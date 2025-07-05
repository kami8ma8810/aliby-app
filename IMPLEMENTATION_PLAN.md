# 📱 Aliby アプリ 実装計画・進捗管理

## 🎯 プロジェクト概要
- **アプリ名**: Aliby
- **目的**: 生まれてからの経過時間をリアルタイムで表示し、節目をゆるく祝うアプリ
- **対象プラットフォーム**: iOS, Android
- **開発フレームワーク**: Flutter (Dart)
- **開発開始日**: 2025-07-04

## 📋 技術スタック (2025年版)

| カテゴリ | 技術選定 | バージョン | 選定理由 |
|---------|----------|-----------|----------|
| フレームワーク | Flutter | 3.24.x | 安定性とメンテナンス性が高い |
| 状態管理 | Provider | 6.1.x | シンプルで学習コストが低い |
| ローカルストレージ | shared_preferences | 2.3.x | 軽量で信頼性が高い |
| 日付操作 | Dart標準 DateTime | - | 標準ライブラリで十分対応可能 |
| タイマー | Dart標準 Timer | - | 標準ライブラリで十分対応可能 |

## 🧪 開発方針
- **TDD（テスト駆動開発）**: 和田卓人さんのRED-GREEN-REFACTORサイクルで実装
  - RED: 失敗するテストを先に書く
  - GREEN: テストを通す最小限のコードを書く
  - REFACTOR: コードをリファクタリング

## 🚀 実装フェーズ

### Phase 1: 基盤構築 (1日目)
- [x] 実装計画書の作成
- [x] Flutterプロジェクトの初期化
- [x] ディレクトリ構造の設定
- [x] 必要なパッケージの追加

### Phase 2: コア機能実装 (2-3日目) - TDD実装
- [x] UserDataモデルのテスト作成と実装
  - [x] テスト作成
  - [x] モデル実装
- [x] StorageServiceのテスト作成と実装
  - [x] テスト作成
  - [x] サービス実装
- [x] Trophyモデルのテスト作成と実装
  - [x] テスト作成
  - [x] モデル実装
- [x] Provider状態管理の基盤設定
  - [x] UserProviderのテスト作成
  - [x] UserProvider実装
  - [x] TimerProviderのテスト作成
  - [x] TimerProvider実装

### Phase 3: UI実装 (4-5日目)
- [ ] HomeScreenの実装
  - [ ] 経過日数の大きな表示
  - [ ] 時間・分・秒の表示
  - [ ] ナビゲーションボタン
- [ ] TrophyHistoryScreenの実装
- [ ] SettingsScreenの実装
  - [ ] リアルタイム表示ON/OFF
  - [ ] テーマ切り替え（ダーク/ライト）

### Phase 4: トロフィー機能 (6日目)
- [ ] トロフィー定義ファイル(JSON)の作成
- [ ] トロフィー条件判定ロジック
- [ ] トロフィー履歴の保存機能
- [ ] トロフィー表示UI

### Phase 5: 仕上げ (7日目)
- [ ] アクセシビリティ対応
- [ ] エラーハンドリング
- [ ] パフォーマンス最適化
- [ ] テスト実装

## 📁 ディレクトリ構造

```
aliby-app/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── user_data.dart
│   │   └── trophy.dart
│   ├── providers/
│   │   ├── user_provider.dart
│   │   ├── timer_provider.dart
│   │   └── trophy_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── trophy_history_screen.dart
│   │   ├── settings_screen.dart
│   │   └── onboarding_screen.dart
│   ├── widgets/
│   │   ├── time_display.dart
│   │   ├── trophy_card.dart
│   │   └── theme_selector.dart
│   ├── services/
│   │   ├── storage_service.dart
│   │   └── trophy_service.dart
│   └── utils/
│       ├── date_utils.dart
│       └── constants.dart
├── assets/
│   └── trophy_config.json
├── test/
├── pubspec.yaml
└── README.md
```

## 📊 進捗状況

### 2025-07-04
- ✅ プロジェクト仕様の確認
- ✅ 実装計画書の作成
- ✅ Flutterプロジェクトの初期化
- ✅ TDDでUserDataモデルの実装完了
- ✅ TDDでStorageServiceの実装完了
- ✅ READMEにアーキテクチャ図・データフロー図を追加
- ✅ TDDでTrophyモデルの実装完了
- 🔄 UserProviderの実装開始

## 🎯 MVP機能チェックリスト

- [ ] 初回起動時の生年月日入力
- [ ] 生年月日のローカル保存
- [ ] 経過日数のリアルタイム表示
- [ ] 経過時間（時・分・秒）の表示
- [ ] リアルタイムカウントのON/OFF切替
- [ ] 基本的なトロフィー表示（100日ごと、誕生日など）
- [ ] トロフィー履歴の閲覧
- [ ] ダーク/ライトテーマ切り替え
- [ ] 基本的なアクセシビリティ対応

## 📝 メモ・課題

### 技術的な検討事項
- うるう年の処理はDart標準のDateTimeで自動対応
- 2月29日生まれの扱いは将来的な実装課題として保留
- バックグラウンドでのタイマー動作は初期MVPでは非対応

### パフォーマンス考慮
- 1秒ごとの更新によるバッテリー消費を考慮
- 設定でリアルタイム更新をOFFにできる機能を実装

### 将来の拡張性
- トロフィー定義をJSONで管理し、追加が容易な設計
- 多言語対応を見据えた文字列管理の検討

## 📈 実装進捗サマリー

### 全体進捗: ████████████░░░░░░░░ 60%

| フェーズ | 進捗 | 詳細 |
|---------|------|------|
| Phase 1: 基盤構築 | ████████████████████ 100% | ✅ 完了 |
| Phase 2: コア機能実装 | ████████████████████ 100% | ✅ 完了 |
| Phase 3: UI実装 | ░░░░░░░░░░░░░░░░░░░░ 0% | 🎯 次の作業 |
| Phase 4: トロフィー機能 | ░░░░░░░░░░░░░░░░░░░░ 0% | ⏳ 未着手 |
| Phase 5: 仕上げ | ░░░░░░░░░░░░░░░░░░░░ 0% | ⏳ 未着手 |

### 実装済み機能
- ✅ **モデル層**: UserData, Trophy, TrophyCondition, TrophyConfig
- ✅ **サービス層**: StorageService
- ✅ **Provider層**: UserProvider, TimerProvider
- ✅ **ドキュメント**: README（アーキテクチャ図含む）、実装計画書

### 次の実装予定
- 🎯 OnboardingScreen（初回起動時の生年月日入力画面）
- 🎯 HomeScreen（メイン画面）の実装
- 🎯 ナビゲーション設定

## 🔄 更新履歴

| 日付 | 内容 |
|------|------|
| 2025-07-04 | プロジェクト開始、実装計画書作成、モデル層・サービス層の一部実装完了 |