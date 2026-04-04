import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/shift.dart';
import '../domain/cash_out.dart';

final cashierRepositoryProvider = Provider<CashierRepository>((ref) {
  return FirestoreCashierRepository(FirebaseFirestore.instance);
});

abstract class CashierRepository {
  Future<ShiftEntity?> getCurrentActiveShift();
  Stream<ShiftEntity?> watchCurrentActiveShift();
  Future<void> createShift(ShiftEntity shift);
  Future<void> closeShift(ShiftEntity shift);
  Future<void> addCashOut(CashOutEntity cashOut);
  Future<List<CashOutEntity>> getCashOutsForShift(String shiftId);
}

class FirestoreCashierRepository implements CashierRepository {
  final FirebaseFirestore _firestore;

  FirestoreCashierRepository(this._firestore);

  @override
  Future<ShiftEntity?> getCurrentActiveShift() async {
    try {
      final snapshot = await _firestore.collection('shifts')
          .where('status', isEqualTo: 'OPEN')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        return ShiftEntity.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting active shift: $e');
      rethrow;
    }
  }

  @override
  Stream<ShiftEntity?> watchCurrentActiveShift() {
    return _firestore.collection('shifts')
        .where('status', isEqualTo: 'OPEN')
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final data = snapshot.docs.first.data();
            data['id'] = snapshot.docs.first.id;
            return ShiftEntity.fromJson(data);
          }
          return null;
        });
  }

  @override
  Future<void> createShift(ShiftEntity shift) async {
    await _firestore.collection('shifts').doc(shift.id).set(shift.toJson());
  }

  @override
  Future<void> closeShift(ShiftEntity shift) async {
    await _firestore.collection('shifts').doc(shift.id).update(shift.toJson());
  }

  @override
  Future<void> addCashOut(CashOutEntity cashOut) async {
    await _firestore.collection('cash_outs').doc(cashOut.id).set(cashOut.toJson());
  }

  @override
  Future<List<CashOutEntity>> getCashOutsForShift(String shiftId) async {
    final snapshot = await _firestore.collection('cash_outs')
        .where('shiftId', isEqualTo: shiftId)
        .get();

    final results = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return CashOutEntity.fromJson(data);
    }).toList();

    // Sort client-side to avoid composite index requirement
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return results;
  }
}
