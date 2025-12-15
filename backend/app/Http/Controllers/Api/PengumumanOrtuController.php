<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pengumuman;
use App\Models\Siswa;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class PengumumanOrtuController extends Controller
{
    public function showByKategori(Request $request, $kategori = 'semua')
    {
        Log::info('=== PENGUMUMAN ORTU CONTROLLER ===', ['kategori' => $kategori]);

        $orangTua = Auth::user();
        
        if (!$orangTua) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        $siswa = $orangTua->siswa;
        
        Log::info('Siswa dari relasi:', [
            'siswa_id' => $siswa ? $siswa->Siswa_Id : null,
            'nama' => $siswa ? $siswa->Nama : null
        ]);

        if (!$siswa) {
            Log::warning('Siswa tidak ditemukan untuk orangtua ID: ' . $orangTua->OrangTua_Id);
            return response()->json([
                'success' => false,
                'message' => 'Data siswa tidak ditemukan'
            ], 404);
        }

        $pengumuman = $this->getPengumumanForOrtu($siswa, $kategori);

        return response()->json([
            'success' => true,
            'data' => $pengumuman,
            'debug' => [
                'siswa_id' => $siswa->Siswa_Id,
                'kelas_id' => $siswa->Kelas_Id,
                'total' => $pengumuman->count()
            ]
        ]);
    }

    private function getPengumumanForOrtu($siswa, $kategori)
    {
        $query = Pengumuman::with(['guru', 'kelas', 'siswa']);

        switch ($kategori) {
            case 'umum':
                $query->where('Tipe', 'umum');
                break;

            case 'perkelas':
                $query->where('Tipe', 'perkelas')
                      ->where('Kelas_Id', $siswa->Kelas_Id);
                break;

            case 'personal':
                $query->where('Tipe', 'personal')
                      ->where('Siswa_Id', $siswa->Siswa_Id);
                break;

            default: // semua
                $query->where(function($q) use ($siswa) {
                    $q->where('Tipe', 'umum')
                      ->orWhere(function($r) use ($siswa) {
                          $r->where('Tipe', 'perkelas')
                            ->where('Kelas_Id', $siswa->Kelas_Id);
                      })
                      ->orWhere(function($r) use ($siswa) {
                          $r->where('Tipe', 'personal')
                            ->where('Siswa_Id', $siswa->Siswa_Id);
                      });
                });
        }

        return $query->orderBy('Tanggal', 'desc')
                    ->orderBy('created_at', 'desc')
                    ->get();
    }
}