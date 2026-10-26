import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient api;
  AuthService(this.api);

  Future<(String token, User user)> login(String email, String password) async {
    final json = await api.post(
      '/api/login',
      body: {'email': email, 'password': password},
      withAuth: false,
    );
    final token = json['token'] as String;
    await api.saveToken(token);
    final user = User.fromJson(json['data'] as Map<String, dynamic>);
    return (token, user);
  }

  Future<(String token, User user)> register({
    required String nama,
    required String email,
    required String password,
    String? nomorTelepon,
    String? alamatRumah,
  }) async {
    final json = await api.post(
      '/api/register',
      body: {
        'nama_pengguna': nama,
        'email': email,
        'password': password,
        if (nomorTelepon != null && nomorTelepon.isNotEmpty)
          'nomor_telepon': nomorTelepon,
        if (alamatRumah != null && alamatRumah.isNotEmpty)
          'alamat_rumah': alamatRumah,
      },
      withAuth: false,
    );
    final token = json['token'] as String;
    await api.saveToken(token);
    final user = User.fromJson(json['data'] as Map<String, dynamic>);
    return (token, user);
  }

  Future<User> me() async {
    final json = await api.get('/api/me');
    return User.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<User> updateProfil({
    required String nama,
    String? nomorTelepon,
    String? alamatRumah,
    String? password,
    String? oldPassword,
  }) async {
    await api.put(
      '/api/profil',
      body: {
        'nama_pengguna': nama,
        'nomor_telepon': nomorTelepon ?? '',
        'alamat_rumah': alamatRumah ?? '',
        if (password != null && password.isNotEmpty) ...{
          'password': password,
          'old_password': oldPassword ?? '',
        },
      },
    );
    return me();
  }

  Future<void> logout() => api.clearToken();
}
