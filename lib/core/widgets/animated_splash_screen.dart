
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_repository.dart';
import '../services/notification_service.dart';
import '../../core/enums/user_role.dart';

class AnimatedSplashScreen extends ConsumerStatefulWidget {
  final String nextRoutePath;

  const AnimatedSplashScreen({
    Key? key,
    required this.nextRoutePath,
  }) : super(key: key);

  @override
  ConsumerState<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends ConsumerState<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) async {
      await _checkAuthAndNavigate();
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    // 1. Check if user is logged in
    final authRepo = ref.read(authRepositoryProvider);
    final user = await authRepo.getCurrentUser();

    if (!mounted) return;

    // Request notification permissions
    await ref.read(notificationServiceProvider).requestPermissions();

    if (user != null) {
      // 2. Check role
      if (user.role == UserRole.dev || user.role == UserRole.admin) {
        context.go('/'); // Dashboard
      } else {
        context.go('/orders'); // Orders Page
      }
    } else {
      // Not logged in or error fetching user
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B00),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
