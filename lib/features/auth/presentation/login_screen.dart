
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to error states
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, state) {
      state.maybeWhen(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
        orElse: () {},
      );
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
               Image.asset(
                'assets/images/logo.png',
                height: 120,
              ),
              const SizedBox(height: 40),
              
              Text(
                'Hompimpa POS',
                style: Theme.of(context).textTheme.headline5?.copyWith( // headlineMedium -> headline5 in old flutter
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF6B00),
                ),
              ),
               const SizedBox(height: 10),
               Text(
                'Sign in to continue',
                style: Theme.of(context).textTheme.bodyText1?.copyWith( // bodyLarge -> bodyText1
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 60),

              if (isLoading)
                const CircularProgressIndicator(color: Color(0xFFFF6B00))
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).signInWithGoogle();
                    },
                    icon: const Icon(Icons.login), 
                    // Note: In a real app, use a Google Logo asset
                    label: const Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.black87,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
