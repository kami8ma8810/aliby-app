import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/performance_utils.dart';
import 'trophy_history_screen.dart';
import 'settings_screen.dart';

/// アプリのメイン画面
/// 経過時間をリアルタイムで表示し、トロフィー情報も表示する
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Providerから状態を取得
    // context.watchについて：
    // https://pub.dev/documentation/provider/latest/provider/WatchContext/watch.html
    // 値の変更を監視し、変更があればウィジェットを再ビルドする
    final userProvider = context.watch<UserProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    
    // リアルタイム表示が有効な場合のみTimerProviderを監視
    if (settingsProvider.isRealtimeEnabled) {
      context.watch<TimerProvider>();
    }
    
    // ユーザーデータがない場合は何も表示しない（通常はOnboardingScreenに遷移）
    if (!userProvider.hasUserData) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 経過時間のコンポーネントを取得
    final ageComponents = userProvider.getAgeComponents();
    final days = ageComponents['days'] ?? 0;
    final hours = ageComponents['hours'] ?? 0;
    final minutes = ageComponents['minutes'] ?? 0;
    final seconds = ageComponents['seconds'] ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー部分
            _buildHeader(context, userProvider),
            
            // メインコンテンツ（経過時間表示）
            Expanded(
              child: Center(
                child: _buildTimeDisplay(context, days, hours, minutes, seconds),
              ),
            ),
            
            // トロフィー表示エリア
            _buildTrophyArea(context, days),
            
            // ボトムナビゲーション
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  /// ヘッダー部分を構築
  Widget _buildHeader(BuildContext context, UserProvider userProvider) {
    final birthdate = userProvider.userData!.birthdate;
    final birthdateText = '${birthdate.year}年${birthdate.month}月${birthdate.day}日生まれ';
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // アプリ名
          Text(
            'Aliby',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          
          // キャッチコピー（レスポンシブ対応）
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              
              if (isMobile) {
                // モバイルでは読点で折り返し
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'あなたの人生、',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      '何日目？',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                );
              } else {
                // デスクトップでは1行表示
                return Text(
                  'あなたの人生、何日目？',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          
          // 生年月日
          Text(
            birthdateText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 時間表示部分を構築
  Widget _buildTimeDisplay(BuildContext context, int days, int hours, int minutes, int seconds) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 「生まれてから」テキスト
        Text(
          '生まれてから',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        
        // 日数の大きな表示
        Semantics(
          label: '$days日経過',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              ExcludeSemantics(
                child: Text(
                  days.toString(),
                  style: PerformanceUtils.getOptimizedTextStyle(
                    Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 72 : 96,
                    ) ?? const TextStyle(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ExcludeSemantics(
                child: Text(
                  '日',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: isSmallScreen ? 28 : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // 時間、分、秒の表示
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimeComponent(context, hours, '時間'),
            SizedBox(width: isSmallScreen ? 8 : 16),
            _buildTimeComponent(context, minutes, '分'),
            SizedBox(width: isSmallScreen ? 8 : 16),
            _buildTimeComponent(context, seconds, '秒'),
          ],
        ),
      ],
    );
  }

  /// 時間コンポーネント（時間、分、秒）の表示
  Widget _buildTimeComponent(BuildContext context, int value, String unit) {
    // 画面幅に応じてパディングを調整
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 360 ? 8.0 : 16.0;
    
    return Semantics(
      label: '$value$unit',
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ExcludeSemantics(
              child: Text(
                value.toString().padLeft(2, '0'),
                style: PerformanceUtils.getOptimizedTextStyle(
                  Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth < 360 ? 20 : null,
                  ) ?? const TextStyle(),
                ),
              ),
            ),
            ExcludeSemantics(
              child: Text(
                unit,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// トロフィー表示エリア
  Widget _buildTrophyArea(BuildContext context, int days) {
    // 100日ごとの記念日判定（簡易実装）
    final bool hasTrophy = days > 0 && days % 100 == 0;
    
    if (!hasTrophy) {
      return const SizedBox(height: 80);
    }
    
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 32),
              const SizedBox(width: 8),
              Flexible(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    '100日記念！おめでとうございます！',
                    style: MediaQuery.of(context).size.width < 360
                        ? Theme.of(context).textTheme.bodySmall
                        : null,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ボトムナビゲーション
  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 履歴ボタン
          Semantics(
            label: 'トロフィー履歴',
            button: true,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TrophyHistoryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.history),
              iconSize: 32,
              tooltip: 'トロフィー履歴',
            ),
          ),
          
          // 設定ボタン
          Semantics(
            label: '設定',
            button: true,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
              iconSize: 32,
              tooltip: '設定',
            ),
          ),
        ],
      ),
    );
  }
}