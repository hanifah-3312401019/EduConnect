<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Perizinan;
use App\Models\Guru;
use App\Models\Kelas;
use App\Models\Siswa;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

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

    /**
     * POST /api/guru/perizinan/manual
     * Tambah izin manual oleh guru
     */
    public function storeManual(Request $request)
    {
        $guruId = $this->getGuruId();
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        // Validasi input
        $validator = Validator::make($request->all(), [
            'nama_siswa'    => 'required|string|min:3|max:255',
            'jenis'         => 'required|in:Sakit,Acara Keluarga,Lainnya',
            'tanggal_izin'  => 'required|date',
            'keterangan'    => 'required|string|min:10|max:500',
        ], [
            'nama_siswa.required'    => 'Nama siswa harus diisi',
            'nama_siswa.min'         => 'Nama siswa minimal 3 karakter',
            'jenis.required'         => 'Jenis izin harus dipilih',
            'jenis.in'               => 'Jenis izin tidak valid',
            'tanggal_izin.required'  => 'Tanggal izin harus diisi',
            'tanggal_izin.date'      => 'Format tanggal tidak valid',
            'keterangan.required'    => 'Keterangan harus diisi',
            'keterangan.min'         => 'Keterangan minimal 10 karakter',
            'keterangan.max'         => 'Keterangan maksimal 500 karakter',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        // Ambil kelas yang diampu guru
        $kelasIds = Kelas::where('Guru_Id', $guruId)
            ->pluck('Kelas_Id')
            ->toArray();

        if (empty($kelasIds)) {
            return response()->json([
                'success' => false,
                'message' => 'Guru belum ditugaskan ke kelas'
            ], 400);
        }

        // Cari siswa berdasarkan nama di kelas yang diampu guru
        // PENTING: Load relasi orangTua untuk dapat OrangTua_Id
        $siswa = Siswa::with('orangTua')
            ->whereIn('Kelas_Id', $kelasIds)
            ->where('Nama', 'LIKE', '%' . $request->nama_siswa . '%')
            ->first();

        if (!$siswa) {
            return response()->json([
                'success' => false,
                'message' => 'Siswa dengan nama "' . $request->nama_siswa . '" tidak ditemukan di kelas yang Anda ampu'
            ], 404);
        }

        // Cek apakah siswa punya OrangTua_Id
        if (!$siswa->OrangTua_Id) {
            return response()->json([
                'success' => false,
                'message' => 'Siswa "' . $siswa->Nama . '" belum memiliki data orang tua. Hubungi admin untuk melengkapi data.'
            ], 400);
        }

        // Buat perizinan baru dengan OrangTua_Id dari siswa
        $perizinan = Perizinan::create([
            'Siswa_Id'          => $siswa->Siswa_Id,
            'OrangTua_Id'       => $siswa->OrangTua_Id, // ⭐ INI YANG DITAMBAHKAN
            'Jenis'             => $request->jenis,
            'Keterangan'        => $request->keterangan,
            'Tanggal_Izin'      => $request->tanggal_izin,
            'Tanggal_Pengajuan' => Carbon::now(),
            'Status_Pembacaan'  => 'Sudah Dibaca', // Langsung dibaca karena guru yang input
            'Bukti'             => null, // Tidak ada bukti untuk izin manual
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Izin berhasil ditambahkan',
            'data' => [
                'Id_Perizinan'      => $perizinan->Id_Perizinan,
                'Nama_Siswa'        => $siswa->Nama,
                'Kelas'             => $siswa->kelas->Nama_Kelas ?? '-',
                'Jenis'             => $perizinan->Jenis,
                'Tanggal_Izin'      => $perizinan->Tanggal_Izin->format('Y-m-d'),
                'Keterangan'        => $perizinan->Keterangan,
                'Tanggal_Pengajuan' => $perizinan->Tanggal_Pengajuan->format('Y-m-d H:i'),
            ]
        ], 201);
    }
}