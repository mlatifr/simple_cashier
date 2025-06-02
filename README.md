# Simple Cashier

Aplikasi kasir sederhana yang dibangun menggunakan Flutter 3.22.2. Aplikasi ini dirancang untuk membantu pengelolaan transaksi penjualan dengan antarmuka yang mudah digunakan.

## Teknologi yang Digunakan

- Flutter 3.22.2
- GetX untuk state management dan navigasi
- SQLite untuk penyimpanan data lokal

## Fitur Utama

- Autentikasi pengguna (login dan registrasi)
- Manajemen produk
- Keranjang belanja dengan pengelolaan stok otomatis
- Tampilan produk dengan grid layout
- Pencatatan transaksi

## Struktur Aplikasi

Aplikasi ini menggunakan arsitektur GetX dengan struktur modular:

- **modules**: Berisi modul-modul aplikasi (home, login, register, cart)
- **data**: Berisi helper untuk database dan model data
- **routes**: Berisi konfigurasi routing aplikasi

## Pengelolaan Stok

Aplikasi ini memiliki fitur pengelolaan stok otomatis:
- Stok akan berkurang saat produk ditambahkan ke keranjang
- Stok akan bertambah saat produk dihapus dari keranjang
- Validasi stok saat menambahkan produk ke keranjang

## Getting Started

### Prasyarat

- Flutter 3.22.2 atau yang lebih baru
- Dart SDK 3.4.3 atau yang lebih baru

### Instalasi

1. Clone repositori ini
2. Jalankan `flutter pub get` untuk menginstal dependensi
3. Jalankan aplikasi dengan `flutter run`

## Sumber Daya Flutter

Untuk bantuan memulai dengan Flutter, lihat
[dokumentasi online](https://docs.flutter.dev/), yang menawarkan tutorial,
sampel, panduan pengembangan seluler, dan referensi API lengkap.
