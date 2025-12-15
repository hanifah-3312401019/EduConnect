<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Agenda;
use App\Models\Guru;
use App\Models\Kelas;
use App\Models\Ekstrakulikuler;
use App\Models\Notifikasi;
use App\Models\OrangTua;
use App\Models\Siswa;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;

class AgendaGuruController extends Controller
{
    // Helper method untuk mendapatkan Guru_Id dari header
    private function getGuruId()
    {
        $guruId = request()->header('Guru_Id');
        
        if (!$guruId) {
            return response()->json([
                'success' => false,
                'message' => 'Guru_ID header diperlukan'
            ], 400);
        }

        $guru = Guru::find($guruId);
        if (!$guru) {
            return response()->json([
                'success' => false,
                'message' => 'Guru tidak ditemukan'
            ], 404);
        }

        return $guruId;
    }

    // Pada method sendAgendaNotification() di AgendaGuruController.php
private function sendAgendaNotification($agenda, $tipe)
{
    Log::info('Mengirim notifikasi agenda', [
        'agenda_id' => $agenda->Agenda_Id,
        'tipe' => $tipe,
        'judul' => $agenda->Judul
    ]);
    
    try {
        $guruNama = $agenda->guru ? $agenda->guru->Nama : 'Guru';
        $judulAgenda = $agenda->Judul;
        $tanggalAgenda = $agenda->Tanggal;
        $waktuMulai = $agenda->Waktu_Mulai;
        
        $orangtuaIds = [];
        
        if ($tipe === 'sekolah') {
            $orangtuaIds = OrangTua::pluck('OrangTua_Id')->toArray();
            Log::info('Agenda sekolah - kirim ke semua orangtua: ' . count($orangtuaIds));
            
        } elseif ($tipe === 'perkelas') {
            if (!$agenda->kelas) {
                Log::warning('Kelas tidak ditemukan di agenda');
                return 0;
            }
            
            $kelasId = $agenda->kelas->Kelas_Id;
            $siswaIds = Siswa::where('Kelas_Id', $kelasId)
                ->pluck('Siswa_Id')
                ->toArray();
                
            $orangtuaIds = OrangTua::whereIn('Siswa_Id', $siswaIds)
                ->pluck('OrangTua_Id')
                ->toArray();
                
            Log::info("Agenda perkelas ID {$kelasId} - kirim ke " . count($orangtuaIds) . " orangtua");
            
        } elseif ($tipe === 'ekskul') {
            if (!$agenda->ekstrakulikuler) {
                Log::warning('Ekstrakulikuler tidak ditemukan di agenda');
                return 0;
            }
            
            $ekskulId = $agenda->ekstrakulikuler->Ekstrakulikuler_Id;
            
            $siswaIds = Siswa::where('Ekstrakulikuler_Id', $ekskulId)
                ->pluck('Siswa_Id')
                ->toArray();
                
            if (empty($siswaIds) && Schema::hasTable('ekskul_siswa')) {
                try {
                    $siswaIds = DB::table('ekskul_siswa')
                        ->where('Ekstrakulikuler_Id', $ekskulId)
                        ->pluck('Siswa_Id')
                        ->toArray();
                } catch (\Exception $e) {
                    Log::warning('Error akses pivot: ' . $e->getMessage());
                }
            }
            
            if (empty($siswaIds)) {
                Log::warning('Tidak ada siswa untuk ekskul ini!');
                return 0;
            }
            
            $orangtuaIds = OrangTua::whereIn('Siswa_Id', $siswaIds)
                ->pluck('OrangTua_Id')
                ->toArray();
                
            Log::info("Agenda ekskul ID {$ekskulId} - kirim ke " . count($orangtuaIds) . " orangtua");
        }

        $createdCount = 0;
        
        foreach ($orangtuaIds as $orangtuaId) {
            try {
                // ✅ PERBAIKAN: OrangTua_Id (huruf T besar)
                $notifikasi = Notifikasi::create([
                    'OrangTua_Id' => $orangtuaId,
                    'Judul' => 'Agenda Baru: ' . $judulAgenda,
                    'Pesan' => 'Guru ' . $guruNama . ' membuat agenda baru: ' . $judulAgenda . 
                              ' pada ' . $tanggalAgenda . ' pukul ' . $waktuMulai,
                    'Jenis' => 'agenda',
                    'Agenda_Id' => $agenda->Agenda_Id,
                    'dibaca' => false,
                ]);
                
                $createdCount++;
                
            } catch (\Exception $e) {
                Log::error('Gagal buat notifikasi agenda untuk orangtua ' . $orangtuaId . ': ' . $e->getMessage());
            }
        }

        Log::info('Notifikasi agenda selesai', [
            'agenda_id' => $agenda->Agenda_Id,
            'total_penerima' => count($orangtuaIds),
            'berhasil_dibuat' => $createdCount
        ]);

        return $createdCount;

    } catch (\Exception $e) {
        Log::error('Error sendAgendaNotification: ' . $e->getMessage());
        return 0;
    }
}

