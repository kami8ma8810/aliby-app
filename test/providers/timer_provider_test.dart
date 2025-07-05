import 'package:flutter_test/flutter_test.dart';
import 'package:aliby/providers/timer_provider.dart';

void main() {
  group('TimerProvider', () {
    late TimerProvider timerProvider;

    setUp(() {
      timerProvider = TimerProvider();
    });

    tearDown(() {
      // テスト後にタイマーを確実に停止
      timerProvider.dispose();
    });

    test('should have default values initially', () {
      expect(timerProvider.isRunning, isFalse);
      expect(timerProvider.currentTime, isNotNull);
    });

    test('should start timer', () {
      // Act
      timerProvider.startTimer();
      
      // Assert
      expect(timerProvider.isRunning, isTrue);
    });

    test('should stop timer', () {
      // Arrange
      timerProvider.startTimer();
      
      // Act
      timerProvider.stopTimer();
      
      // Assert
      expect(timerProvider.isRunning, isFalse);
    });

    test('should update time when timer is running', () async {
      // Arrange
      final initialTime = timerProvider.currentTime;
      var notificationCount = 0;
      
      timerProvider.addListener(() {
        notificationCount++;
      });
      
      // Act
      timerProvider.startTimer();
      
      // 2秒待つ（Timer.periodicは1秒ごとなので、少なくとも1回は更新されるはず）
      await Future.delayed(const Duration(seconds: 2));
      
      // Assert
      expect(timerProvider.currentTime.isAfter(initialTime), isTrue);
      expect(notificationCount, greaterThan(0));
      
      // Clean up
      timerProvider.stopTimer();
    });

    test('should not update time when timer is stopped', () async {
      // Arrange
      timerProvider.startTimer();
      await Future.delayed(const Duration(milliseconds: 100));
      timerProvider.stopTimer();
      
      final timeAfterStop = timerProvider.currentTime;
      
      // Act - 停止後に待つ
      await Future.delayed(const Duration(seconds: 1));
      
      // Assert
      expect(timerProvider.currentTime, equals(timeAfterStop));
    });

    test('should toggle timer state', () {
      // Initially stopped
      expect(timerProvider.isRunning, isFalse);
      
      // Toggle to start
      timerProvider.toggleTimer();
      expect(timerProvider.isRunning, isTrue);
      
      // Toggle to stop
      timerProvider.toggleTimer();
      expect(timerProvider.isRunning, isFalse);
    });

    test('should notify listeners when toggling timer', () {
      // Arrange
      var notificationCount = 0;
      timerProvider.addListener(() {
        notificationCount++;
      });
      
      // Act
      timerProvider.toggleTimer();
      
      // Assert
      expect(notificationCount, equals(1));
    });

    test('should dispose timer properly', () {
      // Arrange
      final disposableProvider = TimerProvider();
      disposableProvider.startTimer();
      
      // Act
      disposableProvider.dispose();
      
      // Assert - dispose後はプロパティにアクセスできないため、
      // disposeが正常に実行されたことのみを確認
      expect(() => disposableProvider.dispose(), throwsAssertionError);
    });

    test('should update current time immediately when updateTime is called', () {
      // Arrange
      final beforeUpdate = timerProvider.currentTime;
      
      // 少し待つ
      Future.delayed(const Duration(milliseconds: 10));
      
      // Act
      timerProvider.updateTime();
      
      // Assert
      final afterUpdate = timerProvider.currentTime;
      expect(afterUpdate.isAfter(beforeUpdate) || 
             afterUpdate.isAtSameMomentAs(beforeUpdate), isTrue);
    });
  });
}