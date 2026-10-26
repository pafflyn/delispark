import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reservasi_provider.dart';
import '../widgets/format.dart';
import 'reservasi_detail_screen.dart';

class ReservasiListScreen extends StatefulWidget {
  const ReservasiListScreen({super.key});

  @override
  State<ReservasiListScreen> createState() => _ReservasiListScreenState();
}

class _ReservasiListScreenState extends State<ReservasiListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReservasiProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservasiProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reservasi Saya')),
      body: RefreshIndicator(
        onRefresh: provider.load,
        child: provider.loading && provider.daftar.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : provider.errorMessage != null && provider.daftar.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(provider.errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Center(
                        child: OutlinedButton(
                          onPressed: provider.load,
                          child: const Text('Coba lagi'),
                        ),
                      ),
                    ],
                  )
                : provider.daftar.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          Icon(Icons.confirmation_number_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Belum ada reservasi.\nReservasi wahana dari tab Beranda.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.daftar.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final r = provider.daftar[i];
                          return Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReservasiDetailScreen(id: r.id),
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: r.sudahBayar
                                    ? const Color(0xFFD1FADF)
                                    : const Color(0xFFFEF0C7),
                                child: Icon(
                                  r.sudahBayar ? Icons.check : Icons.hourglass_top,
                                  color: r.sudahBayar
                                      ? const Color(0xFF027A48)
                                      : const Color(0xFFB54708),
                                ),
                              ),
                              title: Text(r.namaWahana,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${r.namaSesi}\n${formatTanggalPanjang(r.waktuMulai)}',
                              ),
                              isThreeLine: true,
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(formatRupiah(r.totalHarga),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    r.sudahBayar ? 'Lunas' : 'Belum bayar',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: r.sudahBayar
                                          ? const Color(0xFF027A48)
                                          : const Color(0xFFB54708),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
