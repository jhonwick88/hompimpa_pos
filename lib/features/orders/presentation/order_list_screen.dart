import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:hompimpa_pos/features/auth/presentation/auth_controller.dart';
import 'package:hompimpa_pos/features/auth/data/auth_repository.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:hompimpa_pos/features/orders/domain/order_item.dart';
import 'package:hompimpa_pos/core/enums/user_role.dart';
import 'package:hompimpa_pos/features/orders/presentation/widgets/nota_preview_dialog.dart';
import 'package:hompimpa_pos/core/widgets/gradient_app_bar.dart';
import 'package:hompimpa_pos/core/widgets/gradient_status_tab_bar.dart';
import 'package:hompimpa_pos/core/widgets/order_card_modern.dart';

// Providers for filtering
final orderStatusFilterProvider = StateProvider<OrderStatus?>((ref) => null);
final orderSearchQueryProvider = StateProvider<String>((ref) => '');
final orderDateFilterProvider = StateProvider<DateTime>((ref) => DateTime.now());
final isSearchModeProvider = StateProvider<bool>((ref) => false);
final orderSortAscendingProvider = StateProvider<bool>((ref) => false);

final filteredOrdersProvider = StreamProvider<List<OrderEntity>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final status = ref.watch(orderStatusFilterProvider);
  final query = ref.watch(orderSearchQueryProvider);
  final date = ref.watch(orderDateFilterProvider);
  final user = ref.watch(authStateChangesProvider).value;
  return repository.getOrdersStream(status: status, searchQuery: query, date: date, currentUser: user);
});

final dailyOrdersProvider = StreamProvider<List<OrderEntity>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final date = ref.watch(orderDateFilterProvider);
  final user = ref.watch(authStateChangesProvider).value;
  return repository.getOrdersStream(date: date, currentUser: user);
});

final reviewOrdersCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final user = ref.watch(authStateChangesProvider).value;
  return repository.getOrdersStream(status: OrderStatus.menungguReview, currentUser: user).map((list) => list.length);
});

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  DateTime? currentBackPressTime;

  Future<bool> _onWillPop() async {
    final user = ref.read(authStateChangesProvider).value;

    if (user != null && (user.role == UserRole.admin || user.role == UserRole.dev)) {
      context.go('/');
      return Future.value(false);
    }

    DateTime now = DateTime.now();
    if (currentBackPressTime == null || 
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tekan sekali lagi untuk keluar'),
          duration: Duration(seconds: 2),
        ),
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    final isSearchMode = ref.watch(isSearchModeProvider);
    final selectedDate = ref.watch(orderDateFilterProvider);
    final dailyOrdersAsync = ref.watch(dailyOrdersProvider);

    final counts = dailyOrdersAsync.when(
      data: (orders) => {
        OrderStatus.belum: orders.where((o) => o.status == OrderStatus.belum).length,
        OrderStatus.proses: orders.where((o) => o.status == OrderStatus.proses).length,
        OrderStatus.selesai: orders.where((o) => o.status == OrderStatus.selesai).length,
      },
      loading: () => {OrderStatus.belum: 0, OrderStatus.proses: 0, OrderStatus.selesai: 0},
      error: (_, __) => {OrderStatus.belum: 0, OrderStatus.proses: 0, OrderStatus.selesai: 0},
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
         // endDrawer: const AppEndDrawer(),
          appBar: GradientAppBar(
            title: isSearchMode 
              ? TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Cari Nama / No Telp...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) => ref.read(orderSearchQueryProvider.notifier).state = val,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     const Text('Pesanan Pelanggan'),
                     Text(
                       DateFormat('dd-MM-yyyy').format(selectedDate),
                       style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                     ),
                  ],
                ),
            actions: [
              IconButton(
                icon: Icon(isSearchMode ? Icons.close : Icons.search),
                onPressed: () {
                  ref.read(isSearchModeProvider.notifier).state = !isSearchMode;
                  if (isSearchMode) {
                    ref.read(orderSearchQueryProvider.notifier).state = '';
                  }
                },
              ),
              Consumer(
                builder: (context, ref, child) {
                  final isAsc = ref.watch(orderSortAscendingProvider);
                  return IconButton(
                    icon: Icon(isAsc ? Icons.arrow_upward : Icons.arrow_downward),
                    tooltip: 'Urutkan Waktu (${isAsc ? 'ASC' : 'DSC'})',
                    onPressed: () => ref.read(orderSortAscendingProvider.notifier).state = !isAsc,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    ref.read(orderDateFilterProvider.notifier).state = picked;
                  }
                },
              ),
              // Builder(
              //   builder: (context) => IconButton(
              //     icon: const Icon(Icons.menu),
              //     onPressed: () => Scaffold.of(context).openEndDrawer(),
              //   ),
              // ),
            ],
