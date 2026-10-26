import 'package:intl/intl.dart';

final NumberFormat _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp',
  decimalDigits: 0,
);

String formatRupiah(num nilai) => _rupiah.format(nilai);

String formatTanggal(String tanggal) {
  // 'YYYY-MM-DD' -> 'Sen, 08 Okt 2026'
  try {
    final d = DateFormat('yyyy-MM-dd').parse(tanggal);
    return DateFormat('EEE, d MMM yyyy', 'id_ID').format(d);
  } catch (_) {
    return tanggal;
  }
}

String formatTanggalPanjang(String datetime) {
  // 'YYYY-MM-DD HH:MM:SS'
  try {
    final d = DateFormat('yyyy-MM-dd HH:mm:ss').parse(datetime);
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(d);
  } catch (_) {
    return datetime;
  }
}
