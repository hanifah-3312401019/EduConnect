import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/widgets/sidebarOrangtua.dart';
import '../orangtua/agenda.dart';
import '../orangtua/pengumuman.dart';

class NotifikasiModel {
  final int notifikasiId;
  final String judul;
  final String pesan;
  final String jenis;
  final DateTime createdAt;
  bool dibaca;
  final int? agendaId;
  final int? pengumumanId;
  final String? tipe;

  NotifikasiModel({
    required this.notifikasiId,
    required this.judul,
    required this.pesan,
    required this.jenis,
    required this.createdAt,
    required this.dibaca,
    this.agendaId,
    this.pengumumanId,
    this.tipe,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      notifikasiId: json['Notifikasi_Id'] ?? 0,
      judul: json['Judul'] ?? '',
      pesan: json['Pesan'] ?? '',
      jenis: json['Jenis'] ?? 'lainnya',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      dibaca: json['dibaca'] ?? false,
      agendaId: json['Agenda_Id'],
      pengumumanId: json['Pengumuman_Id'],
      tipe: json['tipe'],
    );
  }

  bool get hasNavigation => agendaId != null || pengumumanId != null;
  
  String get targetPage {
    if (agendaId != null) return 'agenda';
    if (pengumumanId != null) return 'pengumuman';
    return 'notifikasi';
  }
  
  int? get targetId => agendaId ?? pengumumanId;

  String get kategoriFilter {
    if (jenis == 'agenda') {
      switch (tipe?.toLowerCase()) {
        case 'sekolah': return 'sekolah';
        case 'perkelas': return 'perkelas';
        case 'ekskul': return 'ekskul';
        default: return 'semua';
      }
    } else if (jenis == 'pengumuman') {
      switch (tipe?.toLowerCase()) {
        case 'umum': return 'umum';
        case 'perkelas': return 'perkelas';
        case 'personal': return 'personal';
        default: return 'semua';
      }
    }
    return 'semua';
  }
}

