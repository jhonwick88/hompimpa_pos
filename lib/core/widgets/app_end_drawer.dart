import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hompimpa_pos/core/presentation/theme/app_colors.dart';
import 'package:hompimpa_pos/features/auth/data/auth_repository.dart';
import 'package:hompimpa_pos/features/cashier/presentation/cashier_controller.dart';
import 'package:intl/intl.dart';

class AppEndDrawer extends ConsumerWidget {
  const AppEndDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateChangesProvider);
    final cashierState = ref.watch(cashierProvider);
    final cashierController = ref.watch(cashierProvider.notifier);

    return Drawer(
      backgroundColor: AppColors.creamBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
      ),
      child: userAsync.when(
        data: (user) {
          final String initial = user?.displayName?.isNotEmpty == true
              ? user!.displayName![0].toUpperCase()
              : '?';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER SECTION
              Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.freshGreen.withOpacity(0.2),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.freshGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.displayName ?? 'Kasir',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cashierState.shiftName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: cashierState.isOpen ? AppColors.freshGreen : AppColors.softRed,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cashierState.isOpen ? 'Kasir Aktif' : 'Kasir Tutup',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1),
              
              // OPERASIONAL KASIR SECTION
              _SectionTitle('Operasional Kasir'),
              
              if (cashierState.isOpen)
                _DrawerButton(
                  icon: Icons.remove_circle_outline,
                  label: 'Kurangi Laci',
                  color: AppColors.textPrimary,
                  onTap: () => _showReduceCashDialog(context, ref, cashierState.cashBalance),
                ),

              if (!cashierState.isOpen)
                _DrawerButton(
                  icon: Icons.storefront,
                  label: 'Open Kasir',
                  color: AppColors.freshGreen,
                  isPrimary: true,
                  onTap: () => _showOpenRegisterDialog(context, ref),
                )
              else
                _DrawerButton(
                  icon: Icons.lock_outline,
                  label: 'Close Kasir',
                  color: AppColors.softRed,
                  isPrimary: true,
                  onTap: () => _showCloseRegisterDialog(context, ref, cashierState),
                ),

              const SizedBox(height: 10),
              const Divider(),

              // AKUN SECTION
              _SectionTitle('Akun'),

              _DrawerButton(
                icon: Icons.person_outline,
                label: 'Profil',
                onTap: () { 
                   Navigator.pop(context);
                   // Navigate to profile if route exists, mostly not implemented yet based on task
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile feature coming soon')));
                },
              ),

              _DrawerButton(
                icon: Icons.logout,
                label: 'Logout',
                color: AppColors.softRed,
                onTap: () => _showLogoutDialog(context, ref),
              ),
              
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showReduceCashDialog(BuildContext context, WidgetRef ref, double currentBalance) {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kurangi Laci'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text('Saldo saat ini: Rp ${NumberFormat("#,##0", "id_ID").format(currentBalance)}', style: const TextStyle(fontWeight: FontWeight.bold)),
             const SizedBox(height: 16),
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
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              final reason = reasonController.text.trim();
              
              if (amount <= 0 || reason.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon isi jumlah dan alasan yang valid')));
                 return;
              }
              
              if (amount > currentBalance) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saldo tidak mencukupi')));
                 return;
              }

              ref.read(cashierProvider.notifier).reduceCash(amount, reason);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil mengurangi Rp ${NumberFormat("#,##0", "id_ID").format(amount)}')));
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
            onPressed: () {
              final amount = double.tryParse(initialCashController.text) ?? 0;
              ref.read(cashierProvider.notifier).openRegister(amount);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kasir Berhasil Dibuka! Selamat Bekerja.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.freshGreen),
            child: const Text('Buka Kasir'),
          ),
        ],
      ),
    );
  }

  void _showCloseRegisterDialog(BuildContext context, WidgetRef ref, CashierState state) {
     final actualCashController = TextEditingController();

     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutup Kasir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Transaksi hari ini belum dihitung (Mock)'), 
            const SizedBox(height: 8),
            Text('Sisa Saldo Sistem: Rp ${NumberFormat("#,##0", "id_ID").format(state.cashBalance)}'),
            const SizedBox(height: 16),
            TextField(
              controller: actualCashController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Hitung Uang Fisik', prefixText: 'Rp '),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              ref.read(cashierProvider.notifier).closeRegister();
              Navigator.pop(context);
               
              // Show summary logic could go here
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kasir Berhasil Ditutup.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.softRed),
            child: const Text('Tutup Kasir'),
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
              // Router usually handles redirect on auth state change, but to be safe:
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
