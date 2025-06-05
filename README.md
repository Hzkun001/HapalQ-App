# HafalQ

Aplikasi Flutter untuk membantu menghafal Al-Qur'an, menampilkan jadwal sholat, lokasi, dan fitur-fitur islami lainnya.

## Fitur Utama
- Daftar surah Al-Qur'an lengkap dengan nama, latin, arti, dan jumlah ayat
- Pencarian surah/ayat
- Penampilan jadwal sholat berdasarkan lokasi pengguna (otomatis deteksi lokasi)
- Hitung mundur waktu sholat berikutnya
- Tampilan tanggal hijriyah (dummy)
- UI modern dan responsif

## Spesifikasi & Requirement
- Flutter SDK >= 3.6.0
- Dart >= 3.0.0
- Android/iOS/Web/Windows/Linux/MacOS
- Koneksi internet (untuk jadwal sholat & lokasi)

### Dependency utama
- [geolocator](https://pub.dev/packages/geolocator)
- [geocoding](https://pub.dev/packages/geocoding)
- [http](https://pub.dev/packages/http)
- [intl](https://pub.dev/packages/intl)
- [cupertino_icons](https://pub.dev/packages/cupertino_icons)

## Instalasi & Menjalankan

1. **Clone repository**
   ```bash
   git clone <repo-url>
   cd hafalq
   ```
2. **Install dependency**
   ```bash
   flutter pub get
   ```
3. **Jalankan aplikasi**
   - Android/iOS:
     ```bash
     flutter run
     ```
   - Web:
     ```bash
     flutter run -d chrome
     ```
   - Windows/MacOS/Linux:
     ```bash
     flutter run -d windows # atau macos/linux
     ```

## Struktur Folder
```
lib/
  main.dart                # Entry point aplikasi
  models/                  # Model data (misal: Surah)
  screens/                 # Halaman utama & widget
assets/
  quran-surah-complete.json# Data surah Al-Qur'an
...
```

## Kontribusi
Pull request & issue sangat terbuka untuk pengembangan aplikasi ini.

## Lisensi
Lisensi bebas untuk edukasi dan non-komersial.

---

**Kontak**: [your-email@example.com] (ganti sesuai kontak Anda)
