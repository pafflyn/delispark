import 'tiket.dart';

class Reservasi {
  final int id;
  final double totalHarga;
  final String statusPembayaran;
  final String namaWahana;
  final String namaSesi;
  final String waktuMulai;
  final String waktuSelesai;
  final int? kuota;
  final List<Tiket> tiket;

  const Reservasi({
    required this.id,
    required this.totalHarga,
    required this.statusPembayaran,
    this.namaWahana = '',
    this.namaSesi = '',
    this.waktuMulai = '',
    this.waktuSelesai = '',
    this.kuota,
    this.tiket = const [],
  });

  bool get sudahBayar => statusPembayaran == 'selesai';

  /// dari GET `/api/reservasi` (daftar)
  factory Reservasi.fromListJson(Map<String, dynamic> json) => Reservasi(
        id: int.parse(json['id_reservasi'].toString()),
        totalHarga: (json['total_harga'] as num?)?.toDouble() ?? 0,
        statusPembayaran: json['status_pembayaran'] ?? 'menunggu',
        namaWahana: json['nama_wahana'] ?? '',
        namaSesi: json['nama_sesi'] ?? '',
        waktuMulai: json['waktu_mulai']?.toString() ?? '',
        waktuSelesai: json['waktu_selesai']?.toString() ?? '',
        kuota: json['kuota'] == null ? null : int.parse(json['kuota'].toString()),
      );

  /// dari GET `/api/reservasi/<id>` (detail + tiket)
  factory Reservasi.fromDetailJson(Map<String, dynamic> json) => Reservasi(
        id: int.parse(json['id_reservasi'].toString()),
        totalHarga: (json['total_harga'] as num?)?.toDouble() ?? 0,
        statusPembayaran: json['status_pembayaran'] ?? 'menunggu',
        namaWahana: json['nama_wahana'] ?? '',
        namaSesi: json['nama_sesi'] ?? '',
        waktuMulai: json['waktu_mulai']?.toString() ?? '',
        waktuSelesai: json['waktu_selesai']?.toString() ?? '',
        tiket: (json['tiket'] as List<dynamic>? ?? [])
            .map((t) => Tiket.fromJson(t as Map<String, dynamic>))
            .toList(),
      );

  Reservasi copyWith({String? statusPembayaran, List<Tiket>? tiket}) => Reservasi(
        id: id,
        totalHarga: totalHarga,
        statusPembayaran: statusPembayaran ?? this.statusPembayaran,
        namaWahana: namaWahana,
        namaSesi: namaSesi,
        waktuMulai: waktuMulai,
        waktuSelesai: waktuSelesai,
        kuota: kuota,
        tiket: tiket ?? this.tiket,
      );
}
