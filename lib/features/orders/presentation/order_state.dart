import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderMetadata {
  final String customerName;
  final String customerPhone;
  final String tableNumber;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String selectedVia;
  final bool isDineIn;
  final String selectedPayment;
  final bool cartExpanded;
  final bool isInitialized;

  OrderMetadata({
    this.customerName = '',
    this.customerPhone = '',
    this.tableNumber = '0',
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    this.selectedVia = 'Offline',
    this.isDineIn = false,
    this.selectedPayment = 'Cash',
    this.cartExpanded = false,
    this.isInitialized = false,
  })  : selectedDate = selectedDate ?? DateTime.now(),
        selectedTime = selectedTime ?? TimeOfDay.now();

  OrderMetadata copyWith({
    String? customerName,
    String? customerPhone,
    String? tableNumber,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    String? selectedVia,
    bool? isDineIn,
    String? selectedPayment,
    bool? cartExpanded,
    bool? isInitialized,
  }) {
    return OrderMetadata(
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      tableNumber: tableNumber ?? this.tableNumber,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedVia: selectedVia ?? this.selectedVia,
      isDineIn: isDineIn ?? this.isDineIn,
      selectedPayment: selectedPayment ?? this.selectedPayment,
      cartExpanded: cartExpanded ?? this.cartExpanded,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class OrderMetadataNotifier extends StateNotifier<OrderMetadata> {
  OrderMetadataNotifier() : super(OrderMetadata());

 
  void updateCustomerPhone(String phone) => state = state.copyWith(customerPhone: phone);
  void updateTableNumber(String table) => state = state.copyWith(tableNumber: table);
  void updateSelectedDate(DateTime date) => state = state.copyWith(selectedDate: date);
  void updateSelectedTime(TimeOfDay time) => state = state.copyWith(selectedTime: time);
  void updateSelectedVia(String via) {
    String name = state.customerName;
    // Remove existing prefixes if any
    String baseName = name.replaceAll(RegExp(r'^(Offline - |Grab - )'), '');
    
    String newName = name;
    if (via == 'Offline') {
      newName = 'Offline - $baseName';
    } else if (via == 'GrabFood') {
      newName = 'Grab - $baseName';
    } else {
      newName = baseName;
    }
    
    state = state.copyWith(selectedVia: via, customerName: newName);
  }
  void updateCustomerName(String name) => state = state.copyWith(customerName: name);
  void updateIsDineIn(bool isDineIn) => state = state.copyWith(isDineIn: isDineIn);
  void updateSelectedPayment(String payment) => state = state.copyWith(selectedPayment: payment);
  void updateCartExpanded(bool expanded) => state = state.copyWith(cartExpanded: expanded);
  
  void initialize({
    required String customerName,
    String? customerPhone,
    required DateTime selectedDate,
    required TimeOfDay selectedTime,
    required String selectedVia,
    required bool isDineIn,
    required String tableNumber,
    required String selectedPayment,
  }) {
    state = OrderMetadata(
      customerName: customerName,
      customerPhone: customerPhone ?? '',
      selectedDate: selectedDate,
      selectedTime: selectedTime,
      selectedVia: selectedVia,
      isDineIn: isDineIn,
      tableNumber: tableNumber,
      selectedPayment: selectedPayment,
      isInitialized: true,
    );
  }

  void reset() {
    state = OrderMetadata();
  }
}

final orderMetadataProvider = StateNotifierProvider<OrderMetadataNotifier, OrderMetadata>((ref) {
  return OrderMetadataNotifier();
});
