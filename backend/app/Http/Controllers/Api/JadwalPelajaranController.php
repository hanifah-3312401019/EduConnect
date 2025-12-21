<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\JadwalPelajaran;
use App\Models\Kelas;
use App\Models\OrangTua;
use Illuminate\Support\Facades\Validator;

class JadwalPelajaranController extends Controller
{
    // ===================== LIST SEMUA JADWAL (ADMIN) =====================
    public function getAllJadwal()
    {
        $jadwal = JadwalPelajaran::with('kelas')
            ->urutHari()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $jadwal->map(function ($j) {
                return [
                    'Jadwal_Id' => $j->Jadwal_Id,
                    'Kelas_Id' => $j->Kelas_Id,
                    'Kelas_Nama' => $j->kelas->Nama_Kelas,
                    'Tahun_Ajar' => $j->kelas->Tahun_Ajar,
                    'Hari' => $j->Hari,
                    'Jam_Mulai' => $j->Jam_Mulai,
                    'Jam_Selesai' => $j->Jam_Selesai,
                    'Jam_Format' => date('H.i', strtotime($j->Jam_Mulai)) . ' - ' . date('H.i', strtotime($j->Jam_Selesai)),
                    'Mata_Pelajaran' => $j->Mata_Pelajaran,
                ];
            })
        ]);
    }

    // ===================== JADWAL BERDASARKAN KELAS (FILTER) =====================
    public function getJadwalByKelas($kelas_id)
    {
        $jadwal = JadwalPelajaran::where('Kelas_Id', $kelas_id)
            ->with('kelas')
            ->urutHari()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $jadwal->map(function ($j) {
                return [
                    'Jadwal_Id' => $j->Jadwal_Id,
                    'Hari' => $j->Hari,
                    'Jam_Mulai' => $j->Jam_Mulai,
                    'Jam_Selesai' => $j->Jam_Selesai,
                    'Jam_Format' => date('H.i', strtotime($j->Jam_Mulai)) . ' - ' . date('H.i', strtotime($j->Jam_Selesai)),
                    'Mata_Pelajaran' => $j->Mata_Pelajaran,
                ];
            })
        ]);
    }

    // ===================== TAMBAH JADWAL BARU =====================
    public function createJadwal(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Kelas_Id' => 'required|exists:kelas,Kelas_Id',
            'Hari' => 'required|in:Senin,Selasa,Rabu,Kamis,Jumat',
            'Jam_Mulai' => 'required|date_format:H:i',
            'Jam_Selesai' => 'required|date_format:H:i|after:Jam_Mulai',
            'Mata_Pelajaran' => 'required|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()
            ], 422);
        }

        // CEK JADWAL BENTROK
        $konflik = JadwalPelajaran::where('Kelas_Id', $request->Kelas_Id)
            ->where('Hari', $request->Hari)
            ->where(function ($query) use ($request) {
                $query->whereBetween('Jam_Mulai', [$request->Jam_Mulai, $request->Jam_Selesai])
                      ->orWhereBetween('Jam_Selesai', [$request->Jam_Mulai, $request->Jam_Selesai])
                      ->orWhere(function ($q) use ($request) {
                          $q->where('Jam_Mulai', '<', $request->Jam_Mulai)
                            ->where('Jam_Selesai', '>', $request->Jam_Selesai);
                      });
            })
            ->exists();

        if ($konflik) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal bentrok dengan pelajaran lain di waktu yang sama'
            ], 400);
        }

        $jadwal = JadwalPelajaran::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Jadwal pelajaran berhasil ditambahkan',
            'data' => [
                'Jadwal_Id' => $jadwal->Jadwal_Id,
                'Kelas_Id' => $jadwal->Kelas_Id,
                'Hari' => $jadwal->Hari,
                'Jam_Mulai' => $jadwal->Jam_Mulai,
                'Jam_Selesai' => $jadwal->Jam_Selesai,
                'Jam_Format' => date('H.i', strtotime($jadwal->Jam_Mulai)) . ' - ' . date('H.i', strtotime($jadwal->Jam_Selesai)),
                'Mata_Pelajaran' => $jadwal->Mata_Pelajaran,
            ]
        ]);
    }

    // ===================== UPDATE JADWAL =====================
    public function updateJadwal(Request $request, $id)
    {
        $jadwal = JadwalPelajaran::find($id);
        
        if (!$jadwal) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'Kelas_Id' => 'required|exists:kelas,Kelas_Id',
            'Hari' => 'required|in:Senin,Selasa,Rabu,Kamis,Jumat',
            'Jam_Mulai' => 'required|date_format:H:i',
            'Jam_Selesai' => 'required|date_format:H:i|after:Jam_Mulai',
            'Mata_Pelajaran' => 'required|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()
            ], 422);
        }

        // CEK KONFLIK (kecuali dirinya sendiri)
        $konflik = JadwalPelajaran::where('Kelas_Id', $request->Kelas_Id)
            ->where('Hari', $request->Hari)
            ->where('Jadwal_Id', '!=', $id)
            ->where(function ($query) use ($request) {
                $query->whereBetween('Jam_Mulai', [$request->Jam_Mulai, $request->Jam_Selesai])
                      ->orWhereBetween('Jam_Selesai', [$request->Jam_Mulai, $request->Jam_Selesai])
                      ->orWhere(function ($q) use ($request) {
                          $q->where('Jam_Mulai', '<', $request->Jam_Mulai)
                            ->where('Jam_Selesai', '>', $request->Jam_Selesai);
                      });
            })
            ->exists();

        if ($konflik) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal bentrok dengan pelajaran lain di waktu yang sama'
            ], 400);
        }

        $jadwal->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Jadwal pelajaran berhasil diperbarui',
            'data' => [
                'Jadwal_Id' => $jadwal->Jadwal_Id,
                'Kelas_Id' => $jadwal->Kelas_Id,
                'Hari' => $jadwal->Hari,
                'Jam_Mulai' => $jadwal->Jam_Mulai,
                'Jam_Selesai' => $jadwal->Jam_Selesai,
                'Jam_Format' => date('H.i', strtotime($jadwal->Jam_Mulai)) . ' - ' . date('H.i', strtotime($jadwal->Jam_Selesai)),
                'Mata_Pelajaran' => $jadwal->Mata_Pelajaran,
            ]
        ]);
    }

    // ===================== HAPUS JADWAL =====================
    public function deleteJadwal($id)
    {
        $jadwal = JadwalPelajaran::find($id);
        
        if (!$jadwal) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal tidak ditemukan'
            ], 404);
        }

        $jadwal->delete();

        return response()->json([
            'success' => true,
            'message' => 'Jadwal pelajaran berhasil dihapus'
        ]);
    }

    // ===================== DAFTAR MATA PELAJARAN (DROPDOWN) =====================
    public function getMataPelajaranList()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'Al-Quran/Keagamaan',
                'Matematika',
                'B. Inggris',
                'B. Indonesia',
                'B. Arab',
                'SBDP',
                'PJOK',
                'PAI/Agama',
                'PPKN'
            ]
        ]);
    }

    // ===================== JADWAL UNTUK ORANGTUA =====================
    public function getJadwalForOrangTua(Request $request)
    {
        $user = $request->user();
        
        if ($user->getRoleAttribute() !== 'orang_tua') {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak'
            ], 403);
        }

        // Dapatkan siswa/anak yang dimiliki orangtua
        $siswa = $user->siswa()->first();
        
        if (!$siswa) {
            return response()->json([
                'success' => true,
                'message' => 'Belum ada data siswa',
                'data' => []
            ]);
        }

        // Dapatkan kelas_id dari siswa
        $kelas_id = $siswa->Kelas_Id;
        
        // Ambil jadwal berdasarkan kelas
        $jadwal = JadwalPelajaran::where('Kelas_Id', $kelas_id)
            ->with('kelas')
            ->urutHari()
            ->get();

        // Group by hari
        $jadwalGrouped = [];
        foreach ($jadwal as $j) {
            $hari = $j->Hari;
            if (!isset($jadwalGrouped[$hari])) {
                $jadwalGrouped[$hari] = [];
            }
            $jadwalGrouped[$hari][] = [
                'Jam_Format' => date('H.i', strtotime($j->Jam_Mulai)) . ' - ' . date('H.i', strtotime($j->Jam_Selesai)),
                'Mata_Pelajaran' => $j->Mata_Pelajaran,
            ];
        }

        return response()->json([
            'success' => true,
            'data' => [
                'siswa' => [
                    'Nama' => $siswa->Nama,
                    'Kelas' => $siswa->kelas->Nama_Kelas ?? '-',
                    'Tahun_Ajar' => $siswa->kelas->Tahun_Ajar ?? '-',
                ],
                'jadwal' => $jadwalGrouped
            ]
        ]);
    }
}