import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../reports/presentation/daily_sales_provider.dart';
import '../../orders/presentation/cart_controller.dart';
import '../../orders/data/order_repository.dart';
import '../data/product_repository.dart';
import '../data/product_seeder.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(todaysSalesProvider);
    final ordersAsync = ref.watch(todaysOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hompimpa POS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Seed Data',
            onPressed: () async {
              try {
                final repo = ref.read(productRepositoryProvider);
                final seeder = ProductSeeder(repo);
                await seeder.seed();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data seeded successfully!')));
              } catch (e) {
                print("DEBUG SEED ERROR: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Seed Failed: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 10),
                  )
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/orders'),
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => context.push('/reports'),
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
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('Omzet Hari Ini', style: TextStyle(fontSize: 16)),
                          Text(
                            'Rp \${sales.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('Total Order', style: TextStyle(fontSize: 16)),
                          ordersAsync.when(
                            data: (data) => Text(
                              '\${data.length}',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (_, __) => const Text('Error'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Quick Actions
            ElevatedButton.icon(
              onPressed: () {
                // Quick Order Action
                // 1. Generate random but valid order? 
                // Wait, requirement is "1 klik tambah order default". 
                // Does this mean creating an empty order or adding a default item?
                // "1 klik tambah order dengan nama Random di awali Prefik Singkatan dari Offline Order"
                // It likely means creating a placeholder order for walk-in customers quickly.
                // But creating an order with 0 items? Or allows editing later?
                // Let's assume it goes to Order Entry screen with pre-filled name logic.
                // OR creates an order immediately. "1 klik tambah order" usually implies creation.
                // But without items?
                // Interpret: Open Order Screen with predefined "Quick Order" customer name.
                context.push('/entry?quick=true');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 24),
                primary: Colors.orange,
                onPrimary: Colors.white,
              ),
              icon: const Icon(Icons.flash_on, size: 32),
              label: const Text('QUICK ORDER (Walk-in)', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/entry'),
              style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: 24),
              ),
              icon: const Icon(Icons.add_shopping_cart, size: 32),
              label: const Text('Input Order Manual', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
