import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'profil_screen.dart';
import 'reservasi_list_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  /// Tab yang diminta sebelum shell (re)dibuat, mis. setelah pembayaran sukses.
  static int pendingTab = 0;

  int _index = 0;
  static HomeShellState? _instance;

  static void go(BuildContext context, {int tab = 0}) {
    _instance?.setState(() => _instance!._index = tab);
  }

  @override
  void initState() {
    super.initState();
    _index = HomeShellState.pendingTab;
    HomeShellState.pendingTab = 0;
    _instance = this;
  }

  @override
  void dispose() {
    if (identical(_instance, this)) _instance = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          ReservasiListScreen(),
          ProfilScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.attractions_outlined),
            selectedIcon: Icon(Icons.attractions),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: 'Reservasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
