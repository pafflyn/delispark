import 'package:flutter/foundation.dart';

import '../models/sesi.dart';
import '../models/wahana.dart';
import '../services/catalog_service.dart';

class CatalogProvider extends ChangeNotifier {
  final CatalogService _service;

  CatalogProvider(this._service);

  List<Wahana> wahana = [];
  bool loading = false;
  String? errorMessage;

  Future<void> loadWahana() async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      wahana = await _service.getWahana();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<List<Sesi>> getSesi(int idWahana, String tanggal) =>
      _service.getSesi(idWahana, tanggal);

  List<String> get tanggalTersedia => _service.daftarTanggal();
}
