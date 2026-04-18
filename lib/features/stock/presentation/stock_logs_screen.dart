import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/core/widgets/gradient_app_bar.dart';
import 'package:hompimpa_pos/features/stock/data/stock_repository.dart';
import 'package:hompimpa_pos/features/stock/domain/stock_log.dart';
import 'package:hompimpa_pos/features/products/presentation/product_provider.dart';
import 'package:intl/intl.dart';

class StockLogsScreen extends ConsumerStatefulWidget {
  const StockLogsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StockLogsScreen> createState() => _StockLogsScreenState();
}

class _StockLogsScreenState extends ConsumerState<StockLogsScreen> {
  final List<StockLog> _logs = [];
  QueryDocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  final int _limit = 10;
  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final snapshot = await ref.read(stockRepositoryProvider).getStockLogsPaginated(
            limit: _limit,
            lastDocument: _lastDocument,
          );

      if (snapshot.docs.isNotEmpty) {
        final newLogs = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return StockLog.fromJson(data);
        }).toList();

        setState(() {
          _logs.addAll(newLogs);
          _lastDocument = snapshot.docs.last;
          if (snapshot.docs.length < _limit) {
            _hasMore = false;
          }
        });
      } else {
        setState(() => _hasMore = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stock logs: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteSingle(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Stock Log'),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(stockRepositoryProvider).deleteStockLog(id);
      setState(() {
        _logs.removeWhere((l) => l.id == id);
        _selectedIds.remove(id);
      });
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus ${_selectedIds.length} Log'),
        content: const Text('Hapus data yang dipilih?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(stockRepositoryProvider).bulkDeleteStockLogs(_selectedIds.toList());
      setState(() {
        _logs.removeWhere((l) => _selectedIds.contains(l.id));
        _selectedIds.clear();
      });
    }
  }

  Future<void> _deleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('HAPUS SEMUA STOCK LOG', style: TextStyle(color: Colors.red)),
        content: const Text('PERINGATAN! Seluruh data stock log akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('YA, HAPUS SEMUA')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(stockRepositoryProvider).deleteAllStockLogs();
      setState(() {
        _logs.clear();
        _selectedIds.clear();
        _lastDocument = null;
        _hasMore = false;
      });
    }
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == _logs.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(_logs.map((l) => l.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Stock Logs'),
        actions: [
          if (_logs.isNotEmpty)
            IconButton(
              icon: Icon(_selectedIds.length == _logs.length ? Icons.deselect : Icons.select_all),
              onPressed: _toggleSelectAll,
              tooltip: 'Pilih Semua',
            ),
          if (_selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              onPressed: _deleteSelected,
              tooltip: 'Hapus Terpilih',
            ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            onPressed: _deleteAll,
            tooltip: 'Hapus Semua',
          ),
        ],
      ),
      body: _logs.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(child: Text('No stock logs found.'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _logs.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _logs.length) {
                      return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                    }

                    final log = _logs[index];
                    final isSelected = _selectedIds.contains(log.id);
                    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(log.createdAt);
                    
                    String productName = 'Product ID: ${log.productId}';
                    productsAsync.whenData((products) {
                      final p = products.where((item) => item.id == log.productId).toList();
                      if (p.isNotEmpty) productName = p.first.name;
                    });

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      child: ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selectedIds.add(log.id);
                              } else {
                                _selectedIds.remove(log.id);
                              }
                            });
                          },
                        ),
                        title: Text(productName),
                        subtitle: Text('Qty Change: ${log.qtyChange}\nReason: ${log.reason}\nDate: $dateStr'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              log.qtyChange > 0 ? '+${log.qtyChange}' : '${log.qtyChange}',
                              style: TextStyle(color: log.qtyChange > 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteSingle(log.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
