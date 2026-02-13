import 'package:flutter_riverpod/flutter_riverpod.dart';

class CashierState {
  final bool isOpen;
  final double cashBalance;
  final DateTime? shiftStart;
  final String shiftName;

  CashierState({
    this.isOpen = false,
    this.cashBalance = 0.0,
    this.shiftStart,
    this.shiftName = '',
  });

  CashierState copyWith({
    bool? isOpen,
    double? cashBalance,
    DateTime? shiftStart,
    String? shiftName,
  }) {
    return CashierState(
      isOpen: isOpen ?? this.isOpen,
      cashBalance: cashBalance ?? this.cashBalance,
      shiftStart: shiftStart ?? this.shiftStart,
      shiftName: shiftName ?? this.shiftName,
    );
  }
}

class CashierController extends StateNotifier<CashierState> {
  CashierController() : super(CashierState(shiftName: _determineShift()));

  static String _determineShift() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 14) return 'Shift Pagi (06.00-14.00)';
    if (hour >= 14 && hour < 22) return 'Shift Siang (14.00-22.00)';
    return 'Shift Malam (22.00-06.00)';
  }

  void openRegister(double initialCash) {
    state = state.copyWith(
      isOpen: true,
      cashBalance: initialCash,
      shiftStart: DateTime.now(),
      shiftName: _determineShift(),
    );
  }

  void closeRegister() {
    state = state.copyWith(
      isOpen: false,
      cashBalance: 0,
      shiftStart: null,
    );
  }

  void reduceCash(double amount, String reason) {
    if (state.cashBalance >= amount) {
      state = state.copyWith(cashBalance: state.cashBalance - amount);
      // Here you would typically log the transaction to backend
      print('DEBUG: Reduced cash by $amount for $reason. New balance: ${state.cashBalance}');
    } else {
      throw Exception('Saldo kas tidak cukup!');
    }
  }
}

final cashierProvider = StateNotifierProvider<CashierController, CashierState>((ref) {
  return CashierController();
});
