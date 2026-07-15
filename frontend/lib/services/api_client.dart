import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  String? _token;
  String? _email;

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080';
      }
    } catch (_) {}
    return 'http://localhost:8080';
  }

  String? get token => _token;
  String? get email => _email;
  bool get isLoggedIn => _token != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _email = prefs.getString('auth_email');
  }

  Future<void> saveSession(String token, String email) async {
    _token = token;
    _email = email;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('auth_email', email);
  }

  Future<void> clearSession() async {
    _token = null;
    _email = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_email');
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<http.Response> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    return http.get(url, headers: _headers());
  }

  Future<http.Response> post(String path, [Map<String, dynamic>? body]) async {
    final url = Uri.parse('$baseUrl$path');
    return http.post(
      url,
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$path');
    return http.put(url, headers: _headers(), body: jsonEncode(body));
  }

  Future<http.Response> delete(String path) async {
    final url = Uri.parse('$baseUrl$path');
    return http.delete(url, headers: _headers());
  }
}
