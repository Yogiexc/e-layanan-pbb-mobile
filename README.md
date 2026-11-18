# E-Layanan PBB P2 Mobile (Kota Solo)

Aplikasi mobile berbasis Flutter (Android) untuk pelayanan Pajak Bumi dan Bangunan Perdesaan dan Perkotaan (PBB P2) wilayah Kota Solo.
Aplikasi ini memungkinkan warga untuk mengajukan:
1. **Objek Baru** (Pendaftaran objek pajak baru via formulir SPOP)
2. **Mutasi Subjek/Objek Pajak**:
   - Mutasi Penuh
   - Mutasi Sebagian / Pemecahan
   - Mutasi Penggabungan Objek

## Arsitektur & Teknologi
- **Framework**: Flutter (Dart) - Android Only
- **State Management**: `flutter_riverpod`
- **Routing**: `go_router`
- **Networking**: `dio` dengan interceptor token Sanctum dan mapping error 422
- **Keamanan Token**: `flutter_secure_storage`
- **Peta Lokasi (Sket/Denah)**: `flutter_map` + `latlong2` (OpenStreetMap)
- **Kompresi & Berkas**: `image_picker`, `file_picker`, `flutter_image_compress`
- **Penyimpanan Lokal Preferensi**: `shared_preferences` (Theme mode gelap/terang)

## Konfigurasi API
Base URL API disuntikkan via build argument `--dart-define` dan tidak di-hardcode:
```bash
flutter run --dart-define=API_BASE_URL=https://your-api-domain.com/api/v1
```

## Struktur Proyek
Struktur folder menggunakan **feature-based architecture**:
```
lib/
├── core/
│   ├── network/       # Dio client, Interceptors, ApiResult/Envelope wrapper
│   ├── theme/         # Material 3 Light/Dark Theme & Palet Kota Solo
│   └── utils/         # Validator (NIK, NPWP, Telp), formatters, constants
└── features/
    ├── auth/          # Login, Sesi, Secure Token Storage
    ├── home/          # Beranda, Salam, Menu Utama
    ├── nop/           # Daftar NOP & Badge Status, Detail Pengajuan, Revisi
    ├── pengajuan/     # Formulir Objek Baru & Mutasi, Map Sket, Upload Berkas
    └── akun/          # Profil Wajib Pajak, Ganti Password/Username, Dark Mode
```

## Panduan Desain Antarmuka
Panduan desain dan warna antarmuka dapat dilihat di [docs/ui-guidelines.md](docs/ui-guidelines.md).
