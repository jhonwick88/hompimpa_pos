import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import './public_cart_provider.dart';
import '../../orders/data/order_repository.dart';
import '../../../core/widgets/gradient_app_bar.dart';

class PublicCartScreen extends ConsumerStatefulWidget {
  const PublicCartScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PublicCartScreen> createState() => _PublicCartScreenState();
}

class _PublicCartScreenState extends ConsumerState<PublicCartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _tableController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    // Initialize with current value from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tableController.text = ref.read(publicCartProvider).tableNumber ?? '1';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _tableController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      await ref.read(publicCartProvider.notifier).submitOrder(
        repository: ref.read(orderRepositoryProvider),
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        tableNumber: _tableController.text.trim(),
      );
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pesanan Terkirim!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 10),
              Text(
                'Pesanan Anda sedang dalam peninjauan admin. Silakan tunggu sebentar atau hubungi kasir.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/menu');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('KEMBALI KE MENU'),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengirim pesanan: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(publicCartProvider);
    final total = ref.watch(publicCartTotalProvider);

    if (cartState.items.isEmpty) {
      return Scaffold(
        appBar: GradientAppBar(title: const Text('Keranjang')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text('Keranjang Anda kosong', style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/menu'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('LIHAT MENU'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: GradientAppBar(title: const Text('Konfirmasi Pesanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Item Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartState.items.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return ListTile(
                        title: Text(
                          item.level != null 
                            ? '${item.productName} - Lvl ${item.level} (${item.sambal})' 
                            : item.productName, 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        subtitle: Text(
                          item.toppings != null && item.toppings!.isNotEmpty
                              ? '${item.toppings!.map((t) => t.name).join(", ")}\nRp ${item.price.toStringAsFixed(0)}'
                              : 'Rp ${item.price.toStringAsFixed(0)}',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => ref.read(publicCartProvider.notifier).updateQty(index, -1),
                            ),
                            Text('${item.qty}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () => ref.read(publicCartProvider.notifier).updateQty(index, 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildTotalSection(total),
                const SizedBox(height: 24),
                const Text('Data Pelanggan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildForm(),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'SUBMIT PESANAN (Rp ${total.toStringAsFixed(0)})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSection(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Harga', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(
            'Rp ${total.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          children: [
             TextFormField(
               controller: _nameController,
               decoration: const InputDecoration(
                 labelText: 'Nama Pelanggan*',
                 prefixIcon: Icon(Icons.person),
                 border: OutlineInputBorder(),
               ),
               validator: (val) => val == null || val.isEmpty ? 'Nama wajib diisi' : null,
             ),
             const SizedBox(height: 16),
             TextFormField(
               controller: _phoneController,
               keyboardType: TextInputType.phone,
               decoration: const InputDecoration(
                 labelText: 'Nomor WhatsApp*',
                 prefixIcon: Icon(Icons.phone),
                 border: OutlineInputBorder(),
               ),
               validator: (val) => val == null || val.isEmpty ? 'Nomor WA wajib diisi' : null,
             ),
             const SizedBox(height: 16),
             TextFormField(
               controller: _tableController,
               keyboardType: TextInputType.number,
               decoration: const InputDecoration(
                 labelText: 'Nomor Meja',
                 prefixIcon: Icon(Icons.table_restaurant),
                 border: OutlineInputBorder(),
               ),
             ),
          ],
        ),
      ),
    ),
  );
}
}

extension on Card {
  Widget padding(EdgeInsets geometry) => Padding(padding: geometry, child: this);
}
