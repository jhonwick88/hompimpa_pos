
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
import '../../features/products/presentation/product_master_screen.dart';
import '../../features/products/presentation/topping_master_screen.dart';
import '../../features/auth/presentation/user_master_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../core/widgets/animated_splash_screen.dart';
import '../../features/public_menu/presentation/public_menu_screen.dart';
import '../../features/public_menu/presentation/public_cart_screen.dart';
import '../../features/orders/presentation/review_orders_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    redirect: (context, state) {
       final isLoggedIn = FirebaseAuth.instance.currentUser != null;
       final path = state.uri.path;
       final isLoggingIn = path == '/login';
       final isSplash = path == '/splash';
       final isPublic = path == '/menu' || path == '/cart';
       
       if (!isLoggedIn) {
         if (isSplash) return null; 
         if (isLoggingIn) return null; 
         if (isPublic) return null;
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
        path: '/menu',
        builder: (context, state) => const PublicMenuScreen(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const PublicCartScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrderListScreen(),
      ),
      GoRoute(
        path: '/review-orders',
        builder: (context, state) => const ReviewOrdersScreen(),
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
      GoRoute(
        path: '/master/products',
        builder: (context, state) => const ProductMasterScreen(),
      ),
      GoRoute(
        path: '/master/toppings',
        builder: (context, state) => const ToppingMasterScreen(),
      ),
      GoRoute(
        path: '/master/users',
        builder: (context, state) => const UserMasterScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
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
