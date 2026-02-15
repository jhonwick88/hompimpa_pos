import 'package:flutter/material.dart';
import 'package:hompimpa_pos/core/widgets/app_end_drawer.dart';
import 'package:hompimpa_pos/core/widgets/skeleton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hompimpa_pos/features/reports/presentation/daily_sales_provider.dart';
import 'package:hompimpa_pos/features/products/presentation/product_provider.dart';
import 'package:hompimpa_pos/core/utils/responsive_layout.dart';
import 'package:hompimpa_pos/features/products/data/topping_repository.dart';
import 'package:hompimpa_pos/features/products/data/product_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../core/enums/user_role.dart';
import '../../auth/domain/user_model.dart';
import '../domain/product.dart';
import '../../orders/domain/order.dart';
import 'package:uuid/uuid.dart';
import '../domain/topping.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
    // Role Guard
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final authState = ref.read(authStateChangesProvider);
      if (authState.value != null && authState.value!.role == UserRole.user) {
        context.go('/orders');
      }
    });
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || 
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tekan sekali lagi untuk keluar'),
          duration: Duration(seconds: 2),
        ),
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final sales = ref.watch(todaysSalesProvider);
    final ordersAsync = ref.watch(todaysOrdersProvider);

    final productsAsync = ref.watch(productListProvider);
    final toppingsAsync = ref.watch(toppingListProvider);
    final isTablet = Responsive.isTablet(context);

    // Random-ish but stable colors for summary cards
    final summaryColors = [
      Colors.indigo[400]!,
      Colors.teal[400]!,
      Colors.orange[400]!,
      Colors.pink[400]!,
    ];
    final omzetColor = summaryColors[0];
    final orderColor = summaryColors[1];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        endDrawer: const AppEndDrawer(),
        appBar: AppBar(
          title: const Text('Hompimpa POS'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    children: [
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(Icons.person, size: 18, color: Colors.white),
                      ),
                      TextSpan(text: authState.asData?.value?.displayName ?? '',),
                    ],
                  ),
                ),
              ),
            ), 
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Cards
              if (authState.value?.role == UserRole.dev) ...[
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 8,
                        shadowColor: omzetColor.withOpacity(0.5),
                        color: omzetColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text('Omzet Hari Ini', style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              sales == 0 
                                ? const Skeleton(width: 100, height: 24)
                                : Text(
                                    'Rp ${sales.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        elevation: 8,
                        shadowColor: orderColor.withOpacity(0.5),
                        color: orderColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text('Total Order', style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              ordersAsync.when(
                                data: (data) => Text(
                                  '${data.length}',
                                  style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                loading: () => const Skeleton(width: 40, height: 28),
                                error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => context.push('/void-orders'),
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.red.withOpacity(0.5),
                    color: Colors.red[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               const Text('Void / Batal (Hari Ini)', style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold)),
                               const SizedBox(height: 4),
                               ordersAsync.when(
                                 data: (orders) {
                                   final voidCount = orders.where((o) => o.status == OrderStatus.batal).length;
                                   return Text(
                                     '$voidCount Order',
                                     style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                                   );
                                 },
                                 loading: () => const Skeleton(width: 40, height: 24),
                                 error: (_, __) => const Text('-', style: TextStyle(color: Colors.white)),
                               ),
                             ],
                           ),
                           const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if(authState.value?.role == UserRole.dev) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddProductDialog(context, ref),
                    icon: const Icon(Icons.add_box),
                    label: const Text('TAMBAH PRODUK BARU'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green[700],
                      onPrimary: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Text(
                'Stok Produk',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              // Product Stock List
              productsAsync.when(
                  data: (products) {
                    if (products.isEmpty) {
                      return const Center(child: Text('Belum ada produk'));
                    }
                    
                    final cardColors = [
                      Colors.orange[100],
                      Colors.blue[100],
                      Colors.green[100],
                      Colors.purple[100],
                      Colors.pink[100],
                      Colors.amber[100],
                      Colors.cyan[100],
                      Colors.indigo[100],
                    ];

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final orientation = MediaQuery.of(context).orientation;
                        int crossAxisCount;
                        
                        if (isTablet && orientation == Orientation.portrait) {
                          crossAxisCount = 4; // Tablet portrait
                        } else if (isTablet) {
                          crossAxisCount = 6; // Tablet landscape
                        } else {
                          crossAxisCount = 2; // Phone portrait
                        }
                        
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final bgColor = cardColors[index % cardColors.length];
                        
                            return Card(
                              elevation: 6,
                              shadowColor: Colors.black26,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Stack(
                                children: [
                                  // Content Layer
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            // Main Background
                                            Container(color: bgColor),
                                            
                                            // Product Image or Icon
                                            if (product.imageUrl != null)
                                              Positioned.fill(
                                                child: Image.asset(
                                                  product.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const Center(
                                                      child: Icon(Icons.broken_image,color: Colors.white54),
                                                    );
                                                  },
                                                ),
                                              )
                                            else
                                              const Center(
                                                child: Opacity(
                                                  opacity: 0.1,
                                                  child: Icon(Icons.fastfood, size: 64),
                                                ),
                                              ),
                                      
                                            // Name Label at Bottom with Gradient
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                    colors: [Colors.black87, Colors.transparent],
                                                  ),
                                                ),
                                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                                child: Text(
                                                  product.name,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                      
                                            // Stock Badge at Top Right Edge
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.circular(20), // Oval
                                                  boxShadow: const [
                                                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                                  ],
                                                ),
                                                child: Text(
                                                  '${product.stock}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            // Edit Icon for Dev
                                            if (ref.watch(authStateChangesProvider).value?.role == UserRole.dev)
                                              const Positioned(
                                                top: 4,
                                                left: 4,
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.white70,
                                                  radius: 12,
                                                  child: Icon(Icons.edit, size: 14, color: Colors.black87),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Ripple Layer
                                  Positioned.fill(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          final authState = ref.read(authStateChangesProvider);
                                          final user = authState.value;
                                          if (user != null && user.role == UserRole.dev) {
                                            _showUpdateStockDialog(context, ref, product, user);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 6,
                    itemBuilder: (_, __) => const Skeleton(width: double.infinity, height: double.infinity, borderRadius: 16),
                  ),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),

              const SizedBox(height: 32),
              Text(
                'Stok Topping',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Topping Stock List
              toppingsAsync.when(
                data: (toppings) {
                   if (toppings.isEmpty) {
                      return const Center(child: Text('Belum ada topping'));
                   }
                   
                   return GridView.builder(
                     physics: const NeverScrollableScrollPhysics(),
                     shrinkWrap: true,
                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Keep it simple for headers
                        childAspectRatio: 1.6,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                     ),
                     itemCount: toppings.length,
                     itemBuilder: (context, index) {
                        final topping = toppings[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: Colors.amber[50], // Distinguishable color
                          child: InkWell(
                             onTap: () {
                                if (ref.read(authStateChangesProvider).value?.role == UserRole.dev) {
                                  _showUpdateToppingStockDialog(context, ref, topping);
                                }
                             },
                             borderRadius: BorderRadius.circular(12),
                             child: Padding(
                               padding: const EdgeInsets.all(12.0),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Text(
                                     topping.name, 
                                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                     maxLines: 1, overflow: TextOverflow.ellipsis
                                   ),
                                   const SizedBox(height: 4),
                                   Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     children: [
                                       Text('Stok: ${topping.stock}'),
                                       Text('Rp ${topping.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                     ],
                                   ),
                                 ],
                               ),
                             ),
                          ),
                        );
                     },
                   );
                },
                loading: () => const Skeleton(width: double.infinity, height: 100),
                error: (e, _) => Text('Error loading toppings: $e'),
              ),
              const SizedBox(height: 32), // Bottom padding
            ],
          ),
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.menu,
          activeIcon: Icons.close,
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.add_shopping_cart),
              label: 'Input Order Via WA',
              onTap: () => context.push('/entry'),
            ),
            if(authState.value?.role == UserRole.dev) ...[
              SpeedDialChild(
                child: const Icon(Icons.add),
                label: 'Tambah Produk',
                onTap: () => _showAddProductDialog(context, ref),
              ),
              SpeedDialChild(
                child: const Icon(Icons.analytics),
                label: 'Laporan Penjualan',
                onTap: () => context.push('/reports'),
              ),
            ],
            SpeedDialChild(
              child: const Icon(Icons.history),
              label: 'Pesanan Pelanggan',
              onTap: () => context.push('/orders'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context, WidgetRef ref, Product product, AppUser user) {
    final stockController = TextEditingController(text: product.stock.toString());
    final reasonController = TextEditingController(text: 'Manual by ${user.displayName ?? 'Admin'}');

    showDialog(
      context: context,
      builder: (contextDialog) {
        return AlertDialog(
          title: Text('Update Stock: ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'New Stock'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextDialog),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newStock = int.tryParse(stockController.text);
                if (newStock == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid stock number')));
                  return;
                }

                try {
                  await ref.read(productRepositoryProvider).updateStock(
                    product.id,
                    newStock,
                    reason: reasonController.text,
                    username: user.displayName ?? 'Admin',
                  );
                  Navigator.pop(contextDialog);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stock updated successfully')));
                } catch (e) {
                  Navigator.pop(contextDialog);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update stock: $e')));
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final imageUrlController = TextEditingController(text: 'assets/images/logo.png'); // Default per request
    String category = 'makanan'; // Default

    showDialog(
      context: context,
      builder: (contextDialog) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah Produk Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nama Produk'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      items: const [
                        DropdownMenuItem(value: 'makanan', child: Text('Makanan')),
                        DropdownMenuItem(value: 'minuman', child: Text('Minuman')),
                        DropdownMenuItem(value: 'snack', child: Text('Snack')),
                      ],
                      onChanged: (v) => setState(() => category = v!),
                      decoration: const InputDecoration(labelText: 'Kategori'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stok Awal'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(labelText: 'Image URL (Assets/Network)'),
                    ),
                    const SizedBox(height: 8),
                    const Text('Status Active: TRUE (Default)', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(contextDialog),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || priceController.text.isEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan Harga wajib diisi')));
                       return;
                    }

                    try {
                      final title = nameController.text;
                      final price = double.tryParse(priceController.text) ?? 0;
                      final stock = int.tryParse(stockController.text) ?? 0;
                      final imageUrl = imageUrlController.text;
                      
                      final newProduct = Product(
                        id: const Uuid().v4(),
                        name: title,
                        category: category,
                        price: price,
                        stock: stock,
                        imageUrl: imageUrl.isEmpty ? null : imageUrl,
                        isActive: true, // Default per request
                      );
                      
                      await ref.read(productRepositoryProvider).addProduct(newProduct);
                      Navigator.pop(contextDialog);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil ditambahkan')));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambah produk: $e')));
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showUpdateToppingStockDialog(BuildContext context, WidgetRef ref, Topping topping) {
    final stockController = TextEditingController(text: topping.stock.toString());
    final reasonController = TextEditingController(text: 'Manual Update');

    showDialog(
      context: context,
      builder: (contextDialog) {
        return AlertDialog(
          title: Text('Update Stock Topping: ${topping.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'New Stock'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextDialog),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newStock = int.tryParse(stockController.text);
                if (newStock == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid stock number')));
                  return;
                }

                try {
                  final user = ref.read(authStateChangesProvider).value;
                  await ref.read(toppingRepositoryProvider).updateStock(
                    topping.id,
                    newStock,
                    reason: reasonController.text,
                    username: user?.displayName ?? 'Admin',
                  );
                  Navigator.pop(contextDialog);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stock topping updated successfully')));
                } catch (e) {
                  Navigator.pop(contextDialog);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update stock: $e')));
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
