<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Agenda;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class AgendaOrtuController extends Controller
{
    public function index(Request $request, $kategori = 'semua')
    {
        Log::info('=== AGENDA ORTU CONTROLLER ===', ['kategori' => $kategori]);

        $orangTua = Auth::user();
        
        if (!$orangTua) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        // Gunakan relasi 'siswa()'
        $siswa = $orangTua->siswa;
        
        if (!$siswa) {
            return response()->json([
                'success' => false,
                'message' => 'Data siswa tidak ditemukan'
            ], 404);
        }

        $agenda = $this->getAgendaForOrtu($siswa, $kategori);

        return response()->json([
            'success' => true,
            'data' => $agenda,
            'debug' => [
                'siswa_id' => $siswa->Siswa_Id,
                'kelas_id' => $siswa->Kelas_Id,
                'ekskul_id' => $siswa->Ekstrakulikuler_Id,
                'total_agenda' => $agenda->count()
            ]
        ]);
    }

    private function getAgendaForOrtu($siswa, $kategori)
    {
        $query = Agenda::with(['guru', 'kelas', 'ekstrakulikuler'])
            ->orderBy('Tanggal', 'desc')
            ->orderBy('Waktu_Mulai', 'desc');

        switch ($kategori) {
            case 'sekolah':
                $query->where('Tipe', 'sekolah');
                break;

            case 'perkelas':
                $query->where('Tipe', 'perkelas')
                      ->where('Kelas_Id', $siswa->Kelas_Id);
                break;

            case 'ekskul':
                if ($siswa->Ekstrakulikuler_Id) {
                    $query->where('Tipe', 'ekskul')
                          ->where('Ekstrakulikuler_Id', $siswa->Ekstrakulikuler_Id);
                } else {
                    return collect();
                }
                break;

            default: // semua
                $query->where(function($q) use ($siswa) {
                    $q->where('Tipe', 'sekolah')
                      ->orWhere(function($r) use ($siswa) {
                          $r->where('Tipe', 'perkelas')
                            ->where('Kelas_Id', $siswa->Kelas_Id);
                      })
                      ->orWhere(function($r) use ($siswa) {
                          if ($siswa->Ekstrakulikuler_Id) {
                              $r->where('Tipe', 'ekskul')
                                ->where('Ekstrakulikuler_Id', $siswa->Ekstrakulikuler_Id);
                          }
                      });
                });
        }

        return $query->get();
    }
}