class NotifikasiService {
  static const String baseUrl = 'http://localhost:8000/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> getNotifikasiOrtu() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orangtua/notifikasi'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Sesi telah berakhir, silakan login kembali'};
      }
      return {'success': false, 'message': 'Error ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<int> getUnreadCount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orangtua/notifikasi/unread-count'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data']['unread_count'] ?? 0;
        }
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<bool> markAsRead(int notifikasiId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/notifikasi/$notifikasiId/read'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> markAllAsRead() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/notifikasi/mark-all-read'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteNotification(int notifikasiId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/notifikasi/$notifikasiId'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> clearAllNotifications() async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/notifikasi/clear-all'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class NotifikasiBadge extends StatefulWidget {
  final Function()? onTap;
  final double iconSize;
  final Color iconColor;

  const NotifikasiBadge({
    super.key,
    this.onTap,
    this.iconSize = 24,
    this.iconColor = const Color(0xFF465940),
  });

  @override
  State<NotifikasiBadge> createState() => _NotifikasiBadgeState();
}

class _NotifikasiBadgeState extends State<NotifikasiBadge> {
  int _unreadCount = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) _loadUnreadCount();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    final count = await NotifikasiService.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none, size: widget.iconSize, color: widget.iconColor),
          onPressed: () {
            if (widget.onTap != null) {
              widget.onTap!();
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiPage()));
            }
          },
        ),
        if (_unreadCount > 0) Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
            child: Text(_unreadCount > 9 ? '9+' : _unreadCount.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  List<NotifikasiModel> _notifikasiList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _unreadCount = 0;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadNotifikasi();
  }

  Future<void> _loadNotifikasi() async {
    if (!_isRefreshing) setState(() => _isLoading = true);
    final result = await NotifikasiService.getNotifikasiOrtu();
    
    if (mounted) {
      if (result['success'] == true) {
        final data = result['data'];
        final notifications = (data['notifications'] as List)
            .map((e) => NotifikasiModel.fromJson(e)).toList();
        
        setState(() {
          _notifikasiList = notifications;
          _unreadCount = data['unread_count'] ?? 0;
          _isLoading = false;
          _isRefreshing = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal memuat notifikasi';
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final success = await NotifikasiService.markAllAsRead();
    if (success && mounted) {
      setState(() {
        _unreadCount = 0;
        for (var notif in _notifikasiList) notif.dibaca = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua notifikasi ditandai sebagai dibaca'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _markAsReadAndNavigate(int index) async {
    final notif = _notifikasiList[index];
    final success = await NotifikasiService.markAsRead(notif.notifikasiId);
    if (success && mounted) {
      setState(() {
        notif.dibaca = true;
        _unreadCount--;
      });
      _navigateBasedOnNotification(notif);
    }
  }

  Future<void> _deleteNotifikasi(int index) async {
    final notif = _notifikasiList[index];
    final originalList = List<NotifikasiModel>.from(_notifikasiList);
    
    if (mounted) {
      setState(() {
        if (!notif.dibaca) _unreadCount--;
        _notifikasiList.removeAt(index);
      });
    }

    final success = await NotifikasiService.deleteNotification(notif.notifikasiId);
    if (!success && mounted) {
      setState(() {
        _notifikasiList = originalList;
        if (!notif.dibaca) _unreadCount++;
      });
    }
  }

  Future<void> _clearAllNotifications() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Notifikasi'),
        content: const Text('Apakah Anda yakin ingin menghapus semua notifikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('HAPUS', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final originalList = List<NotifikasiModel>.from(_notifikasiList);
      final originalCount = _unreadCount;
      
      setState(() {
        _notifikasiList.clear();
        _unreadCount = 0;
      });

      final success = await NotifikasiService.clearAllNotifications();
      if (!success && mounted) {
        setState(() {
          _notifikasiList = originalList;
          _unreadCount = originalCount;
        });
      }
    }
  }

  void _navigateBasedOnNotification(NotifikasiModel notif) {
  if (!notif.hasNavigation) return;
  
  switch (notif.targetPage) {
    case 'agenda':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AgendaPage()), // ✅ Navigasi biasa
      ).then((_) { 
        if (mounted) _loadNotifikasi(); 
      });
      break;
    case 'pengumuman':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PengumumanPage()), // ✅ Navigasi biasa
      ).then((_) { 
        if (mounted) _loadNotifikasi(); 
      });
      break;
  }
}

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 30) return '${date.day}/${date.month}/${date.year}';
    else if (difference.inDays > 7) return '${(difference.inDays / 7).floor()} minggu lalu';
    else if (difference.inDays > 0) return '${difference.inDays} hari lalu';
    else if (difference.inHours > 0) return '${difference.inHours} jam lalu';
    else if (difference.inMinutes > 0) return '${difference.inMinutes} menit lalu';
    else return 'Baru saja';
  }

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF465940);
    const Color backgroundColor = Color(0xFFFDFBF0);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const sidebarOrangtua(),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: greenColor),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications, color: greenColor),
            const SizedBox(width: 8),
            Text("Notifikasi${_unreadCount > 0 ? ' ($_unreadCount)' : ''}",
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          if (_unreadCount > 0) IconButton(
            icon: const Icon(Icons.checklist, color: greenColor),
            onPressed: _markAllAsRead,
          ),
          if (_notifikasiList.isNotEmpty) IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _clearAllNotifications,
          ),
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh, color: greenColor),
            onPressed: _isRefreshing ? null : () {
              setState(() => _isRefreshing = true);
              _loadNotifikasi();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage.isNotEmpty) return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.red)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadNotifikasi,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF465940)),
            child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (_notifikasiList.isEmpty) return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 96, color: Colors.grey[400]),
          const SizedBox(height: 24),
          const Text('Tidak ada notifikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Semua pesan dari sekolah akan muncul di sini', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
    return RefreshIndicator(
      onRefresh: _loadNotifikasi,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifikasiList.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notif = _notifikasiList[index];
          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: notif.dibaca ? Colors.white : Colors.blue[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: notif.dibaca ? Colors.grey.shade300 : Colors.blue.shade200, width: 1),
            ),
            child: InkWell(
              onTap: () => _markAsReadAndNavigate(index),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: notif.dibaca ? Colors.grey.shade200 : const Color(0xFF465940).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(child: Text(notif.jenis.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 18))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(notif.judul,
                                style: TextStyle(fontWeight: notif.dibaca ? FontWeight.normal : FontWeight.bold, fontSize: 15),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              )),
                              if (!notif.dibaca) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(notif.pesan, style: TextStyle(fontSize: 14, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(_formatDate(notif.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                              const Spacer(),
                              if (notif.hasNavigation) Row(
                                children: [
                                  Text('Klik untuk lihat', style: TextStyle(fontSize: 10, color: Colors.blue[600])),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.blue),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}