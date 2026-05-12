import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hompimpa_pos/features/reports/presentation/daily_sales_provider.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:hompimpa_pos/core/widgets/gradient_app_bar.dart';

class OmzetDetailScreen extends ConsumerWidget {
  const OmzetDetailScreen({Key? key}) : super(key: key);

  Future<void> _selectDateRange(BuildContext context, WidgetRef ref) async {
    final currentRange = ref.read(salesDateRangeProvider);
    final initialDateRange = currentRange;
    final firstDate = DateTime(2020);
    final lastDate = DateTime.now();

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      ref.read(salesDateRangeProvider.notifier).state = pickedRange;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(analyticsOrdersProvider);
    final dateRange = ref.watch(salesDateRangeProvider);

    final dateFormat = DateFormat('dd MMM yyyy');
    final String dateRangeText = '${dateFormat.format(dateRange.start)} - ${dateFormat.format(dateRange.end)}';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: GradientAppBar(
        title: const Text('Analisa Omzet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context, ref),
            tooltip: 'Filter Tanggal',
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Belum ada transaksi di rentang waktu ini.', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(dateRangeText, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          // Aggregation by Date
          final Map<String, _DailySummary> dailySummaryMap = {};
          double grandTotal = 0;

          for (final order in orders) {
            final dateKey = DateFormat('yyyy-MM-dd').format(order.createdAt ?? order.orderDate);
            if (!dailySummaryMap.containsKey(dateKey)) {
              dailySummaryMap[dateKey] = _DailySummary(
                dateStr: dateKey,
                dateObj: order.createdAt ?? order.orderDate,
                total: 0,
                paymentMethods: {},
              );
            }

            final pm = order.paymentMethod;
            final pmKey = (pm == null || pm.isEmpty) ? 'Lainnya' : pm;

            dailySummaryMap[dateKey]!.total += order.total;
            dailySummaryMap[dateKey]!.paymentMethods[pmKey] = (dailySummaryMap[dateKey]!.paymentMethods[pmKey] ?? 0) + order.total;
            grandTotal += order.total;
          }

          final summaries = dailySummaryMap.values.toList()
            ..sort((a, b) => b.dateObj.compareTo(a.dateObj)); // Sort descending by date

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeaderCard(grandTotal, dateRangeText, dateRange),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final summary = summaries[index];
                      return _buildDailyCard(summary);
                    },
                    childCount: summaries.length,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, trace) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeaderCard(double grandTotal, String dateRangeText, DateTimeRange dateRange) {
    final int days = dateRange.end.difference(dateRange.start).inDays + 1;
    final double averageDaily = days > 0 ? grandTotal / days : 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Omzet',
                style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  dateRangeText,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(grandTotal),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.analytics_outlined, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Rata-rata: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(averageDaily)} / hari',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCard(_DailySummary summary) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.calendar_today, color: Colors.blue),
        ),
        title: Text(
          DateFormat('dd MMMM yyyy').format(summary.dateObj),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(summary.total),
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: summary.paymentMethods.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            e.key.toLowerCase().contains('cash') ? Icons.money : Icons.qr_code,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(e.key, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Text(
                        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(e.value),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class _DailySummary {
  final String dateStr;
  final DateTime dateObj;
  double total;
  final Map<String, double> paymentMethods;

  _DailySummary({
    required this.dateStr,
    required this.dateObj,
    required this.total,
    required this.paymentMethods,
  });
}
