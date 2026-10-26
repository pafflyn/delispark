import '../models/reservasi.dart';
import 'api_client.dart';

class ReservasiService {
  final ApiClient api;
  ReservasiService(this.api);

  Future<List<Reservasi>> getDaftar() async {
    final json = await api.get('/api/reservasi');
    final data = (json['data'] as List<dynamic>? ?? []);
    return data
        .map((e) => Reservasi.fromListJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Reservasi> getDetail(int id) async {
    final json = await api.get('/api/reservasi/$id');
    return Reservasi.fromDetailJson(json['data'] as Map<String, dynamic>);
  }

  Future<Reservasi> buat({required int idSesi, required int jumlahTiket}) async {
    final json = await api.post(
      '/api/reservasi',
      body: {'id_sesi': idSesi, 'jumlah_tiket': jumlahTiket},
    );
    final data = json['data'] as Map<String, dynamic>;
    return getDetail(int.parse(data['id_reservasi'].toString()));
  }

  Future<String> bayar({
    required int idReservasi,
    required int jumlahBayar,
    required String metode,
  }) async {
    final json = await api.post(
      '/api/pembayaran/$idReservasi',
      body: {
        'jumlah_bayar': jumlahBayar,
        'metode_pembayaran': metode,
      },
    );
    final data = json['data'] as Map<String, dynamic>;
    return (data['pdf_file'] ?? '') as String;
  }
}
