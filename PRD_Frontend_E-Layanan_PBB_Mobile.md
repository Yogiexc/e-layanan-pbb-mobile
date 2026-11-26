# PRD Frontend — Aplikasi Mobile E-Layanan PBB P2 (Flutter, Android)

> Prototype siap demo | Kota Solo | Versi 1.0 | 17 November 2026

## Cara Memakai Dokumen Ini (untuk AI Agent)

- Dokumen ini sumber kebenaran untuk sisi mobile. Ikuti isinya; jika ada yang tidak jelas atau bertentangan dengan kode yang ada, tanyakan ke pengembang, jangan berasumsi.
- Kontrak API tidak boleh diubah sepihak. Perubahan harus disepakati dengan pemegang Backend dan diperbarui di kedua PRD.
- Flutter tidak pernah mengakses basis data secara langsung; semua data lewat REST API Laravel.
- Bagian bertanda **Asumsi** adalah keputusan PRD yang belum dikonfirmasi pemilik proyek. Beri tahu pengembang bila Anda menemukan sesuatu yang membuatnya tidak cocok.
- Tulis semua teks antarmuka dalam Bahasa Indonesia.

## Aturan Kerja untuk AI Agent (wajib dipatuhi)
 
### Kualitas kode

- **Hindari over-engineering.** Ini prototype demo. Kerjakan yang diminta PRD dengan solusi paling sederhana yang benar. Jangan menambah lapisan abstraksi, pola desain, paket, atau fitur yang tidak dibutuhkan (prinsip YAGNI dan KISS).
- **Clean code dan best practice.** Nama jelas dan konsisten, fungsi/kelas kecil dengan satu tanggung jawab, tanpa duplikasi (DRY), tanpa kode mati atau komentar basi, tanpa angka/string ajaib (pakai konstanta atau enum). Ikuti konvensi resmi bahasa dan kerangka kerja (lint dan format bawaan Dart/Flutter: `dart format`, `flutter analyze`).
- **Hindari bad code.** Jangan menelan galat diam-diam, jangan menulis logika di tempat yang salah (UI tidak boleh berisi logika data atau panggilan HTTP langsung), jangan menyalin-tempel blok besar, dan jangan menambah dependensi tanpa alasan kuat.
- Perubahan harus kecil dan terfokus: satu tugas, satu perubahan. Jangan merombak file yang tidak terkait.

### Git

