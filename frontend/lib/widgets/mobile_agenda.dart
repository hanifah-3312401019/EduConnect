import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MobileAgenda extends StatefulWidget {
  const MobileAgenda({super.key});

  @override
  State<MobileAgenda> createState() => _MobileAgendaState();
}

class _MobileAgendaState extends State<MobileAgenda> {
  final List<Map<String, dynamic>> _agendaList = [
    {
      "tanggal": DateTime(2025, 11, 15),
      "keterangan": "Rapat koordinasi bulanan bersama wali kelas",
      "tujuan": "Umum",
    },
    {
      "tanggal": DateTime(2025, 11, 18),
      "keterangan": "Penilaian kebersihan kelas oleh OSIS",
      "tujuan": "Per Kelas",
    },
    {
      "tanggal": DateTime(2025, 11, 20),
      "keterangan": "Konsultasi pribadi dengan guru BK",
      "tujuan": "Personal",
    },
  ];

  String _selectedTujuan = "Semua";

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredAgenda = _selectedTujuan == "Semua"
        ? _agendaList
        : _agendaList.where((a) => a["tujuan"] == _selectedTujuan).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Dropdown filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filter Tujuan:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF465940),
                ),
              ),
              DropdownButton<String>(
                value: _selectedTujuan,
                items: const [
                  DropdownMenuItem(value: "Semua", child: Text("Semua")),
                  DropdownMenuItem(value: "Umum", child: Text("Umum")),
                  DropdownMenuItem(
                    value: "Per Kelas",
                    child: Text("Per Kelas"),
                  ),
                  DropdownMenuItem(value: "Personal", child: Text("Personal")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTujuan = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // List agenda
          Expanded(
            child: ListView.builder(
              itemCount: filteredAgenda.length,
              itemBuilder: (context, index) {
                final item = filteredAgenda[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF465940),
                      child: Text(
                        DateFormat('d').format(item["tanggal"]),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    // Keterangan sekarang menjadi "judul"
                    title: Text(
                      item["keterangan"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F3B1F),
                      ),
                    ),

                    subtitle: Text(
                      DateFormat(
                        'EEEE, d MMMM yyyy',
                        'id_ID',
                      ).format(item["tanggal"]),
                    ),

                    trailing: Text(
                      item["tujuan"],
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
