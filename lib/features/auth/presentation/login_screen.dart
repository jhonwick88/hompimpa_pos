
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hompimpa_pos/features/auth/presentation/auth_controller.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FlutterNativeSplash.remove();
    // Listen to error states
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, state) {
      state.maybeWhen(
        error: (error, stackTrace) {
          String message = error.toString();
          
          // Handle specific errors for better UX
          if (message.contains('ApiException: 10')) {
            message = 'Gagal Login: Konfigurasi Salah (Developer Error). Cek SHA-1 & google-services.json.';
          } else if (message.contains('network_error')) {
             message = 'Koneksi Bermasalah. Cek internet Anda.';
          } else if (message.contains('sign_in_canceled')) {
             message = 'Login dibatalkan.';
          }
           
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        orElse: () {},
      );
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB71C1C), // Red 900
              Color(0xFFFF6B00), // Fire Orange
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView( // Added scroll view for safety on small screens
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                 Image.asset(
                  'assets/images/logo.png',
                  height: 350, // 2x larger (approx)
                ),
                const SizedBox(height: 20),
                
                Text(
                  'Hompimpa POS',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 32, // Increased size slightly to match large logo
                    color: Colors.white, // White text for contrast
                    shadows: [
                      const Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4.0,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Masuk untuk melanjutkan',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600], // Lighter white
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                if (isLoading)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(authControllerProvider.notifier).signInWithGoogle();
                      },
                      icon: const Icon(Icons.login), 
                      label: const Text('Sign in with Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // White button
                        foregroundColor: const Color(0xFFB71C1C), // Red text
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
