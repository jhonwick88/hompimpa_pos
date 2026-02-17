import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:hompimpa_pos/features/products/presentation/product_provider.dart';
import 'package:hompimpa_pos/features/orders/presentation/cart_controller.dart';
import 'package:hompimpa_pos/features/products/domain/product.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:hompimpa_pos/features/orders/domain/order_item.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/core/utils/responsive_layout.dart';
import 'package:hompimpa_pos/features/orders/presentation/widgets/mobile_action_bar.dart';
import 'package:hompimpa_pos/features/orders/presentation/widgets/tablet_cart_panel.dart';
import 'package:hompimpa_pos/features/orders/presentation/order_list_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hompimpa_pos/features/products/data/topping_repository.dart';
import 'package:hompimpa_pos/features/orders/presentation/widgets/product_option_dialog.dart';
import 'package:hompimpa_pos/core/widgets/gradient_status_tab_bar.dart';

class OrderEntryScreen extends ConsumerStatefulWidget {
  final bool isQuickOrder;
  final String? existingOrderId;
  const OrderEntryScreen({Key? key, this.isQuickOrder = false, this.existingOrderId}) : super(key: key);

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
    _initOrderType();
  }

  TimeOfDay _parseTime(String timeStr) {
    if (timeStr.isEmpty) return TimeOfDay.now();
    try {
      // Handle "10:30", "10:30 PM", "22:30"
      final parts = timeStr.trim().split(' ')[0].split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        
        final lowerStr = timeStr.toLowerCase();
        if (lowerStr.contains('pm') && hour < 12) hour += 12;
        if (lowerStr.contains('am') && hour == 12) hour = 0;
        
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      debugPrint('Error parsing time: $timeStr');
    }
    return TimeOfDay.now();
  }

  void _initOrderType() {
    if (widget.existingOrderId != null) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        final ordersAsync = ref.read(dailyOrdersProvider);
        ordersAsync.whenData((orders) {
          final order = orders.firstWhere((o) => o.id == widget.existingOrderId);
          _nameController.text = order.customerName;
          _phoneController.text = order.customerPhone ?? '';
          _selectedDate = order.orderDate;
          _selectedTime = _parseTime(order.orderTime);
          ref.read(cartProvider.notifier).setCartItems(order.items);
          setState(() {});
        });
      });
    } else if (widget.isQuickOrder) {
      _nameController.text = "Offline - ${const Uuid().v4().substring(0,4)}";
    } else {
      _nameController.clear();
      // Ensure defaults are fresh for new manual order if widget is reused
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
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
    final isTablet = Responsive.isTablet(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isQuickOrder ? 'Quick Order' : 'New Order'),
          actions: [
            if (!isTablet)
              MobileActionBar(
                onCartPressed: () => _showMobileCart(context),
                onManualOrderPressed: _switchToManualOrder,
                onQuickOrderPressed: _switchToQuickOrder,
              ),
          ],
          bottom: GradientStatusTabBar(
            items: [
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
        body: ResponsiveLayout(
          phone: productsAsync.when(
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
          tablet: Row(
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
      ),
    );
  }

  void _showMobileCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
              child: _MobileCartView(
                nameController: _nameController,
                phoneController: _phoneController,
                selectedDate: _selectedDate,
                selectedTime: _selectedTime,
                onSelectDate: () => _selectDate(context),
                onSelectTime: () => _selectTime(context),
                isQuickOrder: widget.isQuickOrder,
                existingOrderId: widget.existingOrderId,
                standardizePhoneNumber: _standardizePhoneNumber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileCartView extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;
  final bool isQuickOrder;
  final String? existingOrderId;
  final Function(String) standardizePhoneNumber;

  const _MobileCartView({
    required this.nameController,
    required this.phoneController,
    required this.selectedDate,
    required this.selectedTime,
    required this.onSelectDate,
    required this.onSelectTime,
    required this.isQuickOrder,
    this.existingOrderId,
    required this.standardizePhoneNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cart = cartState.items;
    final cartTotal = ref.watch(cartTotalProvider);
    bool isNameFilled = nameController.text.trim().isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.shopping_basket_outlined, color: Colors.orange[700]),
              const SizedBox(width: 12),
              Text(
                'Detail Pesanan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
              ),
              const Spacer(),
              if (cart.isNotEmpty)
                Chip(
                  label: Text('${cart.length} Item'),
                  backgroundColor: Colors.orange[50],
                  labelStyle: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pelanggan (Wajib)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor WhatsApp (Opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: '0812...',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSelectDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSelectTime,
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(selectedTime.format(context)),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(),
              ),
              if (cart.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Column(
                      children: const [
                        Icon(Icons.remove_shopping_cart_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Keranjang masih kosong', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                ...cart.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Text(
                          item.level != null ? '${item.productName} - Lvl ${item.level} (${item.sambal})' : item.productName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${item.qty}x @ Rp ${item.price.toStringAsFixed(0)}',
                          style: TextStyle(color: Colors.orange[800]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Rp ${(item.price * item.qty).toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => ref.read(cartProvider.notifier).removeItem(item),
                            ),
                          ],
                        ),
                      ),
                    )),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            bottom: true,
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    Text(
                      'Rp ${cartTotal.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (cart.isEmpty || !isNameFilled)
                        ? null
                        : () async {
                            final standardizedPhone = phoneController.text.isNotEmpty ? standardizePhoneNumber(phoneController.text) : null;

                            await ref.read(cartProvider.notifier).submitOrder(
                                  ref.read(orderRepositoryProvider),
                                  ref.read(toppingRepositoryProvider), // Added
                                  nameController.text.trim(),
                                  customerPhone: standardizedPhone,
                                  isQuickOrder: isQuickOrder,
                                  pickupDate: selectedDate,
                                  pickupTime: selectedTime.format(context),
                                );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Pesanan berhasil dibuat!'),
                              backgroundColor: Colors.green,
                            ));
                            context.go('/orders');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[800],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('PROSES PESANAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
              child: InkWell(
                onTap: () {
                  print('DEBUG: Tapped ${product.name}, Stock: ${product.stock}'); // Changed to print for visibility
                  
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
                      ref.read(cartProvider.notifier).addItem(product, 1);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                      );
                    }
                  }
                },
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

