class Sesi {
  final int id;
  final String nama;
  final int kuota;
  final int harga;
  final String waktuMulai;
  final String waktuSelesai;

  const Sesi({
    required this.id,
    required this.nama,
    required this.kuota,
    required this.harga,
    required this.waktuMulai,
    required this.waktuSelesai,
  });

  /// dari GET `/api/sesi/<id_wahana>/<tanggal>`
  /// berupa array: `[id, nama, kuota, harga, waktu_mulai, waktu_selesai]`
  factory Sesi.fromListJson(List<dynamic> row) => Sesi(
        id: int.parse(row[0].toString()),
        nama: (row[1] ?? '') as String,
        kuota: int.parse(row[2].toString()),
        harga: row[3] == null ? 0 : (row[3] as num).round(),
        waktuMulai: row[4]?.toString() ?? '',
        waktuSelesai: row[5]?.toString() ?? '',
      );

  String get jamMulai => waktuMulai.length >= 16 ? waktuMulai.substring(11, 16) : '';
  String get jamSelesai => waktuSelesai.length >= 16 ? waktuSelesai.substring(11, 16) : '';
}
