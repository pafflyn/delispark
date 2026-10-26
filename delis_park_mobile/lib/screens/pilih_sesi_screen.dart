import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../models/sesi.dart';
import '../models/wahana.dart';
import '../providers/catalog_provider.dart';
import '../providers/reservasi_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/format.dart';
import 'pembayaran_screen.dart';

class PilihSesiScreen extends StatefulWidget {
  final Wahana wahana;

  const PilihSesiScreen({super.key, required this.wahana});

  @override
  State<PilihSesiScreen> createState() => _PilihSesiScreenState();
}

class _PilihSesiScreenState extends State<PilihSesiScreen> {
  late final List<String> _tanggal;
  String? _tanggalTerpilih;
  List<Sesi> _sesi = [];
  bool _memuatSesi = false;
  int _jumlah = 1;
  Sesi? _sesiTerpilih;
  bool _memesan = false;

  @override
  void initState() {
    super.initState();
    _tanggal = context.read<CatalogProvider>().tanggalTersedia;
    _tanggalTerpilih = _tanggal.first;
    _muatSesi();
  }

  Future<void> _muatSesi() async {
    final tgl = _tanggalTerpilih;
    if (tgl == null) return;
    setState(() {
      _memuatSesi = true;
      _sesiTerpilih = null;
      _jumlah = 1;
    });
    try {
      final hasil = await context
          .read<CatalogProvider>()
          .getSesi(widget.wahana.id, tgl);
      if (mounted) setState(() => _sesi = hasil);
    } catch (e) {
      if (mounted) {
        setState(() => _sesi = []);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _memuatSesi = false);
    }
  }

  Future<void> _pesan() async {
    final sesi = _sesiTerpilih;
    if (sesi == null) return;
    setState(() => _memesan = true);
    try {
      final reservasi = await context.read<ReservasiProvider>().buat(
            idSesi: sesi.id,
            jumlahTiket: _jumlah,
          );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PembayaranScreen(reservasi: reservasi),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        _muatSesi();
      }
    } finally {
      if (mounted) setState(() => _memesan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wahana = widget.wahana;

    return Scaffold(
      appBar: AppBar(title: Text(wahana.nama)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              ApiConfig.url(wahana.gambarUrl),
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 160,
                color: AppColors.surfaceGray,
                child: const Icon(Icons.attractions,
                    size: 64, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pilih Tanggal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _tanggal.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final tgl = _tanggal[i];
                final terpilih = tgl == _tanggalTerpilih;
                return ChoiceChip(
                  label: Text(
                    formatTanggal(tgl),
                    style: TextStyle(
                      color: terpilih ? Colors.white : null,
                      fontWeight: terpilih ? FontWeight.bold : null,
                    ),
                  ),
                  selected: terpilih,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  onSelected: (_) {
                    setState(() => _tanggalTerpilih = tgl);
                    _muatSesi();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Pilih Sesi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (_memuatSesi)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_sesi.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Tidak ada sesi tersedia pada tanggal ini. Pilih tanggal lain.'),
              ),
            )
          else
            ..._sesi.map((s) {
              final terpilih = _sesiTerpilih?.id == s.id;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: terpilih
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ListTile(
                  onTap: () => setState(() {
                    _sesiTerpilih = s;
                    _jumlah = 1;
                  }),
                  leading: Icon(
                    terpilih ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: terpilih ? Theme.of(context).colorScheme.primary : null,
                  ),
                  title: Text('${s.nama} • ${s.jamMulai}–${s.jamSelesai}'),
                  subtitle: Text(
                    '${formatRupiah(s.harga)}/tiket • Sisa kuota: ${s.kuota}',
                  ),
                ),
              );
            }),
          if (_sesiTerpilih != null) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('Jumlah tiket', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      onPressed: _jumlah > 1
                          ? () => setState(() => _jumlah--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$_jumlah', style: const TextStyle(fontSize: 16)),
                    IconButton(
                      onPressed: _jumlah < _sesiTerpilih!.kuota && _jumlah < 20
                          ? () => setState(() => _jumlah++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${formatRupiah(_jumlah * _sesiTerpilih!.harga)}',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _sesiTerpilih == null || _memesan ? null : _pesan,
            child: _memesan
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Buat Reservasi'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
