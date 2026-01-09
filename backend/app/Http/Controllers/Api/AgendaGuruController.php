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
use Illuminate\Support\Facades\Auth;

class AgendaGuruController extends Controller
{
private function getGuru()
{
    $guru = Auth::user(); // ini LANGSUNG model Guru

    if (!$guru || !($guru instanceof \App\Models\Guru)) {
        abort(response()->json([
            'success' => false,
            'message' => 'Unauthenticated'
        ], 401));
    }

    return $guru;
}

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

    public function index(Request $request)
{
    $guru = Auth::user();

    if (!$guru) {
        return response()->json([
            'success' => false,
            'message' => 'Unauthenticated'
        ], 401);
    }

    $guruId = $guru->Guru_Id;
    
    $kelasGuruList = Kelas::where('Guru_Utama_Id', $guruId)
                         ->orWhere('Guru_Pendamping_Id', $guruId)
                         ->get();

    if ($kelasGuruList->isEmpty()) {
        $query = Agenda::where('Guru_Id', $guruId); 
    } else {
        $kelasIds = $kelasGuruList->pluck('Kelas_Id')->toArray();
    
        $query = Agenda::where(function($q) use ($guruId, $kelasIds) {
            $q->where('Guru_Id', $guruId) 
              ->orWhere(function($q2) use ($kelasIds) {
                  $q2->where('Tipe', 'perkelas')
                     ->whereIn('Kelas_Id', $kelasIds); 
              })
              ->orWhere('Tipe', 'ekskul')
              ->orWhere('Tipe', 'sekolah'); 
        });
    }

    $query = $query->with(['guru', 'kelas', 'ekstrakulikuler'])
        ->orderBy('Tanggal', 'desc')
        ->orderBy('Waktu_Mulai', 'desc');

    if ($request->has('tipe') && $request->tipe) {
        $query->where('Tipe', $request->tipe);
    }

    $agenda = $query->get();

    return response()->json([
        'success' => true,
        'data' => $agenda
    ]);
}

    public function store(Request $request)
{
    Log::info('Store request received', $request->all());

    $guru = Auth::user(); // ← LANGSUNG Guru dari token

    if (!$guru) {
        return response()->json([
            'success' => false,
            'message' => 'Unauthenticated'
        ], 401);
    }

    $guruId = $guru->Guru_Id; 

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
                // Cari kelas di mana guru mengajar (ambil kelas pertama)
                $kelasGuru = Kelas::where('Guru_Utama_Id', $guruId)
                                 ->orWhere('Guru_Pendamping_Id', $guruId)
                                 ->first();
                
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
                // Cari kelas di mana guru mengajar (ambil kelas pertama)
                $kelasGuru = Kelas::where('Guru_Utama_Id', $guruId)
                                 ->orWhere('Guru_Pendamping_Id', $guruId)
                                 ->first();
                
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
            $agenda = Agenda::create($data);
            
            $agenda->load(['guru', 'kelas', 'ekstrakulikuler']);
            
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
       $guru = Auth::user();
        
        if (!$guru) {
        return response()->json([
            'success' => false,
            'message' => 'Unauthenticated'
        ], 401);
        }

        $guruId = $guru->Guru_Id;

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
                // Cari kelas di mana guru mengajar (ambil kelas pertama)
                $kelasGuru = Kelas::where('Guru_Utama_Id', $guruId)
                                 ->orWhere('Guru_Pendamping_Id', $guruId)
                                 ->first();
                
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
                // Cari kelas di mana guru mengajar (ambil kelas pertama)
                $kelasGuru = Kelas::where('Guru_Utama_Id', $guruId)
                                 ->orWhere('Guru_Pendamping_Id', $guruId)
                                 ->first();
                
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

    public function destroy($id)
    {
        $guru = Auth::user();
        
         if (!$guru) {
        return response()->json([
            'success' => false,
            'message' => 'Unauthenticated'
        ], 401);
        }

        $guruId = $guru->Guru_Id;

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

    public function getDropdownData()
    {
        $guru = Auth::user();
        
        if (!$guru) {
        return response()->json([
            'success' => false,
            'message' => 'Unauthenticated'
        ], 401);
    }

    $guruId = $guru->Guru_Id;
        
        Log::info('Getting dropdown data for agenda - guru_id: ' . $guruId);
        
        // Cari kelas di mana guru mengajar (ambil kelas pertama)
        $kelasGuru = Kelas::where('Guru_Utama_Id', $guruId)
                         ->orWhere('Guru_Pendamping_Id', $guruId)
                         ->first();
        
        Log::info('Kelas found for guru: ' . ($kelasGuru ? $kelasGuru->Nama_Kelas : 'NO CLASS'));
        
        // Ambil semua ekskul dari database
        $semuaEkskul = Ekstrakulikuler::orderBy('nama')->get();
        Log::info('Total ekskul found: ' . $semuaEkskul->count());

        return response()->json([
            'success' => true,
            'data' => [
                'kelas_guru' => $kelasGuru ? [
                    'Kelas_Id' => $kelasGuru->Kelas_Id,
                    'nama_kelas' => $kelasGuru->Nama_Kelas,
                    'peran' => $kelasGuru->Guru_Utama_Id == $guruId ? 'Guru Utama' : 'Guru Pendamping'
                ] : null,

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