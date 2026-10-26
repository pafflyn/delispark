import 'package:flutter/foundation.dart';

import '../models/reservasi.dart';
import '../services/reservasi_service.dart';

class ReservasiProvider extends ChangeNotifier {
  final ReservasiService _service;

  ReservasiProvider(this._service);

  List<Reservasi> daftar = [];
  bool loading = false;
  String? errorMessage;

  Future<void> load() async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      daftar = await _service.getDaftar();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<Reservasi> getDetail(int id) => _service.getDetail(id);

  Future<Reservasi> buat({required int idSesi, required int jumlahTiket}) async {
    final r = await _service.buat(idSesi: idSesi, jumlahTiket: jumlahTiket);
    await load();
    return r;
  }

  Future<String> bayar({
    required int idReservasi,
    required int jumlahBayar,
    required String metode,
  }) async {
    final pdf = await _service.bayar(
      idReservasi: idReservasi,
      jumlahBayar: jumlahBayar,
      metode: metode,
    );
    await load();
    return pdf;
  }
}
