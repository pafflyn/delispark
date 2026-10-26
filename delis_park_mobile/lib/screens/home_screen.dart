import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../models/wahana.dart';
import '../providers/auth_provider.dart';
import '../providers/catalog_provider.dart';
import '../theme/app_theme.dart';
import 'home_shell.dart';
import 'pilih_sesi_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final catalog = context.read<CatalogProvider>();
    if (catalog.wahana.isEmpty) {
      catalog.loadWahana();
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: catalog.loadWahana,
        child: catalog.loading && catalog.wahana.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : catalog.errorMessage != null && catalog.wahana.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        catalog.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: OutlinedButton(
                          onPressed: catalog.loadWahana,
                          child: const Text('Coba lagi'),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _HeroSection(nama: auth.user?.nama ?? ''),
                      _SectionHeader(title: 'Wahana'),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ...catalog.wahana.map((w) => _WahanaCard(
                                  wahana: w,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PilihSesiScreen(wahana: w),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final String nama;

  const _HeroSection({required this.nama});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/hero-section.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: AppColors.primary),
          ),
          const ColoredBox(color: Colors.black54),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nama.isEmpty ? 'SELAMAT DATANG 👋' : 'Halo, $nama 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'DELIS PARK SYSTEM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      height: 1.15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'DelisPark, Pengalaman Wisata Lebih Baik.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                    ),
                    onPressed: () {
                      HomeShellState.go(context, tab: 1);
                    },
                    child: const Text('Lihat Reservasi Saya'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.indigoHeader,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _WahanaCard extends StatelessWidget {
  final Wahana wahana;
  final VoidCallback onTap;

  const _WahanaCard({required this.wahana, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 190,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    ApiConfig.url(wahana.gambarUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.surfaceGray,
                      child: const Icon(Icons.attractions,
                          size: 64, color: AppColors.primary),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wahana.nama,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          wahana.deskripsi ?? 'Wahana seru di Delis Park',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      wahana.status.toLowerCase() == 'aktif'
                          ? 'Tersedia'
                          : wahana.status,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppColors.success,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                  ),
                  FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                    ),
                    child: const Text('Reservasi'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
