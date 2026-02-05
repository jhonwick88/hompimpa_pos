import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:hompimpa_pos/features/products/presentation/product_provider.dart';
import 'package:hompimpa_pos/features/orders/presentation/cart_controller.dart';
import 'package:hompimpa_pos/features/products/domain/product.dart';
import 'package:hompimpa_pos/features/orders/presentation/widgets/tablet_cart_panel.dart';
import 'package:hompimpa_pos/features/orders/presentation/order_list_screen.dart';

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
  
  @override
  void initState() {
    super.initState();
    _initOrderType();
  }

  void _initOrderType() {
    if (widget.existingOrderId != null) {
      // Find the specific order from the list of orders
      // In a real app, we might want a specific provider for one order
      // but here we can try to find it from the stream or just wait for it.
      // For now, let's use a post-frame callback to safely access ref.
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        final ordersAsync = ref.read(dailyOrdersProvider);
        ordersAsync.whenData((orders) {
          final order = orders.firstWhere((o) => o.id == widget.existingOrderId);
          _nameController.text = order.customerName;
          _phoneController.text = order.customerPhone ?? '';
          _selectedDate = order.orderDate;
          // Time parsing helper would be better, but simple string update for now
          ref.read(cartProvider.notifier).setCartItems(order.items);
          setState(() {});
        });
      });
    } else if (widget.isQuickOrder) {
      _nameController.text = "Offline - ${const Uuid().v4().substring(0,4)}";
    } else {
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
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: productsAsync.when(
                data: (products) => TabBarView(
                  children: [
                    _ProductGrid(products: products),
                    _ProductGrid(products: products.where((p) => p.category == 'makanan').toList()),
                    _ProductGrid(products: products.where((p) => p.category == 'minuman').toList()),
                  ],
                ),
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
