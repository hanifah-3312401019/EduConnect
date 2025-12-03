<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pengumuman;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PengumumanOrtuController extends Controller
{
    public function index(Request $request)
    {
        $orangTua = Auth::user();
        
        if (!$orangTua) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        $pengumuman = $this->getPengumumanForOrtu($orangTua);

        return response()->json([
            'success' => true,
            'data' => $pengumuman
        ]);
    }

    public function showByKategori(Request $request, $kategori = 'semua')
{
    $orangTua = Auth::user();
    if (!$orangTua) {
        return response()->json([
            'success' => false,
            'message' => 'Unauthorized'
        ], 401);
    }

    $pengumuman = $this->getPengumumanForOrtuByKategori($orangTua, $kategori);

    return response()->json([
        'success' => true,
        'data' => $pengumuman
    ]);
}

    private function getPengumumanForOrtu($orangTua)
    {
        $anak = $orangTua->anak;
        if (!$anak) return [];

        return Pengumuman::with('guru')
            ->where(function($query) use ($anak) {
                $query->where('Tipe', 'umum')
                      ->orWhere(function($q) use ($anak) {
                          $q->where('Tipe', 'perkelas')
                            ->where('Kelas_Id', $anak->Kelas_Id);
                      })
                      ->orWhere(function($q) use ($anak) {
                          $q->where('Tipe', 'personal')
                            ->where('Siswa_Id', $anak->Siswa_Id);
                      });
            })
            ->orderBy('Tanggal', 'desc')
            ->get();
    }

    private function getPengumumanForOrtuByKategori($orangTua, $kategori)
    {
        $anak = $orangTua->anak;
        if (!$anak) return [];

        $query = Pengumuman::with('guru');

        switch ($kategori) {
            case 'umum':
                $query->where('Tipe', 'umum');
                break;

            case 'kelas':
            case 'perkelas':  // FIX
                $query->where('Tipe', 'perkelas')
                      ->where('Kelas_Id', $anak->Kelas_Id);
                break;

            case 'personal':
                $query->where('Tipe', 'personal')
                      ->where('Siswa_Id', $anak->Siswa_Id);
                break;

            default:
                $query->where(function($q) use ($anak) {
                    $q->where('Tipe', 'umum')
                      ->orWhere(function($r) use ($anak) {
                          $r->where('Tipe', 'perkelas')
                            ->where('Kelas_Id', $anak->Kelas_Id);
                      })
                      ->orWhere(function($r) use ($anak) {
                          $r->where('Tipe', 'personal')
                            ->where('Siswa_Id', $anak->Siswa_Id);
                      });
                });
        }

        return $query->orderBy('Tanggal', 'desc')->get();
    }
}
