import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../orders/data/order_repository.dart';
import '../../orders/domain/order.dart';

final todaysOrdersProvider = StreamProvider<List<OrderEntity>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final now = DateTime.now();
  // Simply fetching all for today. 
  // Ideally repo should support date range filtering more precisely.
  // For MVP rely on client side filtering or repo's basic date support.
  return repository.getOrdersStream(date: now);
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
