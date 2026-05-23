import 'package:flutter/material.dart';
import 'package:hompimpa_pos/core/widgets/app_end_drawer.dart';
import 'package:intl/intl.dart';
import 'package:hompimpa_pos/core/widgets/skeleton.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hompimpa_pos/features/reports/presentation/daily_sales_provider.dart';
import 'package:hompimpa_pos/features/products/presentation/product_provider.dart';
import 'package:hompimpa_pos/core/utils/responsive_layout.dart';
import 'package:hompimpa_pos/features/products/data/topping_repository.dart';
import 'package:hompimpa_pos/features/products/data/product_repository.dart';
import 'package:hompimpa_pos/features/auth/data/auth_repository.dart';
import 'package:hompimpa_pos/features/auth/presentation/auth_controller.dart';
import 'package:hompimpa_pos/core/enums/user_role.dart';
import 'package:hompimpa_pos/features/auth/domain/user_model.dart';
import 'package:hompimpa_pos/features/products/domain/product.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:uuid/uuid.dart';
import 'package:hompimpa_pos/features/products/domain/topping.dart';
import 'package:hompimpa_pos/core/widgets/gradient_app_bar.dart';
import 'package:hompimpa_pos/core/widgets/app_image.dart';
import 'package:hompimpa_pos/core/extensions/string_extension.dart';

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
    FlutterNativeSplash.remove();
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
    print(sales);
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
        appBar: GradientAppBar(
          title: const Text('Hompimpa POS'),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    (authState.asData?.value?.displayName ?? '').toTitleCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
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
        body: RefreshIndicator(
          onRefresh: () async {
            // Refresh providers
            ref.refresh(todaysSalesProvider);
            ref.refresh(todaysOrdersProvider);
            ref.refresh(productListProvider);
            ref.refresh(toppingListProvider);
            await Future.delayed(const Duration(seconds: 1)); // UX delay
          },
          child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Cards
              
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 8,
                        shadowColor: omzetColor.withOpacity(0.5),
                        color: omzetColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          onTap: authState.value?.role == UserRole.dev
                              ? () => context.push('/omzet-detail')
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Text('Omzet', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                                sales == 0 
                                  ? const Skeleton(width: 100, height: 24)
                                  : Text(
                                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(sales),
                                      style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                            ],
                          ),
                        ),
                       ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        elevation: 8,
                        shadowColor: orderColor.withOpacity(0.5),
                        color: orderColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          onTap: () => context.push('/orders'),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Order', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold)),
                                    Icon(Icons.chevron_right, size: 16, color: Colors.white.withOpacity(0.9)),
                                  ],
                                ),
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
                    ),
                    // Expanded(
                    //   child: _buildActionButton(
                    //     context: context,
                    //     onTap: () => context.push('/void-orders'),
                    //     label: 'VOID',
                    //     color: Colors.red[700]!,
                    //     ordersAsync: ordersAsync,
                    //     isVoid: true,
                    //   ),
                    // ),
                  ],
                ),
                if (authState.value?.role == UserRole.dev) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Product Button
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        onTap: () => _showAddProductDialog(context, ref),
                        icon: Icons.add_box,
                        label: 'PRODUK',
                        color: Colors.green[700]!,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Topping Button
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        onTap: () => _showAddToppingDialog(context, ref),
                        icon: Icons.add_circle_outline,
                        label: 'TOPPING',
                        color: Colors.orange[700]!,
                      ),
                    ),
                  ],
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
                  data: (allProducts) {
                    final products = allProducts.where((p) => p.isActive).toList();
                    if (products.isEmpty) {
                      return const Center(child: Text('Belum ada produk aktif'));
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
                                            Positioned.fill(
                                              child: AppImage(
                                                url: product.imageUrl,
                                                fit: BoxFit.cover,
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
                data: (allToppings) {
                   final toppings = allToppings.where((t) => t.isActive).toList();
                   if (toppings.isEmpty) {
                      return const Center(child: Text('Belum ada topping aktif'));
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
                          itemCount: toppings.length,
                          itemBuilder: (context, index) {
                            final topping = toppings[index];
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
                                            Positioned.fill(
                                              child: AppImage(
                                                url: topping.imageUrl,
                                                fit: BoxFit.cover,
                                                errorWidget: const Center(
                                                  child: Opacity(
                                                    opacity: 0.1,
                                                    child: Icon(Icons.grain, size: 64),
                                                  ),
                                                ),
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
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      topping.name,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                       NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(topping.price),
                                                       style: const TextStyle(
                                                         color: Colors.greenAccent,
                                                         fontSize: 12,
                                                         fontWeight: FontWeight.bold
                                                       ),
                                                    ),
                                                  ],
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
                                                  '${topping.stock}',
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
                                            _showUpdateToppingStockDialog(context, ref, topping);
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
                loading: () => const Skeleton(width: double.infinity, height: 100),
                error: (e, _) => Text('Error loading toppings: $e'),
              ),
              const SizedBox(height: 32), // Bottom padding
            ],
          ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/entry?quick=true'),
              customBorder: const CircleBorder(),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flash_on, color: Colors.white, size: 28),
                  Text(
                    'Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required VoidCallback onTap,
    IconData? icon,
    required String label,
    required Color color,
    AsyncValue<List<OrderEntity>>? ordersAsync,
    bool isVoid = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shadowColor: color.withOpacity(0.4),
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon != null ? Icon(icon, color: Colors.white, size: 28) : const SizedBox.shrink(),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (isVoid && ordersAsync != null) ...[
                const SizedBox(height: 4),
                ordersAsync.when(
                  data: (orders) {
                    final voidCount = orders.where((o) => o.status == OrderStatus.batal).length;
                    return Text(
                      '$voidCount',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                  loading: () => const Skeleton(width: 20, height: 16),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ],
          ),
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
    bool hasSambal = false;
    bool hasLevel = false;
    bool hasTopping = false;

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
                        imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                        isActive: true,
                        hasSambal: hasSambal,
                        hasLevel: hasLevel,
                        hasTopping: hasTopping,
                      );

                      await ref.read(productRepositoryProvider).addProduct(newProduct);
                      ref.refresh(productListProvider);
                      
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
          },
        );
      },
    );
  }

  void _showAddToppingDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final imageUrlController = TextEditingController(text: 'assets/images/logo.png');

    showDialog(
      context: context,
      builder: (contextDialog) {
        return AlertDialog(
          title: const Text('Tambah Topping Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Topping'),
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

                  final newTopping = Topping(
                    id: const Uuid().v4(),
                    name: title,
                    price: price,
                    stock: stock,
                    imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                    isActive: true,
                  );

                  await ref.read(toppingRepositoryProvider).addTopping(newTopping);
                  ref.refresh(toppingListProvider);

                  Navigator.pop(contextDialog);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Topping berhasil ditambahkan')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambah topping: $e')));
                }
              },
              child: const Text('Simpan'),
            ),
          ],
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
                  ref.refresh(toppingListProvider);
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
