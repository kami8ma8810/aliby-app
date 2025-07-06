import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/timer_provider.dart';
import 'providers/trophy_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'utils/performance_utils.dart';

/// アプリのエントリーポイント
/// 
/// runAppについて：
/// https://api.flutter.dev/flutter/widgets/runApp.html
void main() {
  // パフォーマンス最適化の初期化
  WidgetsFlutterBinding.ensureInitialized();
  PerformanceUtils.optimizeImageCache();
  
  runApp(const AlibyApp());
}

/// Alibyアプリのルートウィジェット
/// 
/// MultiProviderについて：
/// https://pub.dev/documentation/provider/latest/provider/MultiProvider-class.html
/// 複数のProviderを一度に設定できる
class AlibyApp extends StatelessWidget {
  const AlibyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // UserProviderを提供
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // TimerProviderを提供
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        // TrophyProviderを提供
        ChangeNotifierProvider(create: (_) => TrophyProvider()),
        // SettingsProviderを提供
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Aliby',
            
            // テーマ設定
            theme: ThemeData(
              // Material 3（Material You）デザインを使用
              useMaterial3: true,
              // シードカラーから自動的にカラースキームを生成
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
            ),
            
            // ダークテーマ設定
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
            ),
            
            // SettingsProviderの設定に従ってテーマを切り替え
            themeMode: settingsProvider.themeMode,
            
            // 初期画面の設定
            home: const InitialScreen(),
            
            // デバッグバナーを非表示
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

/// 初期画面を決定するウィジェット
/// ユーザーデータの有無によってOnboardingScreenかHomeScreenを表示
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserData();
  }

  /// ユーザーデータの存在を確認し、適切な画面へ遷移
  Future<void> _checkUserData() async {
    final userProvider = context.read<UserProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    
    // 設定を初期化
    await settingsProvider.initialize();
    
    // ユーザーデータを読み込み
    await userProvider.loadUserData();
    
    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // ローディング画面
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ユーザーデータの有無で画面を切り替え
    final userProvider = context.watch<UserProvider>();
    
    if (userProvider.hasUserData) {
      // ビルド完了後にタイマー開始とトロフィーチェックを実行
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // リアルタイム表示が有効な場合のみタイマーを開始
        final settingsProvider = context.read<SettingsProvider>();
        if (settingsProvider.isRealtimeEnabled) {
          final timerProvider = context.read<TimerProvider>();
          timerProvider.startTimer();
        }
        
        // トロフィーをチェック
        final trophyProvider = context.read<TrophyProvider>();
        trophyProvider.checkAndAddTrophy(
          userProvider.userData!.birthdate,
          DateTime.now(),
        );
      });
      
      return const HomeScreen();
    } else {
      return const OnboardingScreen();
    }
  }
}
