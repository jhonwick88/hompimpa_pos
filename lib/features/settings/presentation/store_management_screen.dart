import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/store.dart';
import '../data/store_repository.dart';

class StoreManagementScreen extends ConsumerWidget {
  const StoreManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(activeStoresProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Data Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showStoreDialog(context, ref),
          ),
        ],
      ),
      body: storesAsync.when(
        data: (stores) => ListView.separated(
          itemCount: stores.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final store = stores[index];
            return ListTile(
              title: Text(store.name),
              subtitle: Text('${store.phone} | ${store.address}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: store.isActive,
                    onChanged: (value) async {
                      final updated = store.copyWith(isActive: value);
                      await ref.read(storeRepositoryProvider).updateStore(updated);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showStoreDialog(context, ref, store: store),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirm(context, ref, store),
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
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
          title: Text(store == null ? 'Tambah Store' : 'Edit Store'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Store')),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Alamat')),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Nomor Telepon')),
                SwitchListTile(
                  title: const Text('Aktif'),
                  value: isActive,
                  onChanged: (v) => setState(() => isActive = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(contextDialog), child: const Text('Batal')),
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
              child: const Text('Simpan'),
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
        title: const Text('Hapus Store'),
        content: Text('Apakah Anda yakin ingin menghapus ${store.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(contextDialog), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(storeRepositoryProvider).deleteStore(store.id);
              Navigator.pop(contextDialog);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