- Sebelum mulai bekerja, jalankan `git pull` (atau `git pull --rebase`) agar tidak bentrok dengan pekerjaan rekan tim.
- Pesan commit memakai **Conventional Commits**: `tipe(scope): deskripsi singkat dalam huruf kecil`. Tipe: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`. Contoh: `feat(nop): tambah badge status pada daftar NOP` dan `fix(auth): tolak login akun non wajib pajak`.
- Satu commit = satu perubahan logis. Deskripsi imperatif, singkat, tanpa titik di akhir. Jangan commit file rahasia, build, atau berkas hasil generate.
- Jangan memakai `git push --force` atau menulis ulang riwayat yang sudah dipush. Jangan push langsung ke cabang utama bila tim memakai cabang fitur.

### Keamanan (prioritas utama)

- Jangan menulis rahasia di kode atau repositori (URL privat, kunci, kredensial). Konfigurasi lewat `--dart-define`.
- Token hanya di `flutter_secure_storage`. Jangan simpan di `SharedPreferences`, jangan cetak password/token/NIK ke log (termasuk `print`/`debugPrint`).
- Komunikasi hanya lewat HTTPS pada lingkungan selain pengembangan lokal; jangan menonaktifkan pemeriksaan sertifikat.
- Anggap semua data dari server sebagai tidak tepercaya: parsing defensif, jangan menampilkan HTML mentah.
- Validasi klien hanyalah kenyamanan; server tetap penentu. Samarkan NIK pada tampilan (hanya sebagian digit).
- Hapus token dan data sesi saat logout atau saat server membalas 401.

> Bila instruksi di PRD tampak bertentangan dengan aturan kerja ini, hentikan dan tanyakan ke pengembang sebelum melanjutkan.

---

## 1. Ringkasan Proyek

Proyek magang ini membangun ulang sistem E-Layanan PBB P2 (pelayanan Pajak Bumi dan Bangunan Perdesaan dan Perkotaan, wilayah Kota Solo) agar dapat dipakai dari ponsel. Warga mengajukan dua jenis layanan:

- **Objek Baru**: mendaftarkan objek pajak baru lewat formulir SPOP.
- **Mutasi**: perubahan subjek/objek pajak (Mutasi Penuh, Mutasi Sebagian/Pemecahan, Mutasi Penggabungan Objek).

Tujuan akhir: **prototype siap demo, bukan sistem siap produksi.** Utamakan alur utama yang berjalan mulus dan tampilan rapi. Hindari kerumitan yang tidak dibutuhkan demo.

Tiga bagian sistem:

- **Aplikasi mobile (Flutter, Android):** antarmuka warga (login, daftar NOP, ajukan layanan, lihat status).
- **Backend (Laravel):** REST API untuk mobile + dashboard admin (React via Inertia, menyatu dalam proyek Laravel yang sama) untuk verifikasi pengajuan dan kelola user.
- **Data:** Oracle `PBBDUMMY` (read-only via VPN WireGuard, hanya untuk mengambil/validasi NOP) dan PostgreSQL lokal `mgl_elayanan` (struktur disalin kosong dari sistem asli; semua data pengajuan disimpan di sini).

Pembagian tanggung jawab: dokumen ini adalah PRD Frontend. Pasangannya ada di PRD Backend. Kontrak API pada bagian [Kontrak API](#kontrak-api-v1) identik di kedua dokumen.

### Keputusan Final (sudah disepakati)

- Login saja, **tanpa registrasi di aplikasi** (registrasi dilakukan di website; pada prototype akun dibuat lewat seeder dan halaman kelola user di dashboard admin).
- NIK hanya divalidasi format (16 digit numerik). Tidak ada verifikasi ke sistem pemerintah.
- Hubungan akun dengan NOP lewat tabel baru pada migrasi (`user_nop`) tanpa mengubah tabel lain.
- Daftar NOP memakai badge status. Pengajuan yang ditolak dapat diedit dan dikirim ulang.
- Mutasi Sebagian: user hanya mengisi jumlah bidang dan keterangan; admin melengkapi data tiap bidang.
- Mutasi Penggabungan: syarat "bersebelahan" hanya dideklarasikan user dan dicek manual admin; sistem memvalidasi lewat Oracle bahwa semua NOP berada di kecamatan, kelurahan, dan blok yang sama.
- Wilayah: Kota Solo saja (5 kecamatan: Laweyan, Serengan, Pasar Kliwon, Jebres, Banjarsari).
- Platform: Android saja. Di luar scope: simpan draft, notifikasi push, mode offline, pembayaran, verifikasi NIK ke pemerintah.
- Peta: OpenStreetMap dengan `flutter_map` (gratis, tanpa API key). Hasil Point/Polygon disimpan ke kolom geometri PostGIS.
- Cakupan dashboard admin disederhanakan: (a) verifikasi berkas, (b) setuju/tolak, (c) pengisian NOP dan Kode ZNT.

## 2. Scope Frontend

### Di dalam scope

- Login, logout, sesi (token tersimpan aman).
- 3 menu bawah: Beranda, NOP, Akun.
- Formulir Objek Baru dan tiga formulir Mutasi, termasuk upload berkas dan peta sket lokasi.
- Daftar NOP dengan badge status, detail pengajuan, dan alur revisi (edit lalu kirim ulang).
- Akun: lihat profil, ubah username, ganti password, mode gelap (disimpan lokal di perangkat).

### Di luar scope

- Registrasi, lupa password, verifikasi NIK ke pemerintah.
- Simpan draft, notifikasi push (FCM), mode offline, iOS.
- Pembayaran PBB, cetak SPPT, multi-bahasa, multi-wilayah.

## 3. Arsitektur dan Teknologi

- Flutter (stable terbaru), Dart, **feature-based architecture**: `lib/features/{auth, home, nop, pengajuan, akun}` dengan lapisan `data`/`domain`/`presentation`, serta `lib/core` untuk HTTP client, tema, dan util.
- Rekomendasi paket (boleh diganti mengikuti `AGENTS.md` tim): `dio`, `flutter_riverpod`, `go_router`, `flutter_secure_storage` (token), `shared_preferences` (mode gelap), `flutter_map` + `latlong2` (peta OSM), `image_picker`, `file_picker`, `flutter_image_compress`.
- Base URL API diatur lewat konfigurasi build (mis. `--dart-define=API_BASE_URL=...`), bukan ditulis permanen di kode.
- Satu wrapper respons terpusat: membaca envelope `success/message/data/errors/meta` dan memetakan error 422 ke pesan per field pada formulir.
- Interceptor: sisipkan Bearer token; bila 401, hapus token dan arahkan ke Login.
- Mode gelap dan terang memakai tema Material 3 dengan satu warna utama; mode gelap disimpan lokal dan tidak dikirim ke server.

## 4. Navigasi dan Daftar Layar

| Layar | Akses | Ringkasan |
|---|---|---|
| Login | publik | Username + password. Tanpa tombol daftar. |
| Beranda | tab 1 | Salam + 2 tombol besar: Objek Baru dan Mutasi. Opsional: ringkasan jumlah pengajuan menunggu. |
| NOP | tab 2 | Daftar objek pajak akun, badge status, tarik untuk muat ulang, paginasi. |
| Detail NOP / Pengajuan | dari tab NOP | Data objek, wajib pajak, status, catatan penolakan, daftar berkas, tombol Revisi bila ditolak. |
| Akun | tab 3 | Profil; ubah username; ganti password; saklar mode gelap; logout. |
| Objek Baru | dari Beranda | Formulir SPOP Objek Baru (bagian 6). |
| Pilih Jenis Mutasi | dari Beranda | 3 kartu: Mutasi Penuh, Mutasi Sebagian/Pemecahan, Mutasi Penggabungan Objek. |
| Mutasi Penuh / Sebagian / Penggabungan | dari Pilih Jenis | Formulir masing-masing (bagian 6). |
| Sket Lokasi (peta) | dari formulir | Layar penuh untuk meletakkan marker atau menggambar polygon. |

## 5. Spesifikasi Layar

### Login

- Field username dan password (tampil/sembunyi). Tombol **Masuk** menonaktif saat memuat.
- Gagal login: tampilkan pesan dari server (mis. "Username atau password salah."). Akun non-Wajib Pajak ditolak server.
- Setelah sukses: simpan token di secure storage, buka Beranda. Saat aplikasi dibuka ulang dan token masih ada, langsung ke Beranda (validasi lewat `GET /me`).

### NOP dan badge status

- Tiap item: NOP (atau teks "NOP belum terbit" bila `null`), alamat singkat, luas tanah, badge status.
- Objek Baru yang baru disimpan langsung muncul dengan badge **Menunggu** dan NOP kosong sampai disetujui admin.
- Warna badge: Menunggu = kuning/oranye, Ditolak = merah, Disetujui dan Terdaftar = hijau. **Selalu sertakan teks label** (jangan hanya warna).
- Keadaan kosong (belum ada NOP), memuat (skeleton), dan galat (tombol **Coba Lagi**) wajib ada.

### Alur revisi

- Pada Detail Pengajuan berstatus **Ditolak**: tampilkan catatan admin di bagian atas, lalu tombol **Perbaiki dan Kirim Ulang**.
- Tombol membuka formulir yang sama, terisi data sebelumnya (dari `GET /pengajuan/{id}`). Berkas yang sudah ada ditampilkan; user hanya mengganti yang perlu.
- Kirim lewat `POST /pengajuan/{id}/revisi`. Sukses: status kembali Menunggu.

### Akun

- Profil: nama, username, NIK (disamarkan sebagian, mis. `3372********0001`), NPWP bila ada.
- Ubah username dan ganti password lewat dialog atau layar kecil; tampilkan galat per field dari server.
- Mode gelap: saklar, berlaku seketika, tersimpan lokal.
- Logout: panggil `POST /auth/logout` lalu hapus token lokal, kembali ke Login.

## 6. Spesifikasi Formulir

Semua formulir: validasi di sisi klien untuk umpan balik cepat, tetapi server tetap menjadi penentu. Pesan galat 422 ditampilkan di bawah field terkait. Formulir panjang dibagi per bagian (stepper atau seksi yang dapat digulir) sesuai judul di bawah. Tombol Kirim menonaktif selama proses; cegah kirim ganda.

Pilihan (enum) dikirim sebagai **slug teks** seperti pada kolom Aturan. Backend yang memetakan slug ke kode kolom basis data (beberapa kolom di dump bertipe `char(1)`). Aplikasi mobile tidak perlu tahu kode tersebut.

### 6.1 Objek Baru

Jenis transaksi tetap: **Permohonan Objek Baru PBB P2** (tampil read-only, tidak dikirim sebagai field).
Endpoint: `POST /pengajuan/objek-baru` (multipart).

**Objek Baru: Informasi Tambahan**

| Key | Label | Tipe | Wajib | Aturan |
|---|---|---|---|---|
| `nop_bersama` | NOP Bersama | teks | Tidak | maks 50 |
| `no_sppt_lama` | No. SPPT Lama | teks | Tidak | maks 50 |

**Objek Baru: Data Letak Objek Pajak**

| Key | Label | Tipe | Wajib | Aturan |
|---|---|---|---|---|
| `op_nama_jalan` | Nama Jalan (objek) | teks | Ya | maks 100 karakter |
| `op_blok_no` | Blok & No Rumah | teks | Tidak | maks 50 karakter |
| `op_kecamatan_id` | Kecamatan | pilihan | Ya | dari API wilayah; hanya Kota Solo |
| `op_kelurahan_id` | Kelurahan | pilihan | Ya | bergantung kecamatan terpilih |
| `op_rt` | RT | angka | Ya | 1-3 digit |
| `op_rw` | RW | angka | Ya | 1-3 digit |

**Objek Baru: Data Subjek Pajak**

| Key | Label | Tipe | Wajib | Aturan |
|---|---|---|---|---|
| `nik` | Nomor KTP/NIK | teks angka | Ya | tepat 16 digit numerik (hanya cek format, tanpa verifikasi pemerintah) |
| `status_subjek` | Status | pilihan | Ya | `pemilik`, `penyewa`, `pengelola`, `pemangkai`, `sengketa` |
| `pekerjaan` | Pekerjaan | pilihan | Ya | `pns`, `abri`, `pensiunan`, `badan`, `lainnya` |
| `nama_subjek` | Nama Subjek Pajak | teks | Ya | maks 100 karakter |
| `no_telp` | No. Telp / No. HP | teks angka | Ya | 8-15 digit, boleh diawali `+` |
| `npwp` | NPWP | teks angka | Tidak | bila diisi: 15 atau 16 digit (titik dan strip dibuang sebelum validasi) |
| `wp_nama_jalan` | Nama Jalan (subjek) | teks | Ya | maks 100 |
| `wp_blok_no` | Blok & No Rumah (subjek) | teks | Tidak | maks 50 |
| `wp_kelurahan` | Kelurahan / Desa | teks | Ya | teks bebas (alamat subjek bisa di luar Solo) |
| `wp_rt` | RT | angka | Ya | 1-3 digit |
| `wp_rw` | RW | angka | Ya | 1-3 digit |
| `wp_kecamatan` | Kecamatan | teks | Ya | teks bebas |
| `wp_kabupaten_kota` | Kabupaten / Kota | teks | Ya | teks bebas |
| `wp_kode_pos` | Kode Pos | teks angka | Ya | 5 digit |

**Objek Baru: Tanah, Bangunan, Pernyataan, Sket**

| Key | Label | Tipe | Wajib | Aturan |
|---|---|---|---|---|
| `luas_tanah` | Luas Tanah (m²) | desimal | Ya | lebih dari 0, maks 2 desimal |
| `jenis_tanah` | Jenis Tanah | pilihan | Ya | `tanah_bangunan`, `kavling_siap_bangun`, `tanah_kosong`, `fasilitas_umum`, `lahan_pertanian` |
| `no_sertifikat` | Nomor Sertifikat | teks | Tidak | maks 50 |
| `jumlah_bangunan` | Jumlah Bangunan | bilangan bulat | Ya | 0 atau lebih |
| `pernyataan` | Pernyataan Subjek Pajak | checkbox | Ya | harus dicentang (`true`). Teks pernyataan tampil utuh sesuai Pasal 9 ayat (2) UU No. 12 Tahun 1985 |
| `geometry` | Sket / Denah Lokasi | GeoJSON | Ya | satu Point (marker) atau satu Polygon, koordinat WGS84 `[lon, lat]` |

### 6.2 Mutasi Penuh

Jenis transaksi tetap: **Mutasi / Perubahan Subjek dan Objek Pajak PBB P2**.
Endpoint: `POST /pengajuan/mutasi-penuh` (multipart).

Setelah memilih NOP, tampilkan data lama sebagai referensi dan isi awal field letak objek serta tanah dari data tersebut. **Asumsi:** field isian boleh diubah user; yang dikunci hanya NOP. Subjek pajak diisi data pemilik/penguasa baru.

**Mutasi Penuh: NOP**

| Key | Label | Tipe | Wajib | Aturan |
|---|---|---|---|---|
| `nop` | NOP yang diubah | pilihan | Ya | dipilih dari daftar NOP milik akun; data lama tampil read-only: alamat, jenis tanah, luas tanah, kode ZNT, jumlah bangunan, no. sertifikat, serta NIK, nama, alamat, NPWP, pekerjaan, kepemilikan wajib pajak |

**Mutasi Penuh: Data Letak Objek Pajak**

| Key | Label | Tipe | Wajib | Aturan |
|---|---|---|---|---|
| `op_nama_jalan` | Nama Jalan (objek) | teks | Ya | maks 100 karakter |
| `op_blok_no` | Blok & No Rumah | teks | Tidak | maks 50 karakter |
| `op_kecamatan_id` | Kecamatan | pilihan | Ya | dari API wilayah; hanya Kota Solo |
| `op_kelurahan_id` | Kelurahan | pilihan | Ya | bergantung kecamatan terpilih |
| `op_rt` | RT | angka | Ya | 1-3 digit |
| `op_rw` | RW | angka | Ya | 1-3 digit |

**Mutasi Penuh: Data Subjek Pajak**

| Key | Label | Tipe | Wajib | Aturan |
|---|---|---|---|---|
| `nik` | Nomor KTP/NIK | teks angka | Ya | tepat 16 digit numerik (hanya cek format, tanpa verifikasi pemerintah) |
| `status_subjek` | Status | pilihan | Ya | `pemilik`, `penyewa`, `pengelola`, `pemangkai`, `sengketa` |
| `pekerjaan` | Pekerjaan | pilihan | Ya | `pns`, `abri`, `pensiunan`, `badan`, `lainnya` |
| `nama_subjek` | Nama Subjek Pajak | teks | Ya | maks 100 karakter |
| `no_telp` | No. Telp / No. HP | teks angka | Ya | 8-15 digit, boleh diawali `+` |
| `npwp` | NPWP | teks angka | Tidak | bila diisi: 15 atau 16 digit (titik dan strip dibuang sebelum validasi) |
| `wp_nama_jalan` | Nama Jalan (subjek) | teks | Ya | maks 100 |
| `wp_blok_no` | Blok & No Rumah (subjek) | teks | Tidak | maks 50 |
| `wp_kelurahan` | Kelurahan / Desa | teks | Ya | teks bebas (alamat subjek bisa di luar Solo) |
| `wp_rt` | RT | angka | Ya | 1-3 digit |
| `wp_rw` | RW | angka | Ya | 1-3 digit |
| `wp_kecamatan` | Kecamatan | teks | Ya | teks bebas |
| `wp_kabupaten_kota` | Kabupaten / Kota | teks | Ya | teks bebas |
| `wp_kode_pos` | Kode Pos | teks angka | Ya | 5 digit |

**Mutasi Penuh: Tanah, Bangunan, Pernyataan, Sket**

| Key | Label | Tipe | Wajib | Aturan |
|---|---|---|---|---|
| `luas_tanah` | Luas Tanah (m²) | desimal | Ya | lebih dari 0, maks 2 desimal |
| `jenis_tanah` | Jenis Tanah | pilihan | Ya | `tanah_bangunan`, `kavling_siap_bangun`, `tanah_kosong`, `fasilitas_umum`, `lahan_pertanian` |
| `no_sertifikat` | Nomor Sertifikat | teks | Tidak | maks 50 |
| `jumlah_bangunan` | Jumlah Bangunan | bilangan bulat | Ya | 0 atau lebih |
| `pernyataan` | Pernyataan Subjek Pajak | checkbox | Ya | harus dicentang (`true`). Teks pernyataan tampil utuh sesuai Pasal 9 ayat (2) UU No. 12 Tahun 1985 |
| `geometry` | Sket / Denah Lokasi | GeoJSON | Ya | satu Point (marker) atau satu Polygon, koordinat WGS84 `[lon, lat]` |

### 6.3 Mutasi Sebagian / Pemecahan

Jenis pelayanan: **Pendaftaran Mutasi Sebagian**.
Endpoint: `POST /pengajuan/mutasi-sebagian` (**JSON**, tanpa berkas).

| Key | Label | Tipe | Wajib | Aturan |
|---|---|---|---|---|
| `nop` | NOP Induk | pilihan | Ya | dari daftar NOP akun; data induk tampil read-only (RT, RW, jalan, blok, kelurahan, kecamatan, jenis tanah, luas tanah, luas bangunan, kode ZNT, jumlah bangunan, no. sertifikat) beserta data wajib pajak |
| `jumlah_bidang` | Jumlah Bidang | bilangan bulat | Ya | minimal 2 |
| `keterangan` | Keterangan | teks panjang | Ya | maks 500 karakter |

### 6.4 Mutasi Penggabungan Objek

Tampilkan **tiga peringatan** di atas formulir:

1. NOP yang digabung harus lebih dari 1.
2. Lokasi harus pada kecamatan, kelurahan, dan blok yang sama.
3. Lokasi harus bersebelahan.

Tombol **Tambah NOP** memanggil `GET /nop/{nop}/cek`; bila Oracle menyatakan NOP tidak ada atau berbeda kecamatan/kelurahan/blok dari NOP pertama, tampilkan pesan dari server dan **jangan tambahkan**.
Endpoint: `POST /pengajuan/mutasi-penggabungan` (multipart).

**Penggabungan: NOP dan Deklarasi**

| Key | Label | Tipe | Wajib | Aturan |
|---|---|---|---|---|
| `nop_list[]` | Daftar NOP yang digabung | larik teks | Ya | minimal 2 NOP, tanpa duplikat; setiap NOP dicek ke Oracle: ada, serta kecamatan, kelurahan, dan blok sama |
| `deklarasi_bersebelahan` | Deklarasi bersebelahan | checkbox | Ya | harus dicentang; keabsahan dicek manual oleh admin |
| `nop_bersama` | NOP Bersama | teks | Tidak | maks 50 |
| `no_sppt_lama` | No. SPPT Lama | teks | Tidak | maks 50 |

**Penggabungan: Data Letak Objek Pajak**

| Key | Label | Tipe | Wajib | Aturan |
|---|---|---|---|---|
| `op_nama_jalan` | Nama Jalan (objek) | teks | Ya | maks 100 karakter |
| `op_blok_no` | Blok & No Rumah | teks | Tidak | maks 50 karakter |
| `op_kecamatan_id` | Kecamatan | pilihan | Ya | dari API wilayah; hanya Kota Solo |
| `op_kelurahan_id` | Kelurahan | pilihan | Ya | bergantung kecamatan terpilih |
| `op_rt` | RT | angka | Ya | 1-3 digit |
| `op_rw` | RW | angka | Ya | 1-3 digit |

**Penggabungan: Data Subjek Pajak**

| Key | Label | Tipe | Wajib | Aturan |
|---|---|---|---|---|
| `nik` | Nomor KTP/NIK | teks angka | Ya | tepat 16 digit numerik (hanya cek format, tanpa verifikasi pemerintah) |
| `status_subjek` | Status | pilihan | Ya | `pemilik`, `penyewa`, `pengelola`, `pemangkai`, `sengketa` |
| `pekerjaan` | Pekerjaan | pilihan | Ya | `pns`, `abri`, `pensiunan`, `badan`, `lainnya` |
| `nama_subjek` | Nama Subjek Pajak | teks | Ya | maks 100 karakter |
| `no_telp` | No. Telp / No. HP | teks angka | Ya | 8-15 digit, boleh diawali `+` |
| `npwp` | NPWP | teks angka | Tidak | bila diisi: 15 atau 16 digit (titik dan strip dibuang sebelum validasi) |
| `wp_nama_jalan` | Nama Jalan (subjek) | teks | Ya | maks 100 |
| `wp_blok_no` | Blok & No Rumah (subjek) | teks | Tidak | maks 50 |
| `wp_kelurahan` | Kelurahan / Desa | teks | Ya | teks bebas (alamat subjek bisa di luar Solo) |
| `wp_rt` | RT | angka | Ya | 1-3 digit |
| `wp_rw` | RW | angka | Ya | 1-3 digit |
| `wp_kecamatan` | Kecamatan | teks | Ya | teks bebas |
| `wp_kabupaten_kota` | Kabupaten / Kota | teks | Ya | teks bebas |
| `wp_kode_pos` | Kode Pos | teks angka | Ya | 5 digit |

**Penggabungan: Tanah, Bangunan, Pernyataan, Sket**

| Key | Label | Tipe | Wajib | Aturan |
|---|---|---|---|---|
| `kode_znt` | Kode ZNT | teks | Tidak | maks 10; admin dapat mengoreksi saat persetujuan |
| `luas_tanah` | Luas Tanah (m²) | desimal | Ya | lebih dari 0, maks 2 desimal |
| `jenis_tanah` | Jenis Tanah | pilihan | Ya | `tanah_bangunan`, `kavling_siap_bangun`, `tanah_kosong`, `fasilitas_umum`, `lahan_pertanian` |
| `no_sertifikat` | Nomor Sertifikat | teks | Tidak | maks 50 |
| `jumlah_bangunan` | Jumlah Bangunan | bilangan bulat | Ya | 0 atau lebih |
| `pernyataan` | Pernyataan Subjek Pajak | checkbox | Ya | harus dicentang (`true`). Teks pernyataan tampil utuh sesuai Pasal 9 ayat (2) UU No. 12 Tahun 1985 |
| `geometry` | Sket / Denah Lokasi | GeoJSON | Ya | satu Point (marker) atau satu Polygon, koordinat WGS84 `[lon, lat]` |

### Matriks Berkas per Jenis Pengajuan

Keterangan: **W** = wajib, **O** = opsional, **-** = tidak ada.
**OB** = Objek Baru, **MP** = Mutasi Penuh, **MS** = Mutasi Sebagian, **MG** = Mutasi Penggabungan.
Key berkas dipakai sebagai nama field upload.

| Key | Nama berkas | OB | MP | MS | MG |
|---|---|---|---|---|---|
| `ktp` | Lampiran KTP | W | W | - | W |
| `kk` | Lampiran KK | O | - | - | - |
| `sertifikat` | Sertifikat / Bukti Kepemilikan / Bukti Tanah Lainnya | W | W | - | W |
| `sppt_pbb` | SPPT PBB | - | - | - | W |
| `sppt_tetangga` | SPPT PBB Tetangga | W | W | - | - |
| `surat_ket_pembayaran` | Surat Keterangan Pembayaran PBB | - | O | - | O |
| `surat_ket_desa` | Surat Keterangan Desa / Kelurahan | O | O | - | O |
| `surat_kuasa` | Surat Kuasa dari Wajib Pajak (bila dikuasakan) | O | O | - | O |
| `foto_lokasi` | Foto Lokasi Objek | O | O | - | O |
| `imb_pbg` | IMB / PBG | O | O | - | O |

**Aturan berkas (semua jenis):** maksimal 1 MB per file; tipe `.jpg` `.jpeg` `.png` `.pdf`; gambar harus jelas, terbaca, dan tidak terbalik/miring (diperiksa admin). Mutasi Sebagian tidak memiliki lampiran.

## 7. Upload Berkas

- Sumber: kamera, galeri (`image_picker`), atau file PDF (`file_picker`).
- Gambar dikompres otomatis di klien hingga di bawah 1 MB (turunkan kualitas/resolusi bertahap). Jika tetap di atas 1 MB, tolak dengan pesan jelas.
- PDF tidak dikompres: bila lebih dari 1 MB, tampilkan pesan **"Ukuran file maksimal 1 MB"**.
- Tampilkan pratinjau (gambar) atau nama file (PDF), tombol hapus/ganti, dan penanda **Wajib**. Berkas wajib kosong menghalangi pengiriman.
- Kirim sebagai bagian multipart dengan nama field = key berkas (mis. `ktp`, `sertifikat`).

## 8. Peta Sket Lokasi

- Pustaka: `flutter_map` dengan tile OpenStreetMap. Cantumkan atribusi **"OpenStreetMap contributors"** pada peta (syarat lisensi OSM).
- Pusat awal peta: Kota Solo. Pengguna dapat memilih mode **Marker** (satu titik) atau **Polygon** (minimal 3 titik, bisa undo dan hapus).
- Keluaran: GeoJSON Point atau Polygon (koordinat `[longitude, latitude]`, WGS84), dikirim sebagai string JSON pada field `geometry`.
- Tile OSM publik tidak untuk lalu lintas besar; cukup untuk demo. Atur User-Agent paket aplikasi pada tile layer.

## 9. Aturan Validasi Klien Ringkas

- NIK: tepat 16 digit angka. NPWP: kosong atau 15/16 digit setelah titik dan strip dibuang.
- No. telp: 8-15 digit. Kode pos: 5 digit. RT/RW: 1-3 digit.
- Luas tanah lebih dari 0. Jumlah bangunan 0 atau lebih. Jumlah bidang minimal 2.
- Pernyataan harus dicentang. Sket lokasi wajib (satu marker atau satu polygon).
- Seluruh berkas wajib terisi sesuai matriks, tiap berkas maks 1 MB dan tipe yang diizinkan.

---

## Kontrak API (v1)

Base URL: `{host}/api/v1`. Header: `Accept: application/json`; setelah login `Authorization: Bearer {token}`.
Semua pesan dalam Bahasa Indonesia. Zona waktu Asia/Jakarta, tanggal ISO 8601.

| Method | Path | Auth | Keterangan |
|---|---|---|---|
| POST | `/api/v1/auth/login` | publik | Body: `username`, `password`. Hanya role Wajib Pajak. Respons: token Sanctum + profil. |
| POST | `/api/v1/auth/logout` | token | Mencabut token yang sedang dipakai. |
| GET | `/api/v1/me` | token | Profil akun (`name`, `username`, `nik`, `npwp` bila ada). |
| PATCH | `/api/v1/me/username` | token | Body: `username` (unik, 4-30 karakter, huruf/angka/titik/garis bawah). |
| PUT | `/api/v1/me/password` | token | Body: `password_lama`, `password_baru`, `password_baru_confirmation` (min 8). |
| GET | `/api/v1/referensi` | token | Daftar pilihan (`status_subjek`, `pekerjaan`, `jenis_tanah`) dan matriks berkas per jenis pelayanan. |
| GET | `/api/v1/wilayah/kecamatan` | token | Kecamatan Kota Solo. |
| GET | `/api/v1/wilayah/kecamatan/{id}/kelurahan` | token | Kelurahan dalam satu kecamatan. |
| GET | `/api/v1/nop` | token | Daftar NOP/objek milik akun beserta badge status (paginasi). |
| GET | `/api/v1/nop/{nop}` | token | Detail objek + wajib pajak (dari Oracle atau cache) untuk NOP yang tertaut ke akun. |
| GET | `/api/v1/nop/{nop}/cek` | token | Cek NOP di Oracle (dipakai Penggabungan untuk menambah NOP). Respons: ada/tidak, kecamatan, kelurahan, blok. |
| POST | `/api/v1/pengajuan/objek-baru` | token | `multipart/form-data`. Membuat pengajuan Objek Baru. |
| POST | `/api/v1/pengajuan/mutasi-penuh` | token | `multipart/form-data`. |
| POST | `/api/v1/pengajuan/mutasi-sebagian` | token | JSON. |
| POST | `/api/v1/pengajuan/mutasi-penggabungan` | token | `multipart/form-data`. |
| GET | `/api/v1/pengajuan` | token | Riwayat pengajuan milik akun (filter `status`, `jenis`). |
| GET | `/api/v1/pengajuan/{id}` | token | Detail lengkap (data form, berkas, riwayat status, catatan penolakan). |
| POST | `/api/v1/pengajuan/{id}/revisi` | token | `multipart/form-data`. Hanya bila status `ditolak`; kembali menjadi `menunggu`. |

### Format respons

```jsonc
// Sukses
{ "success": true, "message": "OK", "data": { } }

