# MyWebinar

Aplikasi mobile untuk menemukan, mengikuti, dan mengelola webinar dengan mudah.

## Deskripsi Aplikasi
MyWebinar adalah aplikasi berbasis Flutter yang dirancang untuk membantu pengguna dalam manajemen webinar. Aplikasi ini menyediakan antarmuka modern yang ramah pengguna dengan fitur-fitur seperti pelokalan (ID/EN) berbasis lokasi, detail sesi webinar, serta manajemen e-sertifikat.

## Fitur Utama
- **Deteksi Lokasi** — Menyesuaikan bahasa aplikasi secara otomatis (Bahasa Indonesia/Inggris) berdasarkan posisi geografis pengguna.
- **Katalog Webinar** — Menampilkan daftar webinar dengan detail speaker, tanggal, dan waktu.
- **Sertifikasi Digital** — Informasi ketersediaan e-sertifikat untuk setiap sesi webinar.
- **UI Modern** — Menggunakan Flutter BLoC, Flutter Animate, dan Google Fonts (Poppins) untuk pengalaman pengguna yang halus.

## Teknis & Dependensi
Aplikasi ini dibangun menggunakan:
- **Flutter Framework**
- **flutter_bloc** — Manajemen state aplikasi.
- **geolocator** — Deteksi lokasi pengguna untuk fitur lokalisasi.
- **http** — Koneksi API untuk data webinar.
- **shared_preferences** — Penyimpanan data lokal.
- **flutter_animate** — Animasi UI yang responsif.
- **google_fonts** — Tipografi Poppins.

## Memulai
1. Pastikan Flutter SDK sudah terinstal di komputer Anda.
2. Clone repository ini.
3. Jalankan `flutter pub get` untuk mengunduh semua dependensi.
4. Jalankan aplikasi dengan perintah `flutter run`.

## Lisensi
Aplikasi ini bersifat privat (untuk keperluan manajemen webinar).