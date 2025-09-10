import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('token');
      final storedUser = prefs.getString('user');

      if (storedToken != null && storedUser != null) {
        // Validate token structure
        final tokenParts = storedToken.split('.');
        if (tokenParts.length == 3) {
          try {
            final payload = json.decode(
              utf8.decode(base64Url.decode(base64Url.normalize(tokenParts[1]))),
            );
            final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
            
            // Check if token is expired (with 1 minute buffer)
            if (payload['exp'] != null && payload['exp'] > (currentTime + 60)) {
              _token = storedToken;
              _user = User.fromJson(json.decode(storedUser));
              _isAuthenticated = true;
              print('Valid token found, user authenticated');
            } else {
              // Token is expired
              await _clearStoredAuth();
              print('Token expired, clearing storage');
            }
          } catch (e) {
            // Error parsing token
            await _clearStoredAuth();
            print('Error parsing token: $e');
          }
        } else {
          // Invalid token format
          await _clearStoredAuth();
          print('Invalid token format');
        }
      }
    } catch (e) {
      print('Error loading stored auth: $e');
    }
    notifyListeners();
  }

  Future<void> _clearStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    _token = null;
    _user = null;
    _isAuthenticated = false;
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);
      
      final userData = User(
        id: response['id'],
        email: response['email'],
        name: response['name'],
        role: response['role'],
        department: response['department'],
        className: response['className'],
        phoneNumber: response['phoneNumber'],
        verified: response['verified'],
      );

      _user = userData;
      _token = response['accessToken'];
      _isAuthenticated = true;

      // Store in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('user', json.encode(userData.toJson()));

      print('Login successful, user data: ${userData.toJson()}');
    } catch (e) {
      print('Login error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.register(userData);
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOTP(String email, String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.verifyOTP(email, otp);
    } catch (e) {
      print('OTP verification error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    print('Logging out user');
    await _clearStoredAuth();
    notifyListeners();
  }

  String getInitialRoute() {
    if (!_isAuthenticated || _user == null) {
      return '/landing';
    }

    switch (_user!.role) {
      case 'STUDENT':
        return '/student';
      case 'PROFESSOR':
        return '/professor';
      case 'ALUMNI':
        return '/alumni';
      case 'MANAGEMENT':
        return '/management';
      default:
        return '/landing';
    }
  }
}