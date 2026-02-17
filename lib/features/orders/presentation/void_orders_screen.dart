import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:hompimpa_pos/features/auth/presentation/auth_controller.dart';
import 'package:hompimpa_pos/core/enums/user_role.dart';
import 'package:go_router/go_router.dart';
import 'package:hompimpa_pos/features/auth/data/auth_repository.dart';
import 'package:hompimpa_pos/core/widgets/gradient_app_bar.dart';

final voidOrdersProvider = StreamProvider.autoDispose<List<OrderEntity>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  // Reusing getOrdersStream, but filtering for all dates might be heavy if not supported by backend query.
  // Ideally backend should support status filtering.
  return repository.getOrdersStream(status: OrderStatus.batal);
});

class VoidOrdersScreen extends ConsumerStatefulWidget {
  const VoidOrdersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VoidOrdersScreen> createState() => _VoidOrdersScreenState();
}

class _VoidOrdersScreenState extends ConsumerState<VoidOrdersScreen> {
  final Set<String> _selectedOrderIds = {};
  bool _isAllSelected = false;

  @override
  void initState() {
    super.initState();
    // Security check
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final user = ref.read(authStateChangesProvider).value;
      if (user == null || user.role != UserRole.dev) {
        context.go('/');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akses Ditolak: Hanya Developer')),
        );
      }
    });
  }

  void _toggleSelectAll(List<OrderEntity> orders) {
    setState(() {
      _isAllSelected = !_isAllSelected;
      if (_isAllSelected) {
        _selectedOrderIds.addAll(orders.map((o) => o.id));
      } else {
        _selectedOrderIds.clear();
      }
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedOrderIds.contains(id)) {
        _selectedOrderIds.remove(id);
      } else {
        _selectedOrderIds.add(id);
      }
      // Update select all state logic could be here but kept simple
      _isAllSelected = false; 
    });
  }

  Future<void> _deletePermanent(List<String> ids) async {
    final count = ids.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Permanen', style: TextStyle(color: Colors.red)),
        content: Text(
            'Apakah Anda yakin ingin menghapus $count order terpilih secara permanen?\n\n'
            'Tindakan ini TIDAK BISA DIBATALKAN. Data akan hilang selamanya dan tidak masuk laporan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('HAPUS PERMANEN'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (count == 1) {
          await ref.read(orderRepositoryProvider).deleteOrder(ids.first);
        } else {
           await ref.read(orderRepositoryProvider).bulkDeleteOrders(ids);
        }
        
        setState(() {
          _selectedOrderIds.clear();
          _isAllSelected = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$count order berhasil dihapus permanen')),
        );
      } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final voidOrdersAsync = ref.watch(voidOrdersProvider);

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('List Pembatalan Order (DEV)'),
        actions: [
          if (_selectedOrderIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton.icon(
                onPressed: () => _deletePermanent(_selectedOrderIds.toList()),
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                label: Text(
                  'Hapus (${_selectedOrderIds.length})',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: voidOrdersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('Tidak ada order yang dibatalkan'));
          }
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isAllSelected, 
                      onChanged: (_) => _toggleSelectAll(orders),
                    ),
                    const Text('Pilih Semua'),
                    const Spacer(),
                    Text('Total: ${orders.length} Order'),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final isSelected = _selectedOrderIds.contains(order.id);
                    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(order.voidAt ?? order.updatedAt ?? DateTime.now());

                    return Card(
                      color: isSelected ? Colors.red[50] : null,
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggleSelection(order.id),
                        ),
                        title: Text('${order.customerName} (ID: ...${order.id.substring(order.id.length - 6)})'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Void: $dateStr by ${order.voidBy}'),
                            Text('Alasan: ${order.voidReason ?? "-"}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                            Text('Items: ${order.items.length}, Total: Rp ${order.total.toStringAsFixed(0)}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          onPressed: () => _deletePermanent([order.id]),
                        ),
                        onTap: () => _toggleSelection(order.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
