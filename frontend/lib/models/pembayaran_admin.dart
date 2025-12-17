class PembayaranAdmin {
  final int id;
  final int siswaId;
  final String bulan;
  final String tahunAjaran;
  final int totalBayar;

  PembayaranAdmin({
    required this.id,
    required this.siswaId,
    required this.bulan,
    required this.tahunAjaran,
    required this.totalBayar,
  });

  factory PembayaranAdmin.fromJson(Map<String, dynamic> json) {
    return PembayaranAdmin(
      id: json['Pembayaran_Id'],
      siswaId: json['Siswa_Id'],
      bulan: json['Bulan'],
      tahunAjaran: json['Tahun_Ajaran'],
      totalBayar: json['Total_Bayar'],
    );
  }
}
