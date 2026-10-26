import 'package:delis_park/widgets/format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  test('formatRupiah menyusun rupiah tanpa desimal', () {
    expect(formatRupiah(150000), 'Rp150.000');
  });

  test('formatTanggal memformat YYYY-MM-DD', () {
    final hasil = formatTanggal('2026-10-08');
    expect(hasil, isNot('2026-10-08'));
    expect(hasil, contains('2026'));
  });

  test('formatTanggalPanjang memformat datetime MySQL', () {
    final hasil = formatTanggalPanjang('2026-10-08 09:00:00');
    expect(hasil, contains('2026'));
    expect(hasil, contains('09:00'));
  });
}
