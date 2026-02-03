import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/products/presentation/dashboard_screen.dart';
import '../../features/orders/presentation/order_list_screen.dart';
import '../../features/orders/presentation/order_entry_screen.dart';
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
        final quick = state.queryParams['quick'] == 'true';
        return OrderEntryScreen(isQuickOrder: quick);
      },
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
  ],
);
