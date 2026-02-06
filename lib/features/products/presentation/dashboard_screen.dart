import 'package:flutter/material.dart';
import 'package:hompimpa_pos/core/widgets/skeleton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hompimpa_pos/features/reports/presentation/daily_sales_provider.dart';
import 'package:hompimpa_pos/features/products/presentation/product_provider.dart';
import 'package:hompimpa_pos/core/utils/responsive_layout.dart';
import 'package:hompimpa_pos/features/products/data/topping_repository.dart';
import 'package:hompimpa_pos/features/products/data/product_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../core/enums/user_role.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Role Guard
    final authState = ref.watch(authStateChangesProvider);
    authState.whenData((user) {
      if (user != null && user.role == UserRole.user) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
            context.go('/orders');
        });
      }
    });

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
        actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Apakah anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('BATAL'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                         style: ElevatedButton.styleFrom(primary: Colors.red),
                        child: const Text('KELUAR'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(authControllerProvider.notifier).signOut();
                  // ignore: use_build_context_synchronously
                  context.go('/login');
                }
              },
            ),
        ],
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
                          sales == 0 
                            ? const Skeleton(width: 100, height: 24)
                            : Text(
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
                            loading: () => const Skeleton(width: 40, height: 28),
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
                                
                                // Product Image or Icon
                                if (product.imageUrl != null)
                                  Positioned.fill(
                                    child: Image.asset(
                                      product.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.broken_image,color: Colors.white54),
                                        );
                                      },
                                    ),
                                  )
                                else
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
                loading: () => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, __) => const Skeleton(width: double.infinity, height: double.infinity, borderRadius: 16),
                ),
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
            label: 'Input Order Via WA',
            onTap: () => context.push('/entry'),
          ),
          if(authState.value?.role == UserRole.dev || authState.value?.role == UserRole.admin) ...[
            SpeedDialChild(
              child: const Icon(Icons.analytics),
              label: 'Laporan Penjualan',
              onTap: () => context.push('/reports'),
            ),
            SpeedDialChild(
              child: const Icon(Icons.sync),
              label: 'Update Gambar Produk',
              onTap: () async {
                final repo = ref.read(productRepositoryProvider);
                final productsStream = repo.getProducts();
                final products = await productsStream.first;
                
                final imageMap = {
                   'Mie': 'assets/images/products/mie_hompimpa.png',
                   'Pangsit': 'assets/images/products/pangsit_goreng.png',
                   'Jus Jambu': 'assets/images/products/jus_jambu.png',
                   'Jus Alpukat': 'assets/images/products/jus_alpukat.png',
                   'Jus Sirsat': 'assets/images/products/jus_sirsat.png',
                   'Jus Buah Naga': 'assets/images/products/jus_buah_naga.png',
                   'Jus Nanas': 'assets/images/products/jus_nanas.png',
                   'Jus Nangka': 'assets/images/products/jus_nangka.png',
                };
                
                int updatedCount = 0;
                for (final product in products) {
                  if (imageMap.containsKey(product.name)) {
                    final newImage = imageMap[product.name];
                    if (product.imageUrl != newImage) {
                      final updated = product.copyWith(imageUrl: newImage);
                      await repo.updateProduct(updated);
                      updatedCount++;
                    }
                  }
                }
                
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Updated $updatedCount product images')),
                );
              },
            ),
          ],
          SpeedDialChild(
            child: const Icon(Icons.history),
            label: 'Pesanan Pelanggan',
            onTap: () => context.push('/orders'),
          ),
          
        
        ],
      ),
    );
  }
}
