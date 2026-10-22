# Cuaca BMKG

Aplikasi mobile Flutter untuk melihat prakiraan cuaca tingkat kelurahan/desa di Indonesia
menggunakan data terbuka BMKG.

## Deskripsi
Aplikasi mengambil data prakiraan cuaca 3 hari (per 3 jam) dari API publik BMKG dan menyajikannya
dalam tampilan yang ringkas: kondisi saat ini, prakiraan 24 jam, ringkasan 3 hari, dan saran aktivitas.

## Fitur Utama
- Cuaca saat ini: suhu, kondisi, kelembapan, angin, tutupan awan, jarak pandang.
- Prakiraan 24 jam ke depan (per 3 jam).
- Prakiraan 3 hari beserta suhu min/maks dan detail per jam (bottom sheet).
- Saran otomatis (bawa payung, peringatan petir/kabut, cuaca panas).
- Pilih lokasi lewat kode wilayah tingkat IV (adm4), divalidasi langsung ke API.
- Lokasi favorit tersimpan di perangkat dan lokasi terakhir diingat.
- Penanganan loading, sukses, dan error (dengan tombol "Coba Lagi"), serta pull-to-refresh.

## Teknologi / Package
- Flutter & Dart
- `http` untuk permintaan HTTP
- `shared_preferences` untuk menyimpan lokasi
- `FutureBuilder` untuk asynchronous UI
- Sumber data: https://data.bmkg.go.id/prakiraan-cuaca/
  (endpoint: `https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4={kode}`)

## Struktur Folder
```
lib/
  main.dart
  models/weather_model.dart        # class model + parsing JSON
  services/weather_service.dart    # permintaan HTTP & penanganan error
  services/location_storage.dart   # penyimpanan lokasi
  screens/home_screen.dart         # halaman utama (FutureBuilder)
  screens/location_screen.dart     # halaman pilih/tambah lokasi
  widgets/                         # komponen UI
  utils/helpers.dart               # format, ikon, saran cuaca
test/weather_model_test.dart
```

## Cara Menjalankan
1. Pasang Flutter SDK (https://docs.flutter.dev/get-started/install).
2. Clone repositori, lalu jalankan di folder project:
   ```
   flutter create --project-name cuaca_bmkg .
   flutter pub get
   flutter run
   ```
   (`flutter create .` hanya menambahkan folder platform seperti android/ dan ios/;
   file `lib/` dan `pubspec.yaml` yang sudah ada tidak ditimpa. Jika folder platform sudah ada, lewati langkah ini.)
3. Untuk build rilis Android, pastikan `android/app/src/main/AndroidManifest.xml` memuat:
   `<uses-permission android:name="android.permission.INTERNET"/>`
4. Jalankan pengujian: `flutter test`

## Atribusi
Data prakiraan cuaca bersumber dari BMKG (Badan Meteorologi, Klimatologi, dan Geofisika).
