# PANDUAN IMPLEMENTASI SISTEM KOPMA DENGAN LARAVEL
**Studi Kasus:** Sistem Informasi Koperasi Mahasiswa (SI-KOPMA)  
**NIM:** kopma_npm  
**Mata Kuliah:** Basis Data Lanjut  

---

## 1. Struktur Folder Proyek
```text
laravel_kopma/
├── app/
│   ├── Http/Controllers/
│   │   ├── DashboardController.php   (Statistik kas, anggota, dan inventori)
│   │   ├── AnggotaController.php     (CRUD anggota & data keaktifan)
│   │   ├── SimpananController.php    (Setoran & penarikan simpanan)
│   │   ├── KasirController.php       (POS kasir + ACID Transaction + Diskon Anggota)
│   │   └── ShuController.php         (Perhitungan otomatis JMA & JUA per anggota)
│   └── Models/
│       ├── User.php
│       ├── Anggota.php
│       ├── JenisSimpanan.php
│       ├── TransaksiSimpanan.php
│       ├── KategoriBarang.php
│       ├── Barang.php
│       ├── Penjualan.php
│       └── PenjualanDetail.php
├── database/
│   ├── migrations/                  (8 Migration Blueprint relasi tabel)
│   └── seeders/
│       ├── DatabaseSeeder.php
│       └── KopmaSeeder.php          (Data awal testing anggota, produk, kasir)
├── resources/views/
│   ├── layouts/app.blade.php        (Template UI Bootstrap 5 Navbar & Footer)
│   ├── dashboard.blade.php          (Metrik realtime & peringatan stok menipis)
│   ├── anggota/index.blade.php      (Tabel anggota & modal tambah anggota)
│   ├── simpanan/index.blade.php     (Form setor/tarik & riwayat mutasi kas)
│   ├── kasir/index.blade.php        (Keranjang belanja POS, hitung kembalian)
│   └── shu/index.blade.php          (Rekapitulasi SHU transparan)
└── routes/
    ├── web.php                      (Rute navigasi modul web)
    └── api.php                      (Endpoint API pencarian barcode & NIM)
```

---

## 2. Cara Menjalankan Aplikasi di Localhost (XAMPP)

1. **Jalankan Apache & MySQL di XAMPP Control Panel**.
2. **Buat Database Baru di phpMyAdmin**:
   - Buka `http://localhost/phpmyadmin`
   - Buat database baru bernama: `kopma_npm`
3. **Salin file konfigurasi lingkungan**:
   - Salin `.env.example` menjadi `.env`
   - Sesuaikan konfigurasi database:
     ```env
     DB_DATABASE=kopma_npm
     DB_USERNAME=root
     DB_PASSWORD=
     ```
4. **Jalankan Migrasi & Seeder Database**:
   ```bash
   php artisan migrate --seed
   ```
5. **Jalankan Web Server**:
   ```bash
   php artisan serve
   ```
   Aplikasi dapat diakses melalui browser pada: `http://localhost:8000`

---

## 3. Poin-Poin Penting untuk Presentasi ke Dosen Basis Data Lanjut

### A. Konsep Transaksi ACID pada `KasirController.php`
Perhatikan blok kode berikut pada method `checkout()`:
```php
DB::beginTransaction();
try {
    // 1. Kunci baris stok agar tidak terjadi race condition
    $barang = Barang::lockForUpdate()->findOrFail($item['id']);
    
    // 2. Kurangi stok fisik
    $barang->decrement('stok', $item['qty']);

    // 3. Simpan nota transaksi
    $penjualan = Penjualan::create([...]);

    // 4. Jika ada error di tengah jalan -> ROLLBACK otomatis
    DB::commit();
} catch (\Exception $e) {
    DB::rollBack();
}
```
*Penjelasan:* Ini membuktikan sistem mematuhi kaidah **Atomicity** (semua langkah sukses atau semua dibatalkan).

### B. Otomatisasi Perhitungan SHU pada `ShuController.php`
Perhitungan SHU menggunakan agregasi query:
1. **Jasa Modal Anggota (JMA):**
   $$\frac{\text{Simpanan Anggota}}{\text{Total Simpanan Seluruh Koperasi}} \times \text{Alokasi Dana JMA (40\%) }$$
2. **Jasa Usaha Anggota (JUA):**
   $$\frac{\text{Akumulasi Belanja Anggota}}{\text{Total Omset Belanja Seluruh Koperasi}} \times \text{Alokasi Dana JUA (60\%) }$$

Dengan sistem ini, penutupan buku tahunan KOPMA dapat dihitung secara instan dalam hitungan detik.