bottom: GradientStatusTabBar(
  style: TabBarStyle.pill, // atau underline
  items: [
    GradientStatusTabItem(
      title: 'Belum',
      icon: Icons.timer,
      count: counts[OrderStatus.belum]!,
      color: Colors.orange,
    ),
    GradientStatusTabItem(
      title: 'Proses',
      icon: Icons.sync,
      count: counts[OrderStatus.proses]!,
      color: Colors.blue,
    ),
    GradientStatusTabItem(
      title: 'Selesai',
      icon: Icons.check_circle,
      count: counts[OrderStatus.selesai]!,
      color: Colors.green,
    ),
  ],
),
          ),
          body: const TabBarView(
            children: [
              _OrderListTab(status: OrderStatus.belum),
              _OrderListTab(status: OrderStatus.proses),
              _OrderListTab(status: OrderStatus.selesai),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/entry?quick=true'),
            label: const Text('Quick Order'),
            icon: const Icon(Icons.flash_on),
            backgroundColor: Colors.orange,
          ),
        ),
      ),
    );
  }

  Widget _buildTabHeader(String title, IconData icon, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(title, style: const TextStyle(fontSize: 12)),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }
}

class _OrderListTab extends ConsumerWidget {
  final OrderStatus status;
  const _OrderListTab({required this.status});

