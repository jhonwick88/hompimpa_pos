import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/products/data/topping_repository.dart';
import 'package:hompimpa_pos/features/products/domain/topping.dart';
import 'package:uuid/uuid.dart';

class ToppingMasterScreen extends ConsumerWidget {
  const ToppingMasterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toppingsAsync = ref.watch(toppingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Data Topping'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showToppingDialog(context, ref),
          ),
        ],
      ),
      body: toppingsAsync.when(
        data: (toppings) => ListView.builder(
          itemCount: toppings.length,
          itemBuilder: (context, index) {
            final topping = toppings[index];
            return ListTile(
              leading: topping.imageUrl != null 
                ? Image.network(topping.imageUrl!, width: 40, height: 40, errorBuilder: (_, __, ___) => const Icon(Icons.add_circle))
                : const Icon(Icons.add_circle),
              title: Text(topping.name),
              subtitle: Text('Rp ${topping.price} | Stok: ${topping.stock}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: topping.isActive,
                    onChanged: (value) async {
                      final updated = topping.copyWith(isActive: value);
                      await ref.read(toppingRepositoryProvider).updateTopping(updated);
                      ref.refresh(toppingListProvider);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showToppingDialog(context, ref, topping: topping),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirm(context, ref, topping),
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

  void _showToppingDialog(BuildContext context, WidgetRef ref, {Topping? topping}) {
    final nameController = TextEditingController(text: topping?.name ?? '');
    final priceController = TextEditingController(text: topping?.price.toString() ?? '');
    final stockController = TextEditingController(text: topping?.stock.toString() ?? '');
    final imageUrlController = TextEditingController(text: topping?.imageUrl ?? 'assets/images/logo.png');

    showDialog(
      context: context,
      builder: (contextDialog) => AlertDialog(
        title: Text(topping == null ? 'Tambah Topping' : 'Edit Topping'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
              TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number),
              TextField(controller: imageUrlController, decoration: const InputDecoration(labelText: 'Image URL')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(contextDialog), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final newTopping = Topping(
                id: topping?.id ?? const Uuid().v4(),
                name: nameController.text,
                price: double.tryParse(priceController.text) ?? 0,
                stock: int.tryParse(stockController.text) ?? 0,
                imageUrl: imageUrlController.text.isNotEmpty ? imageUrlController.text : null,
                isActive: topping?.isActive ?? true,
              );

              if (topping == null) {
                await ref.read(toppingRepositoryProvider).addTopping(newTopping);
              } else {
                await ref.read(toppingRepositoryProvider).updateTopping(newTopping);
              }
              ref.refresh(toppingListProvider);
              Navigator.pop(contextDialog);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, Topping topping) {
    showDialog(
      context: context,
      builder: (contextDialog) => AlertDialog(
        title: const Text('Hapus Topping'),
        content: Text('Apakah Anda yakin ingin menghapus ${topping.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(contextDialog), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(toppingRepositoryProvider).deleteTopping(topping.id);
              ref.refresh(toppingListProvider);
              Navigator.pop(contextDialog);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
