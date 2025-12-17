<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pembayaran;
use App\Models\Ekstrakulikuler;
use App\Models\Siswa;
use App\Models\OrangTua;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PembayaranController extends Controller
{
    // =========================
    // ADMIN: LIST PEMBAYARAN
    // =========================
    public function index()
    {
        return Pembayaran::with(['siswa', 'ekstrakulikuler'])
            ->orderBy('created_at', 'desc')
            ->get();
    }

    // =========================
    // ADMIN: SIMPAN PEMBAYARAN
    // =========================
    public function store(Request $request)
    {
        $ekskul = Ekstrakulikuler::find($request->Ekstrakulikuler_Id);
        $biayaEkskul = $ekskul ? $ekskul->biaya : 0;

        $total = $request->Biaya_SPP
               + $request->Biaya_Catering
               + $biayaEkskul;

        return Pembayaran::create([
            'Siswa_Id' => $request->Siswa_Id,
            'Ekstrakulikuler_Id' => $request->Ekstrakulikuler_Id,
            'Bulan' => $request->Bulan,
            'Tahun_Ajaran' => $request->Tahun_Ajaran,
            'Biaya_SPP' => $request->Biaya_SPP,
            'Biaya_Catering' => $request->Biaya_Catering,
            'Total_Bayar' => $total
        ]);
    }

    // =========================
    // ADMIN: DETAIL PEMBAYARAN
    // =========================
    public function show($id)
    {
        return Pembayaran::with(['siswa', 'ekstrakulikuler'])
            ->findOrFail($id);
    }

    // =========================
    // ADMIN: UPDATE PEMBAYARAN
    // =========================
    public function update(Request $request, $id)
    {
        $pembayaran = Pembayaran::findOrFail($id);

        $ekskul = Ekstrakulikuler::find($request->Ekstrakulikuler_Id);
        $biayaEkskul = $ekskul ? $ekskul->biaya : 0;

        $total = $request->Biaya_SPP
               + $request->Biaya_Catering
               + $biayaEkskul;

        $pembayaran->update([
            'Siswa_Id' => $request->Siswa_Id,
            'Ekstrakulikuler_Id' => $request->Ekstrakulikuler_Id,
            'Bulan' => $request->Bulan,
            'Tahun_Ajaran' => $request->Tahun_Ajaran,
            'Biaya_SPP' => $request->Biaya_SPP,
            'Biaya_Catering' => $request->Biaya_Catering,
            'Total_Bayar' => $total
        ]);

        return $pembayaran;
    }

    // =========================
    // ADMIN: HAPUS PEMBAYARAN
    // =========================
    public function destroy($id)
    {
        Pembayaran::findOrFail($id)->delete();

        return response()->json(['message' => 'Pembayaran dihapus']);
    }

    // =====================================
    // ORANG TUA: LIHAT PEMBAYARAN
    // =====================================
 public function pembayaranOrangtua(Request $request)
{
    $orangTua = $request->user(); // 🔥 SAMA SEPERTI CONTROLLER PROFIL

    if (!$orangTua || !isset($orangTua->OrangTua_Id)) {
        return response()->json([
            'items' => [],
            'total_bayar' => 0,
            'error' => 'Data orang tua tidak ditemukan'
        ], 200);
    }

    $bulan = $request->query('bulan');
    $tahun = $request->query('tahun');

    $pembayaran = Pembayaran::with(['siswa', 'ekstrakulikuler'])
        ->whereHas('siswa', function ($q) use ($orangTua) {
            $q->where('OrangTua_Id', $orangTua->OrangTua_Id);
        })
        ->when($bulan, function ($q) use ($bulan) {
            $q->where('Bulan', $bulan);
        })
        ->when($tahun, function ($q) use ($tahun) {
            $q->where('Tahun_Ajaran', 'LIKE', "%$tahun%");
        })
        ->get();

    $totalSPP = $pembayaran->sum('Biaya_SPP');
$totalCatering = $pembayaran->sum('Biaya_Catering');
$totalEkskul = $pembayaran->sum(function ($p) {
    return $p->ekstrakulikuler->biaya ?? 0;
});

return response()->json([
    'items' => [
        [
            'nama' => 'SPP',
            'nominal' => $totalSPP,
        ],
        [
            'nama' => 'Catering',
            'nominal' => $totalCatering,
        ],
        [
            'nama' => 'Ekstrakulikuler',
            'nominal' => $totalEkskul,
        ],
    ],
    'total_bayar' => $totalSPP + $totalCatering + $totalEkskul
], 200);
}
}