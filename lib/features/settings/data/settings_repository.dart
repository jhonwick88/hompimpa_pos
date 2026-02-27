import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/nota_settings.dart';
import '../domain/sambal_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(FirebaseFirestore.instance);
});

final notaSettingsProvider = StreamProvider<NotaSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watchNotaSettings();
});

final sambalSettingsProvider = StreamProvider<SambalSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watchSambalSettings();
});

class SettingsRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'settings';
  static const String _notaDoc = 'nota';
  static const String _sambalDoc = 'sambal';

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

  Stream<SambalSettings> watchSambalSettings() {
    return _firestore.collection(_collection).doc(_sambalDoc).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return SambalSettings.fromJson(snapshot.data()!);
      }
      return const SambalSettings(); // Return defaults
    });
  }

  Future<void> updateSambalSettings(SambalSettings settings) async {
    await _firestore.collection(_collection).doc(_sambalDoc).set(settings.toJson());
  }

  Future<SambalSettings> getSambalSettings() async {
    final doc = await _firestore.collection(_collection).doc(_sambalDoc).get();
    if (doc.exists && doc.data() != null) {
      return SambalSettings.fromJson(doc.data()!);
    }
    return const SambalSettings();
  }
}
