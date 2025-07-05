import 'package:flutter/foundation.dart';
import '../models/user_data.dart';
import '../services/storage_service.dart';

/// ユーザー情報の状態管理を行うProviderクラス
/// 
/// ChangeNotifierについて：
/// https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html
/// Providerパターンの基本となるクラス。状態が変更されたときに
/// リスナー（UIなど）に通知する仕組みを提供
class UserProvider extends ChangeNotifier {
  /// ユーザーデータを保持するプライベート変数
  /// _（アンダースコア）で始まる変数はDartではプライベート
  UserData? _userData;
  
  /// ストレージサービスのインスタンス
  final StorageService _storageService = StorageService();

  /// ユーザーデータのゲッター
  /// 外部からは読み取り専用でアクセス可能
  UserData? get userData => _userData;

  /// ユーザーデータが存在するかどうかを返すゲッター
  bool get hasUserData => _userData != null;

  /// 生まれてからの日数を返すゲッター
  /// userDataがnullの場合は0を返す
  int get ageInDays {
    if (_userData == null) return 0;
    return _userData!.ageInDays;
  }

  /// 詳細な経過時間を取得するメソッド
  /// userDataがnullの場合は空のMapを返す
  Map<String, int> getAgeComponents() {
    if (_userData == null) return {};
    return _userData!.getAgeComponents(DateTime.now());
  }

  /// ユーザーデータを設定し、永続化するメソッド
  /// 
  /// @param userData 設定するユーザーデータ
  Future<void> setUserData(UserData userData) async {
    _userData = userData;
    
    // ストレージに保存
    await _storageService.saveUserData(userData);
    
    // リスナーに変更を通知
    // これによりUIが再描画される
    notifyListeners();
  }

  /// ストレージからユーザーデータを読み込むメソッド
  /// アプリ起動時に呼び出される
  Future<void> loadUserData() async {
    _userData = await _storageService.loadUserData();
    
    // データが読み込まれた場合のみ通知
    if (_userData != null) {
      notifyListeners();
    }
  }

  /// ユーザーデータをクリアするメソッド
  /// ストレージからも削除される
  Future<void> clearUserData() async {
    _userData = null;
    
    // ストレージからも削除
    await _storageService.clearUserData();
    
    // リスナーに変更を通知
    notifyListeners();
  }

  /// Providerが破棄される際に呼ばれるメソッド
  /// リソースのクリーンアップに使用
  @override
  void dispose() {
    // 現在は特にクリーンアップすることはないが、
    // 将来的にTimerやStreamを使う場合はここで解放する
    super.dispose();
  }
}