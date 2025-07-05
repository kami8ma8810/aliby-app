import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/timer_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

/// アプリのエントリーポイント
/// 
/// runAppについて：
/// https://api.flutter.dev/flutter/widgets/runApp.html
void main() {
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
      ],
      child: MaterialApp(
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
        
        // システムの設定に従ってテーマを切り替え
        themeMode: ThemeMode.system,
        
        // 初期画面の設定
        home: const InitialScreen(),
        
        // デバッグバナーを非表示
        debugShowCheckedModeBanner: false,
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
      // タイマーを開始
      final timerProvider = context.read<TimerProvider>();
      timerProvider.startTimer();
      
      return const HomeScreen();
    } else {
      return const OnboardingScreen();
    }
  }
}
