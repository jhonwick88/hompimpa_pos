import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:hompimpa_pos/features/settings/domain/nota_settings.dart';

abstract class PrintService {
  Future<void> printOrder(OrderEntity order, NotaSettings settings);
}

final printServiceProvider = Provider<PrintService>((ref) {
  if (kIsWeb) {
    return WebPrintService();
  } else {
    // Ideally we might want to check Platform.isAndroid but kIsWeb is sufficient separater for now 
    // given the project context.
    return AndroidPrintService();
  }
});

class WebPrintService implements PrintService {
  @override
  Future<void> printOrder(OrderEntity order, NotaSettings settings) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll57, // 58mm width approx
        build: (pw.Context context) {
          return _buildPdfContent(order, settings);
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Nota-${order.id.substring(0, 8)}',
    );
  }

  pw.Widget _buildPdfContent(OrderEntity order, NotaSettings settings) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Center(child: pw.Text(settings.storeName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
        if (settings.tagline.isNotEmpty)
          pw.Center(child: pw.Text(settings.tagline, style: const pw.TextStyle(fontSize: 8))),
        pw.SizedBox(height: 4),
        if (settings.address1.isNotEmpty)
          pw.Center(child: pw.Text(settings.address1, style: const pw.TextStyle(fontSize: 8))),
        if (settings.address2.isNotEmpty)
          pw.Center(child: pw.Text(settings.address2, style: const pw.TextStyle(fontSize: 8))),
        if (settings.phone.isNotEmpty)
          pw.Center(child: pw.Text('WA : ${settings.phone}', style: const pw.TextStyle(fontSize: 8))),
        pw.Divider(thickness: 0.5),
        
        // Info
        pw.Text('No Order: ${order.id.substring(0, 8)}', style: const pw.TextStyle(fontSize: 8)),
        pw.Text('Tgl: ${dateFormat.format(order.orderDate.toLocal())}', style: const pw.TextStyle(fontSize: 8)),
        pw.Text('Kasir: ${order.executorName ?? "-"}', style: const pw.TextStyle(fontSize: 8)),
        pw.Text('Bayar: ${order.paymentMethod}', style: const pw.TextStyle(fontSize: 8)),
        pw.Divider(thickness: 0.5),

        // Items
        ...order.items.map((item) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(item.level != null ? '${item.productName} - Lvl ${item.level} (${item.sambal})' : item.productName, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${item.qty} x ${currencyFormat.format(item.price)}', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(currencyFormat.format(item.qty * item.price), style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              if (item.toppings != null && item.toppings!.isNotEmpty)
                ...item.toppings!.map((t) => pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('+ ${t.name}', style: const pw.TextStyle(fontSize: 7)),
                      pw.Text(currencyFormat.format(t.price), style: const pw.TextStyle(fontSize: 7)),
                    ],
                  ),
                )),
              pw.SizedBox(height: 2),
            ],
          );
        }).toList(),
        
        pw.Divider(thickness: 0.5),

        // Summary
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.Text('Rp ${currencyFormat.format(order.total)}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        
        if (order.paidAmount != null && order.paidAmount! > 0) ...[
          pw.SizedBox(height: 2),
           pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Bayar', style: const pw.TextStyle(fontSize: 8)),
              pw.Text('Rp ${currencyFormat.format(order.paidAmount)}', style: const pw.TextStyle(fontSize: 8)),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Kembali', style: const pw.TextStyle(fontSize: 8)),
              pw.Text('Rp ${currencyFormat.format(order.changeAmount ?? 0)}', style: const pw.TextStyle(fontSize: 8)),
            ],
          ),
        ],

        pw.SizedBox(height: 8),
        pw.Divider(thickness: 0.5),
        if (settings.footerMessage.isNotEmpty)
          pw.Center(child: pw.Text(settings.footerMessage, style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.center)),
      ],
    );
  }
}

