import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:hompimpa_pos/features/products/presentation/product_provider.dart';
import 'package:hompimpa_pos/features/orders/presentation/cart_controller.dart';
import 'package:hompimpa_pos/features/products/domain/product.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/features/orders/presentation/widgets/mobile_action_bar.dart';
import 'package:hompimpa_pos/features/orders/presentation/order_list_screen.dart';
import 'package:hompimpa_pos/features/products/data/topping_repository.dart';
import 'package:hompimpa_pos/features/orders/presentation/widgets/product_option_dialog.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';

/// Phone-specific order entry page (< 600px)
/// - Full-screen product grid
/// - Cart accessed via modal bottom sheet
/// - NO TabletCartPanel in widget tree
class PhoneOrderPage extends ConsumerStatefulWidget {
  final bool isQuickOrder;
  final String? existingOrderId;
  
  const PhoneOrderPage({
    Key? key,
    required this.isQuickOrder,
    this.existingOrderId,
  }) : super(key: key);

  @override
  ConsumerState<PhoneOrderPage> createState() => _PhoneOrderPageState();
}

class _PhoneOrderPageState extends ConsumerState<PhoneOrderPage> {
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
  void didUpdateWidget(PhoneOrderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.existingOrderId != oldWidget.existingOrderId) {
      _initOrderType();
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      if (timeStr.contains(':')) {
        final parts = timeStr.split(':');
        final hour = int.tryParse(parts[0].trim());
        final minute = int.tryParse(parts[1].split(' ')[0].trim());
        
        if (hour != null && minute != null) {
          if (timeStr.toLowerCase().contains('pm') && hour < 12) {
             return TimeOfDay(hour: hour + 12, minute: minute);
          }
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
      return TimeOfDay.now();
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  void _initOrderType() {
    // 1. Always clear cart first to ensure no stale data
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      ref.read(cartProvider.notifier).clearCart();
      
      // 2. If editing, fetch and populate
      if (widget.existingOrderId != null) {
        final repository = ref.read(orderRepositoryProvider);
        final order = await repository.getOrder(widget.existingOrderId!);
        
        if (mounted && order != null) {
          _nameController.text = order.customerName;
          _phoneController.text = order.customerPhone ?? '';
          _selectedDate = order.orderDate;
          _selectedTime = _parseTime(order.orderTime);
          _existingOrder = order;
          ref.read(cartProvider.notifier).setCartItems(order.items);
          setState(() {});
        } else if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Order not found')),
             );
             context.pop();
        }
      }
    });

    // 3. Setup form fields
    if (widget.isQuickOrder) {
      _nameController.text = "Offline - ${const Uuid().v4().substring(0,4)}";
    } else if (widget.existingOrderId == null) {
      _nameController.clear();
    }
    setState(() {});
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
          actions: [
            MobileActionBar(
              onCartPressed: () => _showMobileCart(context),
              onManualOrderPressed: () {},
              onQuickOrderPressed: () {},
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Makanan'),
              Tab(text: 'Minuman'),
            ],
          ),
        ),
        body: productsAsync.when(
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
    );
  }

  void _showMobileCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
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
                    onSelectDate: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setModalState(() {
                          _selectedDate = picked;
                        });
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    onSelectTime: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (picked != null && picked != _selectedTime) {
                         setModalState(() {
                          _selectedTime = picked;
                        });
                        setState(() {
                          _selectedTime = picked;
                        });
                      }
                    },
                    isQuickOrder: widget.isQuickOrder,
                    existingOrderId: widget.existingOrderId,
                    existingOrder: _existingOrder,
                    standardizePhoneNumber: _standardizePhoneNumber,
                  ),
                ),
              ],
            ),
          );
        }
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
  final OrderEntity? existingOrder;
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
    this.existingOrder,
    required this.standardizePhoneNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    bool isNameFilled = nameController.text.trim().isNotEmpty;

    return Column(
      children: [
        // ... (title padding remains same)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.shopping_basket_outlined, color: Colors.orange[700]),
              const SizedBox(width: 12),
              Text(
                existingOrderId != null ? 'Update Pesanan' : 'Detail Pesanan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
              ),
// ...
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
                          item.level != null ? '${item.productName} - Lvl ${item.level} (${item.sambal}) - ${item.qty}x' : item.productName + ' - ${item.qty}x',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${item.note != null ? '(${item.note})' : ''}\n${item.toppings != null && item.toppings!.isNotEmpty ? '+ ${item.toppings!.map((t) => t.name).join(", ")}' : ''}',
                          style: TextStyle(color: Colors.orange[800], fontSize: 13),
                        ),
                        isThreeLine: true,
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
                            final messenger = ScaffoldMessenger.of(context);

                            if (existingOrderId != null && existingOrder != null) {
                              try {
                                final CartController controller = ref.read(cartProvider.notifier);
                                await controller.updateOrder(
                                      ref.read(orderRepositoryProvider),
                                      ref.read(toppingRepositoryProvider), // Added
                                      existingOrder!,
                                      nameController.text.trim(),
                                      customerPhone: standardizedPhone,
                                      pickupDate: selectedDate,
                                      pickupTime: selectedTime.format(context),
                                    );
                                    
                                Navigator.pop(context); // Close cart sheet
                                messenger.showSnackBar(const SnackBar(
                                  content: Text('Pesanan berhasil diperbarui!'),
                                  backgroundColor: Colors.blue,
                                ));
                                context.go('/orders'); // Go back to list
                              } catch (e) {
                                messenger.showSnackBar(SnackBar(
                                  content: Text('Gagal memperbarui pesanan: $e'),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            } else {
                              try {
                                final CartController controller = ref.read(cartProvider.notifier);
                                await controller.submitOrder(
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
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('Gagal membuat pesanan: $e'),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      primary: existingOrderId != null ? Colors.blue[800] : Colors.orange[800],
                      onPrimary: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      existingOrderId != null ? 'UPDATE PESANAN' : 'PROSES PESANAN',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
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
  final List<dynamic> products;
  const _ProductGrid({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return const Center(child: Text('Tidak ada produk di kategori ini'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 5 : (constraints.maxWidth > 600 ? 4 : 2);
        
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.8,
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
                          if (isFood) {
                            showDialog(
                              context: context,
                              builder: (context) => ProductOptionDialog(product: product),
                            );
                          } else {
                            ref.read(cartProvider.notifier).addItem(product, 1);
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

