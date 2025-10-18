import 'package:flutter/material.dart';

class MobilePermohonanIzin extends StatelessWidget {
  const MobilePermohonanIzin({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 20),
          
          // List Permohonan
          _buildPermohonanList(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Permohonan Izin',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF465940),
          ),
        ),
      ],
    );
  }

  Widget _buildPermohonanList(BuildContext context) {
    return Column(
      children: [
        // Permohonan 1 - Rasya
        _buildPermohonanItem(
          context: context,
          nama: 'Rasya Zeyfarsyah',
          jenisIzin: 'Sakit',
          tanggal: '12-12-2024',
          alasan: 'Demam',
          bukti: 'Surat_Izin.png',
        ),
        const SizedBox(height: 16),
        
        // Permohonan 2 - Raffa
        _buildPermohonanItem(
          context: context,
          nama: 'Raffa Zeyfarsyah',
          jenisIzin: 'Izin',
          tanggal: '13-12-2024',
          alasan: 'Urusan Keluarga',
          bukti: 'Bukti.png',
        ),
      ],
    );
  }

  Widget _buildPermohonanItem({
    required BuildContext context,
    required String nama,
    required String jenisIzin,
    required String tanggal,
    required String alasan,
    required String bukti,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF465940),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama
          _buildDetailRow('Nama', nama),
          const SizedBox(height: 8),
          
          // Jenis Izin
          _buildDetailRow('Jenis Izin', jenisIzin),
          const SizedBox(height: 8),
          
          // Tanggal
          _buildDetailRow('Tanggal', tanggal),
          const SizedBox(height: 8),
          
          // Alasan
          _buildDetailRow('Alasan', alasan),
          const SizedBox(height: 8),
          
          // Bukti - dengan tombol untuk melihat
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  'Bukti :',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bukti,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ElevatedButton(
                      onPressed: () {
                        _showBuktiDialog(context, bukti, nama);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF465940),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        'Lihat Bukti',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label :',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _showBuktiDialog(BuildContext context, String bukti, String nama) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFDFBF0),
          title: Text(
            'Bukti Izin - $nama',
            style: const TextStyle(
              color: Color(0xFF465940),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Placeholder untuk gambar/surat
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      bukti.toLowerCase().contains('.png') || 
                      bukti.toLowerCase().contains('.jpg') ||
                      bukti.toLowerCase().contains('.jpeg')
                          ? Icons.image
                          : Icons.description,
                      size: 50,
                      color: const Color(0xFF465940),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bukti,
                      style: const TextStyle(
                        color: Color(0xFF465940),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bukti.toLowerCase().contains('.png') || 
                      bukti.toLowerCase().contains('.jpg') ||
                      bukti.toLowerCase().contains('.jpeg')
                          ? '(Gambar)'
                          : '(Dokumen)',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bukti izin dari siswa akan ditampilkan di sini',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: Color(0xFF465940),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Simulasi download/view
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Membuka bukti: $bukti'),
                    backgroundColor: const Color(0xFF465940),
                  ),
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF465940),
              ),
              child: const Text(
                'Buka File',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}