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
import 'package:hompimpa_pos/core/widgets/gradient_app_bar.dart';
import 'package:hompimpa_pos/core/widgets/gradient_status_tab_bar.dart';
import 'package:hompimpa_pos/features/cashier/presentation/cashier_controller.dart';
import 'package:hompimpa_pos/features/orders/presentation/order_state.dart';
import 'package:hompimpa_pos/core/widgets/app_image.dart';

/// Phone-specific order entry page (< 600px)
/// - Full-screen product grid
/// - Cart accessed via modal bottom sheet
class PhoneOrderPage extends ConsumerStatefulWidget {
  final bool isQuickOrder;
  final String? existingOrderId;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController tableController;
  
  const PhoneOrderPage({
    Key? key,
    required this.isQuickOrder,
    this.existingOrderId,
    required this.nameController,
    required this.phoneController,
    required this.tableController,
  }) : super(key: key);

  @override
  ConsumerState<PhoneOrderPage> createState() => _PhoneOrderPageState();
}

class _PhoneOrderPageState extends ConsumerState<PhoneOrderPage> {
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
          actions: [
            MobileActionBar(
              onCartPressed: () => _showMobileCart(context),
              onManualOrderPressed: () {},
              onQuickOrderPressed: () {},
            ),
          ],
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
        body: productsAsync.when(
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
    );
  }

  void _showMobileCart(BuildContext context) {
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
                  child: _MobileCartView(
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
      },
    );
  }
}

