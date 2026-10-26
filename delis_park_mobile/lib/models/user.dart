class User {
  final int id;
  final String nama;
  final String email;
  final String peran;
  final String? nomorTelepon;
  final String? alamatRumah;

  const User({
    required this.id,
    required this.nama,
    required this.email,
    required this.peran,
    this.nomorTelepon,
    this.alamatRumah,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: int.parse(json['id_pengguna'].toString()),
        nama: json['nama_pengguna'] ?? '',
        email: json['email'] ?? '',
        peran: json['peran'] ?? 'pelanggan',
        nomorTelepon: json['nomor_telepon'],
        alamatRumah: json['alamat_rumah'],
      );

  Map<String, dynamic> toJson() => {
        'id_pengguna': id,
        'nama_pengguna': nama,
        'email': email,
        'peran': peran,
        'nomor_telepon': nomorTelepon,
        'alamat_rumah': alamatRumah,
      };
}
