import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/products/presentation/product_provider.dart';
import 'package:hompimpa_pos/features/products/domain/product.dart';
import 'package:hompimpa_pos/features/products/data/product_repository.dart';
import 'package:hompimpa_pos/features/auth/presentation/auth_controller.dart';
import 'package:hompimpa_pos/features/settings/data/store_repository.dart';
import 'package:hompimpa_pos/core/widgets/app_image.dart';
import 'package:uuid/uuid.dart';

class ProductMasterScreen extends ConsumerWidget {
  const ProductMasterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Data Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductDialog(context, ref),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) => ListView.separated(
          itemCount: products.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              leading: AppImage(
                url: product.imageUrl,
                width: 40,
                height: 40,
              ),
              title: Text(product.name),
              subtitle: Text('Rp ${product.price} | Stok: ${product.stock}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: product.isActive,
                    onChanged: (value) async {
                      final updated = product.copyWith(isActive: value);
                      await ref.read(productRepositoryProvider).updateProduct(updated);
                      ref.refresh(productListProvider);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showProductDialog(context, ref, product: product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirm(context, ref, product),
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

  void _showProductDialog(BuildContext context, WidgetRef ref, {Product? product}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '');
    final imageUrlController = TextEditingController(text: product?.imageUrl ?? 'assets/images/logo.png');
    String category = product?.category ?? 'makanan';
    bool hasSambal = product?.hasSambal ?? false;
    bool hasLevel = product?.hasLevel ?? false;
    bool hasTopping = product?.hasTopping ?? false;
    String? selectedStoreId = product?.storeId;
    final storesAsync = ref.read(activeStoresProvider);

    showDialog(
      context: context,
      builder: (contextDialog) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama')),
                DropdownButtonFormField<String>(
                  value: category,
                  items: const [
                    DropdownMenuItem(value: 'makanan', child: Text('Makanan')),
                    DropdownMenuItem(value: 'minuman', child: Text('Minuman')),
                    DropdownMenuItem(value: 'snack', child: Text('Snack')),
                  ],
                  onChanged: (v) {
                    setState(() {
                      category = v!;
                      if (category != 'makanan') {
                        hasSambal = false;
                        hasLevel = false;
                        hasTopping = false;
                      }
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Kategori'),
                ),
                if (category == 'makanan') ...[
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Enable Sambal'),
                    value: hasSambal,
                    onChanged: (v) => setState(() => hasSambal = v),
                  ),
                  SwitchListTile(
                    title: const Text('Enable Level'),
                    value: hasLevel,
                    onChanged: (v) => setState(() => hasLevel = v),
                  ),
                  SwitchListTile(
                    title: const Text('Enable Topping'),
                    value: hasTopping,
                    onChanged: (v) => setState(() => hasTopping = v),
                  ),
                ],
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
                TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number),
                TextField(controller: imageUrlController, decoration: const InputDecoration(labelText: 'Image URL')),
                const SizedBox(height: 16),
                storesAsync.when(
                  data: (stores) => DropdownButtonFormField<String?>(
                    value: selectedStoreId,
                    decoration: const InputDecoration(labelText: 'Store'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('No Store')),
                      ...stores.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                    ],
                    onChanged: (v) => setState(() => selectedStoreId = v),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Error loading stores'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(contextDialog), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final newProduct = Product(
                  id: product?.id ?? const Uuid().v4(),
                  name: nameController.text,
                  category: category,
                  price: double.tryParse(priceController.text) ?? 0,
                   stock: int.tryParse(stockController.text) ?? 0,
                  imageUrl: imageUrlController.text.isNotEmpty ? imageUrlController.text : null,
                  isActive: product?.isActive ?? true,
                  storeId: selectedStoreId,
                  hasSambal: hasSambal,
                  hasLevel: hasLevel,
                  hasTopping: hasTopping,
                );

                if (product == null) {
                  await ref.read(productRepositoryProvider).addProduct(newProduct);
                } else {
                  await ref.read(productRepositoryProvider).updateProduct(newProduct);
                }
                ref.refresh(productListProvider);
                Navigator.pop(contextDialog);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (contextDialog) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Apakah Anda yakin ingin menghapus ${product.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(contextDialog), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(productRepositoryProvider).deleteProduct(product.id);
              ref.refresh(productListProvider);
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
