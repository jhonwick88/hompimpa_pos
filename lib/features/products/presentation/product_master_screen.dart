import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/products/presentation/product_provider.dart';
import 'package:hompimpa_pos/features/products/domain/product.dart';
import 'package:hompimpa_pos/features/products/data/product_repository.dart';
import 'package:hompimpa_pos/features/auth/presentation/auth_controller.dart';
import 'package:hompimpa_pos/features/settings/data/store_repository.dart';
import 'package:hompimpa_pos/core/widgets/app_image.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';
import 'package:hompimpa_pos/features/settings/domain/store.dart';
import 'package:hompimpa_pos/core/enums/user_role.dart';
import 'package:hompimpa_pos/features/auth/data/auth_repository.dart';

class ProductMasterScreen extends ConsumerWidget {
  const ProductMasterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);
    final authState = ref.watch(authStateChangesProvider);

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter & Actions for Admin/Dev
          if (authState.value != null && 
              (authState.value!.role == UserRole.dev || authState.value!.role == UserRole.admin)) ...[
            ref.watch(activeStoresProvider).when(
              data: (stores) {
                final currentFilter = ref.watch(selectedStoreFilterProvider);
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: currentFilter,
                            hint: const Text('Semua Cabang (Global)', style: TextStyle(fontWeight: FontWeight.bold)),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Semua Cabang (Global)', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              ...stores.map((s) => DropdownMenuItem<String?>(
                                value: s.id,
                                child: Text(s.name),
                              )),
                            ],
                            onChanged: (val) {
                              ref.read(selectedStoreFilterProvider.notifier).state = val;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Actions Row
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.copy_all, size: 18),
                              label: const Text('Salin Menu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: () => _showCloneDialog(context, ref, stores),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade800,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.swap_horiz, size: 18),
                              label: const Text('Mutasi Stok', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: () => _showTransferStockDialog(context, ref, stores),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
          
          Expanded(
            child: productsAsync.when(
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
          ),
        ],
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

  void _showCloneDialog(BuildContext context, WidgetRef ref, List<Store> stores) {
    String? fromStoreId;
    String? toStoreId;

    showDialog(
      context: context,
      builder: (contextDialog) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Salin/Clone Menu Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Salin seluruh menu dari satu cabang ke cabang lainnya dengan stok awal 0.'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: fromStoreId,
                decoration: const InputDecoration(labelText: 'Dari Cabang (Source)'),
                items: stores.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (v) => setState(() => fromStoreId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                value: toStoreId,
                decoration: const InputDecoration(labelText: 'Ke Cabang (Destination)'),
                items: stores.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (v) => setState(() => toStoreId = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextDialog),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: (fromStoreId == null || toStoreId == null || fromStoreId == toStoreId)
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await ref.read(productRepositoryProvider).cloneProducts(fromStoreId!, toStoreId!);
                        ref.refresh(productListProvider);
                        ref.refresh(unfilteredProductListProvider);
                        Navigator.pop(contextDialog);
                        messenger.showSnackBar(const SnackBar(
                          content: Text('Menu produk berhasil disalin!'),
                          backgroundColor: Colors.green,
                        ));
                      } catch (e) {
                        Navigator.pop(contextDialog);
                        messenger.showSnackBar(SnackBar(
                          content: Text('Gagal menyalin menu: $e'),
                          backgroundColor: Colors.red,
                        ));
                      }
                    },
              child: const Text('Salin'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransferStockDialog(BuildContext context, WidgetRef ref, List<Store> stores) {
    String? fromStoreId;
    String? toStoreId;
    Product? selectedProduct;
    final qtyController = TextEditingController();

    final allProductsAsync = ref.read(unfilteredProductListProvider);

    showDialog(
      context: context,
      builder: (contextDialog) => StatefulBuilder(
        builder: (context, setState) {
          final allProducts = allProductsAsync.value ?? [];
          
          // Filter products for source store
          final sourceProducts = fromStoreId != null 
              ? allProducts.where((p) => p.storeId == fromStoreId).toList()
              : <Product>[];
              
          // Find matching product in target store
          Product? targetProduct;
          if (selectedProduct != null && toStoreId != null) {
            targetProduct = allProducts.firstWhereOrNull((p) => 
                p.storeId == toStoreId && 
                p.name.toLowerCase() == selectedProduct!.name.toLowerCase());
          }

          return AlertDialog(
            title: const Text('Mutasi/Transfer Stok Cabang'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Source Store
                  DropdownButtonFormField<String?>(
                    value: fromStoreId,
                    decoration: const InputDecoration(labelText: 'Dari Cabang (Source)'),
                    items: stores.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (v) {
                      setState(() {
                        fromStoreId = v;
                        selectedProduct = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Source Product
                  DropdownButtonFormField<Product?>(
                    value: selectedProduct,
                    decoration: const InputDecoration(labelText: 'Pilih Produk'),
                    items: sourceProducts.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (Stok: ${p.stock})'))).toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedProduct = v;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Target Store
                  DropdownButtonFormField<String?>(
                    value: toStoreId,
                    decoration: const InputDecoration(labelText: 'Ke Cabang (Destination)'),
                    items: stores.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (v) {
                      setState(() {
                        toStoreId = v;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Target Product Match Info
                  if (selectedProduct != null && toStoreId != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: targetProduct != null ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: targetProduct != null ? Colors.green.shade300 : Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            targetProduct != null ? Icons.check_circle : Icons.error,
                            color: targetProduct != null ? Colors.green.shade800 : Colors.red.shade800,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              targetProduct != null
                                  ? 'Produk cocok ditemukan!\nStok tujuan saat ini: ${targetProduct.stock}'
                                  : 'Produk dengan nama yang sama tidak ditemukan di cabang tujuan.',
                              style: TextStyle(
                                fontSize: 12,
                                color: targetProduct != null ? Colors.green.shade900 : Colors.red.shade900,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Quantity
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Jumlah Mutasi (Qty)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(contextDialog),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: (fromStoreId == null || 
                            toStoreId == null || 
                            selectedProduct == null || 
                            targetProduct == null || 
                            fromStoreId == toStoreId)
                    ? null
                    : () async {
                        final qty = int.tryParse(qtyController.text);
                        final messenger = ScaffoldMessenger.of(context);
                        
                        if (qty == null || qty <= 0) {
                          messenger.showSnackBar(const SnackBar(content: Text('Jumlah mutasi tidak valid')));
                          return;
                        }
                        
                        if (qty > selectedProduct!.stock) {
                          messenger.showSnackBar(SnackBar(content: Text('Stok asal tidak cukup (Stok: ${selectedProduct!.stock})')));
                          return;
                        }
                        
                        final authState = ref.read(authStateChangesProvider);
                        final username = authState.value?.displayName ?? 'Admin';
                        
                        try {
                          await ref.read(productRepositoryProvider).transferStock(
                                selectedProduct!.id,
                                targetProduct!.id,
                                qty,
                                username: username,
                              );
                          ref.refresh(productListProvider);
                          ref.refresh(unfilteredProductListProvider);
                          Navigator.pop(contextDialog);
                          messenger.showSnackBar(const SnackBar(
                            content: Text('Mutasi stok berhasil dilakukan!'),
                            backgroundColor: Colors.green,
                          ));
                        } catch (e) {
                          Navigator.pop(contextDialog);
                          messenger.showSnackBar(SnackBar(
                            content: Text('Gagal melakukan mutasi: $e'),
                            backgroundColor: Colors.red,
                          ));
                        }
                      },
                child: const Text('Mutasi'),
              ),
            ],
          );
        },
      ),
    );
  }
}
