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

/// Tablet-specific order entry page (>= 600px)
/// - Split layout: product grid + side cart panel
/// - TabletCartPanel always in widget tree
/// - Action buttons in cart header
class TabletOrderPage extends ConsumerStatefulWidget {
  final bool isQuickOrder;
  final String? existingOrderId;
  
  const TabletOrderPage({
    Key? key,
    required this.isQuickOrder,
    this.existingOrderId,
  }) : super(key: key);

  @override
  ConsumerState<TabletOrderPage> createState() => _TabletOrderPageState();
}

class _TabletOrderPageState extends ConsumerState<TabletOrderPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  OrderEntity? _existingOrder;
  
  @override
  void initState() {
    super.initState();
    _initOrderType();
  }

  @override
  void didUpdateWidget(TabletOrderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.existingOrderId != oldWidget.existingOrderId) {
      _initOrderType();
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      // 1. Try standard HH:mm
      if (timeStr.contains(':')) {
        final parts = timeStr.split(':');
        final hour = int.tryParse(parts[0].trim());
        final minute = int.tryParse(parts[1].split(' ')[0].trim()); // Handle "10:30 PM"
        
        if (hour != null && minute != null) {
          // Handle PM if present and simple split didn't catch it
          if (timeStr.toLowerCase().contains('pm') && hour < 12) {
             return TimeOfDay(hour: hour + 12, minute: minute);
          }
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
      
      // 2. Try parsing "HH mm" or other formats if needed, or just default
      // If we really need strict parsing, we can use DateFormat.jm() but need context/clean string
      
      return TimeOfDay.now();
    } catch (e) {
      print('Error parsing time "$timeStr": $e');
      return TimeOfDay.now();
    }
  }

  void _initOrderType() {
    // 1. Always clear cart first
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      final cc.CartController controller = ref.read(cc.cartProvider.notifier);
      controller.clearCart();
      
      // 2. Fetch if editing
      if (widget.existingOrderId != null) {
        final repository = ref.read(orderRepositoryProvider);
        final order = await repository.getOrder(widget.existingOrderId!);
        
        if (mounted && order != null) {
          _nameController.text = order.customerName;
          _phoneController.text = order.customerPhone ?? '';
          _selectedDate = order.orderDate;
          _selectedTime = _parseTime(order.orderTime);
          _existingOrder = order;
          final cc.CartController controller = ref.read(cc.cartProvider.notifier);
          controller.setCartItems(order.items);
          setState(() {});
        } else if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Order not found')),
             );
             context.pop();
        }
      }
    });

    // 3. Setup form
    if (widget.isQuickOrder) {
      _nameController.text = "Offline - ${const Uuid().v4().substring(0,4)}";
    } else if (widget.existingOrderId == null) {
      _nameController.clear();
    }
    setState(() {});
  }

  void _switchToQuickOrder() {
    if (!widget.isQuickOrder) {
      context.go('/entry?quick=true');
    }
  }

  void _switchToManualOrder() {
    if (widget.isQuickOrder) {
      context.go('/entry');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
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
              GradientStatusTabItem(
                title: 'Semua',
                icon: Icons.all_inclusive,
                count: 0,
                color: Colors.blue,
              ),
              GradientStatusTabItem(
                title: 'Makanan',
                icon: Icons.fastfood,
                count: 0,
                color: Colors.orange,
              ),
              GradientStatusTabItem(
                title: 'Minuman',
                icon: Icons.local_drink,
                count: 0,
                color: Colors.green,
              ),
            ],
          ),
        ),
        body: Row(
          children: [
            Expanded(
              flex: 2,
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
            TabletCartPanel(
              nameController: _nameController,
              phoneController: _phoneController,
              selectedDate: _selectedDate,
              selectedTime: _selectedTime,
              onSelectDate: () => _selectDate(context),
              onSelectTime: () => _selectTime(context),
              onManualOrder: _switchToManualOrder,
              onQuickOrder: _switchToQuickOrder,
              isQuickOrder: widget.isQuickOrder,
              existingOrderId: widget.existingOrderId,
              existingOrder: _existingOrder,
              standardizePhoneNumber: _standardizePhoneNumber,
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
                        child: product.imageUrl != null
                            ? Image.asset(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: isFood ? Colors.orange.shade100 : Colors.blue.shade100,
                                    child: Center(
                                      child: Icon(Icons.broken_image,
                                          color: isFood ? Colors.orange : Colors.blue),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: isFood ? Colors.orange.shade100 : Colors.blue.shade100,
                                child: Center(
                                  child: Icon(
                                    isFood ? Icons.fastfood : Icons.local_drink,
                                    size: 40,
                                    color: isFood ? Colors.orange : Colors.blue,
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
                          final cashierState = ref.read(cashierProvider);
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

