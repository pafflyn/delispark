import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/reservasi_provider.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'services/api_client.dart';
import 'services/catalog_service.dart';
import 'services/reservasi_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  runApp(const DelisParkApp());
}

class DelisParkApp extends StatelessWidget {
  const DelisParkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiClient();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(api)..init()),
        Provider(create: (_) => CatalogService(api)),
        Provider(create: (_) => ReservasiService(api)),
        ChangeNotifierProxyProvider<CatalogService, CatalogProvider>(
          create: (ctx) => CatalogProvider(ctx.read<CatalogService>()),
          update: (_, service, previous) => previous ?? CatalogProvider(service),
        ),
        ChangeNotifierProxyProvider<ReservasiService, ReservasiProvider>(
          create: (ctx) => ReservasiProvider(ctx.read<ReservasiService>()),
          update: (_, service, previous) => previous ?? ReservasiProvider(service),
        ),
      ],
      child: MaterialApp(
        title: 'Delis Park',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const RootGate(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const RootGate(),
        },
      ),
    );
  }
}

/// Menentukan layar awal berdasarkan status autentikasi.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    switch (auth.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const _Splash();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticated:
        return const HomeShell();
    }
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo-brand.png',
              width: 140,
              height: 140,
              errorBuilder: (_, _, _) => const Icon(
                Icons.attractions,
                size: 72,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delis Park',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pengalaman Wisata Lebih Baik.',
              style: TextStyle(fontSize: 13, color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