class AndroidPrintService implements PrintService {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  @override
  Future<void> printOrder(OrderEntity order, NotaSettings settings) async {
    // 1. Check Permissions
    if (await Permission.bluetoothConnect.request().isGranted &&
        await Permission.bluetoothScan.request().isGranted && 
        await Permission.location.request().isGranted) {
          
      // 2. Check Connection
       bool? isConnected = await bluetooth.isConnected;
       if (isConnected != true) {
         // Verify if there are devices. 
         // Realistically we need a UI to select printer if not connected.
         // For now, let's assume auto-connect or error if not paired/connected?
         // As per requirement: "connectPrinter()" 
         // Simpler approach: fail if not connected, relying on external settings connection or implementing rudimentary picker if needed.
         // However, prompt implies "Android -> Connect via Bluetooth" which might need a picker.
         // For specific scope "Click Print -> Print", usually implies printing to *connected* printer.
         
         List<BluetoothDevice> devices = [];
         try {
           devices = await bluetooth.getBondedDevices();
         } catch (e) {
           throw Exception('Bluetooth error: $e');
         }

         if (devices.isEmpty) {
           throw Exception('Tidak ada printer paired. Silakan pasangkan printer di pengaturan Bluetooth.');
         }
         
         // Try connect to first available (naive approach for MVP as per prompt implicity)
         // Or throw error to let UI handle it?
         // Better: Attempt connect to first device if not connected.
         try {
           await bluetooth.connect(devices.first);
         } catch (e) {
           throw Exception('Gagal terkoneksi ke printer: ${devices.first.name}');
         }
       }

       // 3. Print
       if (await bluetooth.isConnected == true) {
          _printReceipt(order, settings);
       } else {
          throw Exception('Printer tidak terhubung.');
       }

    } else {
      throw Exception('Izin Bluetooth/Lokasi tidak diberikan.');
    }
  }

  void _printReceipt(OrderEntity order, NotaSettings settings) async {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Header
    bluetooth.printCustom(settings.storeName, 1, 1);
    if (settings.tagline.isNotEmpty)
      bluetooth.printCustom(settings.tagline, 0, 1);
    bluetooth.printNewLine();
    if (settings.address1.isNotEmpty)
      bluetooth.printCustom(settings.address1, 0, 1);
    if (settings.address2.isNotEmpty)
      bluetooth.printCustom(settings.address2, 0, 1);
    if (settings.phone.isNotEmpty)
      bluetooth.printCustom("WA : ${settings.phone}", 0, 1);
    bluetooth.printCustom("--------------------------------", 0, 1);

    // Info
    bluetooth.printLeftRight("No Order:", order.id.substring(0, 8), 0);
    bluetooth.printLeftRight("Tgl:", dateFormat.format(order.orderDate.toLocal()), 0);
    bluetooth.printLeftRight("Kasir:", order.executorName ?? "-", 0);
    bluetooth.printLeftRight("Bayar:", order.paymentMethod, 0);
    bluetooth.printCustom("--------------------------------", 0, 1);

    // Items
    for (var item in order.items) {
      bluetooth.printCustom(item.productName, 0, 0); // Left align
      String qtyPrice = "${item.qty} x ${currencyFormat.format(item.price)}";
      String subtotal = currencyFormat.format(item.qty * item.price);
      bluetooth.printLeftRight(qtyPrice, subtotal, 0);

      if (item.toppings != null) {
        for (var t in item.toppings!) {
           bluetooth.printLeftRight(" + ${t.name}", currencyFormat.format(t.price), 0);
        }
      }
    }
    bluetooth.printCustom("--------------------------------", 0, 1);

    // Summary
    bluetooth.printLeftRight("TOTAL", "Rp ${currencyFormat.format(order.total)}", 1);
    
    if (order.paidAmount != null && order.paidAmount! > 0) {
      bluetooth.printLeftRight("Bayar", "Rp ${currencyFormat.format(order.paidAmount)}", 0);
      bluetooth.printLeftRight("Kembali", "Rp ${currencyFormat.format(order.changeAmount ?? 0)}", 0);
    }
    
    bluetooth.printNewLine();
    bluetooth.printCustom("--------------------------------", 0, 1);
    if (settings.footerMessage.isNotEmpty)
      bluetooth.printCustom(settings.footerMessage, 0, 1);
    bluetooth.printNewLine();
    bluetooth.paperCut();
  }
}
