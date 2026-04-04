import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hompimpa_pos/features/reports/presentation/daily_sales_provider.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:hompimpa_pos/core/widgets/gradient_app_bar.dart';

class OmzetDetailScreen extends ConsumerWidget {
  const OmzetDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(todaysOrdersProvider);

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Detail Omzet Hari Ini'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          final completedOrders = orders.where((o) => o.status == OrderStatus.selesai).toList();
          if (completedOrders.isEmpty) {
            return const Center(child: Text('Belum ada transaksi selesai hari ini.'));
          }

          // Aggregation by Payment Method
          final Map<String, _PaymentSummary> summaryMap = {};
          
          double grandTotal = 0;

          for (final order in completedOrders) {
            final pm = order.paymentMethod;
            final key = (pm == null || pm.isEmpty) ? 'Lainnya' : pm;

            if (!summaryMap.containsKey(key)) {
              summaryMap[key] = _PaymentSummary(method: key, count: 0, total: 0);
            }

            summaryMap[key]!.count += 1;
            summaryMap[key]!.total += order.total;
            grandTotal += order.total;
          }

          final summaries = summaryMap.values.toList()
            ..sort((a, b) => b.total.compareTo(a.total)); // Sort by highest amount

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: summaries.length + 1,
            itemBuilder: (context, index) {
              if (index < summaries.length) {
                final summary = summaries[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.payment, color: Colors.blue),
                    ),
                    title: Text(
                      summary.method,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${summary.count} Order'),
                    trailing: Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(summary.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Grand Total',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(grandTotal),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, trace) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _PaymentSummary {
  final String method;
  int count;
  double total;

  _PaymentSummary({required this.method, required this.count, required this.total});
}
