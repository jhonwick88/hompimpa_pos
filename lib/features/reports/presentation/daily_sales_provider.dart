import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:hompimpa_pos/features/auth/data/auth_repository.dart';

final todaysOrdersProvider = StreamProvider<List<OrderEntity>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final authUser = ref.watch(authStateChangesProvider).value;
  final now = DateTime.now();
  // Simply fetching all for today. 
  // Ideally repo should support date range filtering more precisely.
  // For MVP rely on client side filtering or repo's basic date support.
  return repository.getOrdersStream(date: now, currentUser: authUser, status: OrderStatus.selesai);
});

final todaysSalesProvider = Provider<double>((ref) {
  final ordersAsync = ref.watch(todaysOrdersProvider);
  return ordersAsync.when(
    data: (orders) => orders
        .where((o) => o.status == OrderStatus.selesai) // Only count completed
        .fold(0.0, (sum, order) => sum + order.total),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});
