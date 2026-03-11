import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:hompimpa_pos/features/auth/data/auth_repository.dart';
import 'package:hompimpa_pos/core/enums/user_role.dart';
import 'package:hompimpa_pos/features/settings/data/store_repository.dart';

final reportDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final reportSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedStoreIdProvider = StateProvider<String?>((ref) => null); // For Dev to filter

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

class StoreSalesReport {
  final String storeId;
  final String storeName;
  final double totalRevenue;
  final int orderCount;

  StoreSalesReport({
    required this.storeId,
    required this.storeName,
    required this.totalRevenue,
    required this.orderCount,
  });
}

final dailyProductSalesProvider = StreamProvider<List<ProductSalesReport>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final date = ref.watch(reportDateProvider);
  final user = ref.watch(authStateChangesProvider).value;
  final selectedStoreId = ref.watch(selectedStoreIdProvider);

  return repository.getOrdersStream(date: date, currentUser: user).map((orders) {
    var filtered = orders;
    
    // Additional Dev Filtering
    if (user?.role == UserRole.dev && selectedStoreId != null) {
      filtered = filtered.where((o) => o.items.any((i) => i.storeId == selectedStoreId)).toList();
    }
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

final dailyStoreSalesProvider = StreamProvider<List<StoreSalesReport>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final storeRepo = ref.watch(storeRepositoryProvider);
  final date = ref.watch(reportDateProvider);
  final user = ref.watch(authStateChangesProvider).value;

  // We need both orders and stores
  final ordersStream = repository.getOrdersStream(date: date, currentUser: user);
  final storesStream = storeRepo.watchActiveStores();

  return ordersStream.asyncMap((orders) async {
    final stores = await storesStream.first;
    final storeMap = {for (var s in stores) s.id: s.name};
    
    final completedOrders = orders.where((o) => o.status == OrderStatus.selesai).toList();
    
    final salesMap = <String, Map<String, dynamic>>{};

    for (final order in completedOrders) {
      final sId = order.storeId ?? 'unknown';
      if (!salesMap.containsKey(sId)) {
        salesMap[sId] = {
          'revenue': 0.0,
          'count': 0,
        };
      }
      salesMap[sId]!['revenue'] += order.total;
      salesMap[sId]!['count'] += 1;
    }

    return salesMap.entries.map((entry) {
      return StoreSalesReport(
        storeId: entry.key,
        storeName: storeMap[entry.key] ?? 'Unknown Store (${entry.key})',
        totalRevenue: entry.value['revenue'],
        orderCount: entry.value['count'],
      );
    }).toList();
  });
});
