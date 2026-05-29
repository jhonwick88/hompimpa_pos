import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hompimpa_pos/core/widgets/gradient_app_bar.dart';
import 'package:hompimpa_pos/features/auth/data/auth_repository.dart';
import 'package:hompimpa_pos/features/settings/data/store_repository.dart';
import 'package:hompimpa_pos/features/reports/presentation/daily_sales_provider.dart';
import 'package:hompimpa_pos/core/enums/user_role.dart';
import 'package:hompimpa_pos/features/settings/domain/store.dart';

final userStoreProvider = FutureProvider.autoDispose<Store?>((ref) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user != null && user.storeId != null) {
    return ref.read(storeRepositoryProvider).getStore(user.storeId!);
  }
  return null;
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateChangesProvider);
    final storeAsync = ref.watch(userStoreProvider);
    final todaysOrdersAsync = ref.watch(todaysOrdersProvider);
    
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 700;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const GradientAppBar(
        title: Text('Profil Kinerja'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF8F9FA),
              Colors.orange.shade50.withOpacity(0.3),
              Colors.red.shade50.withOpacity(0.15),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: userAsync.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text('Pengguna tidak ditemukan. Silakan login kembali.'));
            }

            final String initial = user.displayName?.isNotEmpty == true
                ? user.displayName![0].toUpperCase()
                : '?';

            return todaysOrdersAsync.when(
              data: (orders) {
                // Calculate performance metrics
                final totalOrders = orders.length;
                final totalRevenue = orders.fold<double>(0.0, (sum, order) => sum + order.total);
                final averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;
                
                // Target calculations
                const targetOrders = 30; // Daily transaction target
                final targetPercentage = totalOrders / targetOrders;
                final targetProgress = targetPercentage > 1.0 ? 1.0 : targetPercentage;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40.0 : 20.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ===== PROFILE HEADER CARD =====
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB71C1C), Color(0xFFFF6D00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB71C1C).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: isTablet ? 48 : 38,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      initial,
                                      style: TextStyle(
                                        fontSize: isTablet ? 36 : 28,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFB71C1C),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                user.displayName ?? 'Pengguna',
                                                style: TextStyle(
                                                  fontSize: isTablet ? 24 : 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                user.role.name.toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  letterSpacing: 0.8,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          user.email,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.85),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.storefront_rounded, size: 16, color: Colors.white70),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: storeAsync.when(
                                                data: (store) => Text(
                                                  store?.name ?? 'Pusat (Global)',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                loading: () => const Text('Loading Cabang...', style: TextStyle(color: Colors.white70)),
                                                error: (_, __) => const Text('Semua Cabang', style: TextStyle(color: Colors.white70)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // ===== MAIN METRICS TITLE =====
                        const Text(
                          'Ringkasan Kinerja Hari Ini',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2D3436),
                            letterSpacing: -0.5,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // ===== PERFORMANCE METRICS STACK/GRID =====
                        if (isTablet)
                          GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2.2,
                            ),
                            children: [
                              _buildMetricCard(
                                title: 'Transaksi Sukses',
                                value: '$totalOrders',
                                subText: 'selesai diproses',
                                icon: Icons.assignment_turned_in_outlined,
                                color: Colors.indigo,
                              ),
                              _buildMetricCard(
                                title: 'Total Omzet Anda',
                                value: 'Rp ${NumberFormat('#,###', 'id_ID').format(totalRevenue)}',
                                subText: 'omzet hari ini',
                                icon: Icons.payments_outlined,
                                color: Colors.teal,
                              ),
                              _buildMetricCard(
                                title: 'Rata-rata Transaksi',
                                value: 'Rp ${NumberFormat('#,###', 'id_ID').format(averageOrderValue)}',
                                subText: 'nilai per order',
                                icon: Icons.analytics_outlined,
                                color: Colors.orange,
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildMetricCard(
                                title: 'Transaksi Sukses',
                                value: '$totalOrders',
                                subText: 'selesai diproses',
                                icon: Icons.assignment_turned_in_outlined,
                                color: Colors.indigo,
                              ),
                              const SizedBox(height: 12),
                              _buildMetricCard(
                                title: 'Total Omzet Anda',
                                value: 'Rp ${NumberFormat('#,###', 'id_ID').format(totalRevenue)}',
                                subText: 'omzet hari ini',
                                icon: Icons.payments_outlined,
                                color: Colors.teal,
                              ),
                              const SizedBox(height: 12),
                              _buildMetricCard(
                                title: 'Rata-rata Transaksi',
                                value: 'Rp ${NumberFormat('#,###', 'id_ID').format(averageOrderValue)}',
                                subText: 'nilai per order',
                                icon: Icons.analytics_outlined,
                                color: Colors.orange,
                              ),
                            ],
                          ),
                        
                        const SizedBox(height: 32),
                        
                        // ===== TARGET TRACKING CARD =====
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Progres Target Harian',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3436),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${(targetProgress * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: targetProgress,
                                  minHeight: 12,
                                  backgroundColor: Colors.grey.shade100,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade800),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Pencapaian: $totalOrders dari target harian $targetOrders transaksi.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // ===== ACHIEVEMENTS SECTION =====
                        const Text(
                          'Pencapaian & Kredensial',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2D3436),
                            letterSpacing: -0.5,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // ===== CUSTOM BADGES LIST =====
                        Column(
                          children: [
                            _buildBadgeItem(
                              title: 'Akurasi Kasir (Perfect Streak)',
                              description: 'Laporan penutupan kasir dinilai presisi tinggi tanpa selisih uang fisik.',
                              icon: Icons.verified_user_outlined,
                              iconColor: Colors.green,
                              bgColor: Colors.green.shade50,
                            ),
                            const SizedBox(height: 12),
                            _buildBadgeItem(
                              title: 'Pelayanan Cepat (Speedy Cashier)',
                              description: 'Memproses transaksi secara cepat di bawah batas standar waktu POS.',
                              icon: Icons.bolt,
                              iconColor: Colors.amber.shade900,
                              bgColor: Colors.amber.shade50,
                            ),
                            const SizedBox(height: 12),
                            _buildBadgeItem(
                              title: 'Kasir Teladan (Star Service)',
                              description: 'Memiliki reputasi performa shift kerja yang bersih, disiplin, dan terpercaya.',
                              icon: Icons.star_outline_rounded,
                              iconColor: Colors.purple,
                              bgColor: Colors.purple.shade50,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading performance: $e')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading user: $e')),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subText,
    required IconData icon,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color.shade700, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D3436),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subText,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
