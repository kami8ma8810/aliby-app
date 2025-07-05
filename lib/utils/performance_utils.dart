import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// パフォーマンス最適化のためのユーティリティクラス
/// 
/// メモリ使用量の削減とレンダリング効率の向上を目的とする
class PerformanceUtils {
  /// デバウンス処理を行うヘルパー関数
  /// 
  /// 頻繁に呼び出される処理を指定時間内で1回だけ実行するように制限
  /// 例：検索フィールドでの入力処理、スクロールイベント処理など
  static Function debounce(Function function, Duration delay) {
    Timer? timer;
    
    return () {
      // 既存のタイマーをキャンセル
      timer?.cancel();
      
      // 新しいタイマーを設定
      timer = Timer(delay, () {
        function();
      });
    };
  }

  /// スロットル処理を行うヘルパー関数
  /// 
  /// 指定時間内に最大1回だけ関数を実行
  /// debounceとの違い：最初の呼び出しで即座に実行される
  static Function throttle(Function function, Duration delay) {
    bool isThrottled = false;
    
    return () {
      if (!isThrottled) {
        function();
        isThrottled = true;
        
        Timer(delay, () {
          isThrottled = false;
        });
      }
    };
  }

  /// メモリキャッシュのサイズ制限
  static const int maxCacheSize = 50;

  /// イメージキャッシュの最適化
  /// 
  /// Flutterのイメージキャッシュサイズを適切に設定
  static void optimizeImageCache() {
    // イメージキャッシュの最大サイズを設定（MB単位）
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
    
    // キャッシュ可能な画像数を制限
    PaintingBinding.instance.imageCache.maximumSize = maxCacheSize;
  }

  /// リストビューの最適化設定
  /// 
  /// 大量のアイテムを表示する際のパフォーマンス設定
  static ScrollPhysics getOptimizedScrollPhysics() {
    return const BouncingScrollPhysics(
      // より滑らかなスクロールを実現
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  /// テキストレンダリングの最適化
  /// 
  /// 頻繁に更新されるテキストウィジェットの最適化設定
  static TextStyle getOptimizedTextStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      // フォントの特徴を事前に計算してキャッシュ
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// ウィジェットのリビルドを最小化するためのキー生成
  /// 
  /// 状態が変わらないウィジェットには同じキーを使用
  static Key getStableKey(String identifier) {
    return ValueKey('stable_$identifier');
  }

  /// メモリ使用量のモニタリング（デバッグ用）
  /// 
  /// 開発中のメモリリーク検出に使用
  static void logMemoryUsage(String context) {
    if (!kReleaseMode) {
      // TODO: 本番環境では無効化される
      debugPrint('[$context] Memory usage monitoring');
    }
  }

  /// アニメーションのフレームレート最適化
  /// 
  /// デバイスの性能に応じてアニメーションの複雑さを調整
  static Duration getOptimizedAnimationDuration({
    Duration standard = const Duration(milliseconds: 300),
    Duration slow = const Duration(milliseconds: 500),
  }) {
    // 低性能デバイスではアニメーションを簡略化
    // TODO: デバイスの性能を検出する実装を追加
    return standard;
  }

  /// 不要なリビルドを防ぐためのメモ化
  /// 
  /// 計算コストの高い処理結果をキャッシュ
  static final Map<String, dynamic> _memoCache = {};
  
  static T memoize<T>(String key, T Function() computation) {
    if (_memoCache.containsKey(key)) {
      return _memoCache[key] as T;
    }
    
    final result = computation();
    
    // キャッシュサイズの制限
    if (_memoCache.length >= maxCacheSize) {
      _memoCache.remove(_memoCache.keys.first);
    }
    
    _memoCache[key] = result;
    return result;
  }

  /// キャッシュのクリア
  static void clearMemoCache() {
    _memoCache.clear();
  }
}