    // Get semua agenda guru dengan filter tipe
    public function index(Request $request)
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $query = Agenda::where('Guru_Id', $guruId)
            ->with(['guru', 'kelas', 'ekstrakulikuler'])
            ->orderBy('Tanggal', 'desc')
            ->orderBy('Waktu_Mulai', 'desc');

        // Filter by tipe jika ada
        if ($request->has('tipe') && $request->tipe) {
            $query->where('Tipe', $request->tipe);
        }

        $agenda = $query->get();

        return response()->json([
            'success' => true,
            'data' => $agenda
        ]);
    }

    // BUAT AGENDA BARU DENGAN NOTIFIKASI
    public function store(Request $request)
    {
        Log::info('Store request received', $request->all());
        
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        // Validasi
        $validator = Validator::make($request->all(), [
            'Judul' => 'required|string|max:255',
            'Deskripsi' => 'required|string',
            'Tanggal' => 'required|date',
            'Waktu_Mulai' => 'required|date_format:H:i',
            'Waktu_Selesai' => 'required|date_format:H:i',
            'Tipe' => 'required|in:sekolah,perkelas,ekskul',
            'Ekstrakulikuler_Id' => 'nullable|required_if:Tipe,ekskul|exists:ekstrakulikuler,Ekstrakulikuler_Id',
        ], [
            'Waktu_Mulai.date_format' => 'Format waktu harus HH:MM (contoh: 08:00)',
            'Waktu_Selesai.date_format' => 'Format waktu harus HH:MM (contoh: 10:00)',
            'Ekstrakulikuler_Id.required_if' => 'Pilih ekstrakurikuler untuk agenda ekskul',
        ]);

        // Validasi tambahan
        $validator->after(function ($validator) use ($request, $guruId) {
            if ($request->Waktu_Mulai && $request->Waktu_Selesai) {
                if (strtotime($request->Waktu_Selesai) <= strtotime($request->Waktu_Mulai)) {
                    $validator->errors()->add('Waktu_Selesai', 'Waktu selesai harus setelah waktu mulai.');
                }
            }
        });

        if ($validator->fails()) {
            Log::warning('Validasi gagal', $validator->errors()->toArray());
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        // Prepare data berdasarkan tipe
        $data = [
            'Guru_Id' => $guruId,
            'Judul' => $request->Judul,
            'Deskripsi' => $request->Deskripsi,
            'Tanggal' => $request->Tanggal,
            'Waktu_Mulai' => $request->Waktu_Mulai,
            'Waktu_Selesai' => $request->Waktu_Selesai,
            'Tipe' => $request->Tipe,
        ];

        // Handle berdasarkan tipe
        switch ($request->Tipe) {
            case 'sekolah':
                $data['Kelas_Id'] = null;
                $data['Ekstrakulikuler_Id'] = null;
                break;
                
            case 'perkelas':
                $kelasGuru = Kelas::where('Guru_Id', $guruId)->first();
                if (!$kelasGuru) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Anda belum memiliki kelas. Tidak dapat membuat agenda kelas.'
                    ], 400);
                }
                $data['Kelas_Id'] = $kelasGuru->Kelas_Id;
                $data['Ekstrakulikuler_Id'] = null;
                break;
                
            case 'ekskul':
                $kelasGuru = Kelas::where('Guru_Id', $guruId)->first();
                if (!$kelasGuru) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Anda belum memiliki kelas. Tidak dapat membuat agenda ekskul.'
                    ], 400);
                }
                $data['Kelas_Id'] = $kelasGuru->Kelas_Id;
                $data['Ekstrakulikuler_Id'] = $request->Ekstrakulikuler_Id;
                break;
        }

        DB::beginTransaction();
        
        try {
            // BUAT AGENDA
            $agenda = Agenda::create($data);
            
            // LOAD RELATIONSHIPS
            $agenda->load(['guru', 'kelas', 'ekstrakulikuler']);
            
            // KIRIM NOTIFIKASI KE ORANGTUA
            $jumlahPenerima = $this->sendAgendaNotification($agenda, $request->Tipe);
            
            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Agenda berhasil dibuat' . 
                           ($jumlahPenerima > 0 ? ' dan notifikasi dikirim ke ' . $jumlahPenerima . ' orangtua' : ''),
                'data' => $agenda
            ], 201);
            
        } catch (\Exception $e) {
            DB::rollBack();
            
            Log::error('Gagal membuat agenda: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat agenda: ' . $e->getMessage()
            ], 500);
        }
    }

    // Update agenda
    public function update(Request $request, $id)
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $agenda = Agenda::where('Agenda_Id', $id)
            ->where('Guru_Id', $guruId)
            ->first();

        if (!$agenda) {
            return response()->json([
                'success' => false,
                'message' => 'Agenda tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'Judul' => 'required|string|max:255',
            'Deskripsi' => 'required|string',
            'Tanggal' => 'required|date',
            'Waktu_Mulai' => 'required|date_format:H:i',
            'Waktu_Selesai' => 'required|date_format:H:i',
            'Tipe' => 'required|in:sekolah,perkelas,ekskul',
            'Ekstrakulikuler_Id' => 'nullable|required_if:Tipe,ekskul|exists:ekstrakulikuler,Ekstrakulikuler_Id',
        ], [
            'Waktu_Mulai.date_format' => 'Format waktu harus HH:MM (contoh: 08:00)',
            'Waktu_Selesai.date_format' => 'Format waktu harus HH:MM (contoh: 10:00)',
            'Ekstrakulikuler_Id.required_if' => 'Pilih ekstrakurikuler untuk agenda ekskul',
        ]);

        $validator->after(function ($validator) use ($request, $guruId) {
            if ($request->Waktu_Mulai && $request->Waktu_Selesai) {
                if (strtotime($request->Waktu_Selesai) <= strtotime($request->Waktu_Mulai)) {
                    $validator->errors()->add('Waktu_Selesai', 'Waktu selesai harus setelah waktu mulai.');
                }
            }
        });

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        // Prepare data berdasarkan tipe
        $data = [
            'Judul' => $request->Judul,
            'Deskripsi' => $request->Deskripsi,
            'Tanggal' => $request->Tanggal,
            'Waktu_Mulai' => $request->Waktu_Mulai,
            'Waktu_Selesai' => $request->Waktu_Selesai,
            'Tipe' => $request->Tipe,
        ];

        // Handle berdasarkan tipe
        switch ($request->Tipe) {
            case 'sekolah':
                $data['Kelas_Id'] = null;
                $data['Ekstrakulikuler_Id'] = null;
                break;
                
            case 'perkelas':
                $kelasGuru = Kelas::where('Guru_Id', $guruId)->first();
                if (!$kelasGuru) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Anda belum memiliki kelas. Tidak dapat mengubah agenda menjadi tipe kelas.'
                    ], 400);
                }
                $data['Kelas_Id'] = $kelasGuru->Kelas_Id;
                $data['Ekstrakulikuler_Id'] = null;
                break;
                
            case 'ekskul':
                $kelasGuru = Kelas::where('Guru_Id', $guruId)->first();
                if (!$kelasGuru) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Anda belum memiliki kelas. Tidak dapat mengubah agenda menjadi tipe ekskul.'
                    ], 400);
                }
                $data['Kelas_Id'] = $kelasGuru->Kelas_Id;
                $data['Ekstrakulikuler_Id'] = $request->Ekstrakulikuler_Id;
                break;
        }

        DB::beginTransaction();
        
        try {
            // Update agenda
            $agenda->update($data);
            
            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Agenda berhasil diupdate',
                'data' => $agenda->load(['guru', 'kelas', 'ekstrakulikuler'])
            ]);
            
        } catch (\Exception $e) {
            DB::rollBack();
            
            Log::error('Gagal update agenda: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Gagal update agenda: ' . $e->getMessage()
            ], 500);
        }
    }

    // Hapus agenda BESERTA NOTIFIKASINYA
    public function destroy($id)
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $agenda = Agenda::where('Agenda_Id', $id)
            ->where('Guru_Id', $guruId)
            ->first();

        if (!$agenda) {
            return response()->json([
                'success' => false,
                'message' => 'Agenda tidak ditemukan'
            ], 404);
        }

        DB::beginTransaction();
        
        try {
            // Hapus notifikasi terkait agenda ini
            Notifikasi::where('Agenda_Id', $id)->delete();
            
            // Hapus agenda
            $agenda->delete();
            
            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Agenda berhasil dihapus beserta notifikasinya'
            ]);
            
        } catch (\Exception $e) {
            DB::rollBack();
            
            Log::error('Gagal hapus agenda: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus agenda: ' . $e->getMessage()
            ], 500);
        }
    }

    // Get dropdown data (kelas, ekskul)
    public function getDropdownData()
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        // Ambil kelas guru (1 guru = 1 kelas)
        $kelasGuru = Kelas::where('Guru_Id', $guruId)->first();
        
        // Ambil SEMUA ekskul di sekolah (untuk dropdown ekskul)
        $semuaEkskul = Ekstrakulikuler::orderBy('nama')->get();

        return response()->json([
            'success' => true,
            'data' => [
                // Kelas guru (bisa null jika guru belum punya kelas)
                'kelas_guru' => $kelasGuru ? [
                    'Kelas_Id' => $kelasGuru->Kelas_Id,
                    'nama_kelas' => $kelasGuru->Nama_Kelas
                ] : null,

                // Semua ekskul sekolah (untuk dropdown ekskul)
                'ekstrakulikuler' => $semuaEkskul->map(function($ekskul) {
                    return [
                        'Ekstrakulikuler_Id' => $ekskul->Ekstrakulikuler_Id,
                        'nama' => $ekskul->nama
                    ];
                })->toArray()
            ]
        ]);
    }
}