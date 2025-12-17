class PembayaranOrangtua {
  final String? bulan;
  final String? tahunAjaran;
  final List<PembayaranItem> items;
  final int totalBayar;

  PembayaranOrangtua({
    this.bulan,
    this.tahunAjaran,
    required this.items,
    required this.totalBayar,
  });

  factory PembayaranOrangtua.fromJson(Map<String, dynamic> json) {
    return PembayaranOrangtua(
      bulan: json['bulan'],
      tahunAjaran: json['tahun_ajaran'],
      totalBayar: json['total_bayar'],
      items: (json['items'] as List)
          .map((e) => PembayaranItem.fromJson(e))
          .toList(),
    );
  }
}

class PembayaranItem {
  final String nama;
  final int nominal;

  PembayaranItem({required this.nama, required this.nominal});

  factory PembayaranItem.fromJson(Map<String, dynamic> json) {
    return PembayaranItem(nama: json['nama'], nominal: json['nominal']);
  }
}
