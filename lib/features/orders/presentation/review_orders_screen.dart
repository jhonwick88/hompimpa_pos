import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/core/widgets/gradient_app_bar.dart';
import 'package:hompimpa_pos/core/widgets/order_card_modern.dart';
import 'package:intl/intl.dart';

class ReviewOrdersScreen extends ConsumerWidget {
  const ReviewOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We want only orders with status 'menungguReview'
    final ordersAsync = ref.watch(reviewOrdersProvider);

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Review Pesanan Baru'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.checklist, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Tidak ada pesanan yang menunggu review', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCardModern(
                order: order,
                queueNumber: index + 1,
                statusColor: Colors.orange,
                statusIcon: Icons.rate_review,
                actionSection: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _approveOrder(context, ref, order),
                      icon: const Icon(Icons.check),
                      label: const Text('SETUJUI'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _rejectOrder(context, ref, order),
                      icon: const Icon(Icons.close),
                      label: const Text('TOLAK'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Gagal memuat data: $e')),
      ),
    );
  }

  Future<void> _approveOrder(BuildContext context, WidgetRef ref, OrderEntity order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui Pesanan?'),
        content: Text('Pesanan dari ${order.customerName} akan masuk ke daftar order aktif.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('BATAL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('SETUJUI'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(orderRepositoryProvider).updateOrderStatus(order.id, OrderStatus.belum, order.items);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan disetujui')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyetujui: $e')));
      }
    }
  }

  Future<void> _rejectOrder(BuildContext context, WidgetRef ref, OrderEntity order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pesanan?'),
        content: Text('Pesanan dari ${order.customerName} akan ditandai sebagai ditolak.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('BATAL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('TOLAK'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(orderRepositoryProvider).updateOrderStatus(order.id, OrderStatus.ditolak, order.items);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan ditolak')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menolak: $e')));
      }
    }
  }
}

// Provider for review list
final reviewOrdersProvider = StreamProvider<List<OrderEntity>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrdersStream(status: OrderStatus.menungguReview);
});
