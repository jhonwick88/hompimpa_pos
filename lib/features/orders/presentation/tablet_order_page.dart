import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:hompimpa_pos/features/products/presentation/product_provider.dart';
import 'package:hompimpa_pos/features/orders/presentation/cart_controller.dart' as cc;
import 'package:hompimpa_pos/features/products/domain/product.dart';
import 'package:hompimpa_pos/features/orders/presentation/widgets/tablet_cart_panel.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/features/orders/presentation/order_list_screen.dart';
import 'package:hompimpa_pos/features/orders/presentation/widgets/product_option_dialog.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:hompimpa_pos/core/widgets/gradient_app_bar.dart';
import 'package:hompimpa_pos/core/widgets/gradient_status_tab_bar.dart';
import 'package:hompimpa_pos/features/cashier/presentation/cashier_controller.dart';
import 'package:hompimpa_pos/core/widgets/app_image.dart';

/// Tablet-specific order entry page (>= 600px)
/// - Split layout: product grid + side cart panel
/// - TabletCartPanel always in widget tree
/// - Action buttons in cart header
class TabletOrderPage extends ConsumerStatefulWidget {
  final bool isQuickOrder;
  final String? existingOrderId;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController tableController;
  
  const TabletOrderPage({
    Key? key,
    required this.isQuickOrder,
    this.existingOrderId,
    required this.nameController,
    required this.phoneController,
    required this.tableController,
  }) : super(key: key);

  @override
  ConsumerState<TabletOrderPage> createState() => _TabletOrderPageState();
}

class _TabletOrderPageState extends ConsumerState<TabletOrderPage> {
  OrderEntity? _existingOrder;
  
  @override
  void initState() {
    super.initState();
    _loadExistingOrder();
  }

  Future<void> _loadExistingOrder() async {
    if (widget.existingOrderId != null) {
      final repository = ref.read(orderRepositoryProvider);
      _existingOrder = await repository.getOrder(widget.existingOrderId!);
      if (mounted) setState(() {});
    }
  }

  String _standardizePhoneNumber(String phone) {
    String clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.startsWith('0')) {
      return '62' + clean.substring(1);
    }
    if (clean.startsWith('8')) {
      return '62' + clean;
    }
    return clean;
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: GradientAppBar(
          title: Text(widget.isQuickOrder ? 'Quick Order' : 'New Order'),
          bottom: GradientStatusTabBar(
            items: const [
              GradientStatusTabItem(title: 'Semua', icon: Icons.all_inclusive, count: 0, color: Colors.blue),
              GradientStatusTabItem(title: 'Makanan', icon: Icons.fastfood, count: 0, color: Colors.orange),
              GradientStatusTabItem(title: 'Minuman', icon: Icons.local_drink, count: 0, color: Colors.green),
            ],
          ),
        ),
        body: Row(
          children: [
            // Left Side: Product Selection (70%)
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  Expanded(
                    child: productsAsync.when(
                      data: (products) {
                        final activeProducts = products.where((p) => p.isActive).toList();
                        return TabBarView(
                          children: [
                            _ProductGrid(products: activeProducts),
                            _ProductGrid(products: activeProducts.where((p) => p.category == 'makanan').toList()),
                            _ProductGrid(products: activeProducts.where((p) => p.category == 'minuman').toList()),
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(child: Text('Error: $e')),
                    ),
                  ),
                ],
              ),
            ),
            
            // Vertical Divider
            Container(width: 1, color: Colors.grey[200]),
            
            // Right Side: Cart Panel (30%)
            Expanded(
              flex: 3,
              child: TabletCartPanel(
                nameController: widget.nameController,
                phoneController: widget.phoneController,
                tableController: widget.tableController,
                isQuickOrder: widget.isQuickOrder,
                existingOrderId: widget.existingOrderId,
                existingOrder: _existingOrder,
                standardizePhoneNumber: _standardizePhoneNumber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductGrid extends ConsumerWidget {
  final List<dynamic> products;
  const _ProductGrid({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashierState = ref.watch(cashierProvider);

    if (products.isEmpty) {
      return const Center(child: Text('Tidak ada produk di kategori ini'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 5 : (constraints.maxWidth > 600 ? 4 : 3);
        
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final isFood = product.category == 'makanan';
            
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                       child: AppImage(
                          url: product.imageUrl,
                          errorWidget: const Center(
                            child: Opacity(
                              opacity: 0.1,
                              child: Icon(Icons.grain, size: 64),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Rp ${product.price.toStringAsFixed(0)}',
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    product.category,
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Stok: ${product.stock}',
                              style: TextStyle(
                                fontSize: 11,
                                color: product.stock < 10 ? Colors.red : Colors.grey.shade600,
                                fontWeight: product.stock < 10 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Check Cashier State
                          if (!cashierState.isOpen) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kasir belum dibuka. Silakan buka kasir terlebih dahulu.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          print('DEBUG: Tablet Tapped ${product.name}, Stock: ${product.stock}');

                          if (product.stock <= 0) {
                             ScaffoldMessenger.of(context).hideCurrentSnackBar();
                             ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Stok ${product.name} habis!', style: const TextStyle(fontWeight: FontWeight.bold)),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(20),
                              ),
                            );
                            return;
                          }

                          if (isFood) {
                            showDialog(
                              context: context,
                              builder: (context) => ProductOptionDialog(product: product),
                            );
                          } else {
                            try {
                              ref.read(cc.cartProvider.notifier).addItem(product, 1);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString().replaceAll('Exception: ', '')),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(20),
                                ),
                              );
                            }
                          }
                        },
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
  }
}

