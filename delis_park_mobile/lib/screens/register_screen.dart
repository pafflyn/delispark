import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  final _teleponCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    _teleponCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      nama: _namaCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      nomorTelepon: _teleponCtrl.text.trim(),
      alamatRumah: _alamatCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Registrasi gagal.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loading = auth.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Pelanggan')),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo-brand.png',
                    width: 110,
                    height: 110,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.attractions,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _namaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Email tidak valid' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _teleponCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'No. Telepon (opsional)',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _alamatCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Alamat (opsional)',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pass2Ctrl,
                  obscureText: _obscure,
                  decoration: const InputDecoration(
                    labelText: 'Ulangi Password',
                  ),
                  validator: (v) =>
                      v != _passCtrl.text ? 'Password tidak sama' : null,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Daftar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
