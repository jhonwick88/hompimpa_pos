import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hompimpa_pos/features/reports/presentation/daily_sales_provider.dart';
import 'package:hompimpa_pos/features/products/presentation/product_provider.dart';
import 'package:hompimpa_pos/core/utils/responsive_layout.dart';
import 'package:hompimpa_pos/features/products/data/topping_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(todaysSalesProvider);
    final ordersAsync = ref.watch(todaysOrdersProvider);
    final productsAsync = ref.watch(productListProvider);
    final isTablet = Responsive.isTablet(context);

    // Random-ish but stable colors for summary cards
    final summaryColors = [
      Colors.indigo[400]!,
      Colors.teal[400]!,
      Colors.orange[400]!,
      Colors.pink[400]!,
    ];
    final omzetColor = summaryColors[0];
    final orderColor = summaryColors[1];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hompimpa POS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 8,
                    shadowColor: omzetColor.withOpacity(0.5),
                    color: omzetColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('Omzet Hari Ini', style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            'Rp ${sales.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    elevation: 8,
                    shadowColor: orderColor.withOpacity(0.5),
                    color: orderColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('Total Order', style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          ordersAsync.when(
                            data: (data) => Text(
                              '${data.length}',
                              style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            loading: () => const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                            error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              'Stok Produk',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Product Stock List
            Expanded(
              child: productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(child: Text('Belum ada produk'));
                  }
                  
                  final cardColors = [
                    Colors.orange[100],
                    Colors.blue[100],
                    Colors.green[100],
                    Colors.purple[100],
                    Colors.pink[100],
                    Colors.amber[100],
                    Colors.cyan[100],
                    Colors.indigo[100],
                  ];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final orientation = MediaQuery.of(context).orientation;
                      int crossAxisCount;
                      
                      if (isTablet && orientation == Orientation.portrait) {
                        crossAxisCount = 4; // Tablet portrait
                      } else if (isTablet) {
                        crossAxisCount = 6; // Tablet landscape
                      } else {
                        crossAxisCount = 2; // Phone portrait
                      }
                      
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final bgColor = cardColors[index % cardColors.length];
                      
                          return Card(
                            elevation: 6,
                            shadowColor: Colors.black26,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Stack(
                              children: [
                                // Main Background
                                Container(color: bgColor),
                                
                                // Product Image Placeholder or Icon
                                const Center(
                                  child: Opacity(
                                    opacity: 0.1,
                                    child: Icon(Icons.fastfood, size: 64),
                                  ),
                                ),

                                // Name Label at Bottom with Gradient
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [Colors.black87, Colors.transparent],
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    child: Text(
                                      product.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),

                                // Stock Badge at Top Right Edge
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(20), // Oval
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                      ],
                                    ),
                                    child: Text(
                                      '${product.stock}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add_shopping_cart),
            label: 'Input Order Manual',
            onTap: () => context.push('/entry'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.bolt),
            label: 'Quick Order',
            onTap: () => context.push('/entry?quick=true'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.history),
            label: 'Pesanan Pelanggan',
            onTap: () => context.push('/orders'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.analytics),
            label: 'Laporan Penjualan',
            onTap: () => context.push('/reports'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.cloud_upload, color: Colors.white),
            backgroundColor: Colors.red,
            label: 'Seed Toppings (Temp)',
            onTap: () async {
              try {
                await ref.read(toppingRepositoryProvider).seedToppings();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Toppings seeded successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
