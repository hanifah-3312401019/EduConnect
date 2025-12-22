import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../widgets/sidebar.dart';

class PermohonanIzin extends StatefulWidget {
  const PermohonanIzin({super.key});

  @override
  State<PermohonanIzin> createState() => _PermohonanIzinState();
}

class _PermohonanIzinState extends State<PermohonanIzin> with SingleTickerProviderStateMixin {
  List<dynamic> _listPerizinan = [];
  List<dynamic> _filteredPerizinan = [];
  bool _loading = true;
  String _errorMessage = '';
  String _filterJenis = 'Semua';
  String _searchQuery = '';
  late TabController _tabController;
  
  String get _baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000/api";
    } else {
      return "http://10.0.2.2:8000/api";
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadPerizinan();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0: _filterJenis = 'Semua'; break;
          case 1: _filterJenis = 'Sakit'; break;
          case 2: _filterJenis = 'Acara Keluarga'; break;
          case 3: _filterJenis = 'Lainnya'; break;
        }
        _applyFilter();
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredPerizinan = _listPerizinan.where((izin) {
        bool matchesJenis = _filterJenis == 'Semua' || izin['Jenis'] == _filterJenis;
        bool matchesSearch = _searchQuery.isEmpty ||
            (izin['Nama_Siswa'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (izin['Kelas'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesJenis && matchesSearch;
      }).toList();
    });
  }

  Future<void> _loadPerizinan() async {
    setState(() { 
      _loading = true; 
      _errorMessage = ''; 
    });
    
    try {
      final token = await _getToken();
      
      print('🔍 Fetching from: $_baseUrl/guru/perizinan');
      print('🔑 Token: ${token.substring(0, 20)}...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/guru/perizinan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - Server tidak merespon');
        },
      );
      
      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          setState(() {
            _listPerizinan = data['data'] ?? [];
            _applyFilter();
          });
          
          if (_listPerizinan.isEmpty) {
            setState(() {
              _errorMessage = 'Belum ada perizinan dari siswa Anda';
            });
          }
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Gagal memuat data';
          });
        }
      } else if (response.statusCode == 403) {
        setState(() {
          _errorMessage = 'Akses ditolak. Anda tidak memiliki izin.';
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'Data guru tidak ditemukan. Hubungi admin.';
        });
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Anda belum ditugaskan ke kelas';
        });
      } else {
        final data = json.decode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Gagal memuat data (${response.statusCode})';
        });
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        if (e.toString().contains('timeout')) {
          _errorMessage = 'Server tidak merespon. Periksa koneksi Anda.';
        } else if (e.toString().contains('SocketException')) {
          _errorMessage = 'Tidak dapat terhubung ke server.\nPastikan Laravel sudah running.';
        } else {
          _errorMessage = 'Error: $e';
        }
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    const greenColor = Color(0xFF465940);
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF0),
      appBar: AppBar(
        title: const Text(
          'Permohonan Izin',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: greenColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadPerizinan,
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilter();
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari nama siswa atau kelas...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _applyFilter();
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              // Tab Bar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: [
                  Tab(
                    child: Row(
                      children: [
                        const Icon(Icons.all_inbox, size: 18),
                        const SizedBox(width: 6),
                        Text('Semua (${_listPerizinan.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        const Icon(Icons.medical_services, size: 18),
                        const SizedBox(width: 6),
                        Text('Sakit (${_listPerizinan.where((e) => e['Jenis'] == 'Sakit').length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        const Icon(Icons.celebration, size: 18),
                        const SizedBox(width: 6),
                        Text('Acara (${_listPerizinan.where((e) => e['Jenis'] == 'Acara Keluarga').length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        const Icon(Icons.more_horiz, size: 18),
                        const SizedBox(width: 6),
                        Text('Lainnya (${_listPerizinan.where((e) => e['Jenis'] == 'Lainnya').length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      drawer: const Sidebar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF465940)),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat data...',
              style: TextStyle(
                color: Color(0xFF465940),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.orange[400],
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadPerizinan,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF465940),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_filteredPerizinan.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              "Tidak ada data perizinan",
              style: TextStyle(fontSize: 18),
            ),
            if (_filterJenis != 'Semua') ...[
              const SizedBox(height: 8),
              Text(
                "untuk kategori $_filterJenis",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadPerizinan,
      color: const Color(0xFF465940),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredPerizinan.length,
        itemBuilder: (context, index) => _buildCard(_filteredPerizinan[index]),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> izin) {
    const greenColor = Color(0xFF465940);
    Color jenisColor = izin['Jenis'] == 'Sakit' 
        ? Colors.red 
        : izin['Jenis'] == 'Acara Keluarga' 
            ? Colors.orange 
            : Colors.blue;
    
    IconData jenisIcon = izin['Jenis'] == 'Sakit' 
        ? Icons.medical_services 
        : izin['Jenis'] == 'Acara Keluarga' 
            ? Icons.celebration 
            : Icons.more_horiz;
    
    bool isNew = izin['Status_Pembacaan'] == 'Belum Dibaca';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isNew 
            ? BorderSide(color: Colors.orange.withOpacity(0.3), width: 2) 
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showDetail(izin),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan Avatar dan Status
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: greenColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        (izin['Nama_Siswa'] ?? '?')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: greenColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                izin['Nama_Siswa'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: greenColor,
                                ),
                              ),
                            ),
                            if (isNew)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'BARU',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.class_, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              izin['Kelas'] ?? '-',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              izin['Tanggal_Pengajuan'] ?? '-',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Jenis dan Tanggal
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: jenisColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: jenisColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(jenisIcon, size: 16, color: jenisColor),
                        const SizedBox(width: 6),
                        Text(
                          izin['Jenis'] ?? '-',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: jenisColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: greenColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: greenColor),
                        const SizedBox(width: 6),
                        Text(
                          izin['Tanggal_Izin'] ?? '-',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: greenColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Keterangan
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.description, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        izin['Keterangan'] ?? '-',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDetail(izin),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('Detail'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: greenColor,
                        side: const BorderSide(color: greenColor),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  if (izin['Bukti'] != null && izin['Bukti'] != 'null') ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _lihatBukti(
                          context,
                          izin['Bukti'],
                          izin['Nama_Siswa'] ?? 'Siswa',
                        ),
                        icon: const Icon(Icons.attachment, size: 18),
                        label: const Text('Bukti'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(Map<String, dynamic> izin) {
    const greenColor = Color(0xFF465940);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: greenColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          (izin['Nama_Siswa'] ?? '?')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: greenColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Perizinan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: greenColor,
                            ),
                          ),
                          Text(
                            izin['Nama_Siswa'] ?? '-',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                
                // Data Siswa
                _buildSection(
                  'Data Siswa',
                  Icons.person,
                  [
                    _buildRow('Nama', izin['Nama_Siswa'] ?? '-'),
                    _buildRow('Kelas', izin['Kelas'] ?? '-'),
                    _buildRow('Jenis Kelamin', izin['Jenis_Kelamin_Siswa'] ?? '-'),
                    _buildRow('Tanggal Lahir', izin['Tanggal_Lahir_Siswa'] ?? '-'),
                    _buildRow('Alamat', izin['Alamat_Siswa'] ?? '-'),
                    _buildRow('Agama', izin['Agama_Siswa'] ?? '-'),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Data Orang Tua
                _buildSection(
                  'Data Orang Tua',
                  Icons.family_restroom,
                  [
                    _buildRow('Nama', izin['Nama_OrangTua'] ?? '-'),
                    _buildRow('Email', izin['Email_OrangTua'] ?? '-'),
                    _buildRow('No. Telepon', izin['No_Telepon_OrangTua'] ?? '-'),
                    _buildRow('Alamat', izin['Alamat_OrangTua'] ?? '-'),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Data Perizinan
                _buildSection(
                  'Data Perizinan',
                  Icons.description,
                  [
                    _buildRow('Jenis Izin', izin['Jenis'] ?? '-'),
                    _buildRow('Tanggal Izin', izin['Tanggal_Izin'] ?? '-'),
                    _buildRow('Tanggal Pengajuan', izin['Tanggal_Pengajuan'] ?? '-'),
                    _buildRow('Status', izin['Status_Pembacaan'] ?? '-'),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Keterangan
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: greenColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: greenColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.notes, size: 18, color: greenColor),
                          SizedBox(width: 8),
                          Text(
                            'Keterangan:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: greenColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        izin['Keterangan'] ?? '-',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                
                // Bukti Button
                if (izin['Bukti'] != null && izin['Bukti'] != 'null') ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _lihatBukti(
                          context,
                          izin['Bukti'],
                          izin['Nama_Siswa'] ?? 'Siswa',
                        );
                      },
                      icon: const Icon(Icons.attachment),
                      label: const Text('Lihat Bukti Perizinan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    const greenColor = Color(0xFF465940);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: greenColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: greenColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
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
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF465940)),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 50, color: Colors.red[400]),
                    const SizedBox(height: 10),
                    const Text('Gagal memuat gambar'),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(color: Color(0xFF465940)),
            ),
          ),
        ],
      ),
    );
  }
} 