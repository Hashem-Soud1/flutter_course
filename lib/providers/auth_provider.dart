import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? user;
  bool isAdmin = false;
  bool isLoading = true;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    user = _authService.currentUser;
    if (user != null) {
      await _checkAdminStatus();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> _checkAdminStatus() async {
    if (user == null) return;
    try {
      final userData = await _authService.getUserData(user!.uid);
      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>;
        isAdmin = data['role'] == 'admin';
      }
    } catch (e) {
      isAdmin = false;
    }
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      final credential = await _authService.signIn(email, password);
      user = credential.user;
      if (user != null) {
        await _checkAdminStatus();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    isLoading = true;
    notifyListeners();
    try {
      final credential = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );
      user = credential.user;
      isAdmin = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    user = null;
    isAdmin = false;
    notifyListeners();
  }
}
