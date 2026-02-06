import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/topping.dart';

abstract class ToppingRepository {
  Future<List<Topping>> getToppings();
  Future<void> reduceStock(String id, int qty);
  Future<void> seedToppings();
}

class FirestoreToppingRepository implements ToppingRepository {
  final FirebaseFirestore _firestore;

  FirestoreToppingRepository(this._firestore);

  @override
  Future<List<Topping>> getToppings() async {
    try {
      final snapshot = await _firestore.collection('toppings').where('isActive', isEqualTo: true).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Topping.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error fetching toppings: $e');
      return [];
    }
  }

  @override
  Future<void> reduceStock(String id, int qty) async {
    final docRef = _firestore.collection('toppings').doc(id);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Topping $id does not exist!");
      }
      
      final currentStock = (snapshot.data()?['stock'] as int?) ?? 0;
      if (currentStock < qty) {
        throw Exception("Stock insufficient for ${snapshot.data()?['name']}");
      }
      
      transaction.update(docRef, {'stock': currentStock - qty});
    });
  }

  @override
  Future<void> seedToppings() async {
    final toppings = [
      {'id': 'pangsit', 'name': 'Pangsit', 'price': 1500.0, 'stock': 10000, 'isActive': true},
      {'id': 'bakso', 'name': 'Bakso', 'price': 3000.0, 'stock': 10000, 'isActive': true},
      {'id': 'sosis', 'name': 'Sosis', 'price': 3000.0, 'stock': 10000, 'isActive': false},
    ];

    final batch = _firestore.batch();
    for (var t in toppings) {
      final docRef = _firestore.collection('toppings').doc(t['id'] as String);
      batch.set(docRef, t);
    }
    await batch.commit();
    print("DEBUG: Seeded toppings to Firestore");
  }
}

// Keeping InMemory for unexpected rollback needs, but provider uses Firestore now
class InMemoryToppingRepository implements ToppingRepository {
  final List<Topping> _toppings = [
    const Topping(id: 'pangsit', name: 'Pangsit', price: 1500, stock: 10000, isActive: true),
    const Topping(id: 'bakso', name: 'Bakso', price: 3000, stock: 10000, isActive: true),
    const Topping(id: 'sosis', name: 'Sosis', price: 3000, stock: 10000, isActive: false),
  ];

  @override
  Future<List<Topping>> getToppings() async {
    return _toppings;
  }

  @override
  Future<void> reduceStock(String id, int qty) async {
     // no-op
  }
  
  @override
  Future<void> seedToppings() async {
    print("Mock Seed Done");
  }
}

final toppingRepositoryProvider = Provider<ToppingRepository>((ref) {
  return FirestoreToppingRepository(FirebaseFirestore.instance);
});

final toppingListProvider = FutureProvider<List<Topping>>((ref) async {
  final repository = ref.watch(toppingRepositoryProvider);
  return repository.getToppings();
});
