import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/store.dart';
import '../data/store_repository.dart';
import 'package:hompimpa_pos/core/widgets/gradient_app_bar.dart';

class StoreManagementScreen extends ConsumerWidget {
  const StoreManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(storesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: GradientAppBar(
        title: const Text('Master Data Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showStoreDialog(context, ref),
          ),
        ],
      ),
      body: storesAsync.when(
        data: (stores) {
          if (stores.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_rounded, size: 72, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data store',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Klik tombol + di pojok kanan atas untuk menambah',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: stores.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final store = stores[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: store.isActive ? Colors.transparent : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: store.isActive ? 1.0 : 0.7,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                         
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        store.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: store.isActive 
                                              ? const Color(0xFF2D3436) 
                                              : Colors.grey.shade500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: store.isActive 
                                            ? Colors.green.shade50 
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        store.isActive ? 'Aktif' : 'Non-aktif',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: store.isActive 
                                              ? Colors.green.shade800 
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade400),
                                    const SizedBox(width: 6),
                                    Text(
                                      store.phone.isNotEmpty ? store.phone : '-',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade400),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        store.address.isNotEmpty ? store.address : '-',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: store.isActive,
                                  activeColor: Colors.orange.shade800,
                                  activeTrackColor: Colors.orange.shade100,
                                  inactiveThumbColor: Colors.grey.shade400,
                                  inactiveTrackColor: Colors.grey.shade200,
                                  onChanged: (value) async {
                                    final updated = store.copyWith(isActive: value);
                                    await ref.read(storeRepositoryProvider).updateStore(updated);
                                  },
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade600),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showStoreDialog(context, ref, store: store);
                                  } else if (value == 'delete') {
                                    _showDeleteConfirm(context, ref, store);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 20, color: Colors.blue.shade700),
                                        const SizedBox(width: 12),
                                        const Text('Edit Store', style: TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red.shade700),
                                        const SizedBox(width: 12),
                                        const Text('Hapus Store', style: TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  InputDecoration _dialogInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: Colors.orange.shade800),
      labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.orange.shade800, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      isDense: true,
    );
  }

  void _showStoreDialog(BuildContext context, WidgetRef ref, {Store? store}) {
    final nameController = TextEditingController(text: store?.name ?? '');
    final addressController = TextEditingController(text: store?.address ?? '');
    final phoneController = TextEditingController(text: store?.phone ?? '');
    bool isActive = store?.isActive ?? true;

    showDialog(
      context: context,
      builder: (contextDialog) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            store == null ? 'Tambah Store' : 'Edit Store',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: _dialogInputDecoration('Nama Store', Icons.storefront_rounded),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: _dialogInputDecoration('Alamat', Icons.location_on_outlined),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: _dialogInputDecoration('Nomor Telepon', Icons.phone_outlined),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: SwitchListTile(
                    title: const Text('Status Aktif', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    value: isActive,
                    activeColor: Colors.orange.shade800,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    onChanged: (v) => setState(() => isActive = v),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextDialog),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newStore = Store(
                  id: store?.id ?? const Uuid().v4(),
                  name: nameController.text,
                  address: addressController.text,
                  phone: phoneController.text,
                  isActive: isActive,
                );

                if (store == null) {
                  await ref.read(storeRepositoryProvider).addStore(newStore);
                } else {
                  await ref.read(storeRepositoryProvider).updateStore(newStore);
                }
                Navigator.pop(contextDialog);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 0,
              ),
              child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, Store store) {
    showDialog(
      context: context,
      builder: (contextDialog) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Hapus Store', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4),
            children: [
              const TextSpan(text: 'Apakah Anda yakin ingin menghapus store '),
              TextSpan(text: store.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: '? Tindakan ini tidak dapat dibatalkan.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextDialog),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(storeRepositoryProvider).deleteStore(store.id);
              Navigator.pop(contextDialog);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
            ),
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
