class Tiket {
  final int id;
  final String kodeTiket;
  final String statusTiket;

  const Tiket({
    required this.id,
    required this.kodeTiket,
    required this.statusTiket,
  });

  factory Tiket.fromJson(Map<String, dynamic> json) => Tiket(
        id: int.parse(json['id_tiket'].toString()),
        kodeTiket: json['kode_tiket'] ?? '',
        statusTiket: json['status_tiket'] ?? 'belum_digunakan',
      );

  bool get sudahDipakai => statusTiket == 'sudah_digunakan';
}
