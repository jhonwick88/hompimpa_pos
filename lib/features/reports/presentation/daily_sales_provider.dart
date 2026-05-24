import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:hompimpa_pos/features/auth/data/auth_repository.dart';
import 'package:hompimpa_pos/features/products/presentation/product_provider.dart';
import 'package:hompimpa_pos/core/enums/user_role.dart';

final todaysOrdersProvider = StreamProvider.autoDispose<List<OrderEntity>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final authUser = ref.watch(authStateChangesProvider).value;
  final filterStoreId = ref.watch(selectedStoreFilterProvider);
  final now = DateTime.now();

  return repository.getOrdersStream(date: now, currentUser: authUser, status: OrderStatus.selesai).map((orders) {
    if (authUser != null && (authUser.role == UserRole.dev || authUser.role == UserRole.admin)) {
      if (filterStoreId != null) {
        return orders.where((o) => o.storeId == filterStoreId).toList();
      }
    }
    return orders;
  });
});

final todaysSalesProvider = Provider<double>((ref) {
  final ordersAsync = ref.watch(todaysOrdersProvider);
  return ordersAsync.when(
    data: (orders) => orders
        .fold(0.0, (sum, order) => sum + order.total),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

final salesDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: now.subtract(const Duration(days: 6)),
    end: now,
  );
});

final analyticsOrdersProvider = FutureProvider.autoDispose<List<OrderEntity>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  final authUser = ref.watch(authStateChangesProvider).value;
  final dateRange = ref.watch(salesDateRangeProvider);
  final filterStoreId = ref.watch(selectedStoreFilterProvider);

  final orders = await repository.getAnalyticsOrders(
    dateRange.start, 
    dateRange.end, 
    currentUser: authUser,
  );

  if (authUser != null && (authUser.role == UserRole.dev || authUser.role == UserRole.admin)) {
    if (filterStoreId != null) {
      return orders.where((o) => o.storeId == filterStoreId).toList();
    }
  }
  return orders;
});
