import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/services/print_service.dart'; // Adjust path as needed
import '../../domain/order.dart';
import '../../../settings/data/settings_repository.dart';

class NotaPreviewDialog extends ConsumerStatefulWidget {
  final OrderEntity order;

  const NotaPreviewDialog({Key? key, required this.order}) : super(key: key);

  @override
  ConsumerState<NotaPreviewDialog> createState() => _NotaPreviewDialogState();
}

class _NotaPreviewDialogState extends ConsumerState<NotaPreviewDialog> {
  bool _isPrinting = false;

  Future<void> _handlePrint() async {
    setState(() {
      _isPrinting = true;
    });

    try {
      final printService = ref.read(printServiceProvider);
      // Wait for settings if they are still loading, or get them from repository directly
      final settings = await ref.read(settingsRepositoryProvider).getNotaSettings();
      await printService.printOrder(widget.order, settings);
      
      if (mounted) {
        Navigator.pop(context); // Close dialog on success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Print berhasil dikirim'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final order = widget.order;
    final settingsAsync = ref.watch(notaSettingsProvider);

    return settingsAsync.when(
      data: (settings) => AlertDialog(
        title: const Text('Preview Nota', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 300,
          height: 500,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Center(child: Text(settings.storeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        if (settings.tagline.isNotEmpty)
                          Center(child: Text(settings.tagline, style: const TextStyle(fontSize: 12))),
                        const SizedBox(height: 8),
                        if (settings.address1.isNotEmpty)
                          Center(child: Text(settings.address1, style: const TextStyle(fontSize: 12))),
                        if (settings.address2.isNotEmpty)
                          Center(child: Text(settings.address2, style: const TextStyle(fontSize: 12))),
                        if (settings.phone.isNotEmpty)
                          Center(child: Text('WA : ${settings.phone}', style: const TextStyle(fontSize: 12))),
                        const Divider(thickness: 1, color: Colors.black),

                        // Info
                        _buildInfoRow('No Order:', order.id.substring(0, 8)),
                        _buildInfoRow('Tgl:', dateFormat.format(order.orderDate.toLocal())),
                        _buildInfoRow('Kasir:', order.executorName ?? "-"),
                        _buildInfoRow('Bayar:', order.paymentMethod),
                        const Divider(thickness: 1, color: Colors.black),

                        // Items
                        ...order.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.level != null ? '${item.productName} - Lvl ${item.level} (${item.sambal})' : item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${item.qty} x ${currencyFormat.format(item.price)}', style: const TextStyle(fontSize: 12)),
                                    Text(currencyFormat.format(item.qty * item.price), style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                                if (item.toppings != null && item.toppings!.isNotEmpty)
                                  ...item.toppings!.map((t) => Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('+ ${t.name}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        Text(currencyFormat.format(t.price), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                  )),
                              ],
                            ),
                          );
                        }).toList(),
                        
                        const Divider(thickness: 1, color: Colors.black),

                        // Summary
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Rp ${currencyFormat.format(order.total)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        
                        if (order.paidAmount != null && order.paidAmount! > 0) ...[
                          const SizedBox(height: 4),
                           Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Bayar', style: TextStyle(fontSize: 12)),
                              Text('Rp ${currencyFormat.format(order.paidAmount)}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Kembali', style: TextStyle(fontSize: 12)),
                              Text('Rp ${currencyFormat.format(order.changeAmount ?? 0)}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        const Divider(thickness: 1, color: Colors.black),
                        if (settings.footerMessage.isNotEmpty)
                          Center(child: Text(settings.footerMessage, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isPrinting ? null : () => Navigator.pop(context),
            child: const Text('BATAL', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            onPressed: _isPrinting ? null : _handlePrint,
            icon: _isPrinting 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.print),
            label: Text(_isPrinting ? 'Printing...' : 'PRINT', style: const TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
