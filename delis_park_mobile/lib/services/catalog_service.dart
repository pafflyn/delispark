import '../models/sesi.dart';
import '../models/wahana.dart';
import 'api_client.dart';

class CatalogService {
  final ApiClient api;
  CatalogService(this.api);

  Future<List<Wahana>> getWahana() async {
    final json = await api.get('/api/wahana', withAuth: false);
    final data = (json['data'] as List<dynamic>? ?? []);
    return data
        .map((row) => Wahana.fromListJson(row as List<dynamic>))
        .where((w) => w.status == 'aktif')
        .toList();
  }

  Future<Wahana> getWahanaDetail(int id) async {
    final json = await api.get('/api/wahana/$id');
    return Wahana.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<List<Sesi>> getSesi(int idWahana, String tanggal) async {
    final json = await api.get('/api/sesi/$idWahana/$tanggal', withAuth: false);
    final data = (json['data'] as List<dynamic>? ?? []);
    return data.map((row) => Sesi.fromListJson(row as List<dynamic>)).toList();
  }

  /// 14 hari ke depan: [YYYY-MM-DD, ...]
  List<String> daftarTanggal({int hari = 14}) {
    final now = DateTime.now();
    return List.generate(
      hari,
      (i) {
        final d = now.add(Duration(days: i));
        return '${d.year.toString().padLeft(4, '0')}-'
            '${d.month.toString().padLeft(2, '0')}-'
            '${d.day.toString().padLeft(2, '0')}';
      },
    );
  }
}