class _MobileCartView extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController tableController;
  final bool isQuickOrder;
  final String? existingOrderId;
  final OrderEntity? existingOrder;
  final Function(String) standardizePhoneNumber;

  const _MobileCartView({
    required this.nameController,
    required this.phoneController,
    required this.tableController,
    required this.isQuickOrder,
    this.existingOrderId,
    this.existingOrder,
    required this.standardizePhoneNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cart = cartState.items;
    final cartTotal = ref.watch(cartTotalProvider);
    final metadata = ref.watch(orderMetadataProvider);
    final metadataNotifier = ref.read(orderMetadataProvider.notifier);

    bool isNameFilled = nameController.text.trim().isNotEmpty;
    bool isWhatsAppValid = metadata.selectedVia != 'WhatsApp' || 
        (nameController.text.trim().isNotEmpty && phoneController.text.trim().isNotEmpty);

    return Column(
      children: [
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
              // Order Via Section
              const Text('Order Via', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                   Expanded(
                     child: _ViaButtonSmall(
                        label: 'Offline',
                        isSelected: metadata.selectedVia == 'Offline',
                        icon: Icons.storefront,
                        onTap: () => metadataNotifier.updateSelectedVia('Offline'),
                      ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     child: _ViaButtonSmall(
                        label: 'WA',
                        isSelected: metadata.selectedVia == 'WhatsApp',
                        icon: Icons.message,
                        onTap: () => metadataNotifier.updateSelectedVia('WhatsApp'),
                        color: Colors.green,
                      ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     child: _ViaButtonSmall(
                        label: 'Grab',
                        isSelected: metadata.selectedVia == 'GrabFood',
                        icon: Icons.delivery_dining,
                        onTap: () => metadataNotifier.updateSelectedVia('GrabFood'),
                        color: Colors.green[700],
                      ),
                   ),
                ],
              ),
              const SizedBox(height: 16),

              // Dine In & Table Section
              Row(
                children: [
                  const Text('Dine In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(width: 8),
                  Switch(
                    value: metadata.isDineIn,
                    onChanged: (v) => metadataNotifier.updateIsDineIn(v),
                    activeColor: Colors.orange[800],
                  ),
                  if (metadata.isDineIn) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: tableController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'No. Meja',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => metadataNotifier.updateTableNumber(v),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Payment Method Section
              const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ViaButtonSmall(
                      label: 'Cash',
                      isSelected: metadata.selectedPayment == 'Cash',
                      icon: Icons.money,
                      onTap: () => metadataNotifier.updateSelectedPayment('Cash'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ViaButtonSmall(
                      label: 'QRIS',
                      isSelected: metadata.selectedPayment == 'QRIS',
                      icon: Icons.qr_code_scanner,
                      onTap: () => metadataNotifier.updateSelectedPayment('QRIS'),
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pelanggan (Wajib)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                onChanged: (v) => metadataNotifier.updateCustomerName(v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: metadata.selectedVia == 'WhatsApp' ? 'Nomor WhatsApp (Wajib)' : 'Nomor WhatsApp (Opsional)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                  hintText: '0812...',
                ),
                onChanged: (v) => metadataNotifier.updateCustomerPhone(v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: metadata.selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) metadataNotifier.updateSelectedDate(picked);
                      },
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(DateFormat('dd/MM/yyyy').format(metadata.selectedDate)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: metadata.selectedTime,
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) metadataNotifier.updateSelectedTime(picked);
                      },
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text('${metadata.selectedTime.hour.toString().padLeft(2, '0')}:${metadata.selectedTime.minute.toString().padLeft(2, '0')}'),
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
                          '${item.note != null ? '(${item.note})\n' : ''}${item.toppings != null && item.toppings!.isNotEmpty ? '+ ${item.toppings!.map((t) => t.name).join(", ")}\n' : ''}Rp ${(item.price * item.qty).toStringAsFixed(0)}',
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
                    onPressed: (cart.isEmpty || !isNameFilled || !isWhatsAppValid)
                        ? null
                        : () async {
                            final standardizedPhone = phoneController.text.isNotEmpty ? standardizePhoneNumber(phoneController.text) : null;
                            final messenger = ScaffoldMessenger.of(context);

                            bool shouldProceed = true;
                            if (standardizedPhone != null && standardizedPhone.isNotEmpty) {
                                final now = DateTime.now();
                                final startOfDay = DateTime(now.year, now.month, now.day);
                                final repo = ref.read(orderRepositoryProvider);
                                final orders = await repo.getOrdersByTimeRange(startOfDay, now);
                                
                                bool hasActiveOrder = orders.any((o) => 
                                    o.customerPhone == standardizedPhone && 
                                    o.status != OrderStatus.selesai &&
                                    o.id != existingOrderId);
                                    
                                if (hasActiveOrder) {
                                    shouldProceed = await showDialog<bool>(
                                        context: context,
                                        builder: (alertContext) => AlertDialog(
                                            title: const Text('Peringatan: Nomor WA Aktif'),
                                            content: const Text('Nomor WA ini sudah memiliki pesanan aktif (belum selesai) hari ini.\n\nApakah Anda yakin ingin menyimpan pesanan ini dengan nomor yang sama?'),
                                            actions: [
                                                TextButton(
                                                    onPressed: () => Navigator.pop(alertContext, false),
                                                    child: const Text('TIDAK, PERIKSA ORDER', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                                ),
                                                ElevatedButton(
                                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white),
                                                    onPressed: () => Navigator.pop(alertContext, true),
                                                    child: const Text('YA, LANJUTKAN'),
                                                ),
                                            ],
                                        ),
                                    ) ?? false;
                                }
                            }
                            
                            if (!shouldProceed) {
                                Navigator.pop(context); // Close cart sheet
                                context.go('/orders');
                                return;
                            }

                            if (existingOrderId != null && existingOrder != null) {
                              try {
                                final CartController controller = ref.read(cartProvider.notifier);
                                await controller.updateOrder(
                                      ref.read(orderRepositoryProvider),
                                      ref.read(toppingRepositoryProvider),
                                      existingOrder!,
                                      nameController.text.trim(),
                                      customerPhone: standardizedPhone,
                                      pickupDate: metadata.selectedDate,
                                      pickupTime: '${metadata.selectedTime.hour.toString().padLeft(2, '0')}:${metadata.selectedTime.minute.toString().padLeft(2, '0')}',
                                      orderSource: metadata.selectedVia,
                                      isDineIn: metadata.isDineIn,
                                      tableNumber: tableController.text,
                                      paymentMethod: metadata.selectedPayment,
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
                                      ref.read(toppingRepositoryProvider),
                                      nameController.text.trim(),
                                      customerPhone: standardizedPhone,
                                      isQuickOrder: isQuickOrder,
                                      pickupDate: metadata.selectedDate,
                                      pickupTime: '${metadata.selectedTime.hour.toString().padLeft(2, '0')}:${metadata.selectedTime.minute.toString().padLeft(2, '0')}',
                                      orderSource: metadata.selectedVia,
                                      isDineIn: metadata.isDineIn,
                                      tableNumber: tableController.text,
                                      paymentMethod: metadata.selectedPayment,
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
                      backgroundColor: existingOrderId != null ? Colors.blue[800] : Colors.orange[800],
                      foregroundColor: Colors.white,
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

class _ViaButtonSmall extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ViaButtonSmall({
    required this.label,
    required this.isSelected,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? Colors.orange[800]!;
    return Material(
      color: isSelected ? activeColor : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? activeColor : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
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
                              builder: (context) => ProductOptionDialog(
                                product: product,
                              ),
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
