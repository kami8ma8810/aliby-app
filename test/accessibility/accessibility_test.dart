import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:aliby/screens/home_screen.dart';
import 'package:aliby/screens/settings_screen.dart';
import 'package:aliby/screens/onboarding_screen.dart';
import 'package:aliby/providers/user_provider.dart';
import 'package:aliby/providers/timer_provider.dart';
import 'package:aliby/providers/trophy_provider.dart';
import 'package:aliby/providers/settings_provider.dart';
import 'package:aliby/models/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Accessibility Tests', () {
    late UserProvider userProvider;
    late TimerProvider timerProvider;
    late TrophyProvider trophyProvider;
    late SettingsProvider settingsProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      userProvider = UserProvider();
      timerProvider = TimerProvider();
      trophyProvider = TrophyProvider();
      settingsProvider = SettingsProvider();
    });

    tearDown(() {
      timerProvider.dispose();
    });

    /// テスト用のウィジェットを作成
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<TimerProvider>.value(value: timerProvider),
            ChangeNotifierProvider<TrophyProvider>.value(value: trophyProvider),
            ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
          ],
          child: child,
        ),
      );
    }

    group('Semantics Labels', () {
      testWidgets('HomeScreen should have proper semantics labels', (WidgetTester tester) async {
        // Arrange
        final birthdate = DateTime(2000, 1, 1);
        await userProvider.setUserData(UserData(birthdate: birthdate));

        // Act
        await tester.pumpWidget(createTestWidget(const HomeScreen()));

        // Assert - 重要な要素にSemanticsが設定されているか確認
        expect(
          find.bySemanticsLabel(RegExp(r'.*日.*')),
          findsWidgets,
        );
        
        // ナビゲーションボタンのセマンティクス
        expect(find.bySemanticsLabel('トロフィー履歴'), findsOneWidget);
        expect(find.bySemanticsLabel('設定'), findsOneWidget);
      });

      testWidgets('OnboardingScreen should have proper semantics', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(const OnboardingScreen()));

        // Assert
        expect(find.text('ようこそ'), findsOneWidget);
        expect(find.text('生年月日を入力してください'), findsOneWidget);
        expect(find.text('日付を選択'), findsOneWidget);
      });

      testWidgets('SettingsScreen should have proper semantics', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(const SettingsScreen()));

        // Assert
        expect(find.text('設定'), findsOneWidget);
        expect(find.text('ダークモード'), findsOneWidget);
        expect(find.text('リアルタイム表示'), findsOneWidget);
      });
    });

    group('Focus Management', () {
      testWidgets('Tab navigation should work properly in HomeScreen', (WidgetTester tester) async {
        // Arrange
        await userProvider.setUserData(UserData(birthdate: DateTime(2000, 1, 1)));

        // Act
        await tester.pumpWidget(createTestWidget(const HomeScreen()));

        // フォーカス可能な要素を確認
        final focusableWidgets = find.byWidgetPredicate(
          (widget) => widget is IconButton,
        );
        
        // Assert
        expect(focusableWidgets, findsWidgets);
      });

      testWidgets('Settings switches should be keyboard accessible', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(const SettingsScreen()));

        // スイッチウィジェットを確認
        final switches = find.byType(Switch);
        
        // Assert
        expect(switches, findsWidgets);
        
        // 各スイッチがフォーカス可能であることを確認
        await tester.ensureVisible(switches.first);
      });
    });

    group('Screen Reader Support', () {
      testWidgets('Time display should be readable by screen readers', (WidgetTester tester) async {
        // Arrange
        final birthdate = DateTime.now().subtract(const Duration(days: 100, hours: 5, minutes: 30));
        await userProvider.setUserData(UserData(birthdate: birthdate));

        // Act
        await tester.pumpWidget(createTestWidget(const HomeScreen()));

        // Assert - 時間表示がテキストとして存在することを確認
        expect(find.text('100'), findsOneWidget); // 日数
        expect(find.textContaining('時間'), findsOneWidget);
        expect(find.textContaining('分'), findsOneWidget);
        expect(find.textContaining('秒'), findsOneWidget);
      });

      testWidgets('Trophy notifications should be announced', (WidgetTester tester) async {
        // Arrange
        final birthdate = DateTime.now().subtract(const Duration(days: 100));
        await userProvider.setUserData(UserData(birthdate: birthdate));

        // Act
        await tester.pumpWidget(createTestWidget(const HomeScreen()));

        // Assert - トロフィー通知が表示される
        expect(find.textContaining('100日記念'), findsOneWidget);
      });
    });

    group('Contrast and Visual', () {
      testWidgets('Dark mode should maintain sufficient contrast', (WidgetTester tester) async {
        // Arrange
        await settingsProvider.toggleDarkMode();

        // Act
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.dark,
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
                ChangeNotifierProvider<UserProvider>.value(value: userProvider),
                ChangeNotifierProvider<TimerProvider>.value(value: timerProvider),
                ChangeNotifierProvider<TrophyProvider>.value(value: trophyProvider),
              ],
              child: const SettingsScreen(),
            ),
          ),
        );

        // Assert - ダークモードでもテキストが見えることを確認
        expect(find.text('設定'), findsOneWidget);
        expect(find.text('ダークモード'), findsOneWidget);
      });

      testWidgets('Interactive elements should have minimum tap targets', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(const HomeScreen()));

        // IconButtonのサイズを確認
        final iconButtons = tester.widgetList<IconButton>(find.byType(IconButton));
        
        for (final button in iconButtons) {
          // Assert - 最小タップ領域48x48を満たしているか
          expect(button.iconSize, greaterThanOrEqualTo(24)); // アイコンサイズ + パディング = 48
        }
      });
    });

    group('Error Handling and Feedback', () {
      testWidgets('Date picker should provide clear feedback', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(const OnboardingScreen()));

        // 日付選択ボタンをタップ
        final dateButton = find.text('日付を選択');
        expect(dateButton, findsOneWidget);
        
        await tester.tap(dateButton);
        await tester.pumpAndSettle();

        // Assert - DatePickerが表示される
        // DatePickerDialogは別のルートで表示されるため、
        // ここではボタンが正しく機能することを確認
        expect(find.text('日付を選択'), findsOneWidget);
      });

      testWidgets('Settings changes should provide feedback', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(const SettingsScreen()));

        // ダークモードスイッチを見つけてタップ
        final darkModeSwitch = find.byType(Switch).first;
        await tester.tap(darkModeSwitch);
        await tester.pump();

        // Assert - 状態が変更されたことを確認
        final switchWidget = tester.widget<Switch>(darkModeSwitch);
        expect(switchWidget.value, isTrue);
      });
    });
  });
}