import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hompimpa_pos/core/services/print_service.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:hompimpa_pos/features/settings/data/settings_repository.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

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
      
      // Step 0: Check if Bluetooth is ON
      bool isPowerOn = await printService.isBluetoothEnabled();
      if (!isPowerOn) {
        if (mounted) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Bluetooth Mati', style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text('Harap nyalakan Bluetooth Anda terlebih dahulu untuk mencetak nota.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
        setState(() => _isPrinting = false);
        return;
      }

      // Step 1: Check Connection
      bool isConnected = await printService.isConnected();
      
      if (!isConnected) {
        // Step 2: Get Devices
        final devices = await printService.getBluetoothDevices();
        if (devices.isEmpty) {
          throw Exception('Tidak ada printer Bluetooth yang terpasang (paired).');
        }

        // Step 3: Show Picker
        final selectedDevice = await _showDevicePicker(devices);
        if (selectedDevice == null) {
          if (mounted) setState(() => _isPrinting = false);
          return; // User cancelled
        }

        // Step 4: Connect
        final success = await printService.connectToDevice(selectedDevice);
        if (!success) {
          throw Exception('Gagal menghubungkan ke printer ${selectedDevice.name}.');
        }
      }

      // Step 5: Get Settings & Print
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

  Future<BluetoothDevice?> _showDevicePicker(List<BluetoothDevice> devices) async {
    return showDialog<BluetoothDevice>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Printer Bluetooth', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: devices.length,
              itemBuilder: (BuildContext context, int index) {
                final device = devices[index];
                return ListTile(
                  leading: const Icon(Icons.print, color: Colors.blue),
                  title: Text(device.name ?? 'Unknown Device'),
                  subtitle: Text(device.address ?? ''),
                  onTap: () => Navigator.pop(context, device),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
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
