import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../orders/domain/order.dart';
import '../../orders/domain/order_item.dart';
import '../../orders/data/order_repository.dart';
import '../../products/domain/product.dart';
import '../../products/domain/topping.dart';
import '../../settings/domain/sambal_settings.dart';
import 'package:collection/collection.dart';

class PublicCartState {
  final List<OrderItem> items;
  final String tableNumber;
  PublicCartState({this.items = const [], this.tableNumber = '1'});
  
  PublicCartState copyWith({List<OrderItem>? items, String? tableNumber}) {
    return PublicCartState(
      items: items ?? this.items,
      tableNumber: tableNumber ?? this.tableNumber,
    );
  }
}

class PublicCartNotifier extends StateNotifier<PublicCartState> {
  PublicCartNotifier() : super(PublicCartState());

  void updateTableNumber(String tableNumber) {
    state = state.copyWith(tableNumber: tableNumber);
  }

  void addItem(Product product, int qty, {String? level, String? sambal, String? note, List<Topping>? toppings, SambalSettings settings = const SambalSettings()}) {
    final currentItems = state.items;
    final existingIndex = currentItems.indexWhere((item) {
      final bool toppingsMatch = const DeepCollectionEquality.unordered().equals(item.toppings, toppings);
      return item.productId == product.id && 
             item.level == level && 
             item.sambal == sambal && 
             item.note == note &&
             toppingsMatch;
    });

    double unitPrice = product.price;
    
    // Default Pangsit charge for Mie
    final isMie = product.category.toLowerCase().contains('mie') || product.name.toLowerCase().contains('mie');
    if (isMie) {
      unitPrice += 1500;
    }

    if (toppings != null) {
      for (var t in toppings) {
        unitPrice += t.price;
      }
    }

    if (level != null) {
       final levelVal = double.tryParse(level) ?? 0;
       final isLevelable = isMie || product.category.toLowerCase().contains('pangsit') || product.name.toLowerCase().contains('pangsit');
       
       if (isLevelable) {
         if (levelVal >= 6) {
           unitPrice += settings.level6to7Price;
         } else if (levelVal >= 4) {
           unitPrice += settings.level4to5Price;
         } else {
           unitPrice += settings.level0to3Price;
         }
       }
    }

    if (existingIndex != -1) {
      final existingItem = currentItems[existingIndex];
      final newItems = List<OrderItem>.from(currentItems);
      newItems[existingIndex] = existingItem.copyWith(qty: existingItem.qty + qty);
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

  void updateQty(int index, int delta) {
    if (index < 0 || index >= state.items.length) return;
    final item = state.items[index];
    final newQty = item.qty + delta;
    if (newQty <= 0) {
      state = state.copyWith(items: state.items.whereIndexed((i, _) => i != index).toList());
    } else {
      final newItems = List<OrderItem>.from(state.items);
      newItems[index] = item.copyWith(qty: newQty);
      state = state.copyWith(items: newItems);
    }
  }

  void clear() {
    state = PublicCartState();
  }

  Future<void> submitOrder({
    required OrderRepository repository,
    required String customerName,
    required String customerPhone,
    required String tableNumber,
  }) async {
    if (state.items.isEmpty) return;
    
    final total = state.items.fold<double>(0.0, (sum, item) => sum + (item.price * item.qty));
    final now = DateTime.now();

    final order = OrderEntity(
      id: const Uuid().v4(),
      customerName: customerName,
      customerPhone: customerPhone,
      total: total,
      orderDate: now,
      orderTime: DateFormat('HH:mm').format(now),
      status: OrderStatus.menungguReview,
      items: state.items,
      createdAt: now,
      updatedAt: now,
      orderSource: 'Public Web',
      isDineIn: true,
      tableNumber: tableNumber,
      paymentMethod: 'Tunai/QRIS',
    );

    await repository.addOrder(order);
    clear();
  }
}

final publicCartProvider = StateNotifierProvider<PublicCartNotifier, PublicCartState>((ref) {
  return PublicCartNotifier();
});

final publicCartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(publicCartProvider);
  return cart.items.fold(0, (sum, item) => sum + (item.price * item.qty));
});
