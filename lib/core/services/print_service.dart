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
  Future<List<BluetoothDevice>> getBluetoothDevices();
  Future<bool> isConnected();
  Future<bool> isBluetoothEnabled();
  Future<bool> connectToDevice(BluetoothDevice device);
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
        pageFormat: PdfPageFormat.roll80,
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
        pw.Center(child: pw.Text(settings.storeName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14))),
        if (settings.tagline.isNotEmpty)
          pw.Center(child: pw.Text(settings.tagline, style: const pw.TextStyle(fontSize: 10))),
        pw.SizedBox(height: 4),
        if (settings.address1.isNotEmpty)
          pw.Center(child: pw.Text(settings.address1, style: const pw.TextStyle(fontSize: 10))),
        if (settings.address2.isNotEmpty)
          pw.Center(child: pw.Text(settings.address2, style: const pw.TextStyle(fontSize: 10))),
        if (settings.phone.isNotEmpty)
          pw.Center(child: pw.Text('WA : ${settings.phone}', style: const pw.TextStyle(fontSize: 10))),
        pw.Divider(thickness: 1.0),
        
        // Info
        pw.Text('No Order: ${order.id.substring(0, 8)}', style: const pw.TextStyle(fontSize: 10)),
        pw.Text('Tgl: ${dateFormat.format(order.orderDate.toLocal())}', style: const pw.TextStyle(fontSize: 10)),
        pw.Text('Kasir: ${order.executorName ?? "-"}', style: const pw.TextStyle(fontSize: 10)),
        pw.Text('Bayar: ${order.paymentMethod}', style: const pw.TextStyle(fontSize: 10)),
        pw.Divider(thickness: 1.0),

        // Items
        ...order.items.map((item) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(item.level != null ? '${item.productName} - Lvl ${item.level} (${item.sambal})' : item.productName, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${item.qty} x ${currencyFormat.format(item.price)}', style: pw.TextStyle(fontSize: 10, decoration: item.productName.contains('(Gratis)') ? pw.TextDecoration.lineThrough : null)),
                  pw.Text(currencyFormat.format(item.qty * item.price), style: pw.TextStyle(fontSize: 10, decoration: item.productName.contains('(Gratis)') ? pw.TextDecoration.lineThrough : null)),
                ],
              ),
              if (item.toppings != null && item.toppings!.isNotEmpty)
                ...item.toppings!.map((t) => pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('+ ${t.name}', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text(currencyFormat.format(t.price), style: pw.TextStyle(fontSize: 9, decoration: t.name.contains('(Gratis)') ? pw.TextDecoration.lineThrough : null)),
                    ],
                  ),
                )),
              pw.SizedBox(height: 2),
            ],
          );
        }).toList(),
        
        pw.Divider(thickness: 1.0),

        // Summary
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text('Rp ${currencyFormat.format(order.total)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        
        if (order.paidAmount != null && order.paidAmount! > 0) ...[
          pw.SizedBox(height: 2),
           pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Bayar', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Rp ${currencyFormat.format(order.paidAmount)}', style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Kembali', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Rp ${currencyFormat.format(order.changeAmount ?? 0)}', style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
        ],

        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1.0),
        if (settings.footerMessage.isNotEmpty)
          pw.Center(child: pw.Text(settings.footerMessage, style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center)),
      ],
    );
  }

  @override
  Future<List<BluetoothDevice>> getBluetoothDevices() async => [];

  @override
  Future<bool> isConnected() async => true; // Web printing is always ready

  @override
  Future<bool> isBluetoothEnabled() async => true;

  @override
  Future<bool> connectToDevice(BluetoothDevice device) async => true;
}

class AndroidPrintService implements PrintService {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  @override
  Future<List<BluetoothDevice>> getBluetoothDevices() async {
    if (await Permission.bluetoothConnect.request().isGranted &&
        await Permission.bluetoothScan.request().isGranted && 
        await Permission.location.request().isGranted) {
      return await bluetooth.getBondedDevices();
    }
    return [];
  }

  @override
  Future<bool> isConnected() async {
    return await bluetooth.isConnected ?? false;
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    return await bluetooth.isOn ?? false;
  }

  @override
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await bluetooth.connect(device);
      return true;
    } catch (e) {
      debugPrint('Error connecting to Bluetooth: $e');
      return false;
    }
  }
  String formatLeftRight(String left, String right, {int width = 46}) {
    if (left.length + right.length >= width) {
      // kalau kepanjangan, potong kiri
      left = left.substring(0, width - right.length - 1);
    }

    int space = width - (left.length + right.length);
    return left + (' ' * space) + right;
  }

  @override
  Future<void> printOrder(OrderEntity order, NotaSettings settings) async {
    if (await bluetooth.isConnected != true) {
      throw Exception('Printer tidak terhubung. Silakan pilih printer terlebih dahulu.');
    }
    _printReceipt(order, settings);
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
    bluetooth.printCustom("------------------------------------------------", 0, 1);

    // Info
    bluetooth.printCustom(formatLeftRight("No Order:", order.id.substring(0, 8)), 0, 0);
    bluetooth.printCustom(formatLeftRight("Tgl:", dateFormat.format(order.orderDate.toLocal())), 0, 0);
    bluetooth.printCustom(formatLeftRight("Kasir:", order.executorName ?? "-"), 0, 0);
    bluetooth.printCustom(formatLeftRight("Bayar:", order.paymentMethod), 0, 0);
    bluetooth.printCustom("------------------------------------------------", 0, 1);

    // Items
    for (var item in order.items) {
      bluetooth.printCustom(item.productName, 0, 0); // Left align
      String qtyPrice = "${item.qty} x ${currencyFormat.format(item.price)}";
      String subtotal = currencyFormat.format(item.qty * item.price);
      
      // Strikethrough simulation for free items
      if (item.productName.contains('(Gratis)')) {
        subtotal = "~~$subtotal~~";
      }
      
      bluetooth.printCustom(formatLeftRight(qtyPrice, subtotal), 0, 0);

      if (item.toppings != null) {
        for (var t in item.toppings!) {
           String toppingPrice = currencyFormat.format(t.price);
           if (t.name.contains('(Gratis)')) {
             toppingPrice = "~~$toppingPrice~~";
           }
           bluetooth.printCustom(formatLeftRight(" + ${t.name}", toppingPrice), 0, 0);
        }
      }
    }
    bluetooth.printCustom("------------------------------------------------", 0, 1);

    // Summary
    bluetooth.printCustom(formatLeftRight("TOTAL", "Rp ${currencyFormat.format(order.total)}"), 1, 0);
    
    if (order.paidAmount != null && order.paidAmount! > 0) {
      bluetooth.printCustom(formatLeftRight("Bayar", "Rp ${currencyFormat.format(order.paidAmount)}"), 0, 0);
      bluetooth.printCustom(formatLeftRight("Kembali", "Rp ${currencyFormat.format(order.changeAmount ?? 0)}"), 0, 0);
    }
    
    bluetooth.printNewLine();
    bluetooth.printCustom("------------------------------------------------", 0, 1);
    if (settings.footerMessage.isNotEmpty)
      bluetooth.printCustom(settings.footerMessage, 0, 1);
    bluetooth.printNewLine();
    bluetooth.paperCut();
  }
}
