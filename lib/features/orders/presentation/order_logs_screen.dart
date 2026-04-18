import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/core/widgets/gradient_app_bar.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class OrderLogsScreen extends ConsumerStatefulWidget {
  const OrderLogsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrderLogsScreen> createState() => _OrderLogsScreenState();
}

class _OrderLogsScreenState extends ConsumerState<OrderLogsScreen> {
  final List<OrderEntity> _orders = [];
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
      final snapshot = await ref.read(orderRepositoryProvider).getOrdersPaginated(
            limit: _limit,
            lastDocument: _lastDocument,
          );

      if (snapshot.docs.isNotEmpty) {
        final newOrders = snapshot.docs.map((doc) {
          return OrderEntity.fromJsonRobust({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          });
        }).toList();

        setState(() {
          _orders.addAll(newOrders);
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
          SnackBar(content: Text('Error loading orders: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _exportToExcel() async {
    setState(() => _isLoading = true);
    try {
      final orders = await ref.read(orderRepositoryProvider).getAllOrders();
      
      if (orders.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada data untuk diekspor.')),
          );
        }
        return;
      }

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Orders'];
      excel.delete('Sheet1'); // Remove default sheet
      
      // Add Headers
      List<String> headers = [
        'ID Order', 
        'Tanggal', 
        'Jam', 
        'Pelanggan', 
        'Total (Rp)', 
        'Status', 
        'Metode Pembayaran', 
        'Produk'
      ];
      
      // Header values
      for (var i = 0; i < headers.length; i++) {
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#FFC107'),
        );
      }
      
      for (var row = 0; row < orders.length; row++) {
        var order = orders[row];
        final dateStr = order.createdAt != null 
            ? DateFormat('dd/MM/yyyy').format(order.createdAt!)
            : order.orderDate.toString();
        
        final productsSummary = order.items.map((i) => '${i.productName} x${i.qty}').join(', ');
        
        final rowIndex = row + 1;
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value = TextCellValue(order.id);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value = TextCellValue(dateStr);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value = TextCellValue(order.orderTime);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value = TextCellValue(order.customerName);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value = DoubleCellValue(order.total);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).value = TextCellValue(order.status.name);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).value = TextCellValue(order.paymentMethod);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex)).value = TextCellValue(productsSummary);
      }
      
      final fileBytes = excel.save();
      final directory = await getTemporaryDirectory();
      final fileName = 'OrderLogs_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final file = File('${directory.path}/$fileName');
      
      if (fileBytes != null) {
        await file.writeAsBytes(fileBytes);
        
        if (mounted) {
          await Share.shareXFiles([XFile(file.path)], text: 'Export Data Order Logs');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error export excel: $e')),
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
        title: const Text('Hapus Order'),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(orderRepositoryProvider).deleteOrder(id);
      setState(() {
        _orders.removeWhere((o) => o.id == id);
        _selectedIds.remove(id);
      });
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus ${_selectedIds.length} Order'),
        content: const Text('Hapus data yang dipilih?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(orderRepositoryProvider).bulkDeleteOrders(_selectedIds.toList());
      setState(() {
        _orders.removeWhere((o) => _selectedIds.contains(o.id));
        _selectedIds.clear();
      });
    }
  }

  Future<void> _deleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('HAPUS SEMUA ORDER', style: TextStyle(color: Colors.red)),
        content: const Text('PERINGATAN! Seluruh data order akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('YA, HAPUS SEMUA')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(orderRepositoryProvider).deleteAllOrders();
      setState(() {
        _orders.clear();
        _selectedIds.clear();
        _lastDocument = null;
        _hasMore = false;
      });
    }
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == _orders.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(_orders.map((o) => o.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Order Logs'),
        actions: [
          if (_orders.isNotEmpty)
            IconButton(
              icon: Icon(_selectedIds.length == _orders.length ? Icons.deselect : Icons.select_all),
              onPressed: _toggleSelectAll,
              tooltip: 'Pilih Semua',
            ),
          IconButton(
            icon: const Icon(Icons.file_download, color: Colors.white),
            onPressed: _exportToExcel,
            tooltip: 'Export Excel',
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
      body: _orders.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No orders found.'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _orders.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _orders.length) {
                      return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                    }

                    final order = _orders[index];
                    final isSelected = _selectedIds.contains(order.id);
                    final dateStr = order.createdAt != null 
                        ? DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt!)
                        : order.orderDate.toString();

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      child: ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selectedIds.add(order.id);
                              } else {
                                _selectedIds.remove(order.id);
                              }
                            });
                          },
                        ),
                        title: Text('${order.customerName} - Rp ${order.total.toStringAsFixed(0)}'),
                        subtitle: Text('Date: $dateStr\nID: ${order.id}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteSingle(order.id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.selesai: return Colors.green;
      case OrderStatus.proses: return Colors.blue;
      case OrderStatus.batal: return Colors.red;
      default: return Colors.orange;
    }
  }
}
