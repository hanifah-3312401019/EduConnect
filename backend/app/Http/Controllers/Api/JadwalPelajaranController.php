<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\JadwalPelajaran;
use App\Models\Kelas;
use App\Models\OrangTua;
use App\Models\Siswa;
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

    // ===================== JADWAL UNTUK ORANG TUA =====================
    public function getJadwalForOrangTua(Request $request)
    {
        try {
            $user = $request->user();
            
            // Validasi user adalah orang tua
            if (!$user || $user->getRoleAttribute() !== 'orang_tua') {
                return response()->json([
                    'success' => false,
                    'message' => 'Akses ditolak. Hanya untuk orang tua.'
                ], 403);
            }

            // Dapatkan siswa/anak yang dimiliki orang tua
            $siswa = Siswa::where('OrangTua_Id', $user->OrangTua_Id)->first();
            
            if (!$siswa) {
                return response()->json([
                    'success' => true,
                    'message' => 'Belum ada data siswa/anak',
                    'data' => [
                        'siswa' => null,
                        'jadwal' => []
                    ]
                ]);
            }

            // Dapatkan kelas_id dari siswa
            $kelas_id = $siswa->Kelas_Id;
            
            // Ambil jadwal berdasarkan kelas
            $jadwal = JadwalPelajaran::where('Kelas_Id', $kelas_id)
                ->with('kelas')
                ->urutHari()
                ->get();

            // Format data untuk response
            $jadwalFormatted = $jadwal->map(function ($j) {
                return [
                    'hari' => $j->Hari,
                    'jam_mulai' => $j->Jam_Mulai,
                    'jam_selesai' => $j->Jam_Selesai,
                    'jam_format' => date('H.i', strtotime($j->Jam_Mulai)) . ' - ' . date('H.i', strtotime($j->Jam_Selesai)),
                    'mata_pelajaran' => $j->Mata_Pelajaran,
                ];
            });

            // Group by hari
            $jadwalGrouped = [];
            foreach ($jadwalFormatted as $j) {
                $hari = $j['hari'];
                if (!isset($jadwalGrouped[$hari])) {
                    $jadwalGrouped[$hari] = [];
                }
                $jadwalGrouped[$hari][] = [
                    'jam' => $j['jam_format'],
                    'mata_pelajaran' => $j['mata_pelajaran'],
                ];
            }

            // Urutkan hari sesuai urutan
            $orderedDays = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
            $orderedJadwal = [];
            foreach ($orderedDays as $hari) {
                if (isset($jadwalGrouped[$hari])) {
                    $orderedJadwal[$hari] = $jadwalGrouped[$hari];
                } else {
                    $orderedJadwal[$hari] = [];
                }
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'siswa' => [
                        'nama' => $siswa->Nama,
                        'kelas' => $siswa->kelas ? $siswa->kelas->Nama_Kelas : '-',
                        'tahun_ajar' => $siswa->kelas ? $siswa->kelas->Tahun_Ajar : '-',
                    ],
                    'jadwal' => $orderedJadwal
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
}