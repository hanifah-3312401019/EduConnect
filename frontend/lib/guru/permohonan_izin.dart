import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar.dart';

class PermohonanIzin extends StatefulWidget {
  const PermohonanIzin({super.key});

  @override
  State<PermohonanIzin> createState() => _PermohonanIzinState();
}

class _PermohonanIzinState extends State<PermohonanIzin> {
  List<dynamic> _listPerizinan = [];
  bool _loading = true;
  final String _baseUrl = 'http://10.0.2.2:8000/api';
  
  // GlobalKey untuk Scaffold
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _loadPerizinan();
  }

  Future<void> _loadPerizinan() async {
    setState(() => _loading = true);
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/guru/perizinan'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _listPerizinan = data['data']);
      } else {
        _showSnackBar('Gagal memuat data perizinan');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFDFBF0),
      appBar: AppBar(
        title: const Text('Permohonan Izin', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF465940),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const Sidebar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_listPerizinan.isEmpty) {
      return const Center(child: Text("Tidak ada permohonan izin"));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          return _buildMobileList();
        } else {
          return _buildWebList();
        }
      },
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _listPerizinan.length,
      itemBuilder: (context, index) {
        final izin = _listPerizinan[index];
        return _buildIzinCard(izin, context);
      },
    );
  }

  Widget _buildWebList() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Daftar Permohonan Izin',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF465940)),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _listPerizinan.length,
              itemBuilder: (context, index) {
                final izin = _listPerizinan[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildIzinCard(izin, context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIzinCard(Map<String, dynamic> izin, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF465940),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan nama siswa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    izin['Nama_Siswa'] ?? '-',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Chip(
                  label: Text(
                    izin['Status_Pembacaan'] ?? '-',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: (izin['Status_Pembacaan'] == 'Belum Dibaca') ? Colors.orange : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Informasi lengkap untuk guru
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return _buildGridDetails(izin);
                } else {
                  return _buildColumnDetails(izin);
                }
              },
            ),
            
            // Bukti
            if (izin['Bukti'] != null) ...[
              const SizedBox(height: 12),
              const Text('Bukti:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _lihatBukti(context, izin['Bukti'], izin['Nama_Siswa']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF465940),
                ),
                child: const Text('Lihat Bukti'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGridDetails(Map<String, dynamic> izin) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 4,
      children: [
        _buildDetailItem('Kelas', izin['Kelas'] ?? '-'),
        _buildDetailItem('NIS', izin['NIS'] ?? '-'),
        _buildDetailItem('Jenis Izin', izin['Jenis'] ?? '-'),
        _buildDetailItem('Tanggal Izin', izin['Tanggal_Izin'] ?? '-'),
        _buildDetailItem('Pengajuan', izin['Tanggal_Pengajuan'] ?? '-'),
        _buildDetailItem('Orang Tua', izin['Nama_OrangTua'] ?? '-'),
      ],
    );
  }

  Widget _buildColumnDetails(Map<String, dynamic> izin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem('Kelas', izin['Kelas'] ?? '-'),
        _buildDetailItem('NIS', izin['NIS'] ?? '-'),
        _buildDetailItem('Jenis Izin', izin['Jenis'] ?? '-'),
        _buildDetailItem('Tanggal Izin', izin['Tanggal_Izin'] ?? '-'),
        _buildDetailItem('Tanggal Pengajuan', izin['Tanggal_Pengajuan'] ?? '-'),
        _buildDetailItem('Alasan', izin['Keterangan'] ?? '-'),
        _buildDetailItem('Orang Tua', izin['Nama_OrangTua'] ?? '-'),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _lihatBukti(BuildContext context, String url, String nama) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bukti Izin - $nama'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 50, color: Colors.red),
                          SizedBox(height: 10),
                          Text('Gagal memuat gambar'),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text('Bukti perizinan dari orang tua'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}