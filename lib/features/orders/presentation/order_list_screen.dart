import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../orders/data/order_repository.dart';
import '../../orders/domain/order.dart';
import '../../orders/domain/order_item.dart';
import '../../../core/enums/user_role.dart';

// Providers for filtering
final orderStatusFilterProvider = StateProvider<OrderStatus?>((ref) => null);
final orderSearchQueryProvider = StateProvider<String>((ref) => '');
final orderDateFilterProvider = StateProvider<DateTime>((ref) => DateTime.now());
final isSearchModeProvider = StateProvider<bool>((ref) => false);

final filteredOrdersProvider = StreamProvider<List<OrderEntity>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final status = ref.watch(orderStatusFilterProvider);
  final query = ref.watch(orderSearchQueryProvider);
  final date = ref.watch(orderDateFilterProvider);
  return repository.getOrdersStream(status: status, searchQuery: query, date: date);
});

final dailyOrdersProvider = StreamProvider<List<OrderEntity>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final date = ref.watch(orderDateFilterProvider);
  return repository.getOrdersStream(date: date);
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
          appBar: AppBar(
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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'logout') {
                     final confirm = await showDialog<bool>(
                       context: context,
                       builder: (context) => AlertDialog(
                         title: const Text('Logout'),
                         content: const Text('Apakah anda yakin ingin keluar?'),
                         actions: [
                           TextButton(
                             child: const Text('BATAL'),
                             onPressed: () => Navigator.pop(context, false),
                           ),
                           ElevatedButton(
                             style: ElevatedButton.styleFrom(primary: Colors.red),
                             child: const Text('KELUAR'),
                             onPressed: () => Navigator.pop(context, true),
                           ),
                         ],
                       ),
                     );

                     if (confirm == true) {
                       await ref.read(authControllerProvider.notifier).signOut();
                       if (mounted) {
                        context.go('/login');
                       }
                     }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(child: _buildTabHeader('Belum', Icons.timer, counts[OrderStatus.belum]!, Colors.orange)),
                Tab(child: _buildTabHeader('Proses', Icons.sync, counts[OrderStatus.proses]!, Colors.blue)),
                Tab(child: _buildTabHeader('Selesai', Icons.check_circle, counts[OrderStatus.selesai]!, Colors.green)),
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

    final dateStr = DateFormat('dd/MM/yyyy').format(order.orderDate);
    final itemsSummary = order.items.map((i) => "${i.productName} x${i.qty}").join("\n");
    
    final message = "*Hi, Hompier !*\n"
        "Terima kasih telah memesan *Hompimpa Mie & Pangsit*.\n\n"
        "Detail Pesanan :\n"
        "- Tanggal: $dateStr\n"
        "- Jam: ${order.orderTime}\n"
        "- Item Order:\n$itemsSummary\n\n"
        "- Total Pembayaran: *Rp ${order.total.toStringAsFixed(0)}*\n\n"
        "*Sudah Bisa diambil*.\n\n"
        "Silakan konfirmasi jika ada yang perlu dikoreksi. Terima Kasih dan sehat selalu :).";

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
            style: ElevatedButton.styleFrom(primary: Colors.green),
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

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref, OrderEntity order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pesanan'),
        content: Text('Apakah Anda yakin ingin menghapus pesanan ${order.customerName}? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(primary: Colors.red),
            child: const Text('HAPUS'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final messenger = ScaffoldMessenger.of(context);
        await ref.read(orderRepositoryProvider).deleteOrder(order.id);
        messenger.showSnackBar(const SnackBar(content: Text('Pesanan telah dihapus')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrdersAsync = ref.watch(filteredOrdersProvider);

    return allOrdersAsync.when(
      data: (orders) {
        // Filter by status
        final filtered = orders.where((o) => o.status == status).toList();
        
        // Sort by time/creation
        filtered.sort((a, b) {
            final dateA = a.createdAt ?? a.orderDate;
            final dateB = b.createdAt ?? b.orderDate;
            return dateA.compareTo(dateB);
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

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final order = filtered[index];
            // Queue number 1, 2, 3...
            final queueNumber = index + 1;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 2,
              child: ExpansionTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${order.customerName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (order.executorName != null)
                             Text(
                               'Eksekutor : ${order.executorName}',
                               style: const TextStyle(fontSize: 10, color: Colors.indigo, fontStyle: FontStyle.italic),
                             ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$queueNumber',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Text('Total: Rp ${order.total.toStringAsFixed(0)} | ${order.orderTime}'),
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(order.status),
                  child: Icon(_getStatusIcon(order.status), color: Colors.white, size: 20),
                ),
                children: [
                   ...order.items.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return ListTile(
                      dense: true,
                      title: Text(
                        item.level != null 
                          ? '${item.productName} - Lvl ${item.level} (${item.sambal})'
                          : item.productName, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: '${item.qty}x @ Rp ${item.price.toStringAsFixed(0)}'),
                                if (item.note != null && item.note!.isNotEmpty)
                                  TextSpan(
                                    text: ' (${item.note})',
                                    style: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          if (item.toppings != null && item.toppings!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Toppings: ${item.toppings!.map((t) => t.name).join(", ")}',
                                style: TextStyle(fontSize: 11, color: Colors.grey[900], fontStyle: FontStyle.italic),
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Rp ${(item.price * item.qty).toStringAsFixed(0)}'),
                          if (order.status == OrderStatus.belum)
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                              onPressed: () => _editOrderItem(context, ref, order, idx),
                            ),
                        ],
                      ),
                    );
                  }),
                  const Divider(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (order.status == OrderStatus.belum) ...[
                            ElevatedButton.icon(
                              onPressed: () => context.push('/entry/add/${order.id}'),
                              icon: const Icon(Icons.add_shopping_cart, size: 18),
                              label: const Text('Tambah'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orange,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  final messenger = ScaffoldMessenger.of(context);
                                  final authState = ref.read(authStateChangesProvider);
                                  final user = authState.value;
                                  print('login data: ${user}');
                                  await ref.read(orderRepositoryProvider).updateOrderStatus(
                                    order.id, 
                                    OrderStatus.proses, 
                                    order.items,
                                    executorName: user?.displayName ?? 'Admin',
                                    executorId: user?.uid
                                  );
                                  messenger.showSnackBar(const SnackBar(content: Text('Pesanan sedang diproses')));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui: $e')));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: const Text('Proses'),
                            ),
                          ],
                          if (order.status == OrderStatus.proses) ...[
                            ElevatedButton.icon(
                              onPressed: () => _showSelesaiConfirmation(context, ref, order),
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: const Text('Selesai'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green, 
                                onPrimary: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ],
                          if (order.status != OrderStatus.selesai) ...[
                            ElevatedButton.icon(
                              onPressed: () => _showDeleteConfirmation(context, ref, order),
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Hapus'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                onPrimary: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.belum: return Icons.timer;
      case OrderStatus.proses: return Icons.sync;
      case OrderStatus.selesai: return Icons.check_circle;
    }
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
                  min: 1,
                  max: 7,
                  divisions: 6,
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
            final updated = widget.item.copyWith(
              qty: _qty,
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
