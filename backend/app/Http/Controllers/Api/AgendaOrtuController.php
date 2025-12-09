<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Agenda;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AgendaOrtuController extends Controller
{
    public function index(Request $request, $kategori = 'semua')
    {
        $orangTua = Auth::user();
        
        if (!$orangTua) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        $anak = $orangTua->anak;
        if (!$anak) {
            return response()->json([
                'success' => false,
                'message' => 'Data anak tidak ditemukan'
            ], 404);
        }

        $agenda = $this->getAgendaForOrtu($anak, $kategori);

        return response()->json([
            'success' => true,
            'data' => $agenda
        ]);
    }

    private function getAgendaForOrtu($anak, $kategori)
    {
        $query = Agenda::with(['guru', 'kelas', 'ekstrakulikuler'])
            ->orderBy('Tanggal', 'desc')
            ->orderBy('Waktu_Mulai', 'desc');

        switch ($kategori) {
            case 'sekolah':
                // Agenda sekolah (umum) - semua kelas
                $query->where('Tipe', 'sekolah');
                break;

            case 'perkelas':
                // Agenda perkelas anak
                $query->where('Tipe', 'perkelas')
                      ->where('Kelas_Id', $anak->Kelas_Id);
                break;

            case 'ekskul':
                // Agenda ekskul anak
                if ($anak->Ekstrakulikuler_Id) {
                    $query->where('Tipe', 'ekskul')
                          ->where('Ekstrakulikuler_Id', $anak->Ekstrakulikuler_Id);
                } else {
                    return collect();
                }
                break;

            default: // semua
                // Gabungan semua agenda yang relevan
                $query->where(function($q) use ($anak) {
                    // Agenda sekolah (umum)
                    $q->where('Tipe', 'sekolah');
                })->orWhere(function($q) use ($anak) {
                    // Agenda perkelas anak
                    $q->where('Tipe', 'perkelas')
                      ->where('Kelas_Id', $anak->Kelas_Id);
                })->orWhere(function($q) use ($anak) {
                    // Agenda ekskul anak
                    if ($anak->Ekstrakulikuler_Id) {
                        $q->where('Tipe', 'ekskul')
                          ->where('Ekstrakulikuler_Id', $anak->Ekstrakulikuler_Id);
                    }
                });
        }

        return $query->get();
    }

    public static function getJenisAgenda($agenda)
    {
        return $agenda->Tipe; 
    }
}