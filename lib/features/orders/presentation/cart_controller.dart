import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/order.dart';
import '../domain/order_item.dart';
import '../data/order_repository.dart';
import '../../products/domain/product.dart';

final cartProvider = StateNotifierProvider<CartController, List<OrderItem>>((ref) {
  return CartController();
});

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + (item.price * item.qty));
});

class CartController extends StateNotifier<List<OrderItem>> {
  CartController() : super([]);

  void addItem(Product product, int qty, {String? level, String? sambal, String? note}) {
    final existingIndex = state.indexWhere((item) => 
      item.productId == product.id && 
      item.level == level && 
      item.sambal == sambal && 
      item.note == note
    );

    if (existingIndex != -1) {
      final existingItem = state[existingIndex];
      final updatedItem = existingItem.copyWith(qty: existingItem.qty + qty);
      final newState = List<OrderItem>.from(state);
      newState[existingIndex] = updatedItem;
      state = newState;
    } else {
      final item = OrderItem(
        productId: product.id,
        productName: product.name,
        qty: qty,
        price: product.price,
        level: level,
        sambal: sambal,
        note: note,
      );
      state = [...state, item];
    }
  }

  void removeItem(OrderItem item) {
    state = state.where((i) => i != item).toList();
  }

  void clearCart() {
    state = [];
  }

  Future<void> submitOrder(
    OrderRepository repository, 
    String customerName, {
    String? customerPhone, 
    bool isQuickOrder = false,
    required DateTime pickupDate,
    required String pickupTime,
  }) async {
    if (state.isEmpty) return;
    
    final total = state.fold<double>(0.0, (sum, item) => sum + (item.price * item.qty));
    final now = DateTime.now();

    // Quick Order Logic Prefix
    String finalCustomerName = customerName;
    if (isQuickOrder) {
       finalCustomerName = "Offline Order - ${const Uuid().v4().substring(0, 4)}";
    }

    final order = OrderEntity(
      id: const Uuid().v4(),
      customerName: finalCustomerName,
      customerPhone: customerPhone,
      total: total,
      orderDate: pickupDate,
      orderTime: pickupTime,
      status: OrderStatus.belum,
      items: state,
      createdAt: now,
      updatedAt: now,
    );

    await repository.addOrder(order);
    clearCart();
  }
}
