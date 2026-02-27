import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:hompimpa_pos/features/orders/presentation/cart_controller.dart' as cc;
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/features/products/data/topping_repository.dart';
import 'package:hompimpa_pos/features/orders/presentation/widgets/pos_action_buttons.dart';

import 'package:hompimpa_pos/features/orders/presentation/order_list_screen.dart';
import '../../domain/order.dart';

class TabletCartPanel extends ConsumerStatefulWidget {
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
  ConsumerState<TabletCartPanel> createState() => _TabletCartPanelState();
}

class _TabletCartPanelState extends ConsumerState<TabletCartPanel> {
  String _selectedVia = 'Offline';
  bool _isDineIn = false;
  final _tableController = TextEditingController(text: '0');
  String _selectedPayment = 'Cash';

  @override
  void initState() {
    super.initState();
    if (widget.existingOrder != null) {
      _selectedVia = widget.existingOrder!.orderSource;
      _isDineIn = widget.existingOrder!.isDineIn;
      _tableController.text = widget.existingOrder!.tableNumber;
      _selectedPayment = widget.existingOrder!.paymentMethod;
    }
  }

  void _onViaSelected(String via) {
    setState(() {
      _selectedVia = via;
      
      final currentName = widget.nameController.text.trim();
      // Remove existing prefixes if any
      String baseName = currentName.replaceAll(RegExp(r'^(Offline - |Grab - )'), '');
      
      if (via == 'Offline') {
        widget.nameController.text = 'Offline - $baseName';
      } else if (via == 'GrabFood') {
        widget.nameController.text = 'Grab - $baseName';
      } else {
        widget.nameController.text = baseName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cc.cartProvider);
    final cart = cartState.items;
    final cartTotal = ref.watch(cc.cartTotalProvider);
    bool isNameFilled = widget.nameController.text.trim().isNotEmpty;
    bool isWhatsAppValid = _selectedVia != 'WhatsApp' || 
        (widget.nameController.text.trim().isNotEmpty && widget.phoneController.text.trim().isNotEmpty);

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
                // Order Via Grid
                const Text('Order Via', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.5,
                  children: [
                    _ViaButton(
                      label: 'Offline',
                      isSelected: _selectedVia == 'Offline',
                      icon: Icons.storefront,
                      onTap: () => _onViaSelected('Offline'),
                    ),
                    _ViaButton(
                      label: 'WhatsApp',
                      isSelected: _selectedVia == 'WhatsApp',
                      icon: Icons.message,
                      color: Colors.green,
                      onTap: () => _onViaSelected('WhatsApp'),
                    ),
                    _ViaButton(
                      label: 'GrabFood',
                      isSelected: _selectedVia == 'GrabFood',
                      icon: Icons.delivery_dining,
                      color: Colors.green[700],
                      onTap: () => _onViaSelected('GrabFood'),
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
                      value: _isDineIn,
                      onChanged: (v) => setState(() => _isDineIn = v),
                      activeColor: Colors.orange[800],
                    ),
                    if (_isDineIn) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _tableController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'No. Meja',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Payment Method
                const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ViaButton(
                        label: 'Cash',
                        isSelected: _selectedPayment == 'Cash',
                        icon: Icons.money,
                        onTap: () => setState(() => _selectedPayment = 'Cash'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ViaButton(
                        label: 'QRIS',
                        isSelected: _selectedPayment == 'QRIS',
                        icon: Icons.qr_code_scanner,
                        onTap: () => setState(() => _selectedPayment = 'QRIS'),
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: widget.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pelanggan (Wajib)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (v) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: widget.phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: _selectedVia == 'WhatsApp' ? 'Nomor WhatsApp (Wajib)' : 'Nomor WhatsApp (Opsional)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone),
                    hintText: '0812...',
                  ),
                  onChanged: (v) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onSelectDate,
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(DateFormat('dd/MM/yyyy').format(widget.selectedDate)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onSelectTime,
                        icon: const Icon(Icons.access_time, size: 18),
                        label: Text(widget.selectedTime.format(context)),
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
                            final standardizedPhone = widget.phoneController.text.isNotEmpty ? widget.standardizePhoneNumber(widget.phoneController.text) : null;
                            final messenger = ScaffoldMessenger.of(context);

                            if (widget.existingOrderId != null && widget.existingOrder != null) {
                              try {
                                final cc.CartController controller = ref.read(cc.cartProvider.notifier);
                                await controller.updateOrder(
                                      ref.read(orderRepositoryProvider),
                                      ref.read(toppingRepositoryProvider), // Added
                                      widget.existingOrder!,
                                      widget.nameController.text.trim(),
                                      customerPhone: standardizedPhone,
                                      pickupDate: widget.selectedDate,
                                      pickupTime: widget.selectedTime.format(context),
                                      orderSource: _selectedVia,
                                      isDineIn: _isDineIn,
                                      tableNumber: _tableController.text,
                                      paymentMethod: _selectedPayment,
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
                                    ref.read(toppingRepositoryProvider), // Added
                                    widget.nameController.text.trim(),
                                    customerPhone: standardizedPhone,
                                    isQuickOrder: widget.isQuickOrder,
                                    pickupDate: widget.selectedDate,
                                    pickupTime: widget.selectedTime.format(context),
                                    orderSource: _selectedVia,
                                    isDineIn: _isDineIn,
                                    tableNumber: _tableController.text,
                                    paymentMethod: _selectedPayment,
                                  );
                              messenger.showSnackBar(const SnackBar(
                                content: Text('Pesanan berhasil dibuat!'),
                                  backgroundColor: Colors.green,
                              ));
                              context.go('/orders');
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.existingOrderId != null ? Colors.blue[800] : Colors.orange[800],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      widget.existingOrderId != null ? 'UPDATE PESANAN' : 'PROSES PESANAN',
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
