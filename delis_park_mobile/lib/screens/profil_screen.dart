import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _teleponCtrl;
  late final TextEditingController _alamatCtrl;
  late final TextEditingController _passCtrl;
  late final TextEditingController _oldPassCtrl;
  bool _editMode = false;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _namaCtrl = TextEditingController(text: user?.nama ?? '');
    _teleponCtrl = TextEditingController(text: user?.nomorTelepon ?? '');
    _alamatCtrl = TextEditingController(text: user?.alamatRumah ?? '');
    _passCtrl = TextEditingController();
    _oldPassCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _teleponCtrl.dispose();
    _alamatCtrl.dispose();
    _passCtrl.dispose();
    _oldPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _menyimpan = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfil(
      nama: _namaCtrl.text.trim(),
      nomorTelepon: _teleponCtrl.text.trim(),
      alamatRumah: _alamatCtrl.text.trim(),
      password: _passCtrl.text.isEmpty ? null : _passCtrl.text,
      oldPassword: _oldPassCtrl.text.isEmpty ? null : _oldPassCtrl.text,
    );
    if (!mounted) return;
    setState(() => _menyimpan = false);
    if (ok) {
      setState(() => _editMode = false);
      _passCtrl.clear();
      _oldPassCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Gagal memperbarui profil.')),
      );
    }
  }

  Future<void> _logout() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (yakin == true && mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          if (!_editMode)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _editMode = true),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Text(
                (user?.nama.isNotEmpty == true) ? user!.nama[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              user?.nama ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
              user?.email ?? '',
              style: const TextStyle(color: AppColors.mutedText),
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _namaCtrl,
                  enabled: _editMode,
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _teleponCtrl,
                  enabled: _editMode,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'No. Telepon'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _alamatCtrl,
                  enabled: _editMode,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                ),
                if (_editMode) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _oldPassCtrl,
                    enabled: _editMode,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password lama (untuk ganti password)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl,
                    enabled: _editMode,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password baru (opsional)',
                    ),
                    validator: (v) =>
                        (v != null && v.isNotEmpty && v.length < 6)
                            ? 'Minimal 6 karakter'
                            : null,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_editMode)
            FilledButton(
              onPressed: _menyimpan ? null : _simpan,
              child: _menyimpan
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan Perubahan'),
            ),
          const SizedBox(height: 8),
          if (_editMode)
            TextButton(
              onPressed: _menyimpan
                  ? null
                  : () {
                      setState(() => _editMode = false);
                      final u = context.read<AuthProvider>().user;
                      _namaCtrl.text = u?.nama ?? '';
                      _teleponCtrl.text = u?.nomorTelepon ?? '';
                      _alamatCtrl.text = u?.alamatRumah ?? '';
                      _passCtrl.clear();
                      _oldPassCtrl.clear();
                    },
              child: const Text('Batal'),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _logout,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.darkButton,
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
