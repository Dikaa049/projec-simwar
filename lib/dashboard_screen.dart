import 'package:flutter/material.dart';
import 'api_service.dart';
import 'main.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tabIndex = 0;
  List _barang = [];
  List _pelanggan = [];
  List _laporan = [];
  List _penjaga = [];
  bool _loading = true;

  int get idWarung => int.tryParse(widget.user['id_warung'].toString()) ?? 1;
  int get idPengguna => int.tryParse(widget.user['id_pengguna'].toString()) ?? 1;
  bool get isPemilik => widget.user['peran'] == 'Pemilik';

  @override
  void initState() {
    super.initState();
    _muatSemuaData();
  }

  Future<void> _muatSemuaData() async {
    setState(() => _loading = true);
    final resDash = await ApiService.get('dashboard.php?id_warung=$idWarung');
    final resLap = await ApiService.get('laporan_aksi.php?id_warung=$idWarung');
    final resPenj = isPemilik ? await ApiService.get('penjaga.php?id_warung=$idWarung') : {'penjaga': []};

    if (mounted) {
      setState(() {
        if (resDash['status'] == 'sukses') {
          _barang = resDash['barang'] ?? [];
          _pelanggan = resDash['pelanggan'] ?? [];
        }
        if (resLap['status'] == 'sukses') {
          _laporan = resLap['laporan'] ?? [];
        }
        if (resPenj['status'] == 'sukses') {
          _penjaga = resPenj['penjaga'] ?? [];
        }
        _loading = false;
      });
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red.shade700 : kHijauTombol),
    );
  }

  String _rupiah(dynamic angka) {
    final val = (double.tryParse(angka.toString()) ?? 0).round();
    final str = val.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $str';
  }

  // ================= DIALOG KASIR / TRANSAKSI KELUAR =================
  Future<void> _bukaKasirDialog() async {
    if (_barang.isEmpty) {
      _snack('Stok barang masih kosong', error: true);
      return;
    }
    int selectedBarang = int.parse(_barang.first['id_barang'].toString());
    int? selectedPelanggan = _pelanggan.isNotEmpty ? int.parse(_pelanggan.first['id_pelanggan'].toString()) : null;
    String metode = 'Tunai';
    final qtyCtrl = TextEditingController(text: '1');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kKremLatar,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Mulai Jual (Kasir)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kHijauHeader)),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                value: selectedBarang,
                isExpanded: true,
                decoration: InputDecoration(labelText: 'Pilih Barang', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                items: _barang.map((b) => DropdownMenuItem<int>(
                  value: int.parse(b['id_barang'].toString()),
                  child: Text('${b['nama_barang']} • Stok: ${b['total_stok']} (${_rupiah(b['harga_jual'])})'),
                )).toList(),
                onChanged: (v) => setSt(() => selectedBarang = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Jumlah Beli', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 12),
              Row(
                children: ['Tunai', 'QRIS', 'Kasbon'].map((m) {
                  final pilih = metode == m;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Center(child: Text(m)),
                        selected: pilih,
                        selectedColor: kHijauTombol,
                        labelStyle: TextStyle(color: pilih ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                        onSelected: (_) => setSt(() => metode = m),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (metode == 'Kasbon' && _pelanggan.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedPelanggan,
                  decoration: InputDecoration(labelText: 'Nama Pelanggan Kasbon', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                  items: _pelanggan.map((p) => DropdownMenuItem<int>(
                    value: int.parse(p['id_pelanggan'].toString()),
                    child: Text(p['nama']),
                  )).toList(),
                  onChanged: (v) => setSt(() => selectedPelanggan = v),
                ),
              ],
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kHijauTombol, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final res = await ApiService.post('transaksi_keluar.php', {
                    'id_warung': idWarung,
                    'id_pengguna': idPengguna,
                    'id_barang': selectedBarang,
                    'jumlah': int.tryParse(qtyCtrl.text) ?? 1,
                    'metode': metode,
                    'id_pelanggan': selectedPelanggan,
                  });
                  _snack(res['pesan'] ?? '', error: res['status'] != 'sukses');
                  _muatSemuaData();
                },
                child: const Text('Selesaikan Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= DIALOG TERIMA BARANG / BARANG MASUK =================
  Future<void> _bukaTerimaBarangDialog({bool baruDefault = false}) async {
    String mode = (_barang.isEmpty || baruDefault) ? 'baru' : 'restok';
    int? selectedBarang = _barang.isNotEmpty ? int.parse(_barang.first['id_barang'].toString()) : null;
    final namaCtrl = TextEditingController();
    final barcodeCtrl = TextEditingController();
    final beliCtrl = TextEditingController();
    final jualCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '10');
    final edCtrl = TextEditingController(text: '2027-06-01');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kKremLatar,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Terima Pasokan / Barang Masuk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kHijauHeader)),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'restok', label: Text('Restok Barang')),
                    ButtonSegment(value: 'baru', label: Text('Produk Baru')),
                  ],
                  selected: {mode},
                  onSelectionChanged: (v) => setSt(() => mode = v.first),
                ),
                const SizedBox(height: 12),
                if (mode == 'restok' && _barang.isNotEmpty)
                  DropdownButtonFormField<int>(
                    value: selectedBarang,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: 'Pilih Barang', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                    items: _barang.map((b) => DropdownMenuItem<int>(
                      value: int.parse(b['id_barang'].toString()),
                      child: Text(b['nama_barang']),
                    )).toList(),
                    onChanged: (v) => setSt(() => selectedBarang = v),
                  )
                else ...[
                  TextField(controller: namaCtrl, decoration: InputDecoration(labelText: 'Nama Produk Baru', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                  const SizedBox(height: 8),
                  TextField(controller: barcodeCtrl, decoration: InputDecoration(labelText: 'Kode Barcode', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: beliCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga Modal', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: jualCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga Jual', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Jumlah Masuk', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: edCtrl, decoration: InputDecoration(labelText: 'Kedaluwarsa (YYYY-MM-DD)', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kHijauTombol, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final res = await ApiService.post('terima_barang.php', {
                      'id_warung': idWarung,
                      'id_pengguna': idPengguna,
                      'mode': mode,
                      'id_barang': selectedBarang,
                      'nama_barang': namaCtrl.text,
                      'kode_batang': barcodeCtrl.text,
                      'harga_beli': double.tryParse(beliCtrl.text) ?? 0,
                      'harga_jual': double.tryParse(jualCtrl.text) ?? 0,
                      'jumlah_fisik': int.tryParse(qtyCtrl.text) ?? 0,
                      'tanggal_kedaluwarsa': edCtrl.text,
                    });
                    _snack(res['pesan'] ?? '', error: res['status'] != 'sukses');
                    _muatSemuaData();
                  },
                  child: const Text('Simpan ke Stok Gudang', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HALAMAN / SHEET BUKU KASBON =================
  void _bukaKasbonSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kKremLatar,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.72,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Buku Kasbon Pelanggan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kHijauHeader)),
                  TextButton.icon(
                    onPressed: () async {
                      final namaCtrl = TextEditingController();
                      final hpCtrl = TextEditingController();
                      await showDialog(
                        context: ctx,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('Tambah Pelanggan Kasbon'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Pelanggan')),
                              TextField(controller: hpCtrl, decoration: const InputDecoration(labelText: 'No. HP / Blok Rumah')),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Batal')),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(dCtx);
                                Navigator.pop(ctx);
                                final res = await ApiService.post('kasbon_aksi.php', {
                                  'aksi': 'tambah_pelanggan',
                                  'id_warung': idWarung,
                                  'nama': namaCtrl.text,
                                  'kontak': hpCtrl.text,
                                });
                                _snack(res['pesan'] ?? '');
                                _muatSemuaData();
                              },
                              child: const Text('Simpan'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Pelanggan Baru'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _pelanggan.length,
                  itemBuilder: (_, i) {
                    final p = _pelanggan[i];
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: kHijauHeader, child: Icon(Icons.person, color: Colors.white)),
                        title: Text(p['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Sisa Utang: ${_rupiah(p['sisa_utang'])}'),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: kHijauTombol, foregroundColor: Colors.white),
                          onPressed: () async {
                            final bayarCtrl = TextEditingController();
                            await showDialog(
                              context: ctx,
                              builder: (dCtx) => AlertDialog(
                                title: Text('Bayar Kasbon - ${p['nama']}'),
                                content: TextField(controller: bayarCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nominal Pembayaran (Rp)')),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Batal')),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(dCtx);
                                      Navigator.pop(ctx);
                                      final res = await ApiService.post('kasbon_aksi.php', {
                                        'aksi': 'bayar',
                                        'id_warung': idWarung,
                                        'id_pengguna': idPengguna,
                                        'id_pelanggan': p['id_pelanggan'],
                                        'jumlah': double.tryParse(bayarCtrl.text) ?? 0,
                                      });
                                      _snack(res['pesan'] ?? '');
                                      _muatSemuaData();
                                    },
                                    child: const Text('Lunasi / Cicil'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Bayar'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SHEET TIM WARUNG (PEMILIK) =================
  void _bukaTimWarungSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kKremLatar,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.65,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tim Warung (Akun Penjaga)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kHijauHeader)),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: kHijauTombol, foregroundColor: Colors.white),
                    onPressed: () async {
                      final namaCtrl = TextEditingController();
                      final hpCtrl = TextEditingController();
                      final sandiCtrl = TextEditingController(text: '123456');
                      await showDialog(
                        context: ctx,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('Tambah Akun Penjaga'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Penjaga (mis. Rina)')),
                              TextField(controller: hpCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Nomor HP Login')),
                              TextField(controller: sandiCtrl, decoration: const InputDecoration(labelText: 'Kata Sandi Awal')),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Batal')),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(dCtx);
                                Navigator.pop(ctx);
                                final res = await ApiService.post('penjaga.php', {
                                  'aksi': 'tambah',
                                  'id_warung': idWarung,
                                  'nama': namaCtrl.text,
                                  'no_hp': hpCtrl.text,
                                  'sandi': sandiCtrl.text,
                                });
                                _snack(res['pesan'] ?? '');
                                _muatSemuaData();
                              },
                              child: const Text('Buat Akun'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _penjaga.isEmpty
                    ? const Center(child: Text('Belum ada akun penjaga terdaftar.'))
                    : ListView.builder(
                  itemCount: _penjaga.length,
                  itemBuilder: (_, i) {
                    final pj = _penjaga[i];
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: kHijauTombol, child: Text(pj['nama'][0].toUpperCase(), style: const TextStyle(color: Colors.white))),
                        title: Text(pj['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${pj['no_hp']} • ${pj['status_akun']}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= BUILD UTAMA SESUAI POV PEMILIK & POV PENJAGA =================
  @override
  Widget build(BuildContext context) {
    final menipis = _barang.where((b) => (int.tryParse(b['total_stok'].toString()) ?? 0) <= (int.tryParse(b['stok_minimum'].toString()) ?? 5)).toList();
    final laporanBaru = _laporan.where((l) => l['status'] == 'Baru').toList();

    return Scaffold(
      backgroundColor: kKremLatar,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: kHijauHeader))
            : IndexedStack(
          index: _tabIndex,
          children: [
            // ================= TAB 0: BERANDA (FIGMA 1:1) =================
            RefreshIndicator(
              onRefresh: _muatSemuaData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
                children: [
                  // HEADER WARUNG AZZAM + STATUS + AVATAR
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user['nama_warung'] ?? 'Warung Azzam',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kHijauHeader),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 13, color: Colors.black45),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.user['alamat'] ?? 'Jl. Garuda Sakti Km 1, Pekanbaru',
                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: const Color(0xFFE2F3E9), borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          children: [
                            CircleAvatar(radius: 4, backgroundColor: kHijauTombol),
                            SizedBox(width: 5),
                            Text('Terhubung', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kHijauTombol)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                        child: CircleAvatar(
                          radius: 19,
                          backgroundColor: kHijauHeader,
                          child: Text(
                            (widget.user['nama'] ?? 'B')[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // KARTU RINGKASAN HIJAU TUA (BEDA POV PEMILIK VS PENJAGA)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: kHijauHeader,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isPemilik ? 'Penjualan hari ini' : 'Transaksi shift ini',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: kHijauPill, borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                isPemilik ? '• Aktif MySQL' : 'Shift ${widget.user['nama']}',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isPemilik ? 'Rp 1.800.000' : '${_barang.length} Item Siap Jual',
                          style: const TextStyle(color: kKuningEmas, fontSize: 28, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPemilik
                              ? 'Total ${_barang.length} jenis produk terdaftar di gudang'
                              : 'Catat setiap barang keluar lewat tombol Kasir di bawah',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // TOMBOL UTAMA: MULAI JUAL (KASIR)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kHijauTombol,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: _bukaKasirDialog,
                    icon: const Icon(Icons.point_of_sale_rounded),
                    label: const Text('Mulai jual (Kasir)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),

                  // KARTU LAPOR KE PEMILIK (KHUSUS POV PENJAGA)
                  if (!isPemilik) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => setState(() => _tabIndex = 3),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kHijauTombol.withOpacity(0.25)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(backgroundColor: Color(0xFFE2F3E9), child: Icon(Icons.campaign_rounded, color: kHijauTombol)),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Lapor ke pemilik', style: TextStyle(fontWeight: FontWeight.bold, color: kHijauHeader)),
                                  Text('Kirim info stok habis, barang rusak, atau kasbon', style: TextStyle(fontSize: 11, color: Colors.black54)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: kHijauHeader),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Text('Perlu perhatian', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kHijauHeader)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _kartuPerhatian(
                        judul: 'Stok menipis',
                        angka: '${menipis.length}',
                        warna: Colors.orange.shade800,
                        latar: const Color(0xFFFFF4E5),
                        ikon: Icons.warning_amber_rounded,
                        onTap: () => setState(() => _tabIndex = 2),
                      ),
                      const SizedBox(width: 10),
                      _kartuPerhatian(
                        judul: 'Pelanggan kasbon',
                        angka: '${_pelanggan.length}',
                        warna: Colors.red.shade700,
                        latar: const Color(0xFFFDECEC),
                        ikon: Icons.receipt_long_rounded,
                        onTap: _bukaKasbonSheet,
                      ),
                      if (isPemilik) ...[
                        const SizedBox(width: 10),
                        _kartuPerhatian(
                          judul: 'Laporan baru',
                          angka: '${laporanBaru.length}',
                          warna: kHijauTombol,
                          latar: const Color(0xFFE2F3E9),
                          ikon: Icons.mark_email_unread_rounded,
                          onTap: () => setState(() => _tabIndex = 3),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text('Menu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kHijauHeader)),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.88,
                    children: [
                      _menuGridItem(Icons.add_box_outlined, 'Barang\nMasuk', () => _bukaTerimaBarangDialog(baruDefault: true)),
                      _menuGridItem(Icons.local_shipping_outlined, 'Terima\nPasokan', () => _bukaTerimaBarangDialog()),
                      _menuGridItem(Icons.inventory_2_outlined, 'Stok\nBarang', () => setState(() => _tabIndex = 2)),
                      _menuGridItem(Icons.book_outlined, 'Buku\nKasbon', _bukaKasbonSheet),
                      _menuGridItem(Icons.point_of_sale_outlined, 'Kasir\nKeluar', _bukaKasirDialog),
                      _menuGridItem(
                        isPemilik ? Icons.inbox_outlined : Icons.send_outlined,
                        isPemilik ? 'Kotak\nMasuk' : 'Lapor\nPemilik',
                            () => setState(() => _tabIndex = 3),
                      ),
                      if (isPemilik)
                        _menuGridItem(Icons.group_outlined, 'Tim\nWarung', _bukaTimWarungSheet),
                      _menuGridItem(Icons.logout_rounded, 'Keluar\nAkun', () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()))),
                    ],
                  ),
                ],
              ),
            ),

            // ================= TAB 1: KASIR CEPAT =================
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Kasir Penjualan Warung Azzam', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kHijauHeader)),
                  const SizedBox(height: 6),
                  const Text('Pilih barang di bawah untuk langsung memotong stok FEFO di database.', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _barang.length,
                      itemBuilder: (_, i) {
                        final b = _barang[i];
                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            title: Text(b['nama_barang'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Stok: ${b['total_stok']} • ${_rupiah(b['harga_jual'])}'),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: kHijauTombol, foregroundColor: Colors.white),
                              onPressed: _bukaKasirDialog,
                              child: const Text('Jual'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ================= TAB 2: STOK BARANG =================
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Katalog Stok Gudang', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kHijauHeader)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: kHijauTombol, foregroundColor: Colors.white),
                        onPressed: _bukaTerimaBarangDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Pasok'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _barang.length,
                      itemBuilder: (_, i) {
                        final b = _barang[i];
                        final stok = int.tryParse(b['total_stok'].toString()) ?? 0;
                        final min = int.tryParse(b['stok_minimum'].toString()) ?? 5;
                        final rendah = stok <= min;
                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: rendah ? Colors.red.shade50 : const Color(0xFFE2F3E9),
                              child: Icon(Icons.inventory_2, color: rendah ? Colors.red : kHijauTombol),
                            ),
                            title: Text(b['nama_barang'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Barcode: ${b['kode_batang']}\nKedaluwarsa: ${b['kedaluwarsa_terdekat'] ?? '-'}'),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('$stok pcs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: rendah ? Colors.red : kHijauHeader)),
                                Text(_rupiah(b['harga_jual']), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ================= TAB 3: KOTAK MASUK (PEMILIK) / LAPOR (PENJAGA) =================
            _tabLaporanKomunikasi(),
          ],
        ),
      ),

      // ================= BOTTOM NAVIGATION BAR KAPSUL HIJAU TUA (FIGMA 1:1) =================
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: kHijauHeader,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_rounded, 'Beranda'),
            _navItem(1, Icons.point_of_sale_rounded, 'Kasir'),
            _navItem(2, Icons.inventory_2_rounded, 'Stok'),
            _navItem(3, isPemilik ? Icons.inbox_rounded : Icons.campaign_rounded, isPemilik ? 'Kotak Masuk' : 'Lapor'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, String label) {
    final aktif = _tabIndex == idx;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: aktif ? 14 : 10, vertical: 8),
        decoration: BoxDecoration(
          color: aktif ? kHijauPill : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: aktif ? Colors.white : Colors.white60, size: 20),
            if (aktif) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _kartuPerhatian({required String judul, required String angka, required Color warna, required Color latar, required IconData ikon, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 15, backgroundColor: latar, child: Icon(ikon, size: 17, color: warna)),
              const SizedBox(height: 10),
              Text(angka, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: warna)),
              Text(judul, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuGridItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE2F3E9),
              child: Icon(icon, size: 20, color: kHijauHeader),
            ),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.15)),
          ],
        ),
      ),
    );
  }

  // ================= TAB LAPORAN (PENJAGA) <-> KOTAK MASUK (PEMILIK) =================
  Widget _tabLaporanKomunikasi() {
    final catatanCtrl = TextEditingController();
    String jenisTerpilih = 'Stok habis';

    return StatefulBuilder(
      builder: (ctx, setSt) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isPemilik ? 'Kotak Masuk (Laporan Penjaga)' : 'Lapor ke Pemilik',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kHijauHeader),
            ),
            const SizedBox(height: 10),
            if (!isPemilik) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 6,
                      children: ['Stok habis', 'Barang rusak', 'Pelanggan', 'Kasbon', 'Lainnya'].map((j) {
                        final pilih = jenisTerpilih == j;
                        return ChoiceChip(
                          label: Text(j, style: TextStyle(fontSize: 12, color: pilih ? Colors.white : Colors.black87)),
                          selected: pilih,
                          selectedColor: kHijauTombol,
                          onSelected: (_) => setSt(() => jenisTerpilih = j),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: catatanCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Misal: Gula pasir 1kg habis, tolong dibelikan lagi...',
                        filled: true,
                        fillColor: kKremLatar,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: kHijauTombol, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () async {
                        final res = await ApiService.post('laporan_aksi.php', {
                          'aksi': 'kirim',
                          'id_warung': idWarung,
                          'id_pengguna': idPengguna,
                          'nama_pengirim': widget.user['nama'],
                          'jenis': jenisTerpilih,
                          'catatan': catatanCtrl.text,
                        });
                        _snack(res['pesan'] ?? '', error: res['status'] != 'sukses');
                        _muatSemuaData();
                      },
                      child: const Text('Kirim ke Pemilik', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('Riwayat Laporan Saya', style: TextStyle(fontWeight: FontWeight.bold, color: kHijauHeader)),
              const SizedBox(height: 6),
            ],
            Expanded(
              child: _laporan.isEmpty
                  ? const Center(child: Text('Belum ada laporan masuk.'))
                  : ListView.builder(
                itemCount: _laporan.length,
                itemBuilder: (_, i) {
                  final lap = _laporan[i];
                  final baru = lap['status'] == 'Baru';
                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(child: Text('${lap['jenis']} • ${lap['nama_pengirim']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: baru ? Colors.red.shade50 : const Color(0xFFE2F3E9), borderRadius: BorderRadius.circular(10)),
                            child: Text(lap['status'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: baru ? Colors.red : kHijauTombol)),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(lap['catatan']),
                          if (lap['balasan'] != null && lap['balasan'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text('Balasan Pemilik: ${lap['balasan']}', style: const TextStyle(color: kHijauTombol, fontWeight: FontWeight.w600, fontSize: 12)),
                            ),
                        ],
                      ),
                      onTap: isPemilik
                          ? () async {
                        final balasCtrl = TextEditingController();
                        await showDialog(
                          context: context,
                          builder: (dCtx) => AlertDialog(
                            title: Text('Balas Laporan (${lap['nama_pengirim']})'),
                            content: TextField(controller: balasCtrl, decoration: const InputDecoration(labelText: 'Tulis balasan ke penjaga...')),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Batal')),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(dCtx);
                                  final res = await ApiService.post('laporan_aksi.php', {
                                    'aksi': 'balas',
                                    'id_laporan': lap['id_laporan'],
                                    'balasan': balasCtrl.text,
                                  });
                                  _snack(res['pesan'] ?? '');
                                  _muatSemuaData();
                                },
                                child: const Text('Kirim Balasan & Selesai'),
                              ),
                            ],
                          ),
                        );
                      }
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}