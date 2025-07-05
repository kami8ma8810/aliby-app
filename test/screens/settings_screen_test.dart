import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:aliby/screens/settings_screen.dart';
import 'package:aliby/providers/settings_provider.dart';
import 'package:aliby/providers/timer_provider.dart';
import 'package:aliby/providers/user_provider.dart';
import 'package:aliby/models/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsScreen', () {
    late SettingsProvider settingsProvider;
    late TimerProvider timerProvider;
    late UserProvider userProvider;

    setUp(() {
      // SharedPreferencesのモックを初期化
      SharedPreferences.setMockInitialValues({});
      settingsProvider = SettingsProvider();
      timerProvider = TimerProvider();
      userProvider = UserProvider();
    });

    tearDown(() {
      timerProvider.dispose();
    });

    /// テスト用のウィジェットを作成
    Widget createTestWidget() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
            ChangeNotifierProvider<TimerProvider>.value(value: timerProvider),
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
          ],
          child: const SettingsScreen(),
        ),
      );
    }

    testWidgets('should display app bar with title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('設定'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display dark mode switch', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('ダークモード'), findsOneWidget);
      expect(find.byType(Switch), findsWidgets);
      
      // ダークモードのスイッチを見つける
      final darkModeSwitch = find.byType(Switch).first;
      expect(darkModeSwitch, findsOneWidget);
    });

    testWidgets('should toggle dark mode when switch is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      expect(settingsProvider.isDarkMode, isFalse);

      // Act
      final darkModeSwitch = find.byType(Switch).first;
      await tester.tap(darkModeSwitch);
      await tester.pump();

      // Assert
      expect(settingsProvider.isDarkMode, isTrue);
    });

    testWidgets('should display realtime display switch', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('リアルタイム表示'), findsOneWidget);
      expect(find.text('経過時間を毎秒更新します'), findsOneWidget);
      
      // リアルタイム表示のスイッチを見つける
      final realtimeSwitch = find.byType(Switch).last;
      expect(realtimeSwitch, findsOneWidget);
    });

    testWidgets('should toggle realtime display when switch is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      expect(settingsProvider.isRealtimeEnabled, isTrue);
      expect(timerProvider.isRunning, isFalse); // 初期状態では停止

      // タイマーを開始
      timerProvider.startTimer();
      expect(timerProvider.isRunning, isTrue);

      // Act - リアルタイム表示をOFFにする
      final realtimeSwitch = find.byType(Switch).last;
      await tester.tap(realtimeSwitch);
      await tester.pump();

      // Assert
      expect(settingsProvider.isRealtimeEnabled, isFalse);
      expect(timerProvider.isRunning, isFalse); // タイマーが停止している
    });

    testWidgets('should display app info section', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('アプリ情報'), findsOneWidget);
      expect(find.text('バージョン'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
    });

    testWidgets('should display birth date section', (WidgetTester tester) async {
      // Arrange - ユーザーデータを設定
      final birthdate = DateTime(2000, 1, 1);
      await userProvider.setUserData(UserData(birthdate: birthdate));

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('生年月日'), findsOneWidget);
      expect(find.text('2000年1月1日'), findsOneWidget);
      expect(find.text('生年月日は初期設定後は変更できません'), findsOneWidget);
    });

    testWidgets('should have proper layout on different screen sizes', (WidgetTester tester) async {
      // Test on different screen sizes
      for (final size in [
        const Size(320, 568), // iPhone SE
        const Size(414, 896), // iPhone 11
        const Size(768, 1024), // iPad
      ]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert - 主要な要素が表示されている
        expect(find.text('設定'), findsOneWidget);
        expect(find.text('ダークモード'), findsOneWidget);
        expect(find.text('リアルタイム表示'), findsOneWidget);
        
        // Clean up
        await tester.pumpWidget(Container());
      }
      
      // Reset view size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should reflect current dark mode state', (WidgetTester tester) async {
      // Arrange - ダークモードをONにする
      await settingsProvider.toggleDarkMode();

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - スイッチがONになっている
      final darkModeSwitch = tester.widget<Switch>(find.byType(Switch).first);
      expect(darkModeSwitch.value, isTrue);
    });

    testWidgets('should reflect current realtime display state', (WidgetTester tester) async {
      // Arrange - リアルタイム表示をOFFにする
      await settingsProvider.toggleRealtimeDisplay();

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - スイッチがOFFになっている
      final realtimeSwitch = tester.widget<Switch>(find.byType(Switch).last);
      expect(realtimeSwitch.value, isFalse);
    });
  });
}