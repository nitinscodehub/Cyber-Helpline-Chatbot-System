import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();
  
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Save chat messages
  Future<void> saveMessages(List<Message> messages) async {
    final messagesJson = messages.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs.setStringList('chat_messages', messagesJson);
  }
  
  // Load chat messages
  Future<List<Message>> loadMessages() async {
    final messagesJson = await _prefs.getStringList('chat_messages');
    if (messagesJson != null) {
      return messagesJson
          .map((m) => Message.fromJson(jsonDecode(m)))
          .toList();
    }
    return [];
  }
  
  // Save user data securely
  Future<void> saveUser(User user) async {
    await _secureStorage.write(
      key: 'user_data',
      value: jsonEncode(user.toJson()),
    );
  }
  
  // Load user data
  Future<User?> loadUser() async {
    final userData = await _secureStorage.read(key: 'user_data');
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }
  
  // Save theme preference
  Future<void> saveTheme(bool isDarkMode) async {
    await _prefs.setBool('is_dark_mode', isDarkMode);
  }
  
  // Load theme preference
  Future<bool> loadTheme() async {
    return await _prefs.getBool('is_dark_mode') ?? false;
  }
  
  // Save language preference
  Future<void> saveLanguage(String language) async {
    await _prefs.setString('language', language);
  }
  
  // Load language preference
  Future<String> loadLanguage() async {
    return await _prefs.getString('language') ?? 'hi';
  }
  
  // Clear all data
  Future<void> clearAllData() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }
}