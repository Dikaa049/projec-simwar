import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2/dbsimwar_api';

  static Future post(String endpoint, Map body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'pesan': 'Gagal terhubung ke server XAMPP ($e)'};
    }
  }

  static Future get(String endpoint) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/$endpoint'));
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'pesan': 'Gagal mengambil data ($e)'};
    }
  }
}