# HafalQ Build Troubleshooting (JVM Target)

## Masalah
Build APK gagal karena error: "Unknown Kotlin JVM target: 20" atau mismatch Java/Kotlin JVM target (Java 11 vs 17) pada plugin seperti `audio_session`.

## Solusi Umum
1. **Pastikan JAVA_HOME ke JDK 17**
2. **Pastikan `android/build.gradle` dan `android/app/build.gradle` sudah override jvmTarget ke 17**
3. **Override jvmTarget di seluruh modul/plugin**
   - Jika error tetap muncul, override manual di plugin pada `.pub-cache` (misal: `audio_session`).

## Cara Override jvmTarget di .pub-cache (Windows)
1. Cari folder plugin, misal:
   ```
   %USERPROFILE%\.pub-cache\hosted\pub.dev\audio_session-<versi>\android\build.gradle
   ```
2. Edit file `build.gradle` plugin:
   Tambahkan/ubah:
   ```gradle
   android {
     ...
     compileOptions {
       sourceCompatibility JavaVersion.VERSION_17
       targetCompatibility JavaVersion.VERSION_17
     }
     kotlinOptions {
       jvmTarget = "17"
     }
   }
   ```
3. Simpan, lalu ulangi `flutter clean`, `flutter pub get`, dan build ulang APK.

## Catatan
- Setiap update/dependency baru, ulangi langkah di atas jika error muncul lagi.
- Jika error menyebut JVM target 20, pastikan tidak ada plugin yang override ke 20.
