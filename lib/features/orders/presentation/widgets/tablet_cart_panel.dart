import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:hompimpa_pos/features/orders/presentation/cart_controller.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/features/products/data/topping_repository.dart';
import 'package:hompimpa_pos/features/orders/presentation/widgets/pos_action_buttons.dart';

import 'package:hompimpa_pos/features/orders/presentation/order_list_screen.dart';
import '../../domain/order.dart';

class TabletCartPanel extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;
  final VoidCallback onManualOrder;
  final VoidCallback onQuickOrder;
  final bool isQuickOrder;
  final String? existingOrderId;
  final OrderEntity? existingOrder;
  final Function(String) standardizePhoneNumber;

  const TabletCartPanel({
    Key? key,
    required this.nameController,
    required this.phoneController,
    required this.selectedDate,
    required this.selectedTime,
    required this.onSelectDate,
    required this.onSelectTime,
    required this.onManualOrder,
    required this.onQuickOrder,
    required this.isQuickOrder,
    this.existingOrderId,
    this.existingOrder,
    required this.standardizePhoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    bool isNameFilled = nameController.text.trim().isNotEmpty;

    return Container(
      width: 400, // Slightly wider for tablet
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
          // Header with Actions
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_basket_outlined, color: Colors.orange[700]),
                    const SizedBox(width: 12),
                    Text(
                      'Cart Summary',
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
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
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
                            item.level != null ? '${item.productName} - Lvl ${item.level} (${item.sambal})' : item.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item.qty}x @ Rp ${item.price.toStringAsFixed(0)} ${item.note != null ? '(${item.note})' : ''}\n${item.toppings != null && item.toppings!.isNotEmpty ? '+ ${item.toppings!.map((t) => t.name).join(", ")}' : ''}',
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
                                await ref.read(cartProvider.notifier).updateOrder(
                                      ref.read(orderRepositoryProvider),
                                      ref.read(toppingRepositoryProvider), // Added
                                      existingOrder!,
                                      nameController.text.trim(),
                                      customerPhone: standardizedPhone,
                                      pickupDate: selectedDate,
                                      pickupTime: selectedTime.format(context),
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
                              await ref.read(cartProvider.notifier).submitOrder(
                                    ref.read(orderRepositoryProvider),
                                    ref.read(toppingRepositoryProvider), // Added
                                    nameController.text.trim(),
                                    customerPhone: standardizedPhone,
                                    isQuickOrder: isQuickOrder,
                                    pickupDate: selectedDate,
                                    pickupTime: selectedTime.format(context),
                                  );
                              messenger.showSnackBar(const SnackBar(
                                content: Text('Pesanan berhasil dibuat!'),
                                backgroundColor: Colors.green,
                              ));
                              context.go('/orders');
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
