import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';
import 'core/router.dart';
import 'core/widgets/animated_splash_screen.dart';
import 'core/services/notification_service.dart';
import 'core/services/order_notification_controller.dart';

void main() async {
  print('APP_START: main() function called');
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  print('APP_START: WidgetsBinding initialized');
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  try {
     // Web Safety: initialization using explicit options for Web
     await Firebase.initializeApp(
       options: kIsWeb 
         ? DefaultFirebaseOptions.web 
         : DefaultFirebaseOptions.currentPlatform,
     ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw 'Firebase Initialization Timed Out after 10 seconds. Check your network connection or Firebase configuration.';
     });
     runApp(const ProviderScope(child: HompimpaApp()));
  } catch (e) {
     print("Firebase init failed: $e");
     runApp(ErrorApp(message: e.toString()));
     // Remove splash if we hit an error so user sees the error screen
     FlutterNativeSplash.remove();
  }
}

class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Configuration Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Firebase initialization failed. Using placeholder firebase_options.dart?\n\nDetails: $message',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 24),
                const Text(
                  'To fix this: Open lib/firebase_options.dart and replace the placeholder keys with your actual Firebase configuration.',
                  textAlign: TextAlign.center,
                ),
              ],
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
    // Check if Android and NOT web
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.initialize((payload) {
             // Navigate to order list
             // Ideally we'd highlight the order, but for now just go there
             ref.read(routerProvider).go('/orders'); 
        });
        
        // Start monitoring
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
        primarySwatch: Colors.orange,
      ),
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );
  }
}
