import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/trophy_provider.dart';
import '../models/user_data.dart';
import 'home_screen.dart';

/// 初回起動時の生年月日入力画面
/// 
/// StatefulWidgetについて：
/// https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html
/// 状態を持つウィジェット。ユーザーの操作によって表示が変わる場合に使用
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

/// OnboardingScreenの状態を管理するクラス
class _OnboardingScreenState extends State<OnboardingScreen> {
  /// 選択された生年月日
  DateTime? _selectedDate;

  /// 日付選択ダイアログを表示するメソッド
  /// 
  /// showDatePickerについて：
  /// https://api.flutter.dev/flutter/material/showDatePicker.html
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(1900); // 最古の選択可能日
    final DateTime lastDate = now; // 未来の日付は選択不可

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20), // デフォルトは20年前
      firstDate: firstDate,
      lastDate: lastDate,
      // localeは実際のアプリではMaterialAppで設定
      helpText: '生年月日を選択',
      cancelText: 'キャンセル',
      confirmText: 'OK',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 開始ボタンが押された時の確認ダイアログを表示
  void _onStartPressed() {
    if (_selectedDate == null) return;
    
    _showConfirmationDialog();
  }

  /// 設定確認ダイアログを表示
  void _showConfirmationDialog() {
    if (_selectedDate == null) return;
    
    final birthdateText = '${_selectedDate!.year}年${_selectedDate!.month}月${_selectedDate!.day}日';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle_outline,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
        title: const Text('設定内容の確認'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('以下の内容で設定します：'),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.cake,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text('生年月日：'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              birthdateText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '生年月日を変更する場合は設定画面からデータリセットが必要です',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('修正する'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _confirmAndStart();
            },
            child: const Text('この内容で設定'),
          ),
        ],
      ),
    );
  }

  /// 確認後にユーザーデータを保存してホーム画面へ遷移
  Future<void> _confirmAndStart() async {
    if (_selectedDate == null) return;

    // UserProviderを取得
    final userProvider = context.read<UserProvider>();
    final trophyProvider = context.read<TrophyProvider>();
    
    // ユーザーデータを作成して保存
    final userData = UserData(birthdate: _selectedDate!);
    await userProvider.setUserData(userData);

    // 過去のトロフィーをチェック
    await trophyProvider.checkPastTrophies(_selectedDate!, DateTime.now());

    // HomeScreenへ遷移
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffoldについて：
      // https://api.flutter.dev/flutter/material/Scaffold-class.html
      // Material Designの基本的な画面構造を提供
      body: SafeArea(
        // SafeAreaについて：
        // https://api.flutter.dev/flutter/widgets/SafeArea-class.html
        // ノッチやステータスバーを避けて表示
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // アプリ名
                  Text(
                    'Aliby',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // タイトル
                  Semantics(
                    header: true,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // スマホサイズの判定（幅600px未満）
                        final isMobile = constraints.maxWidth < 600;
                        
                        if (isMobile) {
                          // モバイルでは読点で折り返し
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'あなたの人生、',
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '何日目？',
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        } else {
                          // デスクトップでは1行表示
                          return Text(
                            'あなたの人生、何日目？',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 説明文
                  Text(
                    '生まれてからの経過時間をリアルタイムで表示し、\n特別な日にはトロフィーでお祝いするアプリです',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // 生年月日入力の案内
                  Text(
                    '生年月日を入力してください',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // 日付選択ボタンまたは選択された日付
                  if (_selectedDate == null)
                    Semantics(
                      button: true,
                      label: '生年月日を選択するボタン',
                      child: ElevatedButton.icon(
                        onPressed: () => _selectDate(context),
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('日付を選択'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        // 選択された日付の表示
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '生年月日',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Semantics(
                                label: '選択された生年月日: ${_selectedDate!.year}年${_selectedDate!.month}月${_selectedDate!.day}日',
                                child: Text(
                                  // 日付のフォーマット
                                  '${_selectedDate!.year}年${_selectedDate!.month}月${_selectedDate!.day}日',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 日付を変更するボタン
                        TextButton(
                          onPressed: () => _selectDate(context),
                          child: const Text('日付を変更'),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 48),

                  // 開始ボタン（日付が選択されている場合のみ表示）
                  if (_selectedDate != null)
                    Semantics(
                      button: true,
                      label: 'アプリを開始する',
                      child: FilledButton(
                        onPressed: _onStartPressed,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          '開始',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}