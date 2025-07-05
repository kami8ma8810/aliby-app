import 'dart:async';
import 'package:flutter/foundation.dart';

/// タイマー機能を管理するProviderクラス
/// 1秒ごとに現在時刻を更新し、リアルタイム表示を実現
/// 
/// Timer.periodicについて：
/// https://api.dart.dev/stable/dart-async/Timer/Timer.periodic.html
class TimerProvider extends ChangeNotifier {
  /// 定期的に実行されるタイマー
  Timer? _timer;
  
  /// 現在の時刻
  DateTime _currentTime = DateTime.now();
  
  /// タイマーが動作中かどうか
  bool _isRunning = false;

  /// 現在時刻のゲッター
  DateTime get currentTime => _currentTime;
  
  /// タイマーが動作中かどうかのゲッター
  bool get isRunning => _isRunning;

  /// タイマーを開始するメソッド
  /// すでに動作中の場合は何もしない
  void startTimer() {
    if (_isRunning) return;
    
    _isRunning = true;
    
    // Timer.periodicで1秒ごとに処理を実行
    // 第1引数: 実行間隔（Duration）
    // 第2引数: 実行する処理（コールバック関数）
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateTime();
    });
    
    // 開始直後に一度更新
    updateTime();
  }

  /// タイマーを停止するメソッド
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }

  /// タイマーの開始/停止を切り替えるメソッド
  void toggleTimer() {
    if (_isRunning) {
      stopTimer();
    } else {
      startTimer();
    }
  }

  /// 現在時刻を更新するメソッド
  /// タイマーから定期的に呼ばれる
  void updateTime() {
    _currentTime = DateTime.now();
    // リスナー（UI）に変更を通知
    notifyListeners();
  }

  /// Providerが破棄される際に呼ばれるメソッド
  /// タイマーを確実に停止してメモリリークを防ぐ
  /// 
  /// disposeの重要性について：
  /// https://api.flutter.dev/flutter/widgets/State/dispose.html
  /// タイマーやアニメーションコントローラーなど、
  /// システムリソースを使用するオブジェクトは必ず解放する
  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    super.dispose();
  }
}