  Future<void> _sendWhatsApp(OrderEntity order) async {
    if (order.customerPhone == null || order.customerPhone!.isEmpty) return;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    final dateStr = DateFormat('dd/MM/yyyy').format(order.orderDate);
    final itemsSummary = order.items.asMap().entries.map((entry) {
      final i = entry.value;
      final index = entry.key + 1;
      
      final isFood = i.productName.toLowerCase().contains('mie') || 
                     i.productName.toLowerCase().contains('pangsit');
      
      String itemText = "$index. *${i.productName} x ${i.qty}*";
      
      if (isFood && i.level != null) {
        itemText += " (Lv. ${i.level}, ${i.sambal ?? 'Campur'})";
      }
      
      //itemText += "\n";
      if (i.toppings != null && i.toppings!.isNotEmpty) {
        final toppings = i.toppings!.map((t) => t.name).join(", ");
        itemText += "   *+ $toppings*";
      }
      itemText += " ... Rp. ${currencyFormat.format(i.price * i.qty)}";
      return itemText;
    }).join("\n");
    
    final message = "*Hi, Hompier !*\n"
        "Terima kasih telah memesan *Hompimpa Mie & Pangsit*.\n\n"
        "*Detail Waktu Pesanan :*\n"
        "- Tanggal: $dateStr\n"
        "- Jam: ${order.orderTime} WIB\n\n"
        "*Item Pesanan :*\n$itemsSummary\n\n"
        "*Total Pembayaran: Rp. ${currencyFormat.format(order.total)}*\n\n"
        "*Sudah Bisa diambil*.\n\n"
        "Silakan konfirmasi jika ada yang perlu dikoreksi. Terima Kasih 🙏 Dan sehat selalu 😊";

    final encodedMessage = Uri.encodeComponent(message);
    final uri = Uri.parse("https://wa.me/${order.customerPhone}?text=$encodedMessage");
    
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
         throw 'Could not launch $uri';
      }
    } catch (e) {
      // debugPrint('Could not launch WhatsApp: $e');
      // Fallback for some devices/browsers
      if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
         // show error
      }
    }
  }

  Future<void> _processOrder(BuildContext context, WidgetRef ref, OrderEntity order) async {
    try {
      final messenger = ScaffoldMessenger.of(context);
      final user = ref.read(authStateChangesProvider).value;
      
      await ref.read(orderRepositoryProvider).updateOrderStatus(
        order.id, 
        OrderStatus.proses, 
        order.items,
        executorId: user?.uid,
        executorName: user?.displayName ?? user?.email,
      );
      messenger.showSnackBar(const SnackBar(content: Text('Pesanan diproses')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memproses pesanan: $e')));
    }
  }

  Future<void> _showSelesaiConfirmation(BuildContext context, WidgetRef ref, OrderEntity order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Selesai'),
        content: Text('Apakah pesanan ${order.customerName} benar-benar sudah selesai?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('YA, SELESAI'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final messenger = ScaffoldMessenger.of(context);
        await ref.read(orderRepositoryProvider).updateOrderStatus(order.id, OrderStatus.selesai, order.items);
        messenger.showSnackBar(const SnackBar(content: Text('Pesanan telah selesai')));
        
        // Send WhatsApp if phone exists
        if (order.customerPhone != null && order.customerPhone!.isNotEmpty) {
          await _sendWhatsApp(order);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyelesaikan: $e')));
      }
    }
  }

  Future<void> _showVoidDialog(BuildContext context, WidgetRef ref, OrderEntity order) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _VoidOrderDialog(order: order),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final messenger = ScaffoldMessenger.of(context);
        final user = ref.read(authStateChangesProvider).value;
        final voidBy = user?.displayName ?? user?.email ?? 'Unknown';

        await ref.read(orderRepositoryProvider).voidOrder(order.id, result, voidBy);
        messenger.showSnackBar(const SnackBar(
          content: Text('Order berhasil divoid'),
          backgroundColor: Colors.red,
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal void order: $e')));
      }
    }
  }

  Future<void> _editOrderItem(BuildContext context, WidgetRef ref, OrderEntity order, int itemIndex) async {
    final item = order.items[itemIndex];
    final updatedItem = await showDialog<OrderItem>(
      context: context,
      builder: (context) => _OrderItemEditDialog(item: item),
    );

    if (updatedItem != null) {
      try {
        final messenger = ScaffoldMessenger.of(context);
        final newItems = List<OrderItem>.from(order.items);
        newItems[itemIndex] = updatedItem;
        await ref.read(orderRepositoryProvider).updateOrderItems(order.id, newItems);
        messenger.showSnackBar(const SnackBar(content: Text('Item pesanan diperbarui')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui item: $e')));
      }
    }
  }

  Future<void> _showRestoreBelumConfirmation(BuildContext context, WidgetRef ref, OrderEntity order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Restore Status'),
        content: Text('Kembalikan pesanan ${order.customerName} ke status "Belum" diproses?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('YA, RESTORE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final messenger = ScaffoldMessenger.of(context);
        await ref.read(orderRepositoryProvider).updateOrderStatus(order.id, OrderStatus.belum, order.items);
        messenger.showSnackBar(const SnackBar(content: Text('Status pesanan berhasil direstore ke Belum')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal merestore status: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrdersAsync = ref.watch(filteredOrdersProvider);
    final isAsc = ref.watch(orderSortAscendingProvider);
    final user = ref.watch(authStateChangesProvider).value;

    return allOrdersAsync.when(
      data: (orders) {
        // Filter by status (exclude void/batal if not in standard tabs)
        // Tabs are Belum, Proses, Selesai. Batal won't match any unless we handled it.
        // Assuming 'status' arg is one of the visible ones.
        final filtered = orders.where((o) => o.status == status).toList();
        
        // Sort by time/orderTime
        filtered.sort((a, b) {
            int cmp = a.orderTime.compareTo(b.orderTime);
            if (cmp == 0) {
              final dateA = a.createdAt ?? a.orderDate;
              final dateB = b.createdAt ?? b.orderDate;
              cmp = dateA.compareTo(dateB);
            }
            return isAsc ? cmp : -cmp;
        });

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Tidak ada pesanan ${status.name}', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
               ref.refresh(filteredOrdersProvider.future),
               ref.refresh(dailyOrdersProvider.future),
            ]);
          },
          child: ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final order = filtered[index];
            // Queue number 1, 2, 3...
            final queueNumber = index + 1;

            return OrderCardModern(
  order: order,
  queueNumber: queueNumber,
  statusColor: _getStatusColor(order.status),
  statusIcon: _getStatusIcon(order.status),
  onEditItem: (order, idx) => _editOrderItem(context, ref, order, idx),
  onStatusTap: (order.status == OrderStatus.proses && user != null && (user.role == UserRole.admin || user.role == UserRole.dev)) 
      ? () => _showRestoreBelumConfirmation(context, ref, order) 
      : null,
  actionSection: Wrap(
    alignment: WrapAlignment.start,
    spacing: 8,
    runSpacing: 8,
    children: [
      if (order.status == OrderStatus.belum) ...[
        ElevatedButton(
          onPressed: () => _processOrder(context, ref, order),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          child: const Text('Proses'),
        ),
      ],
      if (order.status == OrderStatus.proses) ...[
        ElevatedButton.icon(
          onPressed: () => _showSelesaiConfirmation(context, ref, order),
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Selesai'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
        ),
      ],
      if (order.status == OrderStatus.selesai) ...[
        TextButton.icon(
          onPressed: () => _showUpdatePaymentMethodDialog(context, ref, order),
          icon: Icon(
            order.paymentMethod == 'QRIS' ? Icons.qr_code : Icons.money,
            size: 18,
            color: order.paymentMethod == 'QRIS' ? Colors.blue[700] : Colors.green[700],
          ),
          label: Text(
            order.paymentMethod,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: order.paymentMethod == 'QRIS' ? Colors.blue[700] : Colors.green[700],
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showPrintPreview(context, order),
          icon: const Icon(Icons.print, size: 18),
          label: const Text('Print'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
        ),
        if (order.customerPhone != null && order.customerPhone!.isNotEmpty) ...[
          ElevatedButton.icon(
            onPressed: () => _sendWhatsApp(order),
            icon: Icon(Icons.message, size: 18),
            label: Text('Check'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ],
      ],
      if (order.status != OrderStatus.selesai) ...[
          ElevatedButton.icon(
          onPressed: () => context.push('/entry/add/${order.id}'),
          icon: const Icon(Icons.add_shopping_cart, size: 18),
          label: const Text('Tambah'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
        ),
        ElevatedButton.icon(
          onPressed: () => _showVoidDialog(context, ref, order),
          icon: const Icon(Icons.delete_forever, size: 18),
          label: const Text('Void'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
        ),
      ],
    ],
  ),
);
          },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Gagal memuat data: $e')),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.belum: return Colors.orange;
      case OrderStatus.proses: return Colors.blue;
      case OrderStatus.selesai: return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.belum: return Icons.timer;
      case OrderStatus.proses: return Icons.sync;
      case OrderStatus.selesai: return Icons.check_circle;
      default: return Icons.cancel;
    }
  }

  void _showPrintPreview(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (context) => NotaPreviewDialog(order: order),
    );
  }

  Future<void> _showUpdatePaymentMethodDialog(BuildContext context, WidgetRef ref, OrderEntity order) async {
    final newPayment = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Metode Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.money, color: Colors.green),
              title: const Text('Cash'),
              onTap: () => Navigator.pop(context, 'Cash'),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.blue),
              title: const Text('QRIS'),
              onTap: () => Navigator.pop(context, 'QRIS'),
            ),
          ],
        ),
      ),
    );

    if (newPayment != null && newPayment != order.paymentMethod) {
      try {
        final messenger = ScaffoldMessenger.of(context);
        await ref.read(orderRepositoryProvider).updateOrder(order.copyWith(paymentMethod: newPayment));
        messenger.showSnackBar(SnackBar(
          content: Text('Metode pembayaran diperbarui ke $newPayment'),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memperbarui metode pembayaran: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }
}

class _VoidOrderDialog extends StatefulWidget {
  final OrderEntity order;
  const _VoidOrderDialog({Key? key, required this.order}) : super(key: key);

  @override
  State<_VoidOrderDialog> createState() => _VoidOrderDialogState();
}

class _VoidOrderDialogState extends State<_VoidOrderDialog> {
  String? _selectedReason;
  late TextEditingController _reasonController;
  final List<String> _reasons = [
    "Salah input",
    "Pesanan dibatalkan customer",
    "Item tidak tersedia",
    "Duplikat order",
    "Lainnya"
  ];
  bool _isOther = false;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  bool get _isValid {
    if (_selectedReason == null) return false;
    if (_isOther && _reasonController.text.trim().isEmpty) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Void Order', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Order ID: ${widget.order.id.substring(0, 8)}...', 
            style: Theme.of(context).textTheme.bodySmall
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Alasan Void (Wajib):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedReason,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                  _isOther = value == "Lainnya";
                });
              },
              hint: const Text('Pilih alasan...'),
            ),
            if (_isOther) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Masukkan alasan lainnya...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}), // Trigger rebuild for validation
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isValid
              ? () {
                  final finalReason = _isOther ? _reasonController.text.trim() : _selectedReason!;
                  Navigator.pop(context, finalReason);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('KONFIRMASI VOID'),
        ),
      ],
    );
  }
}

