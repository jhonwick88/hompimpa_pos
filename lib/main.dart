import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'core/router.dart';
import 'core/services/notification_service.dart';
import 'core/services/order_notification_controller.dart';
import 'core/services/firebase_config_service.dart';
import 'features/settings/presentation/firebase_setup_screen.dart';

void main() async {
  print('APP_START: main() function called');
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  print('APP_START: WidgetsBinding initialized');
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await initializeDateFormatting('id_ID', null);
    
    // 1. Cek apakah ada konfigurasi custom yang disimpan oleh customer
    FirebaseOptions? targetOptions = await FirebaseConfigService.getCustomOptions();
    
    // 2. Jika tidak ada custom config, fallback ke static platform options
    targetOptions ??= kIsWeb 
        ? DefaultFirebaseOptions.web 
        : DefaultFirebaseOptions.currentPlatform;

    await Firebase.initializeApp(
      options: targetOptions,
    ).timeout(const Duration(seconds: 12), onTimeout: () {
      throw 'Koneksi Firebase timeout. Pastikan koneksi internet aktif dan Project ID/API Key Firebase sudah benar.';
    });

    runApp(const ProviderScope(child: HompimpaApp()));
  } catch (e) {
    print("Firebase init failed: $e");
    runApp(ErrorApp(message: e.toString()));
    // Remove splash if we hit an error so user sees the error/setup screen
    FlutterNativeSplash.remove();
  }
}

class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hompimpa POS Setup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB71C1C),
          primary: const Color(0xFFB71C1C),
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECEB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_off_rounded, color: Color(0xFFB71C1C), size: 48),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Database Belum Terhubung',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Aplikasi Hompimpa POS membutuhkan koneksi ke Firebase Firestore database Anda untuk memulai.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 20, color: Colors.black54),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Error: $message',
                                style: const TextStyle(fontSize: 12, color: Colors.black87, fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FirebaseSetupScreen(isInitialSetup: true),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB71C1C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.settings_rounded),
                          label: const Text(
                            '⚙️ Konfigurasi Database Firebase Sekarang',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HompimpaApp extends ConsumerStatefulWidget {
  const HompimpaApp({Key? key}) : super(key: key);

  @override
  ConsumerState<HompimpaApp> createState() => _HompimpaAppState();
}

class _HompimpaAppState extends ConsumerState<HompimpaApp> {
  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    // Initialize for Android and Web
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.android) {
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.initialize((payload) {
             // Navigate to order list
             // Ideally we'd highlight the order, but for now just go there
             ref.read(routerProvider).go('/orders'); 
        });
        
        // Start monitoring (polling still useful as backup or for real-time data fetch)
        ref.read(orderNotificationControllerProvider).startMonitoring();
    }
  }

  @override
 Widget build(BuildContext context) {
  final router = ref.watch(routerProvider);

  return MaterialApp.router(
    title: 'Hompimpa POS',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: Color(0xFFB71C1C),     // Deep Red (AppBar)
        secondary: Color(0xFFFF6D00),   // Orange untuk tombol
        surface: Colors.white,
        background: Color(0xFFF4F4F4),
      ),

      scaffoldBackgroundColor: Color(0xFFF4F4F4),

      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: false,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFF6D00),
        foregroundColor: Colors.white,
      ),

cardTheme: const CardThemeData(
  color: Colors.white,
  elevation: 2,
  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  ),
),

    ),
    routerConfig: router,
  );
}
}
