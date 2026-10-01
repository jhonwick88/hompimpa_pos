import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:hompimpa_pos/features/products/presentation/product_provider.dart';
import 'package:hompimpa_pos/features/orders/presentation/cart_controller.dart' as cc;
import 'package:hompimpa_pos/features/products/domain/product.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/features/orders/presentation/widgets/tablet_cart_panel.dart';
import 'package:hompimpa_pos/features/orders/presentation/order_list_screen.dart';
import 'package:hompimpa_pos/features/orders/presentation/widgets/product_option_dialog.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:hompimpa_pos/core/widgets/gradient_app_bar.dart';
import 'package:hompimpa_pos/core/widgets/gradient_status_tab_bar.dart';
import 'package:hompimpa_pos/features/cashier/presentation/cashier_controller.dart';
import 'package:hompimpa_pos/core/widgets/app_image.dart';
import 'package:hompimpa_pos/core/widgets/product_card_modern.dart';

class TabletPortraitOrderPage extends ConsumerStatefulWidget {
  final bool isQuickOrder;
  final String? existingOrderId;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController tableController;
  final TextEditingController addressController;
  final TextEditingController deliveryFeeController;
  
  const TabletPortraitOrderPage({
    Key? key,
    required this.isQuickOrder,
    this.existingOrderId,
    required this.nameController,
    required this.phoneController,
    required this.tableController,
    required this.addressController,
    required this.deliveryFeeController,
  }) : super(key: key);

  @override
  ConsumerState<TabletPortraitOrderPage> createState() => _TabletPortraitOrderPageState();
}

class _TabletPortraitOrderPageState extends ConsumerState<TabletPortraitOrderPage> {
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
      length: 4,
      child: Scaffold(
        appBar: GradientAppBar(
          title: Text(widget.isQuickOrder ? 'Quick Order' : 'New Order'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right:24.0, top: 8.0, bottom: 8.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
                onPressed: () => _showCartSheet(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 28, color: Colors.white),
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final cartCount = ref.watch(cc.cartProvider).items.length;
                          if (cartCount == 0) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                '$cartCount',
                                style: const TextStyle(
                                  color: Color(0xFFB71C1C), // Match red theme
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          bottom: GradientStatusTabBar(
            items: const [
              GradientStatusTabItem(title: 'Semua', icon: Icons.all_inclusive, count: 0, color: Colors.blue),
              GradientStatusTabItem(title: 'Makanan', icon: Icons.fastfood, count: 0, color: Colors.orange),
              GradientStatusTabItem(title: 'Minuman', icon: Icons.local_drink, count: 0, color: Colors.green),
              GradientStatusTabItem(title: 'Snack', icon: Icons.cookie_outlined, count: 0, color: Colors.purple),
            ],
          ),
        ),
        body: Column(
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
                      _ProductGrid(products: activeProducts.where((p) => p.category == 'snack').toList()),
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
    );
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final h = MediaQuery.of(context).size.height * 0.85;
        return Material(
          color: Colors.transparent,
          child: Container(
            height: h,
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: TabletCartPanel(
                    nameController: widget.nameController,
                    phoneController: widget.phoneController,
                    tableController: widget.tableController,
                    addressController: widget.addressController,
                    deliveryFeeController: widget.deliveryFeeController,
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
      },
    );
  }
}

class _ProductGrid extends ConsumerWidget {
  final List<dynamic> products;
  
  const _ProductGrid({
    required this.products,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashierState = ref.watch(cashierProvider);

    if (products.isEmpty) {
      return const Center(child: Text('Tidak ada produk di kategori ini'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 5 : (constraints.maxWidth > 600 ? 4 : 2);
        final childAspectRatio = constraints.maxWidth > 900 ? 0.86 : (constraints.maxWidth > 600 ? 0.84 : 0.80);
        
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final isFood = product.category == 'makanan';
            
            return ProductCardModern(
              product: product,
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
                  ref.read(cc.cartProvider.notifier).addItem(product, 1);
                }
              },
            );
          },
        );
      },
    );
  }
}
