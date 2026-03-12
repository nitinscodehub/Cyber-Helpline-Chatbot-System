import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null && _currentUser!.name != 'Guest User';
  String? get error => _error;

  UserProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user');
      
      if (userData != null) {
        _currentUser = User.fromJson(jsonDecode(userData));
      } else {
        _currentUser = User.guest();
        await _saveUser(_currentUser!);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentUser = User.guest();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = user;
      await _saveUser(user);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Demo login - in real app, this would call an API
      if (email == 'demo@example.com' && password == 'password') {
        _currentUser = User(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Demo User',
          phone: '9876543210',
          email: email,
          createdAt: DateTime.now(),
        );
        await _saveUser(_currentUser!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      _currentUser = User.guest();
      await _saveUser(_currentUser!);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void incrementChatCount() {
    if (_currentUser != null) {
      _currentUser!.totalChats++;
      updateUser(_currentUser!);
    }
  }

  void incrementComplaintCount() {
    if (_currentUser != null) {
      _currentUser!.totalComplaints++;
      _currentUser!.safetyScore = (_currentUser!.safetyScore - 5).clamp(0, 100);
      updateUser(_currentUser!);
    }
  }

  void updateSafetyScore(int change) {
    if (_currentUser != null) {
      _currentUser!.safetyScore = (_currentUser!.safetyScore + change).clamp(0, 100);
      updateUser(_currentUser!);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}