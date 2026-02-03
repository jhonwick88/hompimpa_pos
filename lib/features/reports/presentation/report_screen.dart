import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'report_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(reportDateProvider);
    final salesAsync = ref.watch(dailyProductSalesProvider);
    final filteredSales = ref.watch(filteredProductSalesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                ref.read(reportDateProvider.notifier).state = picked;
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Penjualan Per Produk: ${DateFormat('dd MMMM yyyy').format(selectedDate)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              
              // Chart Section
              SizedBox(
                height: 300,
                child: salesAsync.when(
                  data: (sales) {
                    if (sales.isEmpty) {
                      return const Center(child: Text('Tidak ada data penjualan hari ini'));
                    }
                    return _ProductBarChart(sales: sales);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
              
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),
              
              // Table Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Laporan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Cari produk...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => ref.read(reportSearchQueryProvider.notifier).state = val,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _ReportTable(sales: filteredSales),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductBarChart extends StatelessWidget {
  final List<ProductSalesReport> sales;
  const _ProductBarChart({required this.sales});

  @override
  Widget build(BuildContext context) {
    // Limit to top 10 products for better visualization
    final sortedSales = List<ProductSalesReport>.from(sales)
      ..sort((a, b) => b.totalQty.compareTo(a.totalQty));
    final displaySales = sortedSales.length > 10 ? sortedSales.sublist(0, 10) : sortedSales;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: displaySales.fold<double>(0, (max, item) => item.totalQty > max ? item.totalQty.toDouble() : max) + 2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${displaySales[group.x.toInt()].productName}\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: '${rod.toY.toInt()} terjual',
                    style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.w500),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= displaySales.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Transform.rotate(
                    angle: -45 * 3.14159 / 180,
                    child: Text(
                      displaySales[value.toInt()].productName.length > 8
                          ? displaySales[value.toInt()].productName.substring(0, 8) + '...'
                          : displaySales[value.toInt()].productName,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
              reservedSize: 60,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: displaySales.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.totalQty.toDouble(),
                color: Colors.orange,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ReportTable extends StatelessWidget {
  final List<ProductSalesReport> sales;
  const _ReportTable({required this.sales});

  @override
  Widget build(BuildContext context) {
    if (sales.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('Tidak ada data produk yang cocok'),
      ));
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Nama Produk', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
          DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
        ],
        rows: sales.map((s) {
          return DataRow(cells: [
            DataCell(Text(s.productName)),
            DataCell(Text('${s.totalQty}')),
            DataCell(Text('Rp ${NumberFormat('#,###').format(s.totalRevenue)}')),
          ]);
        }).toList(),
      ),
    );
  }
}
