import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveBoolValue(String key, bool value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

// 存储整数
Future<void> saveIntValue(String key, int value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt(key, value);
}

// 存储字符串
Future<void> saveStringValue(String key, String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

// 存储字符串列表
Future<void> saveStringListValue(String key, List<String> value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(key, value);
}

// 读取布尔值
Future<bool?> getBoolValue(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key);
}

// 读取整数
Future<int?> getIntValue(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(key);
}

// 读取字符串
Future<String?> getStringValue(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

// 读取字符串列表
Future<List<String>?> getStringListValue(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(key);
}