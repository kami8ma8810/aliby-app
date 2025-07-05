import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/user_provider.dart';

/// 設定画面
/// テーマの切り替えやリアルタイム表示のON/OFFなどの設定を行う
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // 表示設定セクション
          _buildSectionHeader(context, '表示設定'),
          _buildDarkModeSwitch(context),
          _buildRealtimeDisplaySwitch(context),
          const Divider(),
          
          // ユーザー情報セクション
          _buildSectionHeader(context, 'ユーザー情報'),
          _buildBirthDateInfo(context),
          const Divider(),
          
          // アプリ情報セクション
          _buildSectionHeader(context, 'アプリ情報'),
          _buildAppInfo(context),
        ],
      ),
    );
  }

  /// セクションヘッダー
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// ダークモード切り替えスイッチ
  Widget _buildDarkModeSwitch(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    
    return ListTile(
      leading: Icon(
        settingsProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text('ダークモード'),
      subtitle: Text(
        settingsProvider.isDarkMode ? 'ダークテーマを使用中' : 'ライトテーマを使用中',
      ),
      trailing: Switch(
        value: settingsProvider.isDarkMode,
        onChanged: (value) async {
          await settingsProvider.toggleDarkMode();
        },
      ),
    );
  }

  /// リアルタイム表示切り替えスイッチ
  Widget _buildRealtimeDisplaySwitch(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final timerProvider = context.watch<TimerProvider>();
    
    return ListTile(
      leading: Icon(
        Icons.timer,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text('リアルタイム表示'),
      subtitle: const Text('経過時間を毎秒更新します'),
      trailing: Switch(
        value: settingsProvider.isRealtimeEnabled,
        onChanged: (value) async {
          await settingsProvider.toggleRealtimeDisplay();
          
          // リアルタイム表示の設定に応じてタイマーを制御
          if (settingsProvider.isRealtimeEnabled) {
            timerProvider.startTimer();
          } else {
            timerProvider.stopTimer();
          }
        },
      ),
    );
  }

  /// 生年月日情報
  Widget _buildBirthDateInfo(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    
    if (!userProvider.hasUserData) {
      return const ListTile(
        leading: Icon(Icons.cake),
        title: Text('生年月日'),
        subtitle: Text('未設定'),
      );
    }
    
    final birthdate = userProvider.userData!.birthdate;
    final birthdateText = '${birthdate.year}年${birthdate.month}月${birthdate.day}日';
    
    return ListTile(
      leading: Icon(
        Icons.cake,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text('生年月日'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(birthdateText),
          const SizedBox(height: 4),
          Text(
            '生年月日は初期設定後は変更できません',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

  /// アプリ情報
  Widget _buildAppInfo(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('バージョン'),
          trailing: const Text('1.0.0'),
        ),
        ListTile(
          leading: Icon(
            Icons.description_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('ライセンス'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // ライセンス画面を表示
            showLicensePage(
              context: context,
              applicationName: 'Aliby',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2025 Aliby Project',
            );
          },
        ),
      ],
    );
  }
}