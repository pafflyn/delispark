import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reservasi.dart';
import '../providers/reservasi_provider.dart';
import '../widgets/format.dart';
import 'pembayaran_screen.dart';

class ReservasiDetailScreen extends StatefulWidget {
  final int id;

  const ReservasiDetailScreen({super.key, required this.id});

  @override
  State<ReservasiDetailScreen> createState() => _ReservasiDetailScreenState();
}

class _ReservasiDetailScreenState extends State<ReservasiDetailScreen> {
  Reservasi? _reservasi;
  bool _memuat = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() {
      _memuat = true;
      _error = null;
    });
    try {
      final r = await context.read<ReservasiProvider>().getDetail(widget.id);
      if (mounted) setState(() => _reservasi = r);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _reservasi;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Reservasi')),
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : _error != null || r == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error ?? 'Reservasi tidak ditemukan',
                        textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    r.namaWahana,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    r.sudahBayar ? 'Lunas' : 'Menunggu',
                                    style: TextStyle(
                                      color: r.sudahBayar
                                          ? const Color(0xFF027A48)
                                          : const Color(0xFFB54708),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: r.sudahBayar
                                      ? const Color(0xFFD1FADF)
                                      : const Color(0xFFFEF0C7),
                                  side: BorderSide.none,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _baris(Icons.event, r.namaSesi),
                            _baris(Icons.schedule, formatTanggalPanjang(r.waktuMulai)),
                            _baris(Icons.payments, formatRupiah(r.totalHarga)),
                            _baris(Icons.tag, 'No. Reservasi #${r.id}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tiket',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...r.tiket.map(
                      (t) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            Icons.confirmation_number,
                            color: t.sudahDipakai
                                ? Colors.grey
                                : Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(
                            t.kodeTiket,
                            style: const TextStyle(
                                fontFamily: 'monospace', fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            t.sudahDipakai ? 'Sudah digunakan' : 'Belum digunakan',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!r.sudahBayar)
                      FilledButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PembayaranScreen(reservasi: r),
                          ),
                        ),
                        child: const Text('Lanjut Pembayaran'),
                      ),
                    OutlinedButton(
                      onPressed: _muat,
                      child: const Text('Muat ulang'),
                    ),
                  ],
                ),
    );
  }

  Widget _baris(IconData icon, String teks) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(child: Text(teks)),
          ],
        ),
      );
}
