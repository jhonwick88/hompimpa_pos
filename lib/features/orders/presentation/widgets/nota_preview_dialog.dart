import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/services/print_service.dart'; // Adjust path as needed
import '../../domain/order.dart';

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
      await printService.printOrder(widget.order);
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

    // Approximating 58mm width look. standard phone width ~360dp. 58mm is ~220dp approx visually?
    // Let's us standard dialog width but pad content to look like a strip.
    
    return AlertDialog(
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
                      const Center(child: Text('HOMPIMPA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      const Center(child: Text('Spesialis Mie & Pangsit Level', style: TextStyle(fontSize: 12))),
                      const SizedBox(height: 8),
                      const Center(child: Text('Dsn Bulak 01/05 Ds Nglaban', style: TextStyle(fontSize: 12))),
                      const Center(child: Text('Kec. Loceret Kab. Nganjuk', style: TextStyle(fontSize: 12))),
                      const Center(child: Text('WA : 085934345756', style: TextStyle(fontSize: 12))),
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
                              Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                      const Center(child: Text('Terima kasih', style: TextStyle(fontSize: 12))),
                      const Center(child: Text('Hompimpa', style: TextStyle(fontSize: 12))),
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
          child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton.icon(
          onPressed: _isPrinting ? null : _handlePrint,
          icon: _isPrinting 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.print),
          label: Text(_isPrinting ? 'Printing...' : 'PRINT'),
          style: ElevatedButton.styleFrom(primary: Colors.blue[800]),
        ),
      ],
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
