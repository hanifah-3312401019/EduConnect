import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/env/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/widgets/sidebarOrangtua.dart';
import 'package:frontend/widgets/NavbarOrangtua.dart';

class RekapKetidakhadiranPage extends StatefulWidget {
  const RekapKetidakhadiranPage({super.key});

  @override
  State<RekapKetidakhadiranPage> createState() =>
      _RekapKetidakhadiranPageState();
}

class _RekapKetidakhadiranPageState extends State<RekapKetidakhadiranPage> {
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> rekap = [];

  @override
  void initState() {
    super.initState();
    fetchRekap();
  }

  Future<void> fetchRekap() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        setState(() {
          errorMessage = 'Token tidak ditemukan. Silakan login ulang.';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/orangtua/rekap-ketidakhadiran'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          setState(() {
            rekap = List<Map<String, dynamic>>.from(decoded['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Format data tidak valid';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Koneksi gagal: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Ketidakhadiran'),
        backgroundColor: const Color.fromRGBO(70, 89, 64, 1),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? _errorWidget()
              : rekap.isEmpty
                  ? _emptyWidget()
                  : _listWidget(),
    );
  }

  Widget _listWidget() {
    return RefreshIndicator(
      onRefresh: fetchRekap,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rekap.length,
        itemBuilder: (context, index) {
          final item = rekap[index];

          final bulan = item['bulan_label']?.toString() ?? '-';
          final sakit = item['total_sakit']?.toString() ?? '0';
          final izin = item['total_izin']?.toString() ?? '0';
          final lainnya = item['total_lainnya']?.toString() ?? '0';
          final total = item['total_ketidakhadiran']?.toString() ?? '0';

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                bulan,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Sakit: $sakit | Izin: $izin | Lainnya: $lainnya',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$total hari',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _errorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: fetchRekap,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(70, 89, 64, 1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data rekap',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}