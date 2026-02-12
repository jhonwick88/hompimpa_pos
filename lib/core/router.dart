
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'enums/user_role.dart';
import '../../features/products/presentation/dashboard_screen.dart';
import '../../features/orders/presentation/order_list_screen.dart';
import '../../features/orders/presentation/order_page.dart';
import '../../features/reports/presentation/report_screen.dart';
import '../../features/orders/presentation/void_orders_screen.dart'; // Add this line
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/data/auth_repository.dart';
import '../core/widgets/animated_splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    redirect: (context, state) {
       final isLoggedIn = FirebaseAuth.instance.currentUser != null;
       final isLoggingIn = state.uri.toString() == '/login';
       final isSplash = state.uri.toString() == '/splash';
       
       if (!isLoggedIn) {
         if (isSplash) return null; 
         if (isLoggingIn) return null; 
         return '/login'; 
       }

       if (isLoggingIn) {
          return '/splash'; 
       }

       // Note: Role guarding for Dashboard is handled in DashboardScreen or Splash
       
       return null; 
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const AnimatedSplashScreen(nextRoutePath: '/'),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrderListScreen(),
      ),
      GoRoute(
        path: '/entry',
        builder: (context, state) {
          final isQuickOrder = state.uri.queryParameters['quick'] == 'true';
          return OrderPage(isQuickOrder: isQuickOrder);
        },
      ),
      GoRoute(
        path: '/entry/add/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderPage(
            isQuickOrder: false, 
            existingOrderId: orderId
          );
        },
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/void-orders',
        builder: (context, state) => const VoidOrdersScreen(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
