<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Perizinan;
use App\Models\Guru;
use App\Models\Kelas;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PerizinanGuruController extends Controller
{
    /**
     * Ambil Guru_Id dari TOKEN (BUKAN HEADER)
     */
    private function getGuruId()
    {
        $user = Auth::user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated'
            ], 401);
        }

        // asumsi akun guru login punya kolom Guru_Id
        $guruId = $user->Guru_Id ?? null;

        if (!$guruId) {
            return response()->json([
                'success' => false,
                'message' => 'Akun ini bukan akun guru'
            ], 403);
        }

        $guru = Guru::find($guruId);
        if (!$guru) {
            return response()->json([
                'success' => false,
                'message' => 'Data guru tidak ditemukan'
            ], 404);
        }

        return $guruId;
    }

    /**
     * GET /api/guru/perizinan
     */
    public function index()
    {
        $guruId = $this->getGuruId();
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        // ambil kelas yang diampu guru
        $kelasIds = Kelas::where('Guru_Id', $guruId)
            ->pluck('Kelas_Id')
            ->toArray();

        if (empty($kelasIds)) {
            return response()->json([
                'success' => false,
                'message' => 'Guru belum ditugaskan ke kelas'
            ], 400);
        }

        // ambil perizinan siswa di kelas guru
        $perizinan = Perizinan::with([
                'siswa',
                'siswa.kelas',
                'siswa.orangTua'
            ])
            ->whereHas('siswa', function ($q) use ($kelasIds) {
                $q->whereIn('Kelas_Id', $kelasIds);
            })
            ->orderBy('Tanggal_Pengajuan', 'desc')
            ->get()
            ->map(function ($izin) {
                return [
                    'Id_Perizinan'        => $izin->Id_Perizinan,
                    'Jenis'               => $izin->Jenis,
                    'Keterangan'          => $izin->Keterangan,
                    'Tanggal_Izin'        => optional($izin->Tanggal_Izin)->format('Y-m-d'),
                    'Tanggal_Pengajuan'   => optional($izin->Tanggal_Pengajuan)->format('Y-m-d H:i'),
                    'Status_Pembacaan'    => $izin->Status_Pembacaan,
                    'Bukti'               => $izin->Bukti,

                    // Siswa
                    'Nama_Siswa'          => $izin->siswa->Nama ?? '-',
                    'Jenis_Kelamin_Siswa' => $izin->siswa->Jenis_Kelamin ?? '-',
                    'Tanggal_Lahir_Siswa' => optional($izin->siswa->Tanggal_Lahir)->format('Y-m-d'),
                    'Alamat_Siswa'        => $izin->siswa->Alamat ?? '-',
                    'Agama_Siswa'         => $izin->siswa->Agama ?? '-',

                    // Kelas
                    'Kelas'               => $izin->siswa->kelas->Nama_Kelas ?? '-',

                    // Orang Tua
                    'Nama_OrangTua'       => $izin->siswa->orangTua->Nama ?? '-',
                    'Email_OrangTua'      => $izin->siswa->orangTua->Email ?? '-',
                    'No_Telepon_OrangTua' => $izin->siswa->orangTua->No_Telepon ?? '-',
                    'Alamat_OrangTua'     => $izin->siswa->orangTua->Alamat ?? '-',
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $perizinan
        ]);
    }
}
