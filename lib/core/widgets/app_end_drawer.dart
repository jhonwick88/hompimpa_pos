import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hompimpa_pos/core/presentation/theme/app_colors.dart';
import 'package:hompimpa_pos/features/auth/data/auth_repository.dart';
import 'package:hompimpa_pos/features/cashier/presentation/cashier_controller.dart';
import 'package:hompimpa_pos/core/enums/user_role.dart';
import 'package:hompimpa_pos/features/settings/data/settings_repository.dart';
import 'package:hompimpa_pos/features/settings/domain/sambal_settings.dart';
import 'package:intl/intl.dart';

class AppEndDrawer extends ConsumerWidget {
  const AppEndDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateChangesProvider);
    final cashierState = ref.watch(cashierProvider);
    // final cashierController = ref.read(cashierProvider.notifier); // Not used directly in build

    return Drawer(
  backgroundColor: const Color(0xFFF4F4F4), // lebih netral modern
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
  ),
  child: userAsync.when(
    data: (user) {
      final String initial = user?.displayName?.isNotEmpty == true
          ? user!.displayName![0].toUpperCase()
          : '?';

      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // ===== HEADER GRADIENT =====
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFB71C1C),
                            Color(0xFFFF6D00),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB71C1C),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user?.displayName ?? 'Kasir',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cashierState.activeShift?.shiftName ?? '-',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // STATUS BADGE
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: cashierState.isOpen
                                  ? Colors.green
                                  : Colors.black.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: cashierState.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    cashierState.isOpen
                                        ? 'Kasir Aktif'
                                        : 'Kasir Tutup',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    if (cashierState.error != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.red.shade100,
                        child: Text(
                          cashierState.error!,
                          style: TextStyle(
                              color: Colors.red.shade800, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 20),
                    const Divider(height: 1),

                    // ===== OPERASIONAL =====
                    const SizedBox(height: 16),
                    const _SectionTitle('Operasional Kasir'),

                    if (cashierState.isOpen)
                      _DrawerButton(
                        icon: Icons.remove_circle_outline,
                        label: 'Kurangi Laci',
                        color: Colors.black87,
                        onTap: () => _showReduceCashDialog(context, ref),
                      ),

                    if (!cashierState.isOpen)
                      _DrawerButton(
                        icon: Icons.storefront,
                        label: 'Open Kasir',
                        color: const Color(0xFF2E7D32),
                        isPrimary: true,
                        onTap: () => _showOpenRegisterDialog(context, ref),
                      )
                    else
                      _DrawerButton(
                        icon: Icons.lock_outline,
                        label: 'Close Kasir',
                        color: const Color(0xFFB71C1C),
                        isPrimary: true,
                        onTap: () => _showCloseRegisterDialog(context, ref),
                      ),

                    const SizedBox(height: 10),
                    const SizedBox(height: 10),
                    const Divider(),

                    // ===== MASTER DATA (DEV ONLY) =====
                    if (user?.role == UserRole.dev) ...[
                      const SizedBox(height: 16),
                      const _SectionTitle('Master Data'),
                      _DrawerButton(
                        icon: Icons.inventory_2_outlined,
                        label: 'Produk',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/master/products');
                        },
                      ),
                      _DrawerButton(
                        icon: Icons.layers_outlined,
                        label: 'Topping',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/master/toppings');
                        },
                      ),
                      _DrawerButton(
                        icon: Icons.people_outline,
                        label: 'User',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/master/users');
                        },
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                    ],

                    // ===== SETTING (DEV ONLY) =====
                    if (user?.role == UserRole.dev) ...[
                      const SizedBox(height: 16),
                      const _SectionTitle('Setting'),
                      _DrawerButton(
                        icon: Icons.settings_outlined,
                        label: 'Edit Nota',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/settings');
                        },
                      ),
                      _DrawerButton(
                        icon: Icons.local_fire_department_outlined,
                        label: 'Setting Harga Sambal',
                        onTap: () => _showSambalSettingsDialog(context, ref),
                      ),
                      _DrawerButton(
                        icon: Icons.analytics_outlined,
                        label: 'Laporan Penjualan',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/reports');
                        },
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                    ],

                    // ===== AKUN =====
                    const SizedBox(height: 16),
                    const _SectionTitle('Akun'),

                    _DrawerButton(
                      icon: Icons.person_outline,
                      label: 'Profil',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Profile feature coming soon')),
                        );
                      },
                    ),

                    _DrawerButton(
                      icon: Icons.logout,
                      label: 'Logout',
                      color: const Color(0xFFB71C1C),
                      onTap: () => _showLogoutDialog(context, ref),
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'v1.0.0',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, st) => Center(child: Text('Error: $e')),
  ),
);

  }

  void _showReduceCashDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    final currentBalance = ref.read(cashierProvider).activeShift?.startCash ?? 0; // Estimation only

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kurangi Laci'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             // Text('Modal Awal: Rp ${NumberFormat("#,##0", "id_ID").format(currentBalance)}', style: const TextStyle(fontWeight: FontWeight.bold)),
             // const SizedBox(height: 16),
             TextField(
               controller: amountController,
               keyboardType: TextInputType.number,
               decoration: const InputDecoration(labelText: 'Jumlah Pengurangan', prefixText: 'Rp '),
             ),
             const SizedBox(height: 8),
             TextField(
               controller: reasonController,
               decoration: const InputDecoration(labelText: 'Alasan (Wajib)'),
             ),
             const SizedBox(height: 8),
             const Text(
                'Note: Pengurangan ini akan dicatat sebagai pengurangan omzet harian.',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
             ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              final reason = reasonController.text.trim();
              
              if (amount <= 0 || reason.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon isi jumlah dan alasan yang valid')));
                 return;
              }
              
              Navigator.pop(context);
              try {
                await ref.read(cashierProvider.notifier).reduceCash(amount, reason);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil mengurangi cash drawer')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.softRed),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  void _showOpenRegisterDialog(BuildContext context, WidgetRef ref) {
    final initialCashController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buka Kasir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan modal awal kasir:'),
            const SizedBox(height: 10),
            TextField(
              controller: initialCashController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Modal Awal', prefixText: 'Rp '),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(initialCashController.text) ?? 0;
              Navigator.pop(context);
              try {
                await ref.read(cashierProvider.notifier).openRegister(amount);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kasir Berhasil Dibuka! Selamat Bekerja.')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuka kasir: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.freshGreen),
            child: const Text('Buka Kasir'),
          ),
        ],
      ),
    );
  }

  void _showCloseRegisterDialog(BuildContext context, WidgetRef ref) async {
    // 1. Calculate Summary first
    final controller = ref.read(cashierProvider.notifier);
    
    // Show loading indicator usually, but here we just wait
    // Ideally block UI.
    try {
      final summary = await controller.calculateShiftSummary();
      
      if (!context.mounted) return;

      final actualCashController = TextEditingController();
      final expectedCash = summary['expectedCash'] ?? 0;
      final totalCashSales = summary['totalCashSales'] ?? 0;
      final startCash = summary['startCash'] ?? 0;
      final totalCashOut = summary['totalCashOut'] ?? 0;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tutup Kasir'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow('Modal Awal', startCash),
                _buildSummaryRow('Penjualan Tunai', totalCashSales, isPlus: true),
                _buildSummaryRow('Pengeluaran', totalCashOut, isMinus: true),
                const Divider(thickness: 2),
                _buildSummaryRow('Ekspektasi Kas', expectedCash, isBold: true),
                const SizedBox(height: 16),
                TextField(
                  controller: actualCashController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Hitung Uang Fisik', 
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final actualCash = double.tryParse(actualCashController.text);
                if (actualCash == null) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan jumlah uang fisik')));
                   return;
                }
                
                final difference = actualCash - expectedCash;
                
                if (difference.abs() > 0) {
                  // Show warnings if difference exists
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Selisih Kas: Rp ${NumberFormat("#,##0", "id_ID").format(difference)}', 
                        style: TextStyle(color: difference < 0 ? Colors.red : Colors.green)),
                      content: const Text('Uang fisik tidak sesuai dengan sistem. Apakah Anda yakin ingin melanjutkan?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Periksa Ulang')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true), 
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Ya, Tutup Kasir')
                        ),
                      ],
                    ),
                  );
                  
                  if (confirm != true) return;
                }

                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close drawer
                
                try {
                  await controller.closeRegister(actualCash, summary);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shift Berhasil Ditutup.')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menutup shift: $e')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.softRed),
              child: const Text('Tutup Kasir'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildSummaryRow(String label, double value, {bool isPlus = false, bool isMinus = false, bool isBold = false}) {
    final color = isMinus ? Colors.red : (isBold ? Colors.black : Colors.grey[700]);
    final prefix = isPlus ? '+ ' : (isMinus ? '- ' : '');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
          Text(
            '$prefix Rp ${NumberFormat("#,##0", "id_ID").format(value)}', 
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)
          ),
        ],
      ),
    );
  }

  void _showSambalSettingsDialog(BuildContext context, WidgetRef ref) async {
    final settings = await ref.read(settingsRepositoryProvider).getSambalSettings();
    
    if (!context.mounted) return;

    final lv03Controller = TextEditingController(text: settings.level0to3Price.toStringAsFixed(0));
    final lv45Controller = TextEditingController(text: settings.level4to5Price.toStringAsFixed(0));
    final lv67Controller = TextEditingController(text: settings.level6to7Price.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setting Harga Sambal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lv03Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga Level 0-3', prefixText: 'Rp '),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: lv45Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga Level 4-5', prefixText: 'Rp '),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: lv67Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga Level 6-7', prefixText: 'Rp '),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final newSettings = settings.copyWith(
                level0to3Price: double.tryParse(lv03Controller.text) ?? 0,
                level4to5Price: double.tryParse(lv45Controller.text) ?? 500,
                level6to7Price: double.tryParse(lv67Controller.text) ?? 1000,
              );
              
              Navigator.pop(context);
              try {
                await ref.read(settingsRepositoryProvider).updateSambalSettings(newSettings);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil memperbarui setting sambal')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.freshGreen),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar aplikasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close drawer
              await ref.read(authRepositoryProvider).signOut();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.softRed),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DrawerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isPrimary;

  const _DrawerButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textPrimary,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isPrimary ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: isPrimary ? Colors.white : color),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
                    color: isPrimary ? Colors.white : color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

