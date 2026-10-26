import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reservasi.dart';
import '../providers/reservasi_provider.dart';
import '../widgets/format.dart';
import 'pembayaran_sukses_screen.dart';

class PembayaranScreen extends StatefulWidget {
  final Reservasi reservasi;

  const PembayaranScreen({super.key, required this.reservasi});

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  String _metode = 'QRIS';
  bool _memproses = false;

  Future<void> _bayar() async {
    final reservasi = widget.reservasi;
    setState(() => _memproses = true);
    try {
      await context.read<ReservasiProvider>().bayar(
            idReservasi: reservasi.id,
            jumlahBayar: reservasi.totalHarga.round(),
            metode: _metode,
          );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PembayaranSuksesScreen(idReservasi: reservasi.id),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _memproses = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservasi = widget.reservasi;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservasi.namaWahana,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(reservasi.namaSesi),
                  if (reservasi.waktuMulai.isNotEmpty)
                    Text(formatTanggalPanjang(reservasi.waktuMulai)),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total bayar'),
                      Text(
                        formatRupiah(reservasi.totalHarga),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Metode Pembayaran',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: RadioGroup<String>(
              groupValue: _metode,
              onChanged: (v) => setState(() => _metode = v ?? _metode),
              child: const Column(
                children: [
                  RadioListTile<String>(
                    value: 'QRIS',
                    title: Text('QRIS'),
                    subtitle: Text('Scan kode QR di loket pembayaran'),
                    secondary: Icon(Icons.qr_code_2),
                  ),
                  Divider(height: 1),
                  RadioListTile<String>(
                    value: 'BANK',
                    title: Text('Transfer Bank'),
                    subtitle: Text('Transfer ke rekening Delis Park'),
                    secondary: Icon(Icons.account_balance_outlined),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _memproses ? null : _bayar,
            icon: _memproses
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.payment),
            label: Text(_memproses ? 'Memproses...' : 'Bayar ${formatRupiah(reservasi.totalHarga)}'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pembayaran pada aplikasi ini bersifat simulasi (tanpa payment gateway), sama seperti versi web.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
