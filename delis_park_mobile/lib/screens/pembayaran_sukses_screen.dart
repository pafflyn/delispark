import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reservasi.dart';
import '../providers/reservasi_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/format.dart';
import 'home_shell.dart';

class PembayaranSuksesScreen extends StatefulWidget {
  final int idReservasi;

  const PembayaranSuksesScreen({super.key, required this.idReservasi});

  @override
  State<PembayaranSuksesScreen> createState() => _PembayaranSuksesScreenState();
}

class _PembayaranSuksesScreenState extends State<PembayaranSuksesScreen> {
  Reservasi? _reservasi;
  bool _memuat = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    try {
      final r = await context.read<ReservasiProvider>().getDetail(widget.idReservasi);
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
      appBar: AppBar(
        title: const Text('Pembayaran Berhasil'),
        automaticallyImplyLeading: false,
      ),
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 80),
                    const SizedBox(height: 8),
                    Text(
                      'Pembayaran berhasil!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r?.namaWahana ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (r?.waktuMulai.isNotEmpty == true)
                      Text(
                        formatTanggalPanjang(r!.waktuMulai),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/logo-brand.png',
                                  width: 44,
                                  height: 44,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.confirmation_number,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'E-Tiket Anda',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            if (r != null)
                              ...r.tiket.map(
                                (t) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.confirmation_number,
                                    color: t.sudahDipakai
                                        ? Colors.grey
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                  title: Text(t.kodeTiket,
                                      style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    t.sudahDipakai ? 'Sudah digunakan' : 'Belum digunakan',
                                  ),
                                  trailing: Text(
                                    formatRupiah(r.totalHarga),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tunjukkan kode tiket kepada petugas saat masuk. '
                      'Tiket juga dikirim ke email Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        HomeShellState.pendingTab = 1;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home',
                          (route) => false,
                        );
                      },
                      child: const Text('Lihat Reservasi Saya'),
                    ),
                  ],
                ),
    );
  }
}
