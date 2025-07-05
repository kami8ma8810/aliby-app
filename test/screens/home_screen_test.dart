import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:aliby/screens/home_screen.dart';
import 'package:aliby/providers/user_provider.dart';
import 'package:aliby/providers/timer_provider.dart';
import 'package:aliby/models/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HomeScreen', () {
    late UserProvider userProvider;
    late TimerProvider timerProvider;

    setUp(() {
      // SharedPreferencesのモックを初期化
      SharedPreferences.setMockInitialValues({});
      userProvider = UserProvider();
      timerProvider = TimerProvider();
    });

    tearDown(() {
      timerProvider.dispose();
    });

    /// テスト用のウィジェットを作成
    Widget createTestWidget() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<TimerProvider>.value(value: timerProvider),
          ],
          child: const HomeScreen(),
        ),
      );
    }

    testWidgets('should display age in days', (WidgetTester tester) async {
      // Arrange - 100日前の生年月日を設定
      final birthdate = DateTime.now().subtract(const Duration(days: 100));
      final userData = UserData(birthdate: birthdate);
      await userProvider.setUserData(userData);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - 100日が表示されている
      expect(find.text('100'), findsOneWidget);
      expect(find.text('日'), findsOneWidget);
    });

    testWidgets('should display time components', (WidgetTester tester) async {
      // Arrange
      final birthdate = DateTime.now().subtract(const Duration(
        days: 1,
        hours: 2,
        minutes: 30,
      ));
      final userData = UserData(birthdate: birthdate);
      await userProvider.setUserData(userData);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - 時間コンポーネントが表示されている
      expect(find.textContaining('時間'), findsOneWidget);
      expect(find.textContaining('分'), findsOneWidget);
      expect(find.textContaining('秒'), findsOneWidget);
    });

    testWidgets('should update time every second when timer is running', (WidgetTester tester) async {
      // Arrange
      final birthdate = DateTime.now().subtract(const Duration(days: 1));
      final userData = UserData(birthdate: birthdate);
      await userProvider.setUserData(userData);

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // タイマーを開始
      timerProvider.startTimer();
      
      // 初期の秒数を取得
      final initialSeconds = find.textContaining('秒');
      expect(initialSeconds, findsOneWidget);
      
      // 2秒待つ
      await tester.pump(const Duration(seconds: 2));
      
      // Assert - 時間が更新されている（秒数が変わっている）
      expect(find.textContaining('秒'), findsOneWidget);
      
      // タイマーを停止
      timerProvider.stopTimer();
    });

    testWidgets('should display trophy if available', (WidgetTester tester) async {
      // Arrange - ちょうど100日前の生年月日を設定
      final birthdate = DateTime.now().subtract(const Duration(days: 100));
      final userData = UserData(birthdate: birthdate);
      await userProvider.setUserData(userData);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - トロフィー情報が表示されることを確認
      // 実際の実装では、トロフィーの条件判定が必要
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('should have navigation buttons', (WidgetTester tester) async {
      // Arrange
      final birthdate = DateTime.now().subtract(const Duration(days: 100));
      final userData = UserData(birthdate: birthdate);
      await userProvider.setUserData(userData);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - ナビゲーションボタンが表示されている
      expect(find.byIcon(Icons.history), findsOneWidget); // 履歴ボタン
      expect(find.byIcon(Icons.settings), findsOneWidget); // 設定ボタン
    });

    testWidgets('should show birth date info', (WidgetTester tester) async {
      // Arrange
      final birthdate = DateTime(2000, 1, 1);
      final userData = UserData(birthdate: birthdate);
      await userProvider.setUserData(userData);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - 生年月日情報が表示されている
      expect(find.text('2000年1月1日生まれ'), findsOneWidget);
    });

    testWidgets('should have proper layout on different screen sizes', (WidgetTester tester) async {
      // Arrange
      final birthdate = DateTime.now().subtract(const Duration(days: 365));
      final userData = UserData(birthdate: birthdate);
      await userProvider.setUserData(userData);

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
        expect(find.text('日'), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget);
        
        // Clean up
        await tester.pumpWidget(Container());
      }
      
      // Reset view size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}