class Wahana {
  final int id;
  final String nama;
  final String gambarUrl;
  final String status;
  final String? deskripsi;

  const Wahana({
    required this.id,
    required this.nama,
    required this.gambarUrl,
    required this.status,
    this.deskripsi,
  });

  /// dari GET /api/wahana -> {data: [[id, nama, img_url, status], ...]}
  factory Wahana.fromListJson(List<dynamic> row) => Wahana(
        id: int.parse(row[0].toString()),
        nama: (row[1] ?? '') as String,
        gambarUrl: (row[2] ?? '') as String,
        status: (row[3] ?? '') as String,
      );

  /// dari GET `/api/wahana/<id>`
  factory Wahana.fromJson(Map<String, dynamic> json) => Wahana(
        id: int.parse(json['id_wahana'].toString()),
        nama: json['nama_wahana'] ?? '',
        gambarUrl: json['gambar_url'] ?? '',
        status: json['status_wahana'] ?? 'aktif',
        deskripsi: json['deskripsi'],
      );
}
