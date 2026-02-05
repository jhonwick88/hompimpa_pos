import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/products/presentation/dashboard_screen.dart';
import '../../features/orders/presentation/order_list_screen.dart';
import '../../features/orders/presentation/order_page.dart';
import '../../features/reports/presentation/report_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
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
        final isQuickOrder = state.queryParams['quick'] == 'true';
        return OrderPage(isQuickOrder: isQuickOrder);
      },
    ),
    GoRoute(
      path: '/entry/add/:orderId',
      builder: (context, state) {
        final orderId = state.params['orderId']!;
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
  ],
);