// Daftar
{ "success": true, "data": [ ], "meta": { "page": 1, "per_page": 15, "total": 42 } }

// Gagal
{ "success": false, "message": "Data tidak valid.", "errors": { "nik": ["NIK harus 16 digit."] } }
```

Kode status HTTP:

- `401` = tidak login / token salah
- `403` = bukan milik akun
- `404` = tidak ada
- `422` = validasi gagal
- `429` = terlalu banyak percobaan login

### Contoh respons login dan daftar NOP

```jsonc
// POST /auth/login
// Request: { "username": "budi01", "password": "rahasia123" }
{
  "success": true,
  "data": {
    "token": "1|AbCdEf...",
    "user": { "id": 7, "name": "Budi Santoso", "username": "budi01", "nik": "3372010101900001" }
  }
}

// GET /nop
{
  "success": true,
  "data": [
    {
      "nop": "33.72.010.001.005-0123.0",
      "alamat": "Jl. Slamet Riyadi No. 10, Laweyan",
      "luas_tanah": 120.0,
      "status": "terdaftar",
      "pengajuan_terakhir": null
    },
    {
      "nop": null,
      "alamat": "Jl. Veteran No. 5, Serengan",
      "luas_tanah": 90.0,
      "status": "menunggu",
      "pengajuan_terakhir": { "id": 31, "nomor": "ELY-2026-00031", "jenis": "objek_baru" }
    }
  ],
  "meta": { "page": 1, "per_page": 15, "total": 2 }
}
```

> Contoh NOP di atas hanya ilustrasi format. Panjang dan struktur NOP mengikuti data Oracle `PBBDUMMY`.

### Status pengajuan (dipakai di badge dan filter)

| Nilai | Label badge | Arti | Aksi user |
|---|---|---|---|
| `menunggu` | Menunggu | Baru dikirim atau dikirim ulang setelah revisi. Menunggu admin. | Tidak bisa diedit. |
| `ditolak` | Ditolak | Admin menolak dengan catatan wajib. | Bisa diedit lalu dikirim ulang (status kembali `menunggu`). |
| `disetujui` | Disetujui | Admin menyetujui. Untuk Objek Baru, NOP resmi sudah diisi admin. | Tidak bisa diedit. |
| `terdaftar` | Terdaftar | Khusus daftar NOP: objek resmi tanpa pengajuan yang tertunda atau ditolak. | - |

Jenis pengajuan: `objek_baru`, `mutasi_penuh`, `mutasi_sebagian`, `mutasi_penggabungan`.
Nomor pendaftaran berformat `ELY-{tahun}-{urut 5 digit}`.

---

## 10. Kualitas dan Non-Fungsional

- Android saja; uji pada minimal satu ponsel fisik atau emulator.
- Token hanya di secure storage; jangan mencatat password atau token ke log.
- Semua layar menangani tiga keadaan: **memuat, kosong, galat**.
- Teks Bahasa Indonesia, konsisten istilah (NOP, SPOP, Wajib Pajak, Objek Pajak).
- Aksesibilitas dasar: label pada ikon, kontras warna cukup di kedua tema, target sentuh minimal 48 dp.
- Tidak ada rahasia (URL privat, kredensial) yang ditulis permanen di repositori.

## 11. Asumsi dan Hal Terbuka

- Wajib/opsional beberapa field (mis. no. telp wajib, NPWP opsional) adalah asumsi PRD; selaraskan dengan website asli bila berbeda.
- Pada Mutasi Penuh, field isian boleh diubah; hanya NOP yang dikunci.
- Kode ZNT pada Penggabungan dibuat opsional; pada Objek Baru NOP dan ZNT diisi admin saat persetujuan.
- Desain visual (warna, ikon) belum ditetapkan; pilih tema sederhana yang konsisten dan dokumentasikan di `docs/ui-guidelines.md`.

## 12. Kriteria Selesai (Checklist Demo)

- [ ] Login dengan akun seeder berhasil; logout menghapus sesi.
- [ ] Objek Baru: formulir lengkap + peta + berkas terkirim; objek muncul di tab NOP berbadge Menunggu.
- [ ] Setelah admin menolak: catatan tampil, user mengedit dan kirim ulang, status kembali Menunggu.
- [ ] Setelah admin menyetujui: badge menjadi Disetujui/Terdaftar dan NOP resmi tampil.
- [ ] Tiga jenis Mutasi dapat dikirim; Penggabungan menolak NOP yang tidak sesuai (kecamatan/kelurahan/blok berbeda).
- [ ] Ubah username, ganti password, mode gelap berfungsi; tampilan rapi di layar ponsel umum.