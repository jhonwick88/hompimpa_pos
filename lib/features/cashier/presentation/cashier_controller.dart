import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/cashier/data/cashier_repository.dart';
import 'package:hompimpa_pos/features/cashier/domain/shift.dart';
import 'package:hompimpa_pos/features/cashier/domain/cash_out.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:uuid/uuid.dart';

class CashierState {
  final bool isOpen;
  final double cashBalance;
  final ShiftEntity? activeShift;
  final bool isLoading;
  final String? error;

  CashierState({
    this.isOpen = false,
    this.cashBalance = 0.0,
    this.activeShift,
    this.isLoading = false,
    this.error,
  });

  CashierState copyWith({
    bool? isOpen,
    double? cashBalance,
    ShiftEntity? activeShift,
    bool? isLoading,
    String? error,
  }) {
    return CashierState(
      isOpen: isOpen ?? this.isOpen,
      cashBalance: cashBalance ?? this.cashBalance,
      activeShift: activeShift ?? this.activeShift,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CashierController extends Notifier<CashierState> {
  // Dependencies are accessed via ref
  CashierRepository get _repository => ref.read(cashierRepositoryProvider);
  OrderRepository get _orderRepository => ref.read(orderRepositoryProvider);

  StreamSubscription<ShiftEntity?>? _shiftSubscription;

  @override
  CashierState build() {
    _initShiftListener();
    return CashierState(isLoading: true); 
  }

  void _initShiftListener() {
    _shiftSubscription?.cancel();
    _shiftSubscription = _repository.watchCurrentActiveShift().listen((shift) {
      if (shift != null) {
        state = state.copyWith(
          isOpen: true,
          activeShift: shift,
          cashBalance: shift.startCash, // This might need to be recalculated with cash outs/sales if persistent
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isOpen: false, 
          activeShift: null, 
          cashBalance: 0,
          isLoading: false
        );
      }
    }, onError: (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    });
    
    ref.onDispose(() {
      _shiftSubscription?.cancel();
    });
  }

  static String _determineShift() {
    final hour = DateTime.now().hour;
    if (hour >= 9 && hour < 17) return 'Shift Pagi (09.00-17.00)';
    if (hour >= 17 && hour < 20) return 'Shift Siang (17.00-20.00)';
    return 'Shift Malam (20.00-00.00)';
  }

  Future<void> openRegister(double initialCash) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newShift = ShiftEntity(
        id: const Uuid().v4(),
        shiftName: _determineShift(),
        startTime: DateTime.now(),
        startCash: initialCash,
        status: 'OPEN',
      );

      await _repository.createShift(newShift);

      state = state.copyWith(
        isOpen: true,
        cashBalance: initialCash,
        activeShift: newShift,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Map<String, double>> calculateShiftSummary() async {
    if (state.activeShift == null) return {};

    final shiftId = state.activeShift!.id;
    final startTime = state.activeShift!.startTime;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    // Fetch all orders for today (incorporating all shifts: morning, afternoon, night)
    final orders = await _orderRepository.getOrdersByTimeRange(startOfDay, now);
    final cashOuts = await _repository.getCashOutsForShift(shiftId);

    double totalCashSales = 0;
    double totalNonCashSales = 0;

    for (var order in orders) {
      if (order.status == OrderStatus.selesai) { // Only count finished orders
        // Use logic to determine payment method if available, defaulting to Cash for now if not specified
        // Assuming 'isCash' or similar exists, otherwise treat all as cash or split logic
        // For now, let's assume all are cash unless specified otherwise (needs payment method field in Order)
        // Since we don't have PaymentMethod enum strictly defined in OrderEntity here, 
        // we might stick to simple logic:
        totalCashSales += order.total;
      }
    }

    double totalCashOut = cashOuts.fold(0, (sum, item) => sum + item.amount);
    
    // Expected Cash = Start Cash + Cash Sales - Cash Outs
    // Note: Non-cash sales (QRIS, Transfer) should NOT add to expected physical cash
    
    /* 
       TODO: Filter orders by Payment Method once available in OrderEntity
       For now assuming ALL orders are CASH.
    */
    
    final startCash = state.activeShift!.startCash;
    final expectedCash = startCash + totalCashSales - totalCashOut;

    return {
      'startCash': startCash,
      'totalCashSales': totalCashSales,
      'totalNonCashSales': totalNonCashSales,
      'totalCashOut': totalCashOut,
      'expectedCash': expectedCash,
    };
  }

  Future<void> closeRegister(double endCash, Map<String, double> summary) async {
    if (state.activeShift == null) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final expectedCash = summary['expectedCash'] ?? 0;
      final difference = endCash - expectedCash;

      final updatedShift = state.activeShift!.copyWith(
        endTime: DateTime.now(),
        endCash: endCash,
        expectedCash: expectedCash,
        difference: difference,
        status: 'CLOSED',
        totalCashSales: summary['totalCashSales'],
        totalNonCashSales: summary['totalNonCashSales'],
        totalCashOut: summary['totalCashOut'],
      );

      await _repository.closeShift(updatedShift);

      state = state.copyWith(
        isOpen: false,
        activeShift: null,
        cashBalance: 0,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> reduceCash(double amount, String reason) async {
    if (state.activeShift == null) throw Exception('Tidak ada shift aktif');
    
    // Optimistic balance check (approximate, since we don't stream real-time sales balance yet)
    // For strict control, we'd need to calculate current balance first.
    // For now, allow it, but maybe warn? Or just process it.
    
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cashOut = CashOutEntity(
        id: const Uuid().v4(),
        shiftId: state.activeShift!.id,
        amount: amount,
        reason: reason,
        timestamp: DateTime.now(),
      );

      await _repository.addCashOut(cashOut);
      
      // Update local state if we were tracking balance
      state = state.copyWith(
        isLoading: false,
        cashBalance: state.cashBalance - amount, 
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final cashierProvider = NotifierProvider<CashierController, CashierState>(CashierController.new);
