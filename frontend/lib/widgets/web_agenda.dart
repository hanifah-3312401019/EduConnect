import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WebAgenda extends StatefulWidget {
  const WebAgenda({super.key});

  @override
  State<WebAgenda> createState() => _WebAgendaState();
}

class _WebAgendaState extends State<WebAgenda> {
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
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dan dropdown filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Daftar Agenda Sekolah",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF465940),
                ),
              ),
              Row(
                children: [
                  const Text(
                    "Filter tujuan: ",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedTujuan,
                    items: const [
                      DropdownMenuItem(value: "Semua", child: Text("Semua")),
                      DropdownMenuItem(value: "Umum", child: Text("Umum")),
                      DropdownMenuItem(
                        value: "Per Kelas",
                        child: Text("Per Kelas"),
                      ),
                      DropdownMenuItem(
                        value: "Personal",
                        child: Text("Personal"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedTujuan = value!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tabel agenda
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Tanggal')),
                  DataColumn(label: Text('Agenda / Keterangan')),
                  DataColumn(label: Text('Tujuan')),
                ],
                rows: filteredAgenda.map((agenda) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          DateFormat('dd MMM yyyy').format(agenda["tanggal"]),
                        ),
                      ),
                      DataCell(Text(agenda["keterangan"])),
                      DataCell(Text(agenda["tujuan"])),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
