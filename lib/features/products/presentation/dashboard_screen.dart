import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:hompimpa_pos/core/widgets/product_card_modern.dart';
import 'package:hompimpa_pos/core/extensions/string_extension.dart';
import 'package:hompimpa_pos/features/settings/data/store_repository.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime? currentBackPressTime;
  String _selectedCategory = 'Semua';
  final ScrollController _categoryScrollController = ScrollController();
  final Map<String, GlobalKey> _categoryKeys = {
    'Semua': GlobalKey(),
    'Makanan': GlobalKey(),
    'Minuman': GlobalKey(),
    'Snack': GlobalKey(),
    'Topping': GlobalKey(),
  };

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return DateFormat('dd/MM/yyyy').format(date);
    }
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
    final user = authState.value;
    final sales = ref.watch(todaysSalesProvider);
    final ordersAsync = ref.watch(todaysOrdersProvider);
    final productsAsync = ref.watch(productListProvider);
    final toppingsAsync = ref.watch(toppingListProvider);
    final isTablet = Responsive.isTablet(context);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          // Allow exit
        }
      },
      child: Scaffold(
        endDrawer: const AppEndDrawer(),
        appBar: GradientAppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Hompimpa POS',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    (user?.displayName ?? '').toTitleCase(),
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
            ref.refresh(todaysSalesProvider);
            ref.refresh(todaysOrdersProvider);
            ref.refresh(productListProvider);
            ref.refresh(toppingListProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Welcome Greeting & Branch Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()}, ${(user?.displayName ?? 'Kasir').toTitleCase()} 👋',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(DateTime.now()),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      if (user != null && (user.role == UserRole.dev || user.role == UserRole.admin)) ...[
                        ref.watch(activeStoresProvider).when(
                          data: (stores) {
                            final currentFilter = ref.watch(selectedStoreFilterProvider);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String?>(
                                  value: currentFilter,
                                  hint: const Text('Semua Cabang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  isDense: true,
                                  items: [
                                    const DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text('Semua Cabang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                    ...stores.map((s) => DropdownMenuItem<String?>(
                                      value: s.id,
                                      child: Text(s.name, style: const TextStyle(fontSize: 12)),
                                    )),
                                  ],
                                  onChanged: (val) {
                                    ref.read(selectedStoreFilterProvider.notifier).state = val;
                                  },
                                ),
                              ),
                            );
                          },
                          loading: () => const SizedBox(width: 80, child: LinearProgressIndicator()),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Metric Summary & Order Status Pipeline
                ordersAsync.when(
                  data: (orders) {
                    final belumCount = orders.where((o) => o.status == OrderStatus.belum).length;
                    final prosesCount = orders.where((o) => o.status == OrderStatus.proses).length;
                    final selesaiCount = orders.where((o) => o.status == OrderStatus.selesai).length;
                    final voidCount = orders.where((o) => o.status == OrderStatus.batal).length;

                    return Column(
                      children: [
                        // Row Omzet & Total Orders
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Omzet Hari Ini',
                                value: currencyFormat.format(sales),
                                subtitle: 'Total Penjualan Selesai',
                                icon: Icons.account_balance_wallet,
                                gradient: const [Color(0xFF3949AB), Color(0xFF5C6BC0)],
                                onTap: user?.role == UserRole.dev ? () => context.push('/omzet-detail') : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Total Pesanan',
                                value: '${orders.length} Pesanan',
                                subtitle: 'Hari Ini',
                                icon: Icons.receipt_long,
                                gradient: const [Color(0xFFF4511E), Color(0xFFFF7043)],
                                onTap: () => context.push('/orders'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Order Status Pipeline Grid (4 Status)
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatusPipelineCard(
                                label: 'Belum',
                                count: belumCount,
                                color: Colors.orange,
                                icon: Icons.timer,
                                onTap: () => context.push('/orders'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatusPipelineCard(
                                label: 'Proses',
                                count: prosesCount,
                                color: Colors.blue,
                                icon: Icons.sync,
                                onTap: () => context.push('/orders'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatusPipelineCard(
                                label: 'Selesai',
                                count: selesaiCount,
                                color: Colors.green,
                                icon: Icons.check_circle,
                                onTap: () => context.push('/orders'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatusPipelineCard(
                                label: 'Void',
                                count: voidCount,
                                color: Colors.red,
                                icon: Icons.cancel,
                                onTap: () => context.push('/void-orders'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  loading: () => const Row(
                    children: [
                      Expanded(child: Skeleton(width: double.infinity, height: 90, borderRadius: 16)),
                      SizedBox(width: 12),
                      Expanded(child: Skeleton(width: double.infinity, height: 90, borderRadius: 16)),
                    ],
                  ),
                  error: (e, _) => Text('Error: $e'),
                ),
                const SizedBox(height: 16),

                // 3. Smart Low-Stock Warning Alert Banner
                productsAsync.when(
                  data: (products) {
                    final lowStockProducts = products.where((p) => p.isActive && p.stock <= 5).toList();
                    final toppings = toppingsAsync.asData?.value ?? [];
                    final lowStockToppings = toppings.where((t) => t.isActive && t.stock <= 5).toList();

                    final totalLow = lowStockProducts.length + lowStockToppings.length;
                    if (totalLow == 0) return const SizedBox.shrink();

                    final sampleNames = [
                      ...lowStockProducts.map((p) => p.name),
                      ...lowStockToppings.map((t) => t.name),
                    ].take(3).join(', ');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                                children: [
                                  TextSpan(
                                    text: '⚠️ $totalLow Item Menipis/Habis: ',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                                  ),
                                  TextSpan(
                                    text: '$sampleNames${totalLow > 3 ? '...' : ''}',
                                    style: TextStyle(color: Colors.amber.shade900),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // 4. Quick Actions for Dev / Admin
                if (user?.role == UserRole.dev) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddProductDialog(context, ref),
                          icon: const Icon(Icons.add_box, size: 18),
                          label: const Text('Tambah Produk'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddToppingDialog(context, ref),
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text('Tambah Topping'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // 5. Category Filter Bar (Horizontal scroll with auto-scroll ke kiri saat chip di-klik)
                SingleChildScrollView(
                  controller: _categoryScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildCategoryChip('Semua', Icons.grid_view_rounded),
                      _buildCategoryChip('Makanan', Icons.ramen_dining),
                      _buildCategoryChip('Minuman', Icons.local_drink),
                      _buildCategoryChip('Snack', Icons.cookie_outlined),
                      _buildCategoryChip('Topping', Icons.add_circle_outline),
                      const SizedBox(width: 80), // Ruang ekstra agar chip kanan bisa geser penuh ke sisi kiri
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 6. Modern Grid Product & Topping Cards
                if (_selectedCategory == 'Topping') ...[
                  _buildToppingsSection(toppingsAsync, isTablet, user, currencyFormat),
                ] else ...[
                  _buildProductsSection(productsAsync, isTablet, user, currencyFormat),
                ],

                const SizedBox(height: 80), // Extra space for FAB
              ],
            ),
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/entry?quick=true'),
              borderRadius: BorderRadius.circular(30),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flash_on, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Quick Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _scrollToCategory(String label) {
    setState(() {
      _selectedCategory = label;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyContext = _categoryKeys[label]?.currentContext;
      if (keyContext == null || !_categoryScrollController.hasClients) return;

      final box = keyContext.findRenderObject() as RenderBox?;
      if (box == null) return;

      final viewport = RenderAbstractViewport.of(box);

      // Sisakan jarak intip (~52px) dari tepi kiri agar chip sebelumnya tetap terlihat setengahnya dan bisa diklik
      final isFirst = label == 'Semua';
      final double peekOffset = isFirst ? 0.0 : 52.0;

      final revealedOffset = viewport.getOffsetToReveal(box, 0.0).offset;
      final targetOffset = (revealedOffset - peekOffset).clamp(
        0.0,
        _categoryScrollController.position.maxScrollExtent,
      );

      _categoryScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    final isSelected = _selectedCategory == label;
    return Padding(
      key: _categoryKeys[label],
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _scrollToCategory(label),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.25),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[800],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: gradient[0].withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Icon(icon, color: Colors.white70, size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPipelineCard({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 6),
              Text(
                '$count',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsSection(
    AsyncValue<List<Product>> productsAsync,
    bool isTablet,
    AppUser? user,
    NumberFormat currencyFormat,
  ) {
    return productsAsync.when(
      data: (allProducts) {
        var products = allProducts.where((p) => p.isActive).toList();
        if (_selectedCategory != 'Semua') {
          products = products.where((p) => p.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
        }

        if (products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text('Tidak ada produk kategori $_selectedCategory', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          );
        }

        final orientation = MediaQuery.of(context).orientation;
        int crossAxisCount = 2;
        if (isTablet && orientation == Orientation.portrait) {
          crossAxisCount = 4;
        } else if (isTablet) {
          crossAxisCount = 5;
        }

        final childAspectRatio = crossAxisCount >= 4 ? 0.86 : 0.80;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCardModern(
              product: product,
              onTap: () {
                if (user != null && user.role == UserRole.dev) {
                  _showUpdateStockDialog(context, ref, product, user);
                }
              },
            );
          },
        );
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildToppingsSection(
    AsyncValue<List<Topping>> toppingsAsync,
    bool isTablet,
    AppUser? user,
    NumberFormat currencyFormat,
  ) {
    return toppingsAsync.when(
      data: (toppings) {
        final activeToppings = toppings.where((t) => t.isActive).toList();
        if (activeToppings.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text('Belum ada topping aktif', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          );
        }

        final orientation = MediaQuery.of(context).orientation;
        int crossAxisCount = 2;
        if (isTablet && orientation == Orientation.portrait) {
          crossAxisCount = 4;
        } else if (isTablet) {
          crossAxisCount = 5;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.82,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: activeToppings.length,
          itemBuilder: (context, index) {
            final topping = activeToppings[index];
            Color stockColor = Colors.green.shade700;
            if (topping.stock == 0) {
              stockColor = Colors.red.shade700;
            } else if (topping.stock <= 5) {
              stockColor = Colors.amber.shade800;
            }

            return Card(
              elevation: 3,
              shadowColor: Colors.black.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.15), width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  if (user != null && user.role == UserRole.dev) {
                    _showUpdateToppingStockDialog(context, ref, topping);
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AppImage(url: topping.imageUrl, fit: BoxFit.cover),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: stockColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
                              ),
                              child: Text(
                                topping.stock == 0 ? 'Habis' : 'Stok: ${topping.stock}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          if (user?.role == UserRole.dev) ...[
                            Positioned(
                              top: 6,
                              left: 6,
                              child: CircleAvatar(
                                backgroundColor: Colors.black.withValues(alpha: 0.5),
                                radius: 12,
                                child: const Icon(Icons.edit, size: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            topping.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 0.6,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            currencyFormat.format(topping.price),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Color(0xFFE65100),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
      error: (e, _) => Center(child: Text('Error: $e')),
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
  void _showAddProductDialog(BuildContext context, WidgetRef ref, {Product? product}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '');
    final imageUrlController = TextEditingController(text: product?.imageUrl ?? '');
    String category = product?.category ?? 'makanan';
    bool hasSambal = product?.hasSambal ?? false;
    bool hasLevel = product?.hasLevel ?? false;
    bool hasTopping = product?.hasTopping ?? false;
    String? selectedStoreId = product?.storeId ?? ref.read(selectedStoreFilterProvider);
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
                  imageUrl: imageUrlController.text.trim().isNotEmpty
                      ? imageUrlController.text.trim()
                      : null,
                  isActive: product?.isActive ?? true,
                  storeId: selectedStoreId,
                  hasSambal: hasSambal,
                  hasLevel: hasLevel,
                  hasTopping: hasTopping,
                );

                try {
                  if (product == null) {
                    await ref.read(productRepositoryProvider).addProduct(newProduct);
                  } else {
                    await ref.read(productRepositoryProvider).updateProduct(newProduct);
                  }
                  ref.refresh(productListProvider);
                  Navigator.pop(contextDialog);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil disimpan')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan produk: $e')));
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToppingDialog(BuildContext context, WidgetRef ref, {Topping? topping}) {
    final nameController = TextEditingController(text: topping?.name ?? '');
    final priceController = TextEditingController(text: topping?.price.toString() ?? '');
    final stockController = TextEditingController(text: topping?.stock.toString() ?? '');
    final imageUrlController = TextEditingController(text: topping?.imageUrl ?? '');

    showDialog(
      context: context,
      builder: (contextDialog) {
        return AlertDialog(
          title: Text(topping == null ? 'Tambah Topping' : 'Edit Topping'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Harga'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stok'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
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
                  final title = nameController.text.trim();
                  final price = double.tryParse(priceController.text) ?? 0;
                  final stock = int.tryParse(stockController.text) ?? 0;
                  final imageUrl = imageUrlController.text.trim();

                  final newTopping = Topping(
                    id: topping?.id ?? const Uuid().v4(),
                    name: title,
                    price: price,
                    stock: stock,
                    imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                    isActive: topping?.isActive ?? true,
                  );

                  if (topping == null) {
                    await ref.read(toppingRepositoryProvider).addTopping(newTopping);
                  } else {
                    await ref.read(toppingRepositoryProvider).updateTopping(newTopping);
                  }
                  ref.refresh(toppingListProvider);

                  Navigator.pop(contextDialog);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(topping == null ? 'Topping berhasil ditambahkan' : 'Topping berhasil diperbarui'),
                  ));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan topping: $e')));
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
