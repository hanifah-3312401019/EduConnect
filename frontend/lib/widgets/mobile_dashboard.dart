import 'package:flutter/material.dart';

class MobileDashboard extends StatelessWidget {
  const MobileDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          _buildWelcomeHeader(),
          const SizedBox(height: 20),
          
          // Date Card
          _buildDateCard(),
          const SizedBox(height: 20),
          
          // Attendance Stats - Sesuai gambar
          _buildAttendanceStats(),
          const SizedBox(height: 20),
          
          // Announcements - Sesuai gambar
          _buildAnnouncements(),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang, Bu Siti',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Pantau Perkembangan - Kelas IA',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: Colors.black),
          SizedBox(width: 8),
          Text(
            'Senin, 20-04-2025',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Stats dalam bentuk grid seperti tabel
          Row(
            children: [
              Expanded(
                child: _buildStatBox('20', 'Hadir', Colors.green),
              ),
              Expanded(
                child: _buildStatBox('1', 'Sakit', Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatBox('0', 'Izin', Colors.blue),
              ),
              Expanded(
                child: _buildStatBox('0', 'Alfa', Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String value, String label, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengumuman',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          // Announcement item
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rapat Orang Tua Siswa',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Jadwal rapat akan diumumkan...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Terbaru',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}