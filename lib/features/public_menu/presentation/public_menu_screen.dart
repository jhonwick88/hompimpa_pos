import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../products/presentation/product_provider.dart';
import '../../products/domain/product.dart';
import './public_cart_provider.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../core/widgets/skeleton.dart';

import './public_product_option_dialog.dart';

class PublicMenuScreen extends ConsumerStatefulWidget {
  const PublicMenuScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PublicMenuScreen> createState() => _PublicMenuScreenState();
}

class _PublicMenuScreenState extends ConsumerState<PublicMenuScreen> {
  String selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);
    final cartItems = ref.watch(publicCartProvider).items;
    final totalCount = cartItems.fold<int>(0, (sum, item) => sum + item.qty);

    return Scaffold(
       backgroundColor: const Color(0xFFFAFAFA),
      body: productsAsync.when(
        data: (products) {
          final activeProducts = products.where((p) => p.isActive).toList();
          final categories = [
            'Semua',
            ...activeProducts
                .map((p) => p.category)
                .where((c) => c != null) // Just in case
                .toSet()
                .toList()
          ];
          
          final filteredProducts = selectedCategory == 'Semua'
              ? activeProducts
              : activeProducts.where((p) => p.category == selectedCategory).toList();

          return Column(
            children: [
              const _PremiumHeader(),
              _CategorySelector(
                categories: categories,
                selected: selectedCategory,
                onSelected: (cat) => setState(() => selectedCategory = cat),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 2;
                      if (constraints.maxWidth > 900) {
                        crossAxisCount = 4;
                      } else if (constraints.maxWidth > 600) {
                        crossAxisCount = 3;
                      }
                      
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return _ProductCard(product: filteredProducts[index]);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: Skeleton(width: double.infinity, height: double.infinity)),
        error: (e, s) => Center(child: Text('Gagal memuat menu: $e')),
      ),
bottomNavigationBar: totalCount > 0
    ? Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => context.push('/cart'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '$totalCount Item',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Text(
                    'Lihat →',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    : null,
    );
  }
}
class _PremiumHeader extends ConsumerWidget {
  const _PremiumHeader();

  void _showTableNumberDialog(BuildContext context, WidgetRef ref, String currentTable) {
    final controller = TextEditingController(text: currentTable);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nomor Meja'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Masukkan nomor meja',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(publicCartProvider.notifier).updateTableNumber(controller.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('SIMPAN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(publicCartProvider);
    final cartItems = cartState.items;
    final totalCount =
        cartItems.fold<int>(0, (sum, item) => sum + item.qty);
    final tableNumber = cartState.tableNumber ?? '1';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hompimpa',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Spesialis Mie & Pangsit',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => _showTableNumberDialog(context, ref, tableNumber),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.table_restaurant, size: 20, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Meja $tableNumber',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, size: 14, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => context.push('/cart'),
                  ),
                  if (totalCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$totalCount',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}
class _CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final Function(String) onSelected;

  const _CategorySelector({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
  height: 46,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    itemCount: categories.length,
    itemBuilder: (context, index) {
      final cat = categories[index];
      final isSelected = cat == selected;

      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFF3E0)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: GestureDetector(
            onTap: () => onSelected(cat),
            child: Center(
              child: Text(
                cat,
                style: TextStyle(
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.deepOrange
                      : Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
      );
    },
  ),
);
  }
}

class _ProductCard extends ConsumerWidget {
  final Product product;
  const _ProductCard({required this.product});

   @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: product.imageUrl != null &&
                            product.imageUrl!.isNotEmpty
                        ? Image.network(product.imageUrl!,
                            fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey[200],
                          ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 12, bottom: 12),
                child: InkWell(
                  onTap: () {
                                                    if(product.category != 'makanan'){
                             // Default add 1
                         ref.read(publicCartProvider.notifier).addItem(product, 1);
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text('${product.name} ditambah ke keranjang'),
                             duration: const Duration(seconds: 1),
                             action: SnackBarAction(label: 'LIHAT', onPressed: () => context.push('/cart')),
                           )
                           );
                          }else{
                            showDialog(
                            context: context,
                            builder: (context) => PublicProductOptionDialog(product: product),
                          );
                          }
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: const BoxDecoration(
                      color: Colors.deepOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
