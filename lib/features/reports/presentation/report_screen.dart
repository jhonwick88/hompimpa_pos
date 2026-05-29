import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:hompimpa_pos/features/reports/presentation/report_provider.dart';
import 'package:hompimpa_pos/features/settings/data/store_repository.dart';
import 'package:hompimpa_pos/features/auth/data/auth_repository.dart';
import 'package:hompimpa_pos/core/enums/user_role.dart';
import 'package:hompimpa_pos/core/widgets/gradient_app_bar.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(reportDateProvider);
    final salesAsync = ref.watch(dailyProductSalesProvider);
    final filteredSales = ref.watch(filteredProductSalesProvider);
    final user = ref.watch(authStateChangesProvider).value;
    final storesAsync = ref.watch(activeStoresProvider);
    final selectedStoreId = ref.watch(selectedStoreIdProvider);
    final width = MediaQuery.of(context).size.width;
    final storeSalesAsync = ref.watch(dailyStoreSalesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: GradientAppBar(
          title: const Text('Penjualan'),
          bottom: TabBar(
            tabs: const [
              Tab(
                icon: Icon(Icons.inventory_2_outlined, size: 20),
                text: 'Produk',
              ),
              Tab(
                icon: Icon(Icons.storefront_outlined, size: 20),
                text: 'Store',
              ),
            ],
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
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
      body: TabBarView(
        children: [
          // TAB 0: PRODUK
          SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== TOP SUMMARY CARD =====
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade700, Colors.green.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flex(
                      direction: width > 600 ? Axis.horizontal : Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: width > 600 ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: width > 600 ? null : double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ringkasan Produk',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.7),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                DateFormat('dd MMMM yyyy').format(selectedDate),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (width <= 600 && user?.role == UserRole.dev) const SizedBox(height: 20),
                        // Dev Store Filter
                        if (user?.role == UserRole.dev) 
                          SizedBox(
                            width: width > 600 ? 250 : double.infinity,
                            child: storesAsync.when(
                              data: (stores) => DropdownButtonFormField<String?>(
                                value: selectedStoreId,
                                decoration: InputDecoration(
                                  labelText: 'Filter Store',
                                  labelStyle: const TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                  ),
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                ),
                                style: const TextStyle(fontSize: 13, color: Colors.white),
                                dropdownColor: Colors.green.shade900,
                                iconEnabledColor: Colors.white,
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('Semua Store')),
                                  ...stores.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                                ],
                                onChanged: (val) => ref.read(selectedStoreIdProvider.notifier).state = val,
                              ),
                              loading: () => const LinearProgressIndicator(),
                              error: (_, __) => const SizedBox(),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Chart Section
                    SizedBox(
                      height: 300,
                      child: salesAsync.when(
                        data: (sales) {
                          if (sales.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.analytics_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
                                  const SizedBox(height: 16),
                                  Text('Tidak ada data penjualan hari ini', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                                ],
                              ),
                            );
                          }
                          return _ProductBarChart(sales: sales);
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // ===== DETAIL SECTION HEADER =====

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Detail Penjualan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900, 
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari produk...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            onChanged: (val) => ref.read(reportSearchQueryProvider.notifier).state = val,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _ReportTable(sales: filteredSales),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // TAB 1: STORE
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ringkasan Penjualan per Store',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.w900, 
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 20),
              storeSalesAsync.when(
                data: (reports) {
                  if (reports.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          Icon(Icons.storefront_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('Belum ada penjualan di store mana pun hari ini', 
                            style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    );
                  }
                  
                  if (width > 700) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 3.5,
                      ),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        return _StoreCard(report: reports[index]);
                      },
                    );
                  } else {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reports.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _StoreCard(report: reports[index]);
                      },
                    );
                  }
                },
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                )),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ],
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
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
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
                return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.white70));
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

    final width = MediaQuery.of(context).size.width;

    if (width > 700) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 4.0,
        ),
        itemCount: sales.length,
        itemBuilder: (context, index) {
          return _ProductCard(item: sales[index]);
        },
      );
    } else {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sales.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _ProductCard(item: sales[index]);
        },
      );
    }
  }
}

class _StoreCard extends StatelessWidget {
  final StoreSalesReport report;

  const _StoreCard({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.orange.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.store_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  report.storeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${report.orderCount} pesanan selesai',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rp ${NumberFormat("#,##0", "id_ID").format(report.totalRevenue)}',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductSalesReport item;

  const _ProductCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.totalQty} terjual',
                          style: const TextStyle(
                            color: Colors.white70, 
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(item.totalRevenue)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900, 
                    color: Colors.lightGreenAccent,
                    fontSize: 17,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
