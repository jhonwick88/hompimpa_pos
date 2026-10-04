import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hompimpa_pos/core/enums/user_role.dart';
import 'package:hompimpa_pos/features/auth/domain/user_model.dart';
import 'package:hompimpa_pos/features/products/domain/product.dart';
import 'package:hompimpa_pos/features/products/domain/topping.dart';
import 'package:hompimpa_pos/features/settings/domain/nota_settings.dart';
import 'package:hompimpa_pos/features/settings/domain/sambal_settings.dart';
import 'package:hompimpa_pos/features/settings/domain/store.dart';

class DatabaseSeederService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DatabaseSeederService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Mengecek apakah database sudah memiliki data toko atau produk
  Future<bool> isDatabaseSeeded() async {
    try {
      final stores = await _firestore.collection('stores').limit(1).get();
      final products = await _firestore.collection('products').limit(1).get();
      return stores.docs.isNotEmpty || products.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking database status: $e');
      return false;
    }
  }

  /// Menjalankan Auto Setup / Inisialisasi Database Lengkap
  Future<Map<String, dynamic>> seedInitialDatabase({
    String? storeName,
    String? storeAddress,
    String? storePhone,
    String? adminEmail,
  }) async {
    final report = <String, dynamic>{
      'storesCreated': 0,
      'usersCreated': 0,
      'productsCreated': 0,
      'toppingsCreated': 0,
      'settingsCreated': false,
    };

    final currentUser = _auth.currentUser;
    final defaultStoreId = 'store_main';
    final targetStoreName = (storeName != null && storeName.isNotEmpty) ? storeName : 'Hompimpa POS Pusat';
    final targetStoreAddress = (storeAddress != null && storeAddress.isNotEmpty) ? storeAddress : 'Jl. Merdeka No. 88';
    final targetStorePhone = (storePhone != null && storePhone.isNotEmpty) ? storePhone : '081234567890';

    // 1. INSIALISASI TOKO UTAMA (STORES)
    final storeDoc = await _firestore.collection('stores').doc(defaultStoreId).get();
    if (!storeDoc.exists) {
      final store = Store(
        id: defaultStoreId,
        name: targetStoreName,
        address: targetStoreAddress,
        phone: targetStorePhone,
        isActive: true,
      );
      await _firestore.collection('stores').doc(defaultStoreId).set(store.toJson());
      report['storesCreated'] = 1;
    }

    // 2. INISIALISASI USER ADMIN / DEV
    if (currentUser != null) {
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        final adminUser = AppUser(
          uid: currentUser.uid,
          email: currentUser.email ?? 'admin@hompimpa.com',
          displayName: currentUser.displayName ?? 'Administrator',
          role: UserRole.dev, // Default dev/owner agar memiliki akses penuh
          storeId: defaultStoreId,
        );
        await _firestore.collection('users').doc(currentUser.uid).set(adminUser.toMap());
        report['usersCreated'] = (report['usersCreated'] as int) + 1;
      }
    } else if (adminEmail != null && adminEmail.isNotEmpty) {
      // Pre-register admin email if specified
      final emailQuery = await _firestore.collection('users').where('email', isEqualTo: adminEmail).get();
      if (emailQuery.docs.isEmpty) {
        final newDoc = _firestore.collection('users').doc();
        final adminUser = AppUser(
          uid: newDoc.id,
          email: adminEmail,
          displayName: 'Owner / Administrator',
          role: UserRole.dev,
          storeId: defaultStoreId,
        );
        await newDoc.set(adminUser.toMap());
        report['usersCreated'] = (report['usersCreated'] as int) + 1;
      }
    }

    // 3. INISIALISASI SETTING NOTA & SAMBAL
    final notaDoc = await _firestore.collection('settings').doc('nota_settings').get();
    if (!notaDoc.exists) {
      final defaultNota = NotaSettings(
        storeName: targetStoreName,
        tagline: 'Lezat, Murah, dan Berkualitas',
        address1: targetStoreAddress,
        address2: 'Kota Kasir, Indonesia',
        phone: targetStorePhone,
        footerMessage: 'Terima kasih atas kunjungan Anda! Selamat menikmati.',
      );
      await _firestore.collection('settings').doc('nota_settings').set(defaultNota.toJson());
    }

    final sambalDoc = await _firestore.collection('settings').doc('sambal_settings').get();
    if (!sambalDoc.exists) {
      final defaultSambal = const SambalSettings(
        level0to3Price: 0.0,
        level4to5Price: 500.0,
        level6to7Price: 1000.0,
      );
      await _firestore.collection('settings').doc('sambal_settings').set(defaultSambal.toJson());
    }
    report['settingsCreated'] = true;

    // 4. INISIALISASI TOPPING STARTER
    final initialToppings = [
      const Topping(id: 'top_01', name: 'Keju Mozzarella', price: 5000, stock: 100, isActive: true),
      const Topping(id: 'top_02', name: 'Telur Ceplok / Dadar', price: 4000, stock: 100, isActive: true),
      const Topping(id: 'top_03', name: 'Sambal Bawang Extra', price: 3000, stock: 100, isActive: true),
      const Topping(id: 'top_04', name: 'Saus Keju Melted', price: 4000, stock: 100, isActive: true),
      const Topping(id: 'top_05', name: 'Bawang Goreng Krispi', price: 2000, stock: 100, isActive: true),
    ];

    for (final top in initialToppings) {
      final doc = await _firestore.collection('toppings').doc(top.id).get();
      if (!doc.exists) {
        await _firestore.collection('toppings').doc(top.id).set(top.toJson());
        report['toppingsCreated'] = (report['toppingsCreated'] as int) + 1;
      }
    }

    // 5. INISIALISASI MENU / PRODUK STARTER
    final initialProducts = [
      Product(
        id: 'prod_01',
        name: 'Ayam Geprek Sambal Bawang',
        category: 'Makanan',
        price: 18000,
        stock: 50,
        isActive: true,
        storeId: defaultStoreId,
        hasSambal: true,
        hasLevel: true,
        hasTopping: true,
      ),
      Product(
        id: 'prod_02',
        name: 'Ayam Bakar Madu Spesial',
        category: 'Makanan',
        price: 22000,
        stock: 40,
        isActive: true,
        storeId: defaultStoreId,
        hasSambal: true,
        hasLevel: false,
        hasTopping: true,
      ),
      Product(
        id: 'prod_03',
        name: 'Nasi Goreng Spesial Hompimpa',
        category: 'Makanan',
        price: 20000,
        stock: 35,
        isActive: true,
        storeId: defaultStoreId,
        hasSambal: false,
        hasLevel: true,
        hasTopping: true,
      ),
      Product(
        id: 'prod_04',
        name: 'Kentang Goreng Krispi',
        category: 'Snack',
        price: 12000,
        stock: 60,
        isActive: true,
        storeId: defaultStoreId,
        hasSambal: false,
        hasLevel: false,
        hasTopping: true,
      ),
      Product(
        id: 'prod_05',
        name: 'Es Teh Manis Segar',
        category: 'Minuman',
        price: 5000,
        stock: 150,
        isActive: true,
        storeId: defaultStoreId,
        hasSambal: false,
        hasLevel: false,
        hasTopping: false,
      ),
      Product(
        id: 'prod_06',
        name: 'Es Jeruk Peras Asli',
        category: 'Minuman',
        price: 8000,
        stock: 80,
        isActive: true,
        storeId: defaultStoreId,
        hasSambal: false,
        hasLevel: false,
        hasTopping: false,
      ),
      Product(
        id: 'prod_07',
        name: 'Kopi Susu Gula Aren',
        category: 'Minuman',
        price: 15000,
        stock: 50,
        isActive: true,
        storeId: defaultStoreId,
        hasSambal: false,
        hasLevel: false,
        hasTopping: false,
      ),
    ];

    for (final prod in initialProducts) {
      final doc = await _firestore.collection('products').doc(prod.id).get();
      if (!doc.exists) {
        await _firestore.collection('products').doc(prod.id).set(prod.toJson());
        report['productsCreated'] = (report['productsCreated'] as int) + 1;
      }
    }

    return report;
  }
}
