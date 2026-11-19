# Panduan UI & Desain Visual E-Layanan PBB P2 Mobile

Dokumen ini menjadi acuan desain antarmuka aplikasi Flutter E-Layanan PBB P2 Kota Solo sesuai ketentuan PRD Frontend.

## 1. Tema & Palet Warna (Material 3 - Identitas Pemkot & Bapenda Surakarta)
Aplikasi mendukung mode terang (Light) dan mode gelap (Dark) yang disimpan di penyimpanan lokal (`shared_preferences`). Palet warna mengadopsi identitas resmi Pemerintah Kota Surakarta & Bapenda Surakarta (Merah Marun khas Solo, Putih bersih, dan aksen Emas Keraton).

- **Primary Color**: Merah Marun Surakarta (`#A61C24` / deep `#7B1117`)
- **Accent Color**: Emas Keraton (`#C88A1E`)
- **Background (Light)**: `#F6F6F7`
- **Surface (Light)**: `#FFFFFF`
- **Background (Dark)**: `#111113`
- **Surface (Dark)**: `#1C1C20`

### Warna Badge Status Pengajuan
Sesuai PRD Bab 5 & Bab 10, badge **wajib selalu menyertakan teks label**, bukan hanya warna:
- **Menunggu**: Oranye / Kuning Amber (`#E65100` / `#FFF3E0` background badge)
- **Ditolak**: Merah (`#C62828` / `#FFEBEE` background badge)
- **Disetujui / Terdaftar**: Hijau (`#2E7D32` / `#E8F5E9` background badge)

## 2. Tipografi & Skala
- Menggunakan standar font sistem bawaan Flutter (Roboto) dengan skala Material Design 3.
- Judul formulir: Headline Small / Title Large (semi-bold)
- Label form: Body Medium (medium weight)
- Keterangan & Error 422: Body Small (regular / alert red `#D32F2F`)

## 3. Komponen Form & Interaksi
- **Aksesibilitas**: Target sentuh minimal 48 x 48 dp untuk semua tombol dan ikon.
- **Keadaan Form**:
  - Validasi instan di klien (format NIK 16 digit numerik, no telp, email/NPWP jika ada).
  - Integrasi error validasi 422 dari server di bawah field terkait.
  - Tombol Submit dinonaktifkan (`disabled`) saat pengiriman sedang berlangsung untuk mencegah kirim ganda.
- **3 State Wajib Tiap Layar**:
  1. *Loading*: Skeleton loading atau shimmering indicator.
  2. *Empty*: Ilustrasi/ikon informatif dengan teks panduan Bahasa Indonesia yang jelas.
  3. *Error*: Pesan kegagalan ramah pengguna dengan tombol "Coba Lagi".

## 4. Peta (flutter_map OSM)
- Pusat koordinat awal: Kota Solo (`-7.55611`, `110.83167`).
- Atribusi wajib: `© OpenStreetMap contributors`.
- User-Agent resmi di-pass pada layer OSM.
- Mode: Marker (satu titik) dan Polygon (minimal 3 titik).
