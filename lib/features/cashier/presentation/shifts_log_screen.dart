import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/core/widgets/gradient_app_bar.dart';
import 'package:hompimpa_pos/features/cashier/data/cashier_repository.dart';
import 'package:hompimpa_pos/features/cashier/domain/shift.dart';
import 'package:intl/intl.dart';

class ShiftsLogScreen extends ConsumerStatefulWidget {
  const ShiftsLogScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ShiftsLogScreen> createState() => _ShiftsLogScreenState();
}

class _ShiftsLogScreenState extends ConsumerState<ShiftsLogScreen> {
  final List<ShiftEntity> _shifts = [];
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
      final snapshot = await ref.read(cashierRepositoryProvider).getShiftsPaginated(
            limit: _limit,
            lastDocument: _lastDocument,
          );

      if (snapshot.docs.isNotEmpty) {
        final newShifts = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return ShiftEntity.fromJson(data);
        }).toList();

        setState(() {
          _shifts.addAll(newShifts);
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
          SnackBar(content: Text('Error loading shifts: $e')),
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
        title: const Text('Hapus Shift'),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(cashierRepositoryProvider).deleteShift(id);
      setState(() {
        _shifts.removeWhere((s) => s.id == id);
        _selectedIds.remove(id);
      });
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus ${_selectedIds.length} Shift'),
        content: const Text('Hapus data yang dipilih?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(cashierRepositoryProvider).bulkDeleteShifts(_selectedIds.toList());
      setState(() {
        _shifts.removeWhere((s) => _selectedIds.contains(s.id));
        _selectedIds.clear();
      });
    }
  }

  Future<void> _deleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('HAPUS SEMUA SHIFT', style: TextStyle(color: Colors.red)),
        content: const Text('PERINGATAN! Seluruh data shift akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('YA, HAPUS SEMUA')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(cashierRepositoryProvider).deleteAllShifts();
      setState(() {
        _shifts.clear();
        _selectedIds.clear();
        _lastDocument = null;
        _hasMore = false;
      });
    }
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == _shifts.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(_shifts.map((s) => s.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Shifts Log'),
        actions: [
          if (_shifts.isNotEmpty)
            IconButton(
              icon: Icon(_selectedIds.length == _shifts.length ? Icons.deselect : Icons.select_all),
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
      body: _shifts.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _shifts.isEmpty
              ? const Center(child: Text('No shifts found.'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _shifts.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _shifts.length) {
                      return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                    }

                    final shift = _shifts[index];
                    final isSelected = _selectedIds.contains(shift.id);
                    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(shift.startTime);
                    final endDateStr = shift.endTime != null ? DateFormat('HH:mm').format(shift.endTime!) : 'ACTIVE';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      child: ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selectedIds.add(shift.id);
                              } else {
                                _selectedIds.remove(shift.id);
                              }
                            });
                          },
                        ),
                        title: Text(shift.shiftName),
                        subtitle: Text('Start: $dateStr\nEnd: $endDateStr\nStatus: ${shift.status}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteSingle(shift.id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
