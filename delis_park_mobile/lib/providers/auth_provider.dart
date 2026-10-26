import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, unauthenticated, authenticated }

class AuthProvider extends ChangeNotifier {
  final ApiClient api;
  late final AuthService _auth;

  AuthProvider(this.api) {
    _auth = AuthService(api);
  }

  AuthStatus status = AuthStatus.initial;
  User? user;
  String? errorMessage;

  bool get isLoggedIn => status == AuthStatus.authenticated;

  Future<void> init() async {
    await api.loadToken();
    if (!api.isLoggedIn) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      user = await _auth.me();
      status = AuthStatus.authenticated;
    } catch (_) {
      await api.clearToken();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    return _run(() async {
      final (_, u) = await _auth.login(email, password);
      user = u;
    });
  }

  Future<bool> register({
    required String nama,
    required String email,
    required String password,
    String? nomorTelepon,
    String? alamatRumah,
  }) async {
    return _run(() async {
      final (_, u) = await _auth.register(
        nama: nama,
        email: email,
        password: password,
        nomorTelepon: nomorTelepon,
        alamatRumah: alamatRumah,
      );
      user = u;
    });
  }

  Future<bool> updateProfil({
    required String nama,
    String? nomorTelepon,
    String? alamatRumah,
    String? password,
    String? oldPassword,
  }) async {
    return _run(() async {
      user = await _auth.updateProfil(
        nama: nama,
        nomorTelepon: nomorTelepon,
        alamatRumah: alamatRumah,
        password: password,
        oldPassword: oldPassword,
      );
    });
  }

  Future<void> logout() async {
    await _auth.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      errorMessage = e.toString();
      status = api.isLoggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      return false;
    } finally {
      notifyListeners();
    }
  }
}
