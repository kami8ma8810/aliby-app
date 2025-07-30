# Vercel デプロイ手順

## 初回セットアップ

### 1. Vercelアカウントの作成
1. [Vercel](https://vercel.com)にアクセス
2. GitHubアカウントでサインアップ（推奨）

### 2. プロジェクトのインポート
1. Vercelダッシュボードで「New Project」をクリック
2. GitHubリポジトリ一覧から`aliby-app`を選択
3. 「Import」をクリック

### 3. ビルド設定
以下の設定は`vercel.json`で自動的に適用されます：
- **Build Command**: `flutter build web --release`
- **Output Directory**: `build/web`
- **Install Command**: Flutterの自動インストールスクリプト

### 4. デプロイ
1. 「Deploy」ボタンをクリック
2. 初回ビルドには5-10分程度かかります
3. 完了後、自動的にURLが発行されます

## 自動デプロイ

GitHubの`main`ブランチにプッシュすると自動的にデプロイされます。

## カスタムドメイン設定（オプション）

1. Vercelダッシュボードでプロジェクトを開く
2. 「Settings」→「Domains」を選択
3. カスタムドメインを追加
4. DNSレコードを設定

## トラブルシューティング

### ビルドエラーが発生する場合
- `vercel.json`のFlutterバージョンを確認
- ローカルで`flutter build web`が成功するか確認

### 404エラーが発生する場合
- `vercel.json`の`rewrites`設定を確認
- SPAの設定が正しく適用されているか確認

## 環境変数（必要な場合）

1. プロジェクト設定で「Environment Variables」を選択
2. 必要な環境変数を追加
3. 再デプロイ

## GitHub Pagesからの移行

1. Vercelでのデプロイが成功したことを確認
2. GitHub Pagesの設定を無効化（Settings → Pages → Source → None）
3. README.mdのURLをVercelのURLに更新