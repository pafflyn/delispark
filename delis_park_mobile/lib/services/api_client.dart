import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, [this.statusCode = 0]);

  @override
  String toString() => message;
}

class ApiClient {
  String? _token;

  static const _prefsKey = 'jwt_token';

  String? get token => _token;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_prefsKey);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  Map<String, String> _headers({bool withAuth = true}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (withAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  /// GET/POST/PUT/PUT. Mengembalikan map JSON root dari respons.
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    final uri = Uri.parse(ApiConfig.url(path));
    final headers = _headers(withAuth: withAuth);

    http.Response res;
    try {
      switch (method) {
        case 'POST':
          res = await http
              .post(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(const Duration(seconds: 30));
        case 'PUT':
          res = await http
              .put(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(const Duration(seconds: 30));
        case 'DELETE':
          res = await http
              .delete(uri, headers: headers)
              .timeout(const Duration(seconds: 30));
        default:
          res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server. Pastikan Flask berjalan.');
    }

    Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Respons server tidak valid.', res.statusCode);
    }

    if (res.statusCode >= 400) {
      final pesan = json['pesan']?.toString() ?? 'Terjadi kesalahan (${res.statusCode}).';
      throw ApiException(pesan, res.statusCode);
    }
    return json;
  }

  Future<Map<String, dynamic>> get(String path, {bool withAuth = true}) =>
      request('GET', path, withAuth: withAuth);

  Future<Map<String, dynamic>> post(String path,
          {Map<String, dynamic>? body, bool withAuth = true}) =>
      request('POST', path, body: body, withAuth: withAuth);

  Future<Map<String, dynamic>> put(String path,
          {Map<String, dynamic>? body, bool withAuth = true}) =>
      request('PUT', path, body: body, withAuth: withAuth);
}
