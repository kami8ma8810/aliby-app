import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_data.dart';

/// ローカルストレージへのデータ保存・読み込みを管理するサービスクラス
/// 
/// SharedPreferencesについて：
/// https://pub.dev/packages/shared_preferences
/// iOSではNSUserDefaults、AndroidではSharedPreferencesを使用する
/// クロスプラットフォームなKey-Value型のストレージ
class StorageService {
  /// SharedPreferencesで使用するキーの定義
  /// staticは静的メンバー（クラスレベルの定数）
  /// constはコンパイル時定数
  static const String _userDataKey = 'user_data';

  /// ユーザーデータを保存する
  /// 
  /// asyncキーワード：非同期関数を定義
  /// Future<bool>：非同期で真偽値を返すことを示す
  /// https://dart.dev/codelabs/async-await
  Future<bool> saveUserData(UserData userData) async {
    try {
      // SharedPreferencesのインスタンスを取得
      // awaitで非同期処理の完了を待つ
      final prefs = await SharedPreferences.getInstance();
      
      // UserDataをJSON文字列に変換して保存
      // json.encode()でMap型をJSON文字列に変換
      final jsonString = json.encode(userData.toJson());
      
      // 文字列として保存（SharedPreferencesは基本的な型のみ保存可能）
      return await prefs.setString(_userDataKey, jsonString);
    } catch (e) {
      // エラーが発生した場合はfalseを返す
      print('Error saving user data: $e');
      return false;
    }
  }

  /// 保存されたユーザーデータを読み込む
  /// 
  /// Future<UserData?>：UserDataまたはnullを非同期で返す
  /// ?はnull許容型を示す（Dartのnull safety機能）
  /// https://dart.dev/null-safety
  Future<UserData?> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 保存された文字列を取得
      final jsonString = prefs.getString(_userDataKey);
      
      // データが存在しない場合はnullを返す
      if (jsonString == null) {
        return null;
      }
      
      // JSON文字列をMap型に変換してUserDataを作成
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return UserData.fromJson(jsonData);
    } catch (e) {
      print('Error loading user data: $e');
      return null;
    }
  }

  /// ユーザーデータが存在するかチェック
  Future<bool> hasUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userDataKey);
  }

  /// ユーザーデータを削除
  Future<bool> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_userDataKey);
    } catch (e) {
      print('Error clearing user data: $e');
      return false;
    }
  }
}