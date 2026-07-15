import 'dart:convert';
import 'api_client.dart';

class AuthService {
  bool get isLoggedIn => ApiClient.instance.isLoggedIn;

  String? get currentUserEmail => ApiClient.instance.email;

  Future<String?> login(String email, String password) async {
    try {
      final response = await ApiClient.instance.post('/api/auth/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['token'] as String;
        final userEmail = data['email'] as String;
        await ApiClient.instance.saveSession(token, userEmail);
        return null;
      } else {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return data['error'] as String? ?? 'Failed to log in.';
        } catch (_) {
          return 'Failed to log in: ${response.statusCode}';
        }
      }
    } catch (e) {
      return 'Network error: could not connect to server.';
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      final response = await ApiClient.instance.post('/api/auth/signup', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['token'] as String;
        final userEmail = data['email'] as String;
        await ApiClient.instance.saveSession(token, userEmail);
        return null;
      } else {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return data['error'] as String? ?? 'Failed to sign up.';
        } catch (_) {
          return 'Failed to sign up: ${response.statusCode}';
        }
      }
    } catch (e) {
      return 'Network error: could not connect to server.';
    }
  }

  Future<void> logout() async {
    await ApiClient.instance.clearSession();
  }
}