-- =====================================================================
-- SKEMA BASIS DATA SISTEM INFORMASI KOPMA (KOPERASI MAHASISWA)
-- Mata Kuliah: Basis Data Lanjut
-- =====================================================================

CREATE DATABASE IF NOT EXISTS kopma_npm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE kopma_npm;

-- 1. Tabel Users (Kredensial & Hak Akses Pengurus/Kasir)
CREATE TABLE IF NOT EXISTS users (
    id_user INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nama_lengkap VARCHAR(100) NOT NULL,
    role ENUM('admin', 'kasir', 'bendahara') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabel Anggota (Data Mahasiswa yang menjadi anggota KOPMA)
CREATE TABLE IF NOT EXISTS anggota (
    id_anggota INT AUTO_INCREMENT PRIMARY KEY,
    nim VARCHAR(20) NOT NULL UNIQUE,
    nama VARCHAR(100) NOT NULL,
    jurusan VARCHAR(50),
    fakultas VARCHAR(50),
    no_hp VARCHAR(20),
    email VARCHAR(100),
    status_aktif ENUM('aktif', 'cuti', 'non_aktif') DEFAULT 'aktif',
    tanggal_gabung DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tabel Jenis Simpanan
CREATE TABLE IF NOT EXISTS jenis_simpanan (
    id_jenis INT AUTO_INCREMENT PRIMARY KEY,
    nama_jenis VARCHAR(50) NOT NULL, -- Pokok, Wajib, Sukarela
    nominal_standar DECIMAL(12,2) DEFAULT 0,
    keterangan TEXT
);

-- 4. Tabel Transaksi Simpanan (Pencatatan Setoran & Penarikan)
CREATE TABLE IF NOT EXISTS transaksi_simpanan (
    id_transaksi INT AUTO_INCREMENT PRIMARY KEY,
    id_anggota INT NOT NULL,
    id_jenis INT NOT NULL,
    id_petugas INT NOT NULL,
    tanggal_transaksi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    jenis_mutasi ENUM('setor', 'tarik') NOT NULL,
    nominal DECIMAL(12,2) NOT NULL,
    keterangan VARCHAR(255),
    FOREIGN KEY (id_anggota) REFERENCES anggota(id_anggota) ON UPDATE CASCADE,
    FOREIGN KEY (id_jenis) REFERENCES jenis_simpanan(id_jenis) ON UPDATE CASCADE,
    FOREIGN KEY (id_petugas) REFERENCES users(id_user) ON UPDATE CASCADE
);

-- 5. Tabel Kategori Barang
CREATE TABLE IF NOT EXISTS kategori_barang (
    id_kategori INT AUTO_INCREMENT PRIMARY KEY,
    nama_kategori VARCHAR(50) NOT NULL
);

-- 6. Tabel Master Barang Toko KOPMA
CREATE TABLE IF NOT EXISTS barang (
    id_barang INT AUTO_INCREMENT PRIMARY KEY,
    kode_barcode VARCHAR(50) NOT NULL UNIQUE,
    nama_barang VARCHAR(150) NOT NULL,
    id_kategori INT,
    harga_beli DECIMAL(12,2) NOT NULL,
    harga_jual_umum DECIMAL(12,2) NOT NULL,
    harga_jual_anggota DECIMAL(12,2) NOT NULL,
    stok INT DEFAULT 0,
    stok_minimum INT DEFAULT 5,
    FOREIGN KEY (id_kategori) REFERENCES kategori_barang(id_kategori) ON UPDATE CASCADE ON DELETE SET NULL
);

-- 7. Tabel Penjualan (Header Kasir)
CREATE TABLE IF NOT EXISTS penjualan (
    id_penjualan INT AUTO_INCREMENT PRIMARY KEY,
    no_struk VARCHAR(30) NOT NULL UNIQUE,
    tanggal_transaksi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_anggota INT NULL, -- NULL jika pembeli umum (bukan anggota)
    id_kasir INT NOT NULL,
    total_bruto DECIMAL(12,2) NOT NULL,
    total_diskon DECIMAL(12,2) DEFAULT 0,
    total_netto DECIMAL(12,2) NOT NULL,
    nominal_bayar DECIMAL(12,2) NOT NULL,
    kembalian DECIMAL(12,2) NOT NULL,
    metode_bayar ENUM('tunai', 'qris', 'saldo_simpanan') DEFAULT 'tunai',
    FOREIGN KEY (id_anggota) REFERENCES anggota(id_anggota) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (id_kasir) REFERENCES users(id_user) ON UPDATE CASCADE
);

-- 8. Tabel Detail Penjualan (Item Barang yang dibeli)
CREATE TABLE IF NOT EXISTS penjualan_detail (
    id_detail INT AUTO_INCREMENT PRIMARY KEY,
    id_penjualan INT NOT NULL,
    id_barang INT NOT NULL,
    jumlah INT NOT NULL,
    harga_satuan DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (id_penjualan) REFERENCES penjualan(id_penjualan) ON DELETE CASCADE,
    FOREIGN KEY (id_barang) REFERENCES barang(id_barang) ON UPDATE CASCADE
);
