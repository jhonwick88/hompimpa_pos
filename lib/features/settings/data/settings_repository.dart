import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/nota_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(FirebaseFirestore.instance);
});

final notaSettingsProvider = StreamProvider<NotaSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watchNotaSettings();
});

class SettingsRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'settings';
  static const String _notaDoc = 'nota';

  SettingsRepository(this._firestore);

  Stream<NotaSettings> watchNotaSettings() {
    return _firestore.collection(_collection).doc(_notaDoc).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return NotaSettings.fromJson(snapshot.data()!);
      }
      return const NotaSettings(); // Return defaults
    });
  }

  Future<void> updateNotaSettings(NotaSettings settings) async {
    await _firestore.collection(_collection).doc(_notaDoc).set(settings.toJson());
  }

  Future<NotaSettings> getNotaSettings() async {
    final doc = await _firestore.collection(_collection).doc(_notaDoc).get();
    if (doc.exists && doc.data() != null) {
      return NotaSettings.fromJson(doc.data()!);
    }
    return const NotaSettings();
  }
}
