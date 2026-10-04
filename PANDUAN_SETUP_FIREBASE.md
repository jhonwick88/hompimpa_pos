# 🚀 Panduan Setup Firebase Database untuk Hompimpa POS

Selamat datang di **Hompimpa POS**! Aplikasi kasir & manajemen restoran modern.
Aplikasi ini dirancang dengan arsitektur **Independent Database**, yang berarti seluruh data transaksi, produk, nota, dan omzet tersimpan aman di akun **Google Firebase** milik Anda sendiri (100% privat, cepat, dan **GRATIS** menggunakan kuota Firebase Spark Plan).

---

## 📋 Daftar Isi
1. [Langkah 1: Membuat Project Firebase (Gratis)](#-langkah-1-membuat-project-firebase)
2. [Langkah 2: Mengaktifkan Authentication (Google Login)](#-langkah-2-mengaktifkan-authentication)
3. [Langkah 3: Mengaktifkan Cloud Firestore & Security Rules](#-langkah-3-mengaktifkan-cloud-firestore)
4. [Langkah 4: Mengaktifkan Firebase Storage (Gambar Menu)](#-langkah-4-mengaktifkan-firebase-storage)
5. [Langkah 5: Menyalin Kode Konfigurasi](#-langkah-5-menyalin-kode-konfigurasi)
6. [Langkah 6: Menghubungkan ke Aplikasi Hompimpa POS](#-langkah-6-menghubungkan-ke-aplikasi)
7. [Langkah 7: Menjalankan Auto Setup / Seeder Awal](#-langkah-7-menjalankan-auto-setup-awal)
8. [❓ Pertanyaan Umum & Troubleshooting](#-troubleshooting--solusi-masalah)

---

## 🛠️ Langkah 1: Membuat Project Firebase

1. Buka browser dan kunjungi: **[https://console.firebase.google.com/](https://console.firebase.google.com/)**
2. Login menggunakan akun Google / Gmail Anda.
3. Klik tombol **"Add project"** (atau **"Create a project"**).
4. Masukkan nama project, misalnya: `hompimpa-pos-restoanda` lalu klik **Continue**.
5. Pada pilihan *Google Analytics*, Anda bisa mematikannya atau mengaktifkannya (opsional), lalu klik **Create project**.
6. Tunggu proses selesai (~10 detik), lalu klik **Continue**.

---

## 🔐 Langkah 2: Mengaktifkan Authentication

Fitur ini digunakan agar Anda dan staf kasir dapat login dengan aman.

1. Di menu sidebar kiri Firebase Console, klik **Build** > **Authentication**.
2. Klik tombol **Get started**.
3. Di tab **Sign-in method**, pilih **Google**:
   - Aktifkan toggle **Enable**.
   - Pilih **Project support email** (pilih email Gmail Anda).
   - Klik **Save**.

---

## 🗄️ Langkah 3: Mengaktifkan Cloud Firestore

Cloud Firestore adalah database utama tempat menyimpan produk, pesanan, dan laporan.

1. Di menu sidebar kiri, klik **Build** > **Firestore Database**.
2. Klik tombol **Create database**.
3. **Database location**: Pilih lokasi server terdekat (Disarankan: `asia-southeast2` (Jakarta) atau `asia-southeast1` (Singapura)). Klik **Next**.
4. **Security rules**: Pilih **Start in test mode** atau **production mode**, lalu klik **Create / Enable**.
5. Setelah database aktif, klik tab **Rules** di bagian atas.
6. Hapus kode rules bawaan dan **ganti/paste** dengan kode berikut (atau salin dari file `firestore.rules`):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn() {
      return request.auth != null;
    }

    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }

    function isDev() {
      return isSignedIn() && 
        (exists(/databases/$(database)/documents/users/$(request.auth.uid)) && 
         getUserData().role == 'dev');
    }

    function isAdmin() {
      return isSignedIn() && 
        (exists(/databases/$(database)/documents/users/$(request.auth.uid)) && 
         (getUserData().role == 'admin' || getUserData().role == 'dev'));
    }

    match /users/{userId} {
      allow read: if isSignedIn();
      allow create, update: if isSignedIn() && (request.auth.uid == userId || isAdmin());
      allow delete: if isDev();
    }

    match /stores/{storeId} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }

    match /products/{productId} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }

    match /toppings/{toppingId} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }

    match /settings/{settingId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /orders/{orderId} {
      allow read: if true;
      allow create: if true;
      allow update: if isSignedIn();
      allow delete: if isDev();
    }

    match /shifts/{shiftId} {
      allow read, write: if isSignedIn();
    }

    match /stock_logs/{logId} {
      allow read, write: if isSignedIn();
    }

    match /daily_sales/{saleId} {
      allow read, write: if isSignedIn();
    }

    match /order_logs/{logId} {
      allow read, write: if isSignedIn();
    }

    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```
7. Klik tombol **Publish** di pojok kanan atas.

---

## 🖼️ Langkah 4: Mengaktifkan Firebase Storage

Digunakan untuk menyimpan foto produk dan logo nota restoran Anda.

1. Di menu sidebar kiri, klik **Build** > **Storage**.
2. Klik tombol **Get started**.
3. Pilih **Start in production mode** lalu klik **Next** dan **Done**.
4. Buka tab **Rules** di Storage, dan ganti dengan:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```
5. Klik **Publish**.

---

## 🔑 Langkah 5: Menyalin Kode Konfigurasi

1. Klik ikon **Gear (⚙️ Project settings)** di kiri atas samping *Project Overview*.
2. Scroll ke bawah ke bagian **Your apps**.
3. Klik ikon Web **`</>`**.
4. Masukkan nama aplikasi (misal: `Hompimpa POS Web`), lalu klik **Register app**.
5. Anda akan melihat cuplikan kode seperti berikut:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyD-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  authDomain: "hompimpa-pos-restoanda.firebaseapp.com",
  projectId: "hompimpa-pos-restoanda",
  storageBucket: "hompimpa-pos-restoanda.firebasestorage.app",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef1234567890"
};
```
6. **Salin seluruh teks kode tersebut** (atau cukup salin nilainya).

---

## 📱 Langkah 6: Menghubungkan ke Aplikasi

1. Buka aplikasi **Hompimpa POS** di HP / Tablet / Browser Anda.
2. Jika aplikasi belum terhubung ke database, klik tombol **"⚙️ Konfigurasi Database Firebase Sekarang"** (atau klik link **⚙️ Konfigurasi Database Firebase** pada halaman login).
3. Klik tombol **"📋 Paste Otomatis Config"**.
4. Tempel teks kode yang Anda salin dari Langkah 5, lalu klik **Ekstrak Otomatis**.
5. Semua kolom (*Project ID, API Key, App ID, Messaging Sender ID*) akan terisi secara otomatis!
6. Klik tombol **"Simpan & Terapkan Konfigurasi"**.

---

## ⚡ Langkah 7: Menjalankan Auto Setup Awal

Agar Anda tidak perlu menginput data toko dan menu satu per satu dari awal:

1. Di halaman **Konfigurasi Firebase Database**, klik tombol:
   **"⚡ Jalankan Auto Setup / Seeder Database Awal"**
2. Sistem akan secara otomatis membuatkan:
   - ✅ **Toko Pusat** (Store Master)
   - ✅ **Pengaturan Nota & Tagline**
   - ✅ **Pengaturan Level Sambal & Harga**
   - ✅ **Daftar Topping Siap Pakai** (Keju Mozzarella, Telur, Ekstra Sambal, dll.)
   - ✅ **7 Contoh Menu Starter** (Ayam Geprek, Nasi Goreng, Es Teh, Es Jeruk, dll.)
3. Selesai! Anda dapat langsung login menggunakan akun Google Anda dan mulai bertransaksi kasir.

---

## ❓ Troubleshooting & Solusi Masalah

### 1. Pesan: "Koneksi Bermasalah / Developer Error (10)" pada Android
- Buka **Firebase Console > Project Settings > General**.
- Di bagian Android App, pastikan Anda telah mendaftarkan **SHA-1 Fingerprint** perangkat / keystore Anda.

### 2. Pesan: "Firebase Initialization Timed Out"
- Pastikan koneksi internet perangkat Anda stabil.
- Periksa kembali apakah **Project ID** dan **API Key** sudah diketik/ditempel dengan benar tanpa spasi tambahan.

### 3. Ingin Reset atau Ganti Database ke Cabang Lain?
- Anda dapat membuka **Menu Drawer (Garis Tiga / Avatar)** > **Setting** > **Database & Firebase**.
- Klik tombol **Reset** untuk kembali ke konfigurasi awal atau masukkan kredensial Firebase project cabang baru Anda.

---
*© Hompimpa POS - Solusi Kasir Restoran Cerdas & Modern.*
