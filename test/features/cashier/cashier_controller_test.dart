import 'package:flutter_test/flutter_test.dart';
import 'package:hompimpa_pos/features/cashier/presentation/cashier_controller.dart';
import 'package:hompimpa_pos/features/cashier/data/cashier_repository.dart';
import 'package:hompimpa_pos/features/orders/data/order_repository.dart';
import 'package:hompimpa_pos/features/cashier/domain/shift.dart';
import 'package:hompimpa_pos/features/cashier/domain/cash_out.dart';
import 'package:hompimpa_pos/features/orders/domain/order.dart';
import 'package:hompimpa_pos/features/orders/domain/order_item.dart';

// Manual Mocks
class MockCashierRepository implements CashierRepository {
  ShiftEntity? activeShift;
  List<CashOutEntity> cashOuts = [];
  bool createCalled = false;
  bool closeCalled = false;

  @override
  Future<ShiftEntity?> getCurrentActiveShift() async => activeShift;

  @override
  Future<void> createShift(ShiftEntity shift) async {
    activeShift = shift;
    createCalled = true;
  }

  @override
  Future<void> closeShift(ShiftEntity shift) async {
    activeShift = null; // Closed
    closeCalled = true;
  }

  @override
  Future<void> addCashOut(CashOutEntity cashOut) async {
    cashOuts.add(cashOut);
  }

  @override
  Future<List<CashOutEntity>> getCashOutsForShift(String shiftId) async {
    return cashOuts.where((c) => c.shiftId == shiftId).toList();
  }
}

class MockOrderRepository implements OrderRepository {
  List<OrderEntity> orders = [];

  @override
  Future<void> addOrder(OrderEntity order) async => orders.add(order);

  @override
  Future<void> updateOrder(OrderEntity order) async {} // No-op

  @override
  Stream<List<OrderEntity>> getOrdersStream({DateTime? date, OrderStatus? status, String? searchQuery}) {
    return Stream.value([]);
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus, List<OrderItem> items, {String? executorName, String? executorId}) async {}

  @override
  Future<void> updateOrderItems(String orderId, List<OrderItem> items) async {}

  @override
  Future<void> deleteOrder(String orderId) async {}

  @override
  Future<void> voidOrder(String orderId, String reason, String voidBy) async {}

  @override
  Future<void> bulkDeleteOrders(List<String> orderIds) async {}

  @override
  Future<OrderEntity?> getOrder(String orderId) async => null;

  @override
  Future<List<OrderEntity>> getOrdersForShift(String shiftId) async {
    return orders.where((o) => o.shiftId == shiftId).toList();
  }
}

void main() {
  late CashierController controller;
  late MockCashierRepository mockCashierRepo;
  late MockOrderRepository mockOrderRepo;

  setUp(() {
    mockCashierRepo = MockCashierRepository();
    mockOrderRepo = MockOrderRepository();
    controller = CashierController(mockCashierRepo, mockOrderRepo);
  });

  group('CashierController Logic', () {
    test('openRegister creates a new shift', () async {
      await controller.openRegister(50000);
      
      expect(mockCashierRepo.createCalled, true);
      expect(controller.state.isOpen, true);
      expect(controller.state.activeShift?.startCash, 50000);
    });

    test('reduceCash adds a cash out record', () async {
      await controller.openRegister(50000);
      await controller.reduceCash(10000, 'Test Reason');

      expect(mockCashierRepo.cashOuts.length, 1);
      expect(mockCashierRepo.cashOuts.first.amount, 10000);
      expect(mockCashierRepo.cashOuts.first.reason, 'Test Reason');
    });

    test('calculateShiftSummary calculates correctly', () async {
      // 1. Open Shift
      await controller.openRegister(50000);
      final shiftId = controller.state.activeShift!.id;

      // 2. Add Cash Out
      await controller.reduceCash(5000, 'Buy Ice');

      // 3. Add Orders (Mocking DB)
      // Cash Order
      mockOrderRepo.orders.add(OrderEntity(
        id: '1',
        total: 20000,
        orderDate: DateTime.now(),
        orderTime: '10:00',
        items: [],
        status: OrderStatus.selesai,
        paymentMethod: 'Cash',
        shiftId: shiftId,
      ));
      
      // Non-Cash Order
      mockOrderRepo.orders.add(OrderEntity(
        id: '2',
        total: 15000,
        orderDate: DateTime.now(),
        orderTime: '10:30',
        items: [],
        status: OrderStatus.selesai,
        paymentMethod: 'QRIS',
        shiftId: shiftId,
      ));

      // Incomplete Order (Should be ignored)
      mockOrderRepo.orders.add(OrderEntity(
        id: '3',
        total: 100000,
        orderDate: DateTime.now(),
        orderTime: '11:00',
        items: [],
        status: OrderStatus.proses,
        paymentMethod: 'Cash',
        shiftId: shiftId,
      ));

      // 4. Calculate
      final summary = await controller.calculateShiftSummary();

      // Start: 50,000
      // Cash Sales: 20,000
      // Non-Cash Sales: 15,000
      // Cash Out: 5,000
      // Expected Cash: 50,000 + 20,000 - 5,000 = 65,000

      expect(summary['startCash'], 50000);
      expect(summary['totalCashSales'], 20000);
      expect(summary['totalNonCashSales'], 15000);
      expect(summary['totalCashOut'], 5000);
      expect(summary['expectedCash'], 65000);
    });

    test('closeRegister updates shift status and totals', () async {
      await controller.openRegister(50000);
      final summary = {
        'startCash': 50000.0,
        'totalCashSales': 20000.0,
        'totalNonCashSales': 15000.0,
        'totalCashOut': 5000.0,
        'expectedCash': 65000.0,
      };

      await controller.closeRegister(65000, summary); // Match expectation

      expect(mockCashierRepo.closeCalled, true);
      expect(controller.state.isOpen, false);
    });
  });
}
