import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../products/presentation/product_provider.dart';
import 'cart_controller.dart';
import '../../products/domain/product.dart';
import '../../orders/domain/order.dart';
import '../../orders/domain/order_item.dart';
import '../../orders/data/order_repository.dart';

class OrderEntryScreen extends ConsumerStatefulWidget {
  final bool isQuickOrder;
  const OrderEntryScreen({Key? key, this.isQuickOrder = false}) : super(key: key);

  @override
  ConsumerState<OrderEntryScreen> createState() => _OrderEntryScreenState();
}

class _OrderEntryScreenState extends ConsumerState<OrderEntryScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  @override
  void initState() {
    super.initState();
    if (widget.isQuickOrder) {
      _nameController.text = "Offline - ${const Uuid().v4().substring(0,4)}";
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
    final cart = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    
    // Check if name is filled
    bool isNameFilled = _nameController.text.trim().isNotEmpty;

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
            // Product List (Left Side)
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
            const VerticalDivider(width: 1),
            // Cart (Right Side)
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}), // Refresh to update button state
                      decoration: const InputDecoration(
                        labelText: 'Customer Name (Required)',
                        border: OutlineInputBorder(),
                        errorText: null, // We'll handle via button disable/snackbar
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone (e.g. 0812...)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectTime(context),
                            icon: const Icon(Icons.access_time),
                            label: Text(_selectedTime.format(context)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        final item = cart[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            title: Text(
                              item.level != null 
                                ? '${item.productName} - Level ${item.level} (${item.sambal})'
                                : item.productName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${item.qty}x @ Rp ${item.price.toStringAsFixed(0)}${item.note != null ? '\nKet:${item.note}' : ''}'
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                ref.read(cartProvider.notifier).removeItem(item);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[200],
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('Rp ${cartTotal.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (cart.isEmpty || !isNameFilled)
                                ? null
                                : () async {
                                    final standardizedPhone = _phoneController.text.isNotEmpty 
                                        ? _standardizePhoneNumber(_phoneController.text) 
                                        : null;

                                    await ref.read(cartProvider.notifier).submitOrder(
                                          ref.read(orderRepositoryProvider),
                                          _nameController.text.trim(),
                                          customerPhone: standardizedPhone,
                                          isQuickOrder: widget.isQuickOrder,
                                          pickupDate: _selectedDate,
                                          pickupTime: _selectedTime.format(context),
                                        );
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Placed!')));
                                    context.pop();
                                  },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              onPrimary: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('SUBMIT ORDER', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductGrid extends ConsumerWidget {
  final List<Product> products;
  const _ProductGrid({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return const Center(child: Text('Tidak ada produk di kategori ini'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75, // Adjusted for more content
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
                builder: (context) => ProductOptionDialog(product: product),
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
  }
}

class ProductOptionDialog extends ConsumerStatefulWidget {
  final Product product;
  const ProductOptionDialog({Key? key, required this.product}) : super(key: key);

  @override
  ConsumerState<ProductOptionDialog> createState() => _ProductOptionDialogState();
}

class _ProductOptionDialogState extends ConsumerState<ProductOptionDialog> {
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
