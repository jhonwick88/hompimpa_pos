import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:hompimpa_pos/features/products/presentation/product_provider.dart';
import 'package:hompimpa_pos/features/orders/presentation/cart_controller.dart';
import 'package:hompimpa_pos/features/products/domain/product.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/features/orders/presentation/widgets/tablet_cart_panel.dart';
import 'package:hompimpa_pos/features/orders/presentation/order_list_screen.dart';

/// Tablet portrait order entry page with expandable cart
/// - Cart panel is collapsible to maximize product grid space
/// - Toggle button to show/hide cart
/// - Product grid adjusts from 4 to 2 columns when cart expands
class TabletPortraitOrderPage extends ConsumerStatefulWidget {
  final bool isQuickOrder;
  final String? existingOrderId;
  
  const TabletPortraitOrderPage({
    Key? key,
    required this.isQuickOrder,
    this.existingOrderId,
  }) : super(key: key);

  @override
  ConsumerState<TabletPortraitOrderPage> createState() => _TabletPortraitOrderPageState();
}

class _TabletPortraitOrderPageState extends ConsumerState<TabletPortraitOrderPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _cartExpanded = false; // Cart starts collapsed
  
  @override
  void initState() {
    super.initState();
    _initOrderType();
    _loadExistingOrder();
  }

  void _initOrderType() {
    if (widget.isQuickOrder) {
      _nameController.text = "Offline - ${const Uuid().v4().substring(0,4)}";
    } else {
      _nameController.clear();
    }
    setState(() {});
  }

  Future<void> _loadExistingOrder() async {
    if (widget.existingOrderId != null) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        final ordersAsync = ref.read(dailyOrdersProvider);
        ordersAsync.whenData((orders) {
          final order = orders.firstWhere((o) => o.id == widget.existingOrderId);
          _nameController.text = order.customerName;
          _phoneController.text = order.customerPhone ?? '';
          _selectedDate = order.orderDate;
          ref.read(cartProvider.notifier).setCartItems(order.items);
          setState(() {
            _cartExpanded = true; // Auto expand cart when editing
          });
        });
      });
    }
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
        appBar: AppBar(
          title: Text(widget.isQuickOrder ? 'Quick Order' : 'New Order'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Makanan'),
              Tab(text: 'Minuman'),
            ],
          ),
        ),
        body: Stack(
          children: [
            // Product grid (full width when cart collapsed)
            Positioned.fill(
              right: _cartExpanded ? 350 : 0,
              child: productsAsync.when(
                data: (products) => TabBarView(
                  children: [
                    _ProductGrid(products: products, cartExpanded: _cartExpanded),
                    _ProductGrid(
                      products: products.where((p) => p.category == 'makanan').toList(),
                      cartExpanded: _cartExpanded,
                    ),
                    _ProductGrid(
                      products: products.where((p) => p.category == 'minuman').toList(),
                      cartExpanded: _cartExpanded,
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
            // Expandable cart panel
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: _cartExpanded ? 0 : -350,
              top: 0,
              bottom: 0,
              width: 350,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(-2, 0),
                    ),
                  ],
                ),
                child: TabletCartPanel(
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
                  standardizePhoneNumber: _standardizePhoneNumber,
                ),
              ),
            ),
            // Toggle button
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: _cartExpanded ? 350 : 0,
              top: 100,
              child: Material(
                elevation: 4,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: InkWell(
                  onTap: () => setState(() => _cartExpanded = !_cartExpanded),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  child: Container(
                    width: 40,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _cartExpanded ? Icons.chevron_right : Icons.shopping_cart,
                          color: Colors.white,
                          size: 24,
                        ),
                        if (!_cartExpanded) ...[
                          const SizedBox(height: 4),
                          Consumer(
                            builder: (context, ref, _) {
                              final cart = ref.watch(cartProvider);
                              if (cart.isEmpty) return const SizedBox.shrink();
                              return Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${cart.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
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
  final bool cartExpanded;
  
  const _ProductGrid({
    required this.products,
    required this.cartExpanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return const Center(child: Text('Tidak ada produk di kategori ini'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust grid based on cart state
        // Cart hidden: 4 columns, Cart visible: 2 columns
        final crossAxisCount = cartExpanded ? 2 : 4;
        
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
            
            return GestureDetector(
              onTap: () {
                if (isFood) {
                  showDialog(
                    context: context,
                    builder: (context) => _ProductOptionDialog(product: product),
                  );
                } else {
                  ref.read(cartProvider.notifier).addItem(product, 1);
                }
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
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
              ),
            );
          },
        );
      },
    );
  }
}

class _ProductOptionDialog extends ConsumerStatefulWidget {
  final dynamic product;
  const _ProductOptionDialog({required this.product});

  @override
  ConsumerState<_ProductOptionDialog> createState() => _ProductOptionDialogState();
}

class _ProductOptionDialogState extends ConsumerState<_ProductOptionDialog> {
  int _qty = 1;
  String _sambal = 'Campur';
  double _level = 1;
  final _noteController = TextEditingController();

  Color _getSliderColor() {
    if (_level <= 2) return Colors.green;
    if (_level <= 4) return Colors.amber;
    if (_level <= 6) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Customization: ${widget.product.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Jumlah (Qty)', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                ),
                Text('$_qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _qty++),
                ),
              ],
            ),
            const Divider(),
            const Text('Opsi Sambal', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Radio<String>(
                  value: 'Campur',
                  groupValue: _sambal,
                  onChanged: (v) => setState(() => _sambal = v!),
                ),
                const Text('Campur'),
                Radio<String>(
                  value: 'Pisah',
                  groupValue: _sambal,
                  onChanged: (v) => setState(() => _sambal = v!),
                ),
                const Text('Pisah'),
              ],
            ),
            const Divider(),
            Text('Level Pedas: ${_level.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _getSliderColor(),
                thumbColor: _getSliderColor(),
                overlayColor: _getSliderColor().withOpacity(0.2),
              ),
              child: Slider(
                value: _level,
                min: 1,
                max: 7,
                divisions: 6,
                label: _level.toInt().toString(),
                onChanged: (v) => setState(() => _level = v),
              ),
            ),
            const Divider(),
            const Text('Catatan (Note)', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Contoh: Tanpa daun bawang',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(cartProvider.notifier).addItem(
              widget.product,
              _qty,
              level: _level.toInt().toString(),
              sambal: _sambal,
              note: _noteController.text.isNotEmpty ? _noteController.text : null,
            );
            Navigator.pop(context);
          },
          child: const Text('SUBMIT'),
        ),
      ],
    );
  }
}
