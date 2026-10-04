import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:hompimpa_pos/core/services/firebase_config_service.dart';
import 'package:hompimpa_pos/core/services/database_seeder_service.dart';
import 'package:hompimpa_pos/features/settings/presentation/qr_config_scanner_screen.dart';

class FirebaseSetupScreen extends ConsumerStatefulWidget {
  final bool isInitialSetup;

  const FirebaseSetupScreen({
    Key? key,
    this.isInitialSetup = false,
  }) : super(key: key);

  @override
  ConsumerState<FirebaseSetupScreen> createState() => _FirebaseSetupScreenState();
}

class _FirebaseSetupScreenState extends ConsumerState<FirebaseSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _apiKeyController;
  late TextEditingController _projectIdController;
  late TextEditingController _appIdController;
  late TextEditingController _senderIdController;
  late TextEditingController _storageBucketController;
  late TextEditingController _authDomainController;

  bool _isLoading = false;
  bool _isSeeding = false;
  bool _hasCustom = false;

  bool _isDevMode = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _projectIdController = TextEditingController();
    _appIdController = TextEditingController();
    _senderIdController = TextEditingController();
    _storageBucketController = TextEditingController();
    _authDomainController = TextEditingController();

    _loadExistingConfig();
  }

  Future<void> _loadExistingConfig() async {
    setState(() => _isLoading = true);
    final raw = await FirebaseConfigService.getRawConfig();
    final hasCust = await FirebaseConfigService.hasCustomConfig();
    final isDev = await FirebaseConfigService.isDevModeActive();
    if (mounted) {
      setState(() {
        _apiKeyController.text = raw['apiKey'] ?? '';
        _projectIdController.text = raw['projectId'] ?? '';
        _appIdController.text = raw['appId'] ?? '';
        _senderIdController.text = raw['messagingSenderId'] ?? '';
        _storageBucketController.text = raw['storageBucket'] ?? '';
        _authDomainController.text = raw['authDomain'] ?? '';
        _hasCustom = hasCust;
        _isDevMode = isDev;
        _isLoading = false;
      });
    }
  }

  void _openDeveloperPinDialog() {
    final pinController = TextEditingController();
    bool isPinError = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> verifyAndProceed() async {
            final pin = pinController.text.trim();
            if (FirebaseConfigService.verifyDevPin(pin)) {
              Navigator.pop(ctx);
              await FirebaseConfigService.setDevMode(true);
              await _loadExistingConfig();

              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (alertCtx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Row(
                      children: [
                        Icon(Icons.verified_user, color: Colors.green, size: 28),
                        SizedBox(width: 8),
                        Text('Mode Developer Aktif'),
                      ],
                    ),
                    content: const Text(
                      'Aplikasi sekarang terhubung ke Database Internal Developer Anda. Silakan muat ulang atau lanjutkan ke login.',
                    ),
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB71C1C),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(alertCtx);
                          if (widget.isInitialSetup) {
                            context.go('/login');
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Lanjutkan ke Login'),
                      ),
                    ],
                  ),
                );
              }
            } else {
              setDialogState(() {
                isPinError = true;
              });
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFB71C1C), size: 28),
                SizedBox(width: 10),
                Text('Akses Database Developer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fitur ini khusus untuk Developer pemilik aplikasi. Masukkan PIN Developer untuk beralih ke Database Internal:',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'PIN Developer',
                    hintText: 'Masukkan 4 digit PIN',
                    errorText: isPinError ? 'PIN Developer salah!' : null,
                    prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFFB71C1C)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onSubmitted: (_) => verifyAndProceed(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: verifyAndProceed,
                child: const Text('Buka Database Developer'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _clearCustomConfigOnly() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kosongkan Konfigurasi?'),
        content: const Text(
          'Konfigurasi database custom akan dihapus dari form dan penyimpanan perangkat ini.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseConfigService.clearConfig();
    await _loadExistingConfig();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfigurasi database telah dikosongkan.'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _projectIdController.dispose();
    _appIdController.dispose();
    _senderIdController.dispose();
    _storageBucketController.dispose();
    _authDomainController.dispose();
    super.dispose();
  }

  void _openPasteSnippetDialog() {
    final pasteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.content_paste_rounded, color: Color(0xFFE65100)),
            SizedBox(width: 8),
            Text('Paste Config Firebase', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Salin kode config dari Firebase Console (Project Settings > General > Your Apps) lalu tempel di bawah ini:',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pasteController,
                maxLines: 7,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: 'const firebaseConfig = {\n  apiKey: "AIzaSy...",\n  projectId: "my-store-pos",\n  appId: "1:...",\n  ...\n};',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Ekstrak Otomatis'),
            onPressed: () {
              final text = pasteController.text.trim();
              if (text.isEmpty) {
                Navigator.pop(ctx);
                return;
              }
              final parsed = FirebaseConfigService.parseSnippet(text);
              if (parsed.isNotEmpty) {
                setState(() {
                  if (parsed['apiKey'] != null) _apiKeyController.text = parsed['apiKey']!;
                  if (parsed['projectId'] != null) _projectIdController.text = parsed['projectId']!;
                  if (parsed['appId'] != null) _appIdController.text = parsed['appId']!;
                  if (parsed['messagingSenderId'] != null) _senderIdController.text = parsed['messagingSenderId']!;
                  if (parsed['storageBucket'] != null) _storageBucketController.text = parsed['storageBucket']!;
                  if (parsed['authDomain'] != null) _authDomainController.text = parsed['authDomain']!;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Konfigurasi berhasil diekstrak dan diisi!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ Format tidak dikenali. Pastikan menyalin teks config Firebase yang valid.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openQrScanner() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const QrConfigScannerScreen()),
    );

    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        if (result['apiKey'] != null) _apiKeyController.text = result['apiKey']!;
        if (result['projectId'] != null) _projectIdController.text = result['projectId']!;
        if (result['appId'] != null) _appIdController.text = result['appId']!;
        if (result['messagingSenderId'] != null) _senderIdController.text = result['messagingSenderId']!;
        if (result['storageBucket'] != null) _storageBucketController.text = result['storageBucket']!;
        if (result['authDomain'] != null) _authDomainController.text = result['authDomain']!;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ QR Code berhasil dipindai! Konfigurasi database terisi.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showShareQrDialog() {
    final currentConfig = {
      'apiKey': _apiKeyController.text.trim(),
      'projectId': _projectIdController.text.trim(),
      'appId': _appIdController.text.trim(),
      'messagingSenderId': _senderIdController.text.trim(),
      'storageBucket': _storageBucketController.text.trim(),
      'authDomain': _authDomainController.text.trim(),
    };

    if (currentConfig['projectId']!.isEmpty || currentConfig['apiKey']!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Masukkan atau simpan konfigurasi database terlebih dahulu untuk membagikan QR Code.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final qrPayload = FirebaseConfigService.generateQrPayload(currentConfig);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_2_rounded, color: Color(0xFFB71C1C), size: 28),
            SizedBox(width: 8),
            Text('QR Database Toko', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Arahkan kamera HP/Tablet Kasir baru ke QR Code ini saat membuka menu setup untuk menghubungkan database secara instan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrPayload,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Project: ${currentConfig['projectId']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFB71C1C)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndApplyConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final apiKey = _apiKeyController.text.trim();
      final projectId = _projectIdController.text.trim();
      final appId = _appIdController.text.trim();
      final senderId = _senderIdController.text.trim();
      final storageBucket = _storageBucketController.text.trim();
      final authDomain = _authDomainController.text.trim();

      await FirebaseConfigService.saveConfig(
        apiKey: apiKey,
        projectId: projectId,
        appId: appId.isNotEmpty ? appId : '1:1234567890:web:abcdef',
        messagingSenderId: senderId.isNotEmpty ? senderId : '1234567890',
        storageBucket: storageBucket.isNotEmpty ? storageBucket : '$projectId.firebasestorage.app',
        authDomain: authDomain.isNotEmpty ? authDomain : '$projectId.firebaseapp.com',
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Konfigurasi Disimpan'),
              ],
            ),
            content: const Text(
              'Konfigurasi Firebase database Anda telah tersimpan secara permanen. Aplikasi perlu dimuat ulang untuk menghubungkan koneksi baru.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Trigger reload / navigate
                  if (widget.isInitialSetup) {
                    context.go('/login');
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: const Text('OK / Lanjutkan ke Login'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan konfigurasi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _runInitialSeeder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.auto_fix_high, color: Color(0xFFE65100)),
            SizedBox(width: 8),
            Text('Auto Setup Database Awal'),
          ],
        ),
        content: const Text(
          'Fitur ini akan membuat data Toko Pusat, Pengaturan Nota, Kategori & Topping, serta 7 Menu Starter di database Firebase Anda agar langsung siap digunakan.\n\nLanjutkan?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Mulai Auto Setup'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSeeding = true);
    try {
      final seeder = DatabaseSeederService();
      final report = await seeder.seedInitialDatabase();

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.verified, color: Colors.green),
                SizedBox(width: 8),
                Text('Auto Setup Berhasil!'),
              ],
            ),
            content: Text(
              'Database Firebase Anda telah diinisialisasi:\n\n'
              '• Toko Dibuat: ${report['storesCreated']}\n'
              '• Menu Starter: ${report['productsCreated']} item\n'
              '• Topping Starter: ${report['toppingsCreated']} item\n'
              '• Pengaturan Nota: Berhasil diset\n\n'
              'Aplikasi sekarang siap digunakan untuk transaksi POS!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menjalankan seeder database: $e\nPastikan Firestore Rules sudah diset ke allow read, write!'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  Future<void> _resetToDefault() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Konfigurasi?'),
        content: const Text(
          'Konfigurasi custom akan dihapus dan aplikasi akan kembali menggunakan konfigurasi bawaan (default).',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseConfigService.clearConfig();
    await _loadExistingConfig();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfigurasi berhasil direset ke default.'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: Text(widget.isInitialSetup ? 'Inisialisasi Database POS' : 'Konfigurasi Firebase Database'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB71C1C), Color(0xFFFF6D00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB71C1C).withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.cloud_sync_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Koneksi Database Customer',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'Gunakan database Firebase Cloud Firestore milik Anda sendiri',
                                    style: TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFB71C1C),
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.content_paste_go_rounded, size: 18),
                                label: const Text(
                                  '📋 Paste Config',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                onPressed: _openPasteSnippetDialog,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD54F),
                                  foregroundColor: const Color(0xFF3E2723),
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                                label: const Text(
                                  '📷 Scan QR',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                onPressed: _openQrScanner,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white70, width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                            label: const Text(
                              '📱 Tampilkan QR Code Database Toko (Untuk Dibagikan)',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                            ),
                            onPressed: _showShareQrDialog,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Status Developer Mode
                  if (_isDevMode)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_rounded, color: Colors.blue),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Database Internal Developer Aktif (Terkunci PIN)',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await FirebaseConfigService.setDevMode(false);
                              await _loadExistingConfig();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mode Developer dinonaktifkan.'), backgroundColor: Colors.orange),
                                );
                              }
                            },
                            child: const Text('Matikan', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),

                  // Status Custom Config
                  if (_hasCustom)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.green),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Aplikasi saat ini terhubung dengan database custom Anda.',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                          TextButton(
                            onPressed: _clearCustomConfigOnly,
                            child: const Text('Kosongkan', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),

                  const Text(
                    'PARAMETER FIREBASE CONSOLE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),

                  // Project ID
                  _buildTextField(
                    controller: _projectIdController,
                    label: 'Project ID (Wajib)',
                    hint: 'Contoh: hompimpa-pos-id / toko-saya-12345',
                    icon: Icons.tag,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Project ID wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),

                  // API Key
                  _buildTextField(
                    controller: _apiKeyController,
                    label: 'API Key (Wajib)',
                    hint: 'Contoh: AIzaSyD...',
                    icon: Icons.key_rounded,
                    validator: (v) => v == null || v.trim().isEmpty ? 'API Key wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),

                  // App ID
                  _buildTextField(
                    controller: _appIdController,
                    label: 'App ID (Wajib)',
                    hint: 'Contoh: 1:1234567890:web:abcdef...',
                    icon: Icons.apps_rounded,
                    validator: (v) => v == null || v.trim().isEmpty ? 'App ID wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),

                  // Messaging Sender ID
                  _buildTextField(
                    controller: _senderIdController,
                    label: 'Messaging Sender ID / Project Number',
                    hint: 'Contoh: 123456789012',
                    icon: Icons.send_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),

                  // Storage Bucket
                  _buildTextField(
                    controller: _storageBucketController,
                    label: 'Storage Bucket (Opsional)',
                    hint: 'Contoh: project-id.firebasestorage.app',
                    icon: Icons.folder_shared_outlined,
                  ),
                  const SizedBox(height: 14),

                  // Auth Domain
                  _buildTextField(
                    controller: _authDomainController,
                    label: 'Auth Domain (Opsional)',
                    hint: 'Contoh: project-id.firebaseapp.com',
                    icon: Icons.language_rounded,
                  ),

                  const SizedBox(height: 28),

                  // Tombol Simpan
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveAndApplyConfig,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB71C1C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Simpan & Terapkan Konfigurasi',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Tombol Auto Setup Seeder
                  OutlinedButton.icon(
                    onPressed: _isSeeding ? null : _runInitialSeeder,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE65100),
                      side: const BorderSide(color: Color(0xFFE65100), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isSeeding
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE65100)),
                          )
                        : const Icon(Icons.auto_awesome_rounded),
                    label: Text(
                      _isSeeding ? 'Mengisi Database Awal...' : '⚡ Jalankan Auto Setup / Seeder Database Awal',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tombol Developer Mode (PIN 1471)
                  Center(
                    child: TextButton.icon(
                      onPressed: _openDeveloperPinDialog,
                      icon: const Icon(Icons.lock_outline_rounded, size: 16, color: Colors.grey),
                      label: const Text(
                        '🔐 Beralih ke Database Internal Developer (PIN)',
                        style: TextStyle(color: Colors.grey, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Petunjuk singkat
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: Colors.blue.shade800, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Butuh Panduan Membuat Firebase?',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Silakan baca file panduan lengkap "PANDUAN_SETUP_FIREBASE.md" yang disertakan dalam paket aplikasi untuk petunjuk langkah-demi-langkah dari membuat Firebase Project, mengaktifkan Firestore, Auth, hingga rules.',
                          style: TextStyle(color: Colors.blue.shade900, fontSize: 12.5, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12.5),
        prefixIcon: Icon(icon, color: const Color(0xFFB71C1C), size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 1.8),
        ),
      ),
    );
  }
}
