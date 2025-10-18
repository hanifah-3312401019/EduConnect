import 'package:flutter/material.dart';

class WebPermohonanIzin extends StatelessWidget {
  const WebPermohonanIzin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 24),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: _buildPermohonanList(context),
            ),
          ),
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
            fontSize: 28,
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
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 12),
          
          // Jenis Izin
          _buildDetailRow('Jenis Izin', jenisIzin),
          const SizedBox(height: 12),
          
          // Tanggal
          _buildDetailRow('Tanggal', tanggal),
          const SizedBox(height: 12),
          
          // Alasan
          _buildDetailRow('Alasan', alasan),
          const SizedBox(height: 12),
          
          // Bukti - dengan tombol untuk melihat
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  'Bukti :',
                  style: const TextStyle(
                    fontSize: 16,
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
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        _showBuktiDialog(context, bukti, nama);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF465940),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Lihat Bukti'),
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
          width: 100,
          child: Text(
            '$label :',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
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
        return Dialog(
          backgroundColor: const Color(0xFFFDFBF0),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bukti Izin - $nama',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF465940),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Preview bukti
                Container(
                  width: double.infinity,
                  height: 300,
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
                        size: 80,
                        color: const Color(0xFF465940),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        bukti,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF465940),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bukti.toLowerCase().contains('.png') || 
                        bukti.toLowerCase().contains('.jpg') ||
                        bukti.toLowerCase().contains('.jpeg')
                            ? 'File Gambar'
                            : 'File Dokumen',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'Bukti izin dari siswa akan ditampilkan di sini',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                    const SizedBox(width: 12),
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
                        'Buka File Lengkap',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}