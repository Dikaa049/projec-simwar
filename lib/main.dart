import 'package:flutter/material.dart';
import 'api_service.dart';

const Color kHijauTua = Color(0xFF14372D);
const Color kHijauUtama = Color(0xFF23794F);
const Color kKuningAksen = Color(0xFFF8B62B);
const Color kMerahBata = Color(0xFFC8401E);
const Color kKrem = Color(0xFFF4EFE0);

void main() {
  runApp(const SimwarApp());
}

class SimwarApp extends StatelessWidget {
  const SimwarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMWAR - Warung Azzam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kKrem,
        colorScheme: ColorScheme.fromSeed(seedColor: kHijauTua),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}

// ============================================================================
// 1. LAYAR LOGIN (PEMILIK & PENJAGA)
// ============================================================================
class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _hpCtrl = TextEditingController();
  final _sandiCtrl = TextEditingController();
  String _peran = 'Pemilik';
  bool _obscure = true;
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    final res = await ApiService.post('login.php', {
      'no_hp': _hpCtrl.text.trim(),
      'sandi': _sandiCtrl.text.trim(),
      'peran': _peran,
    });
    setState(() => _loading = false);

    if (!mounted) return;
    if (res['status'] == 'sukses') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(user: Map<String, dynamic>.from(res['user']))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['pesan'] ?? 'Login gagal'), backgroundColor: kMerahBata),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPemilik = _peran == 'Pemilik';

    return Scaffold(
      backgroundColor: kKrem,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 52, 24, 48),
              decoration: const BoxDecoration(
                color: kHijauTua,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: kKuningAksen, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.storefront_rounded, size: 18, color: kHijauTua),
                  ),
                  const SizedBox(height: 12),
                  const Text('SIMWAR', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
                  const Text('Warung Azzam', style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, color: kKuningAksen)),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                          decoration: BoxDecoration(color: kKuningAksen, borderRadius: BorderRadius.circular(4)),
                          child: const Text('WARUNG AZZAM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kHijauTua)),
                        ),
                        Container(
                          width: 170,
                          height: 16,
                          decoration: const BoxDecoration(color: Color(0xFFD96B43), borderRadius: BorderRadius.vertical(top: Radius.circular(6))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (i) => Container(width: 14, height: 16, color: i.isEven ? const Color(0xFFF4EFE6) : const Color(0xFFD96B43))),
                          ),
                        ),
                        Container(
                          width: 156,
                          height: 76,
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(color: Color(0xFFF4EFE6), borderRadius: BorderRadius.vertical(bottom: Radius.circular(8))),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(color: kHijauTua, borderRadius: BorderRadius.circular(6), border: Border.all(color: kKuningAksen, width: 2)),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text('• • • •', style: TextStyle(color: kKuningAksen, fontSize: 10)),
                                      Divider(height: 1, color: Colors.white24),
                                      Text('• • • •', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(color: const Color(0xFF9E5A3C), borderRadius: BorderRadius.circular(4)),
                                  child: const Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(padding: EdgeInsets.only(right: 4), child: CircleAvatar(radius: 2, backgroundColor: kKuningAksen)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: kKrem, borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: ['Pemilik', 'Penjaga'].map((role) {
                            final aktif = _peran == role;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _peran = role),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(vertical: 11),
                                  decoration: BoxDecoration(color: aktif ? kHijauUtama : Colors.transparent, borderRadius: BorderRadius.circular(11)),
                                  child: Text(role, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: aktif ? Colors.white : Colors.black54)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _hpCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '0812 3456 7890',
                          labelText: 'Nomor HP',
                          filled: true,
                          fillColor: kKrem.withOpacity(0.6),
                          prefixIcon: const Icon(Icons.phone_outlined, color: kHijauTua),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _sandiCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          filled: true,
                          fillColor: kKrem.withOpacity(0.6),
                          prefixIcon: const Icon(Icons.lock_outline, color: kHijauTua),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.black45),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kHijauUtama,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DaftarAkunScreen(peran: _peran))),
              child: Text.rich(
                TextSpan(
                  text: 'Belum punya akun? ',
                  style: const TextStyle(color: Colors.black54),
                  children: [
                    TextSpan(
                      text: isPemilik ? 'Buat profil pemilik' : 'Buat profil',
                      style: const TextStyle(color: kHijauUtama, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. LAYAR BUAT PROFIL (PEMILIK & PENJAGA)
// ============================================================================
class DaftarAkunScreen extends StatefulWidget {
  final String peran;
  const DaftarAkunScreen({super.key, required this.peran});

  @override
  State<DaftarAkunScreen> createState() => _DaftarAkunScreenState();
}

class _DaftarAkunScreenState extends State<DaftarAkunScreen> {
  final _namaCtrl = TextEditingController();
  final _hpCtrl = TextEditingController();
  final _sandiCtrl = TextEditingController();
  final _warungCtrl = TextEditingController(text: 'Warung Azzam');
  final _alamatCtrl = TextEditingController(text: 'Jl. Garuda Sakti Km 1, Pekanbaru');
  bool _loading = false;

  bool get isPemilik => widget.peran == 'Pemilik';

  Future<void> _daftar() async {
    setState(() => _loading = true);
    final res = await ApiService.post('daftar.php', {
      'peran': widget.peran,
      'nama': _namaCtrl.text.trim(),
      'no_hp': _hpCtrl.text.trim(),
      'sandi': _sandiCtrl.text.trim(),
      'nama_warung': _warungCtrl.text.trim(),
      'alamat': _alamatCtrl.text.trim(),
    });
    setState(() => _loading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['pesan'] ?? ''), backgroundColor: res['status'] == 'sukses' ? kHijauUtama : kMerahBata),
    );
    if (res['status'] == 'sukses') Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kKrem,
      appBar: AppBar(
        title: Text(isPemilik ? 'Buat Profil Pemilik' : 'Buat Profil Penjaga', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: kHijauTua,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(isPemilik ? 'Data Akun Pemilik' : 'Data Akun Penjaga', style: const TextStyle(fontWeight: FontWeight.bold, color: kHijauTua)),
              const SizedBox(height: 12),
              _field(_namaCtrl, isPemilik ? 'Nama Lengkap Pemilik' : 'Nama Lengkap Penjaga (mis. Rina)', Icons.person_outline),
              const SizedBox(height: 12),
              _field(_hpCtrl, 'Nomor HP', Icons.phone_outlined, isPhone: true),
              const SizedBox(height: 12),
              _field(_sandiCtrl, 'Kata Sandi (Min. 6 Karakter)', Icons.lock_outline, isPass: true),
              const SizedBox(height: 20),
              Text(isPemilik ? 'Identitas Warung' : 'Warung Tempat Bertugas', style: const TextStyle(fontWeight: FontWeight.bold, color: kHijauTua)),
              const SizedBox(height: 12),
              _field(_warungCtrl, 'Nama Warung', Icons.storefront_outlined),
              if (isPemilik) ...[
                const SizedBox(height: 12),
                _field(_alamatCtrl, 'Alamat Warung', Icons.location_on_outlined),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kHijauUtama,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _loading ? null : _daftar,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan & Buat Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {bool isPhone = false, bool isPass = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: kKrem,
        prefixIcon: Icon(icon, color: kHijauTua),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}

// ============================================================================
// 3. DASHBOARD UTAMA (POV PEMILIK VS POV PENJAGA)
// ============================================================================
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
  List _terlaris = [];
  List _riwayatKeluar = [];
  List _kiriman = [];
  List _titipan = [];
  List _laporan = [];
  List _penjaga = [];
  Map<String, dynamic> _ringkas = {};
  bool _loading = true;

  int get idWarung => int.tryParse(widget.user['id_warung'].toString()) ?? 1;
  int get idPengguna => int.tryParse(widget.user['id_pengguna'].toString()) ?? 1;
  bool get isPemilik => widget.user['peran'] == 'Pemilik';

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    setState(() => _loading = true);
    final resDash = await ApiService.get('dashboard.php?id_warung=$idWarung');
    final resLap = await ApiService.get('laporan_aksi.php?id_warung=$idWarung');
    final resPenj = isPemilik ? await ApiService.get('penjaga.php?id_warung=$idWarung') : {'penjaga': []};

    if (!mounted) return;
    setState(() {
      if (resDash['status'] == 'sukses') {
        _barang = resDash['barang'] ?? [];
        _pelanggan = resDash['pelanggan'] ?? [];
        _ringkas = Map<String, dynamic>.from(resDash['ringkas'] ?? {});
        _terlaris = resDash['terlaris'] ?? [];
        _riwayatKeluar = resDash['riwayat_keluar'] ?? [];
        _kiriman = resDash['kiriman'] ?? [];
        _titipan = resDash['titipan'] ?? [];
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

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? kMerahBata : kHijauUtama),
    );
  }

  String _rp(dynamic val) {
    final n = (double.tryParse(val.toString()) ?? 0).round();
    return 'Rp ${n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  int _sisaHari(String? tglStr) {
    if (tglStr == null || tglStr.isEmpty) return 999;
    final dt = DateTime.tryParse(tglStr);
    if (dt == null) return 999;
    return dt.difference(DateTime.now()).inDays;
  }

  Future<void> _bukaCatatKeluarDialog() async {
    if (_barang.isEmpty) {
      _snack('Belum ada barang di katalog', error: true);
      return;
    }
    int selectedBarang = int.parse(_barang.first['id_barang'].toString());
    int? selectedPelanggan = _pelanggan.isNotEmpty ? int.parse(_pelanggan.first['id_pelanggan'].toString()) : null;
    String metode = 'Tunai';
    final qtyCtrl = TextEditingController(text: '1');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kKrem,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          final itemTerpilih = _barang.firstWhere(
                (b) => int.parse(b['id_barang'].toString()) == selectedBarang,
            orElse: () => _barang.first,
          );
          final stokSekarang = int.tryParse(itemTerpilih['total_stok'].toString()) ?? 0;
          final qty = int.tryParse(qtyCtrl.text) ?? 1;
          final harga = double.tryParse(itemTerpilih['harga_jual'].toString()) ?? 0;

          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Catat Barang Keluar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kHijauTua)),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedBarang,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: 'Pilih Barang', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                  items: _barang.map((b) => DropdownMenuItem<int>(
                    value: int.parse(b['id_barang'].toString()),
                    child: Text('${b['nama_barang']} (Stok: ${b['total_stok']})'),
                  )).toList(),
                  onChanged: (v) => setSt(() => selectedBarang = v!),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Batch ED terdekat: ${itemTerpilih['kedaluwarsa_terdekat'] ?? '-'}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          Text('Perubahan stok: $stokSekarang → ${stokSekarang - qty} pcs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: (stokSekarang - qty) < 0 ? kMerahBata : kHijauUtama)),
                        ],
                      ),
                      Text(_rp(harga * qty), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kHijauTua)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setSt(() {}),
                  decoration: InputDecoration(labelText: 'Jumlah Keluar', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: ['Tunai', 'QRIS', 'Kasbon'].map((m) {
                    final pilih = metode == m;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Center(child: Text(m)),
                          selected: pilih,
                          selectedColor: kHijauUtama,
                          labelStyle: TextStyle(color: pilih ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                          onSelected: (_) => setSt(() => metode = m),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (metode == 'Kasbon' && _pelanggan.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: selectedPelanggan,
                    decoration: InputDecoration(labelText: 'Pelanggan Kasbon', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                    items: _pelanggan.map((p) => DropdownMenuItem<int>(
                      value: int.parse(p['id_pelanggan'].toString()),
                      child: Text(p['nama']),
                    )).toList(),
                    onChanged: (v) => setSt(() => selectedPelanggan = v),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kHijauUtama, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
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
                    _muatData();
                  },
                  child: const Text('Simpan Barang Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _bukaCatatMasukDialog({String tabAwal = 'pasokan', bool produkBaru = false}) async {
    String jenisMasuk = tabAwal;
    String modeBarang = (_barang.isEmpty || produkBaru) ? 'baru' : 'restok';
    int? selectedBarang = _barang.isNotEmpty ? int.parse(_barang.first['id_barang'].toString()) : null;

    final fakturCtrl = TextEditingController(text: 'INV-${DateTime.now().year}-${DateTime.now().millisecond}');
    final namaCtrl = TextEditingController();
    final barcodeCtrl = TextEditingController();
    final beliCtrl = TextEditingController();
    final jualCtrl = TextEditingController();
    final qtyFakturCtrl = TextEditingController(text: '12');
    final qtyFisikCtrl = TextEditingController(text: '12');
    final edCtrl = TextEditingController(text: '2027-06-15');

    final penitipCtrl = TextEditingController();
    final barangTitipCtrl = TextEditingController();
    final jmlTitipCtrl = TextEditingController(text: '20');
    final hargaSetorCtrl = TextEditingController(text: '1500');
    final hargaJualTitipCtrl = TextEditingController(text: '2000');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kKrem,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Catat Barang Masuk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kHijauTua)),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'pasokan', label: Text('Pasokan Distributor')),
                    ButtonSegment(value: 'titipan', label: Text('Titipan Warga')),
                  ],
                  selected: {jenisMasuk},
                  onSelectionChanged: (v) => setSt(() => jenisMasuk = v.first),
                ),
                const SizedBox(height: 14),
                if (jenisMasuk == 'pasokan') ...[
                  TextField(controller: fakturCtrl, decoration: InputDecoration(labelText: 'Nomor Faktur Distributor', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                  const SizedBox(height: 10),
                  if (isPemilik)
                    Row(
                      children: [
                        ChoiceChip(label: const Text('Restok Lama'), selected: modeBarang == 'restok', onSelected: (_) => setSt(() => modeBarang = 'restok')),
                        const SizedBox(width: 8),
                        ChoiceChip(label: const Text('+ Tambah Barang Baru'), selected: modeBarang == 'baru', onSelected: (_) => setSt(() => modeBarang = 'baru')),
                      ],
                    ),
                  const SizedBox(height: 8),
                  if (modeBarang == 'restok' && _barang.isNotEmpty)
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
                    TextField(controller: namaCtrl, decoration: InputDecoration(labelText: 'Nama Barang Baru', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                    const SizedBox(height: 8),
                    TextField(controller: barcodeCtrl, decoration: InputDecoration(labelText: 'Kode Batang (Barcode)', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: beliCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga Beli', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: jualCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga Jual', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: qtyFakturCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Di Faktur', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: qtyFisikCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Fisik Diterima', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: edCtrl, decoration: InputDecoration(labelText: 'Tanggal Kedaluwarsa (YYYY-MM-DD)', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kHijauUtama, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final res = await ApiService.post('terima_barang.php', {
                        'id_warung': idWarung,
                        'id_pengguna': idPengguna,
                        'mode': modeBarang,
                        'no_faktur': fakturCtrl.text,
                        'id_barang': selectedBarang,
                        'nama_barang': namaCtrl.text,
                        'kode_batang': barcodeCtrl.text,
                        'harga_beli': double.tryParse(beliCtrl.text) ?? 0,
                        'harga_jual': double.tryParse(jualCtrl.text) ?? 0,
                        'jumlah_faktur': int.tryParse(qtyFakturCtrl.text) ?? 0,
                        'jumlah_fisik': int.tryParse(qtyFisikCtrl.text) ?? 0,
                        'tanggal_kedaluwarsa': edCtrl.text,
                      });
                      _snack(res['pesan'] ?? '', error: res['status'] != 'sukses');
                      _muatData();
                    },
                    child: const Text('Simpan Penerimaan Pasokan', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  TextField(controller: penitipCtrl, decoration: InputDecoration(labelText: 'Nama Warga Penitip (mis. Bu Ani)', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                  const SizedBox(height: 8),
                  TextField(controller: barangTitipCtrl, decoration: InputDecoration(labelText: 'Nama Kue / Keripik Titipan', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                  const SizedBox(height: 8),
                  TextField(controller: jmlTitipCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Jumlah Titip Masuk (pcs)', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: hargaSetorCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga Setor Penitip', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: hargaJualTitipCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga Jual Warung', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kHijauUtama, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final res = await ApiService.post('titipan_aksi.php', {
                        'aksi': 'tambah',
                        'id_warung': idWarung,
                        'nama_penitip': penitipCtrl.text,
                        'nama_barang': barangTitipCtrl.text,
                        'jumlah_masuk': int.tryParse(jmlTitipCtrl.text) ?? 0,
                        'harga_titip': double.tryParse(hargaSetorCtrl.text) ?? 0,
                        'harga_jual': double.tryParse(hargaJualTitipCtrl.text) ?? 0,
                      });
                      _snack(res['pesan'] ?? '', error: res['status'] != 'sukses');
                      _muatData();
                    },
                    child: const Text('Simpan Barang Titipan', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _bukaRekonsiliasiKasDialog() async {
    final laciCtrl = TextEditingController();
    final tunaiSistem = double.tryParse(_ringkas['tunai_hari_ini'].toString()) ?? 0;
    final qrisSistem = double.tryParse(_ringkas['qris_hari_ini'].toString()) ?? 0;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          final laciAktual = double.tryParse(laciCtrl.text) ?? 0;
          final selisih = laciAktual - tunaiSistem;
          return AlertDialog(
            title: const Text('Rekonsiliasi Kas Harian', style: TextStyle(fontWeight: FontWeight.bold, color: kHijauTua)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Catatan Tunai Sistem: ${_rp(tunaiSistem)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Rekap QRIS (Rekening): ${_rp(qrisSistem)}', style: const TextStyle(color: kHijauUtama)),
                const SizedBox(height: 12),
                TextField(
                  controller: laciCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setSt(() {}),
                  decoration: const InputDecoration(labelText: 'Hitung Uang Fisik di Laci (Rp)', border: OutlineInputBorder()),
                ),
                if (laciCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    selisih == 0 ? 'Status: KAS TUNAI SESUAI' : 'Status: SELISIH ${_rp(selisih)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: selisih == 0 ? kHijauUtama : kMerahBata),
                  ),
                ],
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kKrem,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: kHijauTua))
            : isPemilik
            ? IndexedStack(
          index: _tabIndex,
          children: [
            _pemilikBerandaTab(),
            _pemilikKeluarLaporanTab(),
            _masukPasokanTitipanTab(),
            _pemilikStokTab(),
          ],
        )
            : IndexedStack(
          index: _tabIndex,
          children: [
            _penjagaBerandaTab(),
            _penjagaCatatTab(),
            _masukPasokanTitipanTab(),
            _penjagaProfilLaporTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: kHijauTua, borderRadius: BorderRadius.circular(26)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: isPemilik
              ? [
            _navPill(0, Icons.home_rounded, 'Beranda'),
            _navPill(1, Icons.bar_chart_rounded, 'Keluar'),
            _navPill(2, Icons.move_to_inbox_rounded, 'Masuk'),
            _navPill(3, Icons.inventory_2_rounded, 'Stok'),
          ]
              : [
            _navPill(0, Icons.home_rounded, 'Beranda'),
            _navPill(1, Icons.qr_code_scanner_rounded, 'Catat'),
            _navPill(2, Icons.move_to_inbox_rounded, 'Masuk'),
            _navPill(3, Icons.person_rounded, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _navPill(int idx, IconData icon, String label) {
    final aktif = _tabIndex == idx;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: aktif ? 14 : 10, vertical: 8),
        decoration: BoxDecoration(color: aktif ? kKuningAksen : Colors.transparent, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Icon(icon, color: aktif ? kHijauTua : Colors.white70, size: 20),
            if (aktif) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: kHijauTua, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pemilikBerandaTab() {
    final menipis = _barang.where((b) => (int.tryParse(b['total_stok'].toString()) ?? 0) <= (int.tryParse(b['stok_minimum'].toString()) ?? 5)).toList();
    final dekatEd = _barang.where((b) => _sisaHari(b['kedaluwarsa_terdekat']) <= 30).toList();
    final laporanBaru = _laporan.where((l) => l['status'] == 'Baru').length;

    return RefreshIndicator(
      onRefresh: _muatData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 95),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selamat datang,', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    Text(widget.user['nama_warung'] ?? 'Warung Azzam', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kHijauTua)),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFE2F3E9), borderRadius: BorderRadius.circular(8)),
                      child: const Text('Pemilik', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kHijauUtama)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _tabIndex = 1),
                icon: Badge(isLabelVisible: laporanBaru > 0, label: Text('$laporanBaru'), child: const Icon(Icons.notifications_outlined, color: kHijauTua)),
              ),
              GestureDetector(
                onTap: _bukaProfilTimPemilikDialog,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: kHijauTua,
                  child: Text((widget.user['nama'] ?? 'A')[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: kHijauTua, borderRadius: BorderRadius.circular(22)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Barang keluar hari ini', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${_ringkas['item_hari_ini'] ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: kHijauUtama, borderRadius: BorderRadius.circular(20)),
                        child: Text('Omzet: ${_rp(_ringkas['omzet_hari_ini'])}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [18.0, 26.0, 22.0, 34.0, 42.0, 52.0].asMap().entries.map((e) {
                    return Container(
                      width: 7,
                      height: e.value,
                      margin: const EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(color: e.key == 5 ? kKuningAksen : kHijauUtama, borderRadius: BorderRadius.circular(4)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Perlu perhatian', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kHijauTua)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tabIndex = 3),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: kKuningAksen, borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${menipis.length}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kHijauTua)),
                        const Text('Stok menipis', style: TextStyle(fontWeight: FontWeight.bold, color: kHijauTua)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tabIndex = 3),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: kMerahBata, borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${dekatEd.length}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                        const Text('Mendekati kedaluwarsa', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Stok menipis & Kedaluwarsa', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kHijauTua)),
              TextButton(onPressed: () => setState(() => _tabIndex = 3), child: const Text('Lihat semua', style: TextStyle(color: kHijauUtama))),
            ],
          ),
          if (menipis.isEmpty && dekatEd.isEmpty)
            const Card(color: Colors.white, child: ListTile(leading: Icon(Icons.check_circle, color: kHijauUtama), title: Text('Semua stok barang aman')))
          else
            ...menipis.take(3).map((b) => Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                title: Text(b['nama_barang'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Batas minimum: ${b['stok_minimum']} pcs'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
                  child: Text('Sisa ${b['total_stok']}', style: const TextStyle(color: kMerahBata, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _pemilikKeluarLaporanTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 95),
      children: [
        const Text('Barang keluar & Evaluasi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kHijauTua)),
        const Text('Rekap kas Tunai/QRIS, laba operasional & laporan penjaga', style: TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: kHijauTua, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estimasi Laba Operasional (Bulan Ini)', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(_rp(_ringkas['laba_bulan_ini']), style: const TextStyle(color: kKuningAksen, fontSize: 28, fontWeight: FontWeight.w900)),
              const Divider(color: Colors.white24, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tunai Hari Ini: ${_rp(_ringkas['tunai_hari_ini'])}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  Text('QRIS Hari Ini: ${_rp(_ringkas['qris_hari_ini'])}', style: const TextStyle(color: kKuningAksen, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Produk Terlaris', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kHijauTua)),
        const SizedBox(height: 8),
        if (_terlaris.isEmpty)
          const Card(color: Colors.white, child: ListTile(title: Text('Belum ada data penjualan tercatat')))
        else
          ..._terlaris.map((t) => Card(
            color: Colors.white,
            elevation: 0,
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE2F3E9), child: Icon(Icons.trending_up, color: kHijauUtama)),
              title: Text(t['nama_barang'], style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text('${t['terjual']} terjual', style: const TextStyle(fontWeight: FontWeight.bold, color: kHijauTua)),
            ),
          )),
        const SizedBox(height: 16),
        const Text('Kotak Masuk Laporan Penjaga', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kHijauTua)),
        const SizedBox(height: 8),
        if (_laporan.isEmpty)
          const Card(color: Colors.white, child: ListTile(title: Text('Belum ada laporan masuk dari penjaga')))
        else
          ..._laporan.map((lap) => Card(
            color: Colors.white,
            elevation: 0,
            child: ListTile(
              title: Text('${lap['jenis']} • ${lap['nama_pengirim']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${lap['catatan']}${lap['balasan'] != null ? '\nBalasan Anda: ${lap['balasan']}' : ''}'),
              trailing: Chip(
                label: Text(lap['status'], style: TextStyle(fontSize: 11, color: lap['status'] == 'Baru' ? Colors.white : kHijauTua)),
                backgroundColor: lap['status'] == 'Baru' ? kMerahBata : const Color(0xFFE2F3E9),
              ),
              onTap: () async {
                final balasCtrl = TextEditingController();
                await showDialog(
                  context: context,
                  builder: (dCtx) => AlertDialog(
                    title: Text('Balas ${lap['nama_pengirim']}'),
                    content: TextField(controller: balasCtrl, decoration: const InputDecoration(labelText: 'Tulis balasan...')),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Batal')),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(dCtx);
                          await ApiService.post('laporan_aksi.php', {'aksi': 'balas', 'id_laporan': lap['id_laporan'], 'balasan': balasCtrl.text});
                          _muatData();
                        },
                        child: const Text('Kirim & Selesai'),
                      ),
                    ],
                  ),
                );
              },
            ),
          )),
      ],
    );
  }

  Widget _pemilikStokTab() {
    final menipis = _barang.where((b) => (int.tryParse(b['total_stok'].toString()) ?? 0) <= (int.tryParse(b['stok_minimum'].toString()) ?? 5)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 95),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Kelola Stok & Belanja', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kHijauTua)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: kKuningAksen, foregroundColor: kHijauTua),
              onPressed: () => _bukaCatatMasukDialog(tabAwal: 'pasokan', produkBaru: true),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah barang', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (menipis.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(color: kHijauTua, borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${menipis.length} Barang di bawah batas', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const Text('Susun daftar kulakan otomatis ke pemasok', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kKuningAksen, foregroundColor: kHijauTua),
                  onPressed: () {
                    double totalModal = 0;
                    final baris = menipis.map((b) {
                      final pesan = ((int.tryParse(b['stok_minimum'].toString()) ?? 5) * 2) - (int.tryParse(b['total_stok'].toString()) ?? 0);
                      final beli = double.tryParse(b['harga_beli'].toString()) ?? 0;
                      totalModal += pesan * beli;
                      return '• ${b['nama_barang']}: pesan $pesan pcs (${_rp(pesan * beli)})';
                    }).join('\n');

                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Rencana Belanja (Restock Plan)'),
                        content: Text('$baris\n\nEstimasi Total Modal: ${_rp(totalModal)}'),
                        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
                      ),
                    );
                  },
                  child: const Text('Rencana Belanja', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ..._barang.map((b) {
          final stok = int.tryParse(b['total_stok'].toString()) ?? 0;
          final min = int.tryParse(b['stok_minimum'].toString()) ?? 5;
          final kritis = stok <= min;
          return Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: Text(b['nama_barang'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${b['kode_batang']} • ${_rp(b['harga_jual'])}\nED terdekat: ${b['kedaluwarsa_terdekat'] ?? '-'}'),
              isThreeLine: true,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: kritis ? Colors.red.shade50 : const Color(0xFFE2F3E9), borderRadius: BorderRadius.circular(8)),
                    child: Text(kritis ? 'Menipis' : 'Aman', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kritis ? kMerahBata : kHijauUtama)),
                  ),
                  const SizedBox(height: 4),
                  Text('Stok $stok', style: TextStyle(fontWeight: FontWeight.w900, color: kritis ? kMerahBata : kHijauTua)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _penjagaBerandaTab() {
    final menipis = _barang.where((b) => (int.tryParse(b['total_stok'].toString()) ?? 0) <= (int.tryParse(b['stok_minimum'].toString()) ?? 5)).toList();

    return RefreshIndicator(
      onRefresh: _muatData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 95),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Halo,', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    Row(
                      children: [
                        Text(widget.user['nama'] ?? 'Penjaga', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kHijauTua)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFFFF4D6), borderRadius: BorderRadius.circular(8)),
                          child: const Text('Penjaga', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9E6B00))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: kKuningAksen,
                child: Text((widget.user['nama'] ?? 'R')[0].toUpperCase(), style: const TextStyle(color: kHijauTua, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _bukaCatatKeluarDialog,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: kKuningAksen, borderRadius: BorderRadius.circular(22)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: kHijauTua.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.qr_code_scanner_rounded, color: kHijauTua),
                        ),
                        const SizedBox(height: 12),
                        const Text('Catat barang keluar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kHijauTua)),
                        const Text('Pindai kode batang atau pilih manual (Tunai / QRIS)', style: TextStyle(fontSize: 12, color: kHijauTua)),
                      ],
                    ),
                  ),
                  const CircleAvatar(backgroundColor: kHijauTua, child: Icon(Icons.arrow_forward, color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _bukaCatatMasukDialog(tabAwal: 'pasokan'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(radius: 16, backgroundColor: Color(0xFFE2F3E9), child: Icon(Icons.local_shipping_outlined, size: 18, color: kHijauUtama)),
                        SizedBox(height: 10),
                        Text('Terima kiriman', style: TextStyle(fontWeight: FontWeight.bold, color: kHijauTua)),
                        Text('Cocokkan dengan faktur', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _bukaCatatMasukDialog(tabAwal: 'titipan'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(radius: 16, backgroundColor: Color(0xFFFFF4D6), child: Icon(Icons.bakery_dining_outlined, size: 18, color: Color(0xFF9E6B00))),
                        SizedBox(height: 10),
                        Text('Catat titipan', style: TextStyle(fontWeight: FontWeight.bold, color: kHijauTua)),
                        Text('Dari warga sekitar', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Peringatan hari ini', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kHijauTua)),
              TextButton(onPressed: () => setState(() => _tabIndex = 3), child: const Text('Laporkan ke pemilik', style: TextStyle(color: kHijauUtama))),
            ],
          ),
          if (menipis.isEmpty)
            const Card(color: Colors.white, child: ListTile(leading: Icon(Icons.check_circle, color: kHijauUtama), title: Text('Tidak ada peringatan mendesak')))
          else
            ...menipis.map((b) => Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                title: Text(b['nama_barang'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Stok menipis • laporkan ke pemilik'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
                  child: Text('Sisa ${b['total_stok']}', style: const TextStyle(color: kMerahBata, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _penjagaCatatTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 95),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Catat Barang Keluar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kHijauTua)),
            OutlinedButton.icon(onPressed: _bukaRekonsiliasiKasDialog, icon: const Icon(Icons.calculate_outlined, size: 18), label: const Text('Cek Kas Laci')),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: kHijauUtama, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          onPressed: _bukaCatatKeluarDialog,
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Pilih Manual / Catat Transaksi Baru', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 18),
        const Text('Dicatat hari ini', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kHijauTua)),
        const SizedBox(height: 8),
        if (_riwayatKeluar.isEmpty)
          const Card(color: Colors.white, child: ListTile(title: Text('Belum ada barang keluar dicatat hari ini')))
        else
          ..._riwayatKeluar.map((r) => Card(
            color: Colors.white,
            elevation: 0,
            child: ListTile(
              title: Text(r['rincian'] ?? r['kode_transaksi'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('${r['jam']} • ${r['metode_pembayaran']}'),
              trailing: Text(_rp(r['total_tagihan']), style: const TextStyle(fontWeight: FontWeight.bold, color: kHijauTua)),
            ),
          )),
      ],
    );
  }

  Widget _masukPasokanTitipanTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 95),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Barang Masuk & Titipan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kHijauTua)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: kKuningAksen, foregroundColor: kHijauTua),
              onPressed: () => _bukaCatatMasukDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Catat masuk', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text('Barang Titipan Warga (Konsinyasi)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kHijauTua)),
        const SizedBox(height: 8),
        if (_titipan.isEmpty)
          const Card(color: Colors.white, child: ListTile(title: Text('Belum ada catatan barang titipan warga')))
        else
          ..._titipan.map((tp) {
            final masuk = int.tryParse(tp['jumlah_masuk'].toString()) ?? 0;
            final terjual = int.tryParse(tp['jumlah_terjual'].toString()) ?? 0;
            final kembali = int.tryParse(tp['jumlah_kembali'].toString()) ?? 0;
            final sisa = masuk - terjual - kembali;
            final hTitip = double.tryParse(tp['harga_titip'].toString()) ?? 0;
            final hJual = double.tryParse(tp['harga_jual'].toString()) ?? 0;

            return Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${tp['nama_barang']} (${tp['nama_penitip']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Chip(label: Text(tp['status'], style: const TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: tp['status'] == 'Aktif' ? kHijauUtama : Colors.grey),
                      ],
                    ),
                    Text('Masuk: $masuk • Terjual: $terjual • Sisa rak: $sisa pcs', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text('Hak Penitip: ${_rp(terjual * hTitip)} | Untung Warung: ${_rp(terjual * (hJual - hTitip))}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kHijauTua)),
                    if (tp['status'] == 'Aktif')
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            final jualCtrl = TextEditingController(text: '$terjual');
                            final kmbCtrl = TextEditingController(text: '$kembali');
                            await showDialog(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: Text('Update Titipan: ${tp['nama_barang']}'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(controller: jualCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah Terjual')),
                                    TextField(controller: kmbCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sisa Dikembalikan')),
                                  ],
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Batal')),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(dCtx);
                                      await ApiService.post('titipan_aksi.php', {
                                        'aksi': 'update',
                                        'id_titipan': tp['id_titipan'],
                                        'jumlah_terjual': int.tryParse(jualCtrl.text) ?? 0,
                                        'jumlah_kembali': int.tryParse(kmbCtrl.text) ?? 0,
                                        'selesai': true,
                                      });
                                      _muatData();
                                    },
                                    child: const Text('Selesaikan Bagi Hasil'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Update Terjual / Bagi Hasil'),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 16),
        const Text('Verifikasi Kiriman Distributor', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kHijauTua)),
        const SizedBox(height: 8),
        ..._kiriman.map((k) {
          final selisih = int.tryParse(k['selisih'].toString()) ?? 0;
          return Card(
            color: Colors.white,
            elevation: 0,
            child: ListTile(
              title: Text('${k['nama_barang']} (${k['no_faktur']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('${k['tanggal']} • Faktur: ${k['jumlah_faktur']} | Fisik: ${k['jumlah_fisik']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: selisih != 0 ? Colors.red.shade50 : const Color(0xFFE2F3E9), borderRadius: BorderRadius.circular(8)),
                child: Text(selisih != 0 ? 'Selisih $selisih' : 'Sesuai', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: selisih != 0 ? kMerahBata : kHijauUtama)),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _penjagaProfilLaporTab() {
    final catatanCtrl = TextEditingController();
    String jenis = 'Stok habis';

    return StatefulBuilder(
      builder: (ctx, setSt) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 95),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                CircleAvatar(radius: 28, backgroundColor: kKuningAksen, child: Text((widget.user['nama'] ?? 'R')[0].toUpperCase(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kHijauTua))),
                const SizedBox(height: 8),
                Text(widget.user['nama'] ?? 'Penjaga', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kHijauTua)),
                Text('Penjaga • ${widget.user['nama_warung'] ?? 'Warung Azzam'}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: kMerahBata),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen())),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Keluar dari akun'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Lapor ke Pemilik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kHijauTua)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 6,
                  children: ['Stok habis', 'Barang rusak', 'Pelanggan', 'Kasbon', 'Lainnya'].map((j) {
                    return ChoiceChip(
                      label: Text(j, style: TextStyle(fontSize: 12, color: jenis == j ? Colors.white : Colors.black87)),
                      selected: jenis == j,
                      selectedColor: kHijauUtama,
                      onSelected: (_) => setSt(() => jenis = j),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: catatanCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(hintText: 'Tulis kondisi di warung...', filled: true, fillColor: kKrem, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kHijauUtama, foregroundColor: Colors.white),
                  onPressed: () async {
                    final res = await ApiService.post('laporan_aksi.php', {
                      'aksi': 'kirim',
                      'id_warung': idWarung,
                      'id_pengguna': idPengguna,
                      'nama_pengirim': widget.user['nama'],
                      'jenis': jenis,
                      'catatan': catatanCtrl.text,
                    });
                    _snack(res['pesan'] ?? '', error: res['status'] != 'sukses');
                    _muatData();
                  },
                  child: const Text('Kirim ke pemilik', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ..._laporan.map((lap) => Card(
            color: Colors.white,
            elevation: 0,
            child: ListTile(
              title: Text(lap['jenis'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${lap['catatan']}${lap['balasan'] != null ? '\nBalasan Pemilik: ${lap['balasan']}' : ''}'),
              trailing: Text(lap['status'], style: TextStyle(fontWeight: FontWeight.bold, color: lap['status'] == 'Baru' ? kMerahBata : kHijauUtama)),
            ),
          )),
        ],
      ),
    );
  }

  void _bukaProfilTimPemilikDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kKrem,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Profil Pemilik: ${widget.user['nama']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kHijauTua)),
            Text('Total Akun Penjaga: ${_penjaga.length} orang', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: kHijauUtama, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                _bukaCatatMasukDialog(tabAwal: 'pasokan', produkBaru: true);
              },
              icon: const Icon(Icons.add_box),
              label: const Text('Tambah Master Barang Baru'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: kMerahBata),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              icon: const Icon(Icons.logout),
              label: const Text('Keluar dari Akun'),
            ),
          ],
        ),
      ),
    );
  }
}