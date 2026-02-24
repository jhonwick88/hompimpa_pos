import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/settings/data/settings_repository.dart';
import 'package:hompimpa_pos/features/settings/domain/nota_settings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _storeNameController;
  late TextEditingController _taglineController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _phoneController;
  late TextEditingController _footerController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController();
    _taglineController = TextEditingController();
    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();
    _phoneController = TextEditingController();
    _footerController = TextEditingController();
    
    // Load initial data
    Future.microtask(() async {
      final settings = await ref.read(settingsRepositoryProvider).getNotaSettings();
      _storeNameController.text = settings.storeName;
      _taglineController.text = settings.tagline;
      _address1Controller.text = settings.address1;
      _address2Controller.text = settings.address2;
      _phoneController.text = settings.phone;
      _footerController.text = settings.footerMessage;
    });
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _taglineController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _phoneController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final settings = NotaSettings(
        storeName: _storeNameController.text.trim(),
        tagline: _taglineController.text.trim(),
        address1: _address1Controller.text.trim(),
        address2: _address2Controller.text.trim(),
        phone: _phoneController.text.trim(),
        footerMessage: _footerController.text.trim(),
      );

      await ref.read(settingsRepositoryProvider).updateNotaSettings(settings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaturan berhasil disimpan'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Nota'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('HEADER NOTA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _storeNameController,
                decoration: const InputDecoration(labelText: 'Nama Toko', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _taglineController,
                decoration: const InputDecoration(labelText: 'Tagline', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address1Controller,
                decoration: const InputDecoration(labelText: 'Alamat Baris 1', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address2Controller,
                decoration: const InputDecoration(labelText: 'Alamat Baris 2', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'No. WA / Telepon', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              const Text('FOOTER NOTA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _footerController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Pesan Penutup', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6D00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SIMPAN PERUBAHAN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
