import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/order.dart';
import '../domain/order_item.dart';
import '../data/order_repository.dart';
import '../../products/domain/product.dart';
import '../../products/domain/topping.dart';
import '../../products/data/topping_repository.dart';
import '../../cashier/presentation/cashier_controller.dart';
import 'package:collection/collection.dart';

// wrapper class for state
class CartState {
  final List<OrderItem> items;
  CartState({this.items = const []});
  
  CartState copyWith({List<OrderItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

// Provider definition
final cartProvider = NotifierProvider<CartController, CartState>(CartController.new);

final cartTotalProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartProvider); // it returns CartState now
  return cartState.items.fold(0, (sum, item) => sum + (item.price * item.qty));
});

class CartController extends Notifier<CartState> {
  @override
  CartState build() {
    return CartState();
  }

  void addItem(Product product, int qty, {String? level, String? sambal, String? note, List<Topping>? toppings}) {
    final currentItems = state.items;
    final existingIndex = currentItems.indexWhere((item) {
      final bool toppingsMatch = const DeepCollectionEquality.unordered().equals(item.toppings, toppings);
      return item.productId == product.id && 
             item.level == level && 
             item.sambal == sambal && 
             item.note == note &&
             toppingsMatch;
    });

    // Calculate Unit Price including toppings
    double unitPrice = product.price;
    if (toppings != null) {
      for (var t in toppings) {
        unitPrice += t.price;
      }
    }
    // Spicy Level Charge
    if (level != null) {
       final levelVal = int.tryParse(level) ?? 0;
       
       if (levelVal >= 4) {
         final isMiePangsit = product.category.toLowerCase().contains('mie') || 
                              product.name.toLowerCase().contains('mie') ||
                              product.category.toLowerCase().contains('pangsit') ||
                              product.name.toLowerCase().contains('pangsit');
         
         if (isMiePangsit) {
           if (levelVal >= 6) {
             unitPrice += 1000;
           } else {
             unitPrice += 500;
           }
         }
       }
    }

    // Check total stock
    final totalQtyInCart = currentItems.where((i) => i.productId == product.id).fold<int>(0, (sum, i) => sum + i.qty);
    
    if (totalQtyInCart + qty > product.stock) {
      throw Exception('Stok tidak cukup! (Total di keranjang: $totalQtyInCart, Stok: ${product.stock})');
    }

    if (existingIndex != -1) {
      final existingItem = currentItems[existingIndex];
      final updatedItem = existingItem.copyWith(qty: existingItem.qty + qty);
      final newItems = List<OrderItem>.from(currentItems);
      newItems[existingIndex] = updatedItem;
      state = state.copyWith(items: newItems);
    } else {
      final item = OrderItem(
        productId: product.id,
        productName: product.name,
        qty: qty,
        price: unitPrice,
        level: level,
        sambal: sambal,
        note: note,
        toppings: toppings,
      );
      state = state.copyWith(items: [...currentItems, item]);
    }
  }

  void removeItem(OrderItem item) {
    state = state.copyWith(items: state.items.where((i) => i != item).toList());
  }

  void clearCart() {
    state = CartState(items: []);
  }

  void setCartItems(List<OrderItem> items) {
    state = CartState(items: List<OrderItem>.from(items));
  }

  Future<void> submitOrder(
    OrderRepository repository,
    ToppingRepository toppingRepository, 
    String customerName, {
    String? customerPhone, 
    bool isQuickOrder = false,
    required DateTime pickupDate,
    required String pickupTime,
  }) async {
    if (state.items.isEmpty) return;
    
    final total = state.items.fold<double>(0.0, (sum, item) => sum + (item.price * item.qty));
    final now = DateTime.now();

    String finalCustomerName = customerName;
    if (isQuickOrder && finalCustomerName.isEmpty) {
       finalCustomerName = "Offline Order - ${const Uuid().v4().substring(0, 4)}";
    }

    final cashierState = ref.read(cashierProvider);
    final String? shiftId = cashierState.isOpen ? cashierState.activeShift?.id : null;

    final order = OrderEntity(
      id: const Uuid().v4(),
      customerName: finalCustomerName,
      customerPhone: customerPhone,
      total: total,
      orderDate: pickupDate,
      orderTime: pickupTime,
      status: OrderStatus.belum,
      items: state.items,
      createdAt: now,
      updatedAt: now,
      shiftId: shiftId,
    );

    await repository.addOrder(order);
    
    // Reduce Stock
    for (var item in state.items) {
      if (item.toppings != null) {
        for (var topping in item.toppings!) {
          try {
             await toppingRepository.reduceStock(topping.id, item.qty);
          } catch (e) {
             print("Error reducing stock for ${topping.name}: $e");
          }
        }
      }
    }

    clearCart();
  }

  Future<void> updateOrder(
    OrderRepository repository,
    ToppingRepository toppingRepository, 
    OrderEntity existingOrder,
    String customerName, {
    String? customerPhone,
    required DateTime pickupDate,
    required String pickupTime,
  }) async {
    if (state.items.isEmpty) return;

    final total = state.items.fold<double>(0.0, (sum, item) => sum + (item.price * item.qty));
    final now = DateTime.now();

    final updatedOrder = existingOrder.copyWith(
      customerName: customerName,
      customerPhone: customerPhone,
      total: total,
      orderDate: pickupDate,
      orderTime: pickupTime,
      items: state.items,
      updatedAt: now,
    );

    await repository.updateOrder(updatedOrder);
    
    clearCart();
  }
}