class _OrderItemEditDialog extends StatefulWidget {
  final OrderItem item;
  const _OrderItemEditDialog({Key? key, required this.item}) : super(key: key);

  @override
  State<_OrderItemEditDialog> createState() => _OrderItemEditDialogState();
}

class _OrderItemEditDialogState extends State<_OrderItemEditDialog> {
  late int _qty;
  late String? _sambal;
  late double _level;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _qty = widget.item.qty;
    _sambal = widget.item.sambal ?? 'Campur';
    _level = double.tryParse(widget.item.level ?? '1') ?? 1;
    _noteController = TextEditingController(text: widget.item.note);
  }

  Color _getSliderColor() {
    if (_level <= 2) return Colors.green;
    if (_level <= 4) return Colors.amber;
    if (_level <= 6) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final isFood = widget.item.level != null;

    return AlertDialog(
      title: Text('Edit Item: ${widget.item.productName}'),
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
            if (isFood) ...[
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
                  min: 0,
                  max: 7,
                  divisions: 7,
                  label: _level.toInt().toString(),
                  onChanged: (v) => setState(() => _level = v),
                ),
              ),
            ],
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
          child: const Text('BATAL'),
        ),
        ElevatedButton(
          onPressed: () {
            // Recalculate price based on new level
            double newPrice = widget.item.price;
            
            // Check if it was already elevated? 
            // Better to reset to base product price if possible, but we don't have Product object here easily.
            // Assumption: existing price MIGHT have included the +1000.
            // We need to know if it HAD +1000 and if it NEEDS +1000 now.
            
            // Heuristic: Check old level vs new level.
            final oldLevel = double.tryParse(widget.item.level ?? '0') ?? 0;
            final newLvl = _level;
            final isMiePangsit = widget.item.productName.toLowerCase().contains('mie') || widget.item.productName.toLowerCase().contains('pangsit'); // Approximation since category unknown

            if (isMiePangsit) {
              int oldSurcharge = 0;
              if (oldLevel >= 6) oldSurcharge = 1000;
              else if (oldLevel >= 4) oldSurcharge = 500;

              int newSurcharge = 0;
              if (newLvl >= 6) newSurcharge = 1000;
              else if (newLvl >= 4) newSurcharge = 500;

              newPrice = newPrice - oldSurcharge + newSurcharge;
            }

            final updated = widget.item.copyWith(
              qty: _qty,
              price: newPrice, // Update price
              level: isFood ? _level.toInt().toString() : null,
              sambal: isFood ? _sambal : null,
              note: _noteController.text.isNotEmpty ? _noteController.text : null,
            );
            Navigator.pop(context, updated);
          },
          child: const Text('SIMPAN'),
        ),
      ],
    );
  }
}
