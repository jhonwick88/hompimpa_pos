import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../orders/data/order_repository.dart';
import '../../orders/domain/order.dart';

final reportDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final reportSearchQueryProvider = StateProvider<String>((ref) => '');

class ProductSalesReport {
  final String productName;
  final int totalQty;
  final double totalRevenue;

  ProductSalesReport({
    required this.productName,
    required this.totalQty,
    required this.totalRevenue,
  });
}

final dailyProductSalesProvider = StreamProvider<List<ProductSalesReport>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final date = ref.watch(reportDateProvider);

  return repository.getOrdersStream(date: date).map((orders) {
    // Only count completed orders
    final completedOrders = orders.where((o) => o.status == OrderStatus.selesai).toList();
    
    final salesMap = <String, Map<String, dynamic>>{};

    for (final order in completedOrders) {
      for (final item in order.items) {
        if (!salesMap.containsKey(item.productName)) {
          salesMap[item.productName] = {
            'qty': 0,
            'revenue': 0.0,
          };
        }
        salesMap[item.productName]!['qty'] += item.qty;
        salesMap[item.productName]!['revenue'] += (item.qty * item.price);
      }
    }

    return salesMap.entries.map((entry) {
      return ProductSalesReport(
        productName: entry.key,
        totalQty: entry.value['qty'],
        totalRevenue: entry.value['revenue'],
      );
    }).toList();
  });
});

final filteredProductSalesProvider = Provider<List<ProductSalesReport>>((ref) {
  final salesAsync = ref.watch(dailyProductSalesProvider);
  final query = ref.watch(reportSearchQueryProvider).toLowerCase();

  return salesAsync.when(
    data: (sales) {
      if (query.isEmpty) return sales;
      return sales.where((s) => s.productName.toLowerCase().contains(query)).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
