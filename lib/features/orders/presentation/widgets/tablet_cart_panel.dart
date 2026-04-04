import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:hompimpa_pos/features/orders/presentation/cart_controller.dart' as cc;
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/features/products/data/topping_repository.dart';
import 'package:hompimpa_pos/features/orders/presentation/order_state.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';

class TabletCartPanel extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController tableController;
  final bool isQuickOrder;
  final String? existingOrderId;
  final OrderEntity? existingOrder;
  final Function(String) standardizePhoneNumber;

  const TabletCartPanel({
    Key? key,
    required this.nameController,
    required this.phoneController,
    required this.tableController,
    required this.isQuickOrder,
    this.existingOrderId,
    this.existingOrder,
    required this.standardizePhoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cc.cartProvider);
    final cart = cartState.items;
    final cartTotal = ref.watch(cc.cartTotalProvider);
    final metadata = ref.watch(orderMetadataProvider);
    final metadataNotifier = ref.read(orderMetadataProvider.notifier);

    bool isNameFilled = nameController.text.trim().isNotEmpty;
    bool isWhatsAppValid = metadata.selectedVia != 'WhatsApp' || 
        (nameController.text.trim().isNotEmpty && phoneController.text.trim().isNotEmpty);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
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
              padding: const EdgeInsets.all(16),
              children: [
                // Order Via Section
                const Text('Order Via', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ViaButton(
                        label: 'Offline',
                        isSelected: metadata.selectedVia == 'Offline',
                        icon: Icons.storefront,
                        onTap: () => metadataNotifier.updateSelectedVia('Offline'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ViaButton(
                        label: 'WhatsApp',
                        isSelected: metadata.selectedVia == 'WhatsApp',
                        icon: Icons.message,
                        color: Colors.green,
                        onTap: () => metadataNotifier.updateSelectedVia('WhatsApp'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ViaButton(
                        label: 'GrabFood',
                        isSelected: metadata.selectedVia == 'GrabFood',
                        icon: Icons.delivery_dining,
                        color: Colors.green[700],
                        onTap: () => metadataNotifier.updateSelectedVia('GrabFood'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Dine In & Table Number
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
                      child: _ViaButton(
                        label: 'Cash',
                        isSelected: metadata.selectedPayment == 'Cash',
                        icon: Icons.money,
                        onTap: () => metadataNotifier.updateSelectedPayment('Cash'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ViaButton(
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
                const Divider(height: 32),
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
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () {
                                  final cc.CartController controller = ref.read(cc.cartProvider.notifier);
                                  controller.removeItem(item);
                                },
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
                                context.go('/orders');
                                return;
                            }

                            if (existingOrderId != null && existingOrder != null) {
                              try {
                                final cc.CartController controller = ref.read(cc.cartProvider.notifier);
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
                                    
                                messenger.showSnackBar(const SnackBar(
                                  content: Text('Pesanan berhasil diperbarui!'),
                                  backgroundColor: Colors.blue,
                                ));
                                context.go('/orders');
                              } catch (e) {
                                messenger.showSnackBar(SnackBar(
                                  content: Text('Gagal memperbarui pesanan: $e'),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            } else {
                              final cc.CartController controller = ref.read(cc.cartProvider.notifier);
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
                              messenger.showSnackBar(const SnackBar(
                                content: Text('Pesanan berhasil dibuat!'),
                                  backgroundColor: Colors.green,
                              ));
                              context.go('/orders');
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
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViaButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ViaButton({
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
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? activeColor : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey[600]),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
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
