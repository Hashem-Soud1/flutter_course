import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? user;
  Map<String, dynamic>? userData;
  bool isAdmin = false;
  bool isLoading = true;

  AuthProvider() {
    _authService.authStateChanges.listen((User? newUser) async {
      user = newUser;
      if (user != null) {
        await _loadUserData();
      } else {
        userData = null;
        isAdmin = false;
      }
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    try {
      final snapshot = await _authService.getUserData(user!.uid);
      if (snapshot.exists) {
        userData = snapshot.data() as Map<String, dynamic>;
        isAdmin = userData?['role'] == 'admin';
      }
    } catch (_) {
      userData = null;
      isAdmin = false;
    }
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      await _authService.signIn(email, password);
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String gender,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
        gender: gender,
      );
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phoneNumber,
    required String gender,
    required String country,
  }) async {
    if (user == null) return;
    await _authService.updateUserProfile(user!.uid, {
      'name': name,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'country': country,
    });
    await _loadUserData();
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}
