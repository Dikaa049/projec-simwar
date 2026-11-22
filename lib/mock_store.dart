class SimwarLocalStore {
  static String namaWarung = 'Warung Azzam';
  static String alamatWarung = 'Pekanbaru';

  // 1. Akun Pengguna (Pemilik & Penjaga)
  static final List> pengguna = [
  {
  'nama': 'cudid',
  'no_hp': '6281266540421',
  'sandi': '123456',
  'peran': 'Pemilik',
  'status_akun': 'Aktif',
  },
  {
  'nama': 'Penjaga Shift 1',
  'no_hp': '6281200000001',
  'sandi': '123456',
  'peran': 'Penjaga',
  'status_akun': 'Aktif',
  },
  ];

  static Map<String, String>? userAktif;

  // 2. Data Master Barang & Batch Kedaluwarsa
  static final List> barang = [
  {
  'kode_barcode': '8991002101112',
  'nama': 'Beras Ramos 5kg',
  'kategori': 'Sembako',
  'harga_jual': 72000,
  'stok': 14,
  'stok_minimum': 5,
  'kedaluwarsa': '2027-06-15',
  'jenis': 'Reguler',
  },
  {
  'kode_barcode': '8992761112233',
  'nama': 'Minyak Goreng Bimoli 1L',
  'kategori': 'Sembako',
  'harga_jual': 18500,
  'stok': 3, // Stok menipis (<= stok_minimum)
  'stok_minimum': 6,
  'kedaluwarsa': '2027-03-10',
  'jenis': 'Reguler',
  },
  {
  'kode_barcode': '8998866200314',
  'nama': 'Indomie Goreng Original',
  'kategori': 'Mi Instan',
  'harga_jual': 3500,
  'stok': 42,
  'stok_minimum': 15,
  'kedaluwarsa': '2026-12-02', // Mendekati kedaluwarsa!
  'jenis': 'Reguler',
  },
  {
  'kode_barcode': '8993001122334',
  'nama': 'Susu Kental Manis Kaleng',
  'kategori': 'Minuman',
  'harga_jual': 12500,
  'stok': 2, // Stok menipis
  'stok_minimum': 5,
  'kedaluwarsa': '2026-11-28', // Mendekati kedaluwarsa!
  'jenis': 'Reguler',
  },
  ];

  // 3. Data Barang Konsinyasi (Titipan Pemasok & Bagi Hasil)
  static final List> konsinyasi = [
  {
  'pemasok': 'Ibu Siti (Kue Basah)',
  'nama_barang': 'Lontong Sayur & Gorengan Paket',
  'titip_awal': 20,
  'terjual': 15,
  'harga_jual': 2000,
  'setor_pemasok': 1500, // Laba warung Rp500/pcs
  },
  {
  'pemasok': 'Pak Budi (Kerupuk)',
  'nama_barang': 'Kerupuk Jangek Bungkus',
  'titip_awal': 15,
  'terjual': 9,
  'harga_jual': 5000,
  'setor_pemasok': 4000, // Laba warung Rp1.000/pcs
  },
  ];

  // 4. Data Kasbon Pelanggan
  static final List> kasbon = [
  {
  'nama_pelanggan': 'Pak RT 04',
  'kontak': '081371112233',
  'sisa_utang': 45000,
  'catatan': 'Beras & gula minggu lalu',
  },
  {
  'nama_pelanggan': 'Bang Hendra',
  'kontak': '085265443322',
  'sisa_utang': 18000,
  'catatan': 'Rokok & kopi',
  },
  ];

  // 5. Riwayat Transaksi Keluar & Penerimaan
  static final List> riwayatTransaksi = [
  {
  'waktu': 'Hari ini, 10:15',
  'jenis': 'Penjualan Tunai',
  'keterangan': 'Indomie Goreng Original (4 pcs)',
  'nominal': 14000,
  'petugas': 'Penjaga Shift 1',
  },
  ];
}