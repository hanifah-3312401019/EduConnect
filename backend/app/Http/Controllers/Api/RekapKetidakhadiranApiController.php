<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RekapKetidakhadiranApiController extends Controller
{
    // Rekap ketidakhadiran per bulan
    public function index(Request $request)
    {
        $orangTuaId = $request->user()->OrangTua_Id;

        $rekap = DB::table('perizinan')
            ->where('OrangTua_Id', $orangTuaId)
            ->selectRaw("
                DATE_FORMAT(Tanggal_Izin, '%Y-%m') AS bulan,
                DATE_FORMAT(Tanggal_Izin, '%M %Y') AS bulan_label,
                SUM(CASE WHEN Jenis = 'Acara Keluarga' THEN 1 ELSE 0 END) AS total_izin,
                SUM(CASE WHEN Jenis = 'Sakit' THEN 1 ELSE 0 END) AS total_sakit,
                SUM(CASE WHEN Jenis = 'Lainnya' THEN 1 ELSE 0 END) AS total_lainnya,
                COUNT(*) AS total_ketidakhadiran
            ")
            ->groupBy(DB::raw("DATE_FORMAT(Tanggal_Izin, '%Y-%m'), DATE_FORMAT(Tanggal_Izin, '%M %Y')"))
            ->orderBy('bulan', 'DESC')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $rekap
        ]);
    }

    // Detail ketidakhadiran per bulan
    public function detail(Request $request, $bulan)
    {
        $orangTuaId = $request->user()->OrangTua_Id;

        $detail = DB::table('perizinan')
            ->join('siswa', 'perizinan.Siswa_Id', '=', 'siswa.Siswa_Id')
            ->where('perizinan.OrangTua_Id', $orangTuaId)
            ->whereRaw("DATE_FORMAT(perizinan.Tanggal_Izin, '%Y-%m') = ?", [$bulan])
            ->select(
                'perizinan.Id_Perizinan',
                'perizinan.Jenis',
                'perizinan.Keterangan',
                'perizinan.Tanggal_Izin',
                'perizinan.Tanggal_Pengajuan',
                'siswa.Nama as Nama_Siswa'
            )
            ->orderBy('perizinan.Tanggal_Izin', 'DESC')
            ->get();

        return response()->json([
            'success' => true,
            'bulan' => $bulan,
            'data' => $detail
        ]);
    }
}
