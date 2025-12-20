<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pengumuman;
use App\Models\Guru;
use App\Models\Kelas;
use App\Models\Siswa;
use App\Models\Notifikasi;
use App\Models\OrangTua;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class PengumumanGuruController extends Controller
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

    private function sendPengumumanNotification($pengumuman, $tipe)
    {
        Log::info('Mulai kirim notifikasi pengumuman', [
            'pengumuman_id' => $pengumuman->Pengumuman_Id,
            'tipe' => $tipe,
            'judul' => $pengumuman->Judul,
            'kelas_id' => $pengumuman->Kelas_Id,
            'siswa_id' => $pengumuman->Siswa_Id
        ]);
        
        try {
            $guruNama = $pengumuman->guru->Nama ?? 'Guru';
            $judulPengumuman = $pengumuman->Judul;
            
            $orangtuaIds = [];
            
            if ($tipe === 'umum') {
                $orangtuaIds = OrangTua::pluck('OrangTua_Id')->toArray();
                Log::info('Pengumuman UMUM: Kirim ke ' . count($orangtuaIds) . ' orangtua');
            } 
            elseif ($tipe === 'perkelas') {
                if (!$pengumuman->Kelas_Id) {
                    Log::error('Pengumuman PERKELAS: Kelas_Id NULL', $pengumuman->toArray());
                    return 0;
                }
                
                if (!$pengumuman->relationLoaded('kelas')) {
                    $pengumuman->load('kelas');
                }
                
                $kelasId = $pengumuman->Kelas_Id;
                $namaKelas = $pengumuman->kelas ? $pengumuman->kelas->Nama_Kelas : 'Kelas ' . $kelasId;
                
                Log::info('Pengumuman PERKELAS: Mencari siswa di kelas ' . $namaKelas . ' (ID: ' . $kelasId . ')');
                
                $siswaIds = Siswa::where('Kelas_Id', $kelasId)
                    ->pluck('Siswa_Id')
                    ->toArray();
                
                Log::info('Pengumuman PERKELAS: Ditemukan ' . count($siswaIds) . ' siswa');
                
                if (empty($siswaIds)) {
                    Log::warning('Pengumuman PERKELAS: Tidak ada siswa di kelas ini');
                    return 0;
                }
                
                $orangtuaIds = OrangTua::whereIn('Siswa_Id', $siswaIds)
                    ->pluck('OrangTua_Id')
                    ->toArray();
                    
                Log::info('Pengumuman PERKELAS: Ditemukan ' . count($orangtuaIds) . ' orangtua');
                
                if (empty($orangtuaIds)) {
                    Log::warning('Pengumuman PERKELAS: Tidak ada orangtua untuk siswa di kelas ini');
                    Log::info('Detail siswa IDs: ' . implode(', ', $siswaIds));
                    
                    foreach ($siswaIds as $siswaId) {
                        $siswa = Siswa::find($siswaId);
                        $orangtua = OrangTua::where('Siswa_Id', $siswaId)->first();
                        Log::debug('Siswa: ' . ($siswa ? $siswa->Nama : 'ID:' . $siswaId) . 
                                  ' -> OrangTua: ' . ($orangtua ? $orangtua->Nama . ' (ID:' . $orangtua->OrangTua_Id . ')' : 'TIDAK ADA'));
                    }
                }
            }
            elseif ($tipe === 'personal') {
                if (!$pengumuman->Siswa_Id) {
                    Log::error('Pengumuman PERSONAL: Siswa_Id NULL');
                    return 0;
                }
                
                $orangtua = OrangTua::where('Siswa_Id', $pengumuman->Siswa_Id)->first();
                
                if ($orangtua) {
                    $orangtuaIds = [$orangtua->OrangTua_Id];
                    Log::info('Pengumuman PERSONAL: Kirim ke orangtua ID ' . $orangtua->OrangTua_Id);
                } else {
                    Log::warning('Pengumuman PERSONAL: Tidak ditemukan orangtua untuk siswa ID ' . $pengumuman->Siswa_Id);
                    return 0;
                }
            }

            $createdCount = 0;
            foreach ($orangtuaIds as $orangtuaId) {
                try {
                    $notifikasi = Notifikasi::create([
                        'OrangTua_Id' => $orangtuaId,
                        'Judul' => 'Pengumuman Baru: ' . $judulPengumuman,
                        'Pesan' => 'Guru ' . $guruNama . ' mengirim pengumuman baru: ' . $judulPengumuman,
                        'Jenis' => 'pengumuman',
                        'Pengumuman_Id' => $pengumuman->Pengumuman_Id,
                        'dibaca' => false,
                    ]);
                    
                    $createdCount++;
                    Log::debug('Notifikasi dibuat untuk orangtua ID: ' . $orangtuaId);
                    
                } catch (\Exception $e) {
                    Log::error('Gagal buat notifikasi untuk orangtua ' . $orangtuaId . ': ' . $e->getMessage());
                }
            }

            Log::info('Notifikasi pengumuman berhasil dikirim', [
                'pengumuman_id' => $pengumuman->Pengumuman_Id,
                'tipe' => $tipe,
                'jumlah_penerima' => count($orangtuaIds),
                'berhasil_dibuat' => $createdCount
            ]);

            return $createdCount;

        } catch (\Exception $e) {
            Log::error('Gagal mengirim notifikasi pengumuman: ' . $e->getMessage(), [
                'pengumuman_id' => $pengumuman->Pengumuman_Id ?? 'unknown',
                'tipe' => $tipe,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return 0;
        }
    }

    public function getKelasSaya()
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        // Cari semua kelas di mana guru mengajar (baik sebagai utama atau pendamping)
        $kelas = Kelas::where('Guru_Utama_Id', $guruId)
                      ->orWhere('Guru_Pendamping_Id', $guruId)
                      ->get();

        if ($kelas->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki kelas'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $kelas
        ]);
    }

    public function getSiswaKelasSaya()
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        // Cari semua kelas di mana guru mengajar
        $kelas = Kelas::where('Guru_Utama_Id', $guruId)
                      ->orWhere('Guru_Pendamping_Id', $guruId)
                      ->get();

        if ($kelas->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki kelas'
            ], 404);
        }

        $kelasIds = $kelas->pluck('Kelas_Id')->toArray();

        $siswa = Siswa::whereIn('Kelas_Id', $kelasIds)
            ->orderBy('Nama')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $siswa
        ]);
    }

    public function index(Request $request)
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $kelasGuru = Kelas::where('Guru_Utama_Id', $guruId)
                        ->orWhere('Guru_Pendamping_Id', $guruId)
                        ->first();

        if (!$kelasGuru) {
            $query = Pengumuman::where('Guru_Id', $guruId);
        } else {
            $kelasId = $kelasGuru->Kelas_Id;
            
            $query = Pengumuman::where(function($q) use ($guruId, $kelasId) {
                $q->where('Guru_Id', $guruId)
                ->orWhere(function($q2) use ($kelasId) {
                    $q2->where('Tipe', 'perkelas')
                        ->where('Kelas_Id', $kelasId);
                })
                ->orWhere('Tipe', 'umum');
            });
        }

        $pengumuman = $query->with(['guru', 'kelas', 'siswa'])
            ->orderBy('Tanggal', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $pengumuman
        ]);
    }

    public function store(Request $request)
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        // Cari semua kelas di mana guru mengajar
        $kelasGuruList = Kelas::where('Guru_Utama_Id', $guruId)
                             ->orWhere('Guru_Pendamping_Id', $guruId)
                             ->get();
        
        $validator = Validator::make($request->all(), [
            'Judul' => 'required|string|max:255',
            'Isi' => 'required|string',
            'Tipe' => ['required', Rule::in(['umum', 'perkelas', 'personal'])],
            'Tanggal' => 'required|date'
        ], [
            'Tipe.in' => 'Tipe harus berupa: umum, perkelas, atau personal',
        ]);

        if ($request->Tipe === 'perkelas') {
            if ($kelasGuruList->isEmpty()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Anda tidak memiliki kelas untuk membuat pengumuman perkelas'
                ], 422);
            }
            
            $validator->addRules([
                'Kelas_Id' => [
                    'required',
                    'exists:kelas,Kelas_Id',
                    function ($attribute, $value, $fail) use ($kelasGuruList) {
                        $kelasMilikGuru = $kelasGuruList->contains('Kelas_Id', $value);
                        
                        if (!$kelasMilikGuru) {
                            $fail('Kelas tersebut tidak dimiliki oleh Anda.');
                        }
                    }
                ]
            ]);
            
        } elseif ($request->Tipe === 'personal') {
            if ($kelasGuruList->isEmpty()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Anda tidak memiliki kelas untuk membuat pengumuman personal'
                ], 422);
            }
            
            $validator->addRules([
                'Siswa_Id' => [
                    'required',
                    'exists:siswa,Siswa_Id',
                    function ($attribute, $value, $fail) use ($kelasGuruList) {
                        $siswa = Siswa::find($value);
                        
                        if (!$siswa) {
                            $fail('Siswa tidak ditemukan.');
                            return;
                        }
                        
                        // Cek apakah siswa berada di salah satu kelas yang diajar guru
                        $siswaDiKelasGuru = $kelasGuruList->contains('Kelas_Id', $siswa->Kelas_Id);
                        
                        if (!$siswaDiKelasGuru) {
                            $fail('Siswa tersebut tidak berada di kelas Anda.');
                        }
                    }
                ]
            ]);
        }

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = [
            'Guru_Id' => $guruId,
            'Judul' => $request->Judul,
            'Isi' => $request->Isi,
            'Tipe' => strtolower($request->Tipe),
            'Tanggal' => $request->Tanggal
        ];

        if ($request->Tipe === 'perkelas') {
            $data['Kelas_Id'] = $request->Kelas_Id;
            $data['Siswa_Id'] = null;
        } 
        elseif ($request->Tipe === 'personal') {
            $data['Siswa_Id'] = $request->Siswa_Id;
            $siswa = Siswa::find($request->Siswa_Id);
            $data['Kelas_Id'] = $siswa->Kelas_Id;
        } 
        else { 
            $data['Kelas_Id'] = null;
            $data['Siswa_Id'] = null;
        }

        DB::beginTransaction();
        
        try {
            $pengumuman = Pengumuman::create($data);
            
            $pengumuman->load(['guru', 'kelas', 'siswa']);
            
            $jumlahPenerima = $this->sendPengumumanNotification($pengumuman, $request->Tipe);
            
            DB::commit();
            
            return response()->json([
                'success' => true,
                'message' => 'Pengumuman berhasil dibuat' . 
                           ($jumlahPenerima > 0 ? ' dan notifikasi dikirim ke ' . $jumlahPenerima . ' orangtua' : ''),
                'data' => $pengumuman
            ], 201);
            
        } catch (\Exception $e) {
            DB::rollBack();
            
            Log::error('Gagal membuat pengumuman: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat pengumuman: ' . $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request, $id)
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $pengumuman = Pengumuman::where('Pengumuman_Id', $id)
            ->where('Guru_Id', $guruId)
            ->first();

        if (!$pengumuman) {
            return response()->json([
                'success' => false,
                'message' => 'Pengumuman tidak ditemukan'
            ], 404);
        }

        // Cari semua kelas di mana guru mengajar
        $kelasGuruList = Kelas::where('Guru_Utama_Id', $guruId)
                             ->orWhere('Guru_Pendamping_Id', $guruId)
                             ->get();

        $validator = Validator::make($request->all(), [
            'Judul' => 'required|string|max:255',
            'Isi' => 'required|string',
            'Tipe' => ['required', Rule::in(['umum', 'perkelas', 'personal'])],
            'Tanggal' => 'required|date'
        ]);

        if ($request->Tipe === 'perkelas') {
            if ($kelasGuruList->isEmpty()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Anda tidak memiliki kelas untuk mengupdate pengumuman perkelas'
                ], 422);
            }
            
            $validator->addRules([
                'Kelas_Id' => [
                    'required',
                    'exists:kelas,Kelas_Id',
                    function ($attribute, $value, $fail) use ($kelasGuruList) {
                        $kelasMilikGuru = $kelasGuruList->contains('Kelas_Id', $value);
                        
                        if (!$kelasMilikGuru) {
                            $fail('Kelas tersebut tidak dimiliki oleh Anda.');
                        }
                    }
                ]
            ]);
            
        } elseif ($request->Tipe === 'personal') {
            if ($kelasGuruList->isEmpty()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Anda tidak memiliki kelas untuk mengupdate pengumuman personal'
                ], 422);
            }
            
            $validator->addRules([
                'Siswa_Id' => [
                    'required',
                    'exists:siswa,Siswa_Id',
                    function ($attribute, $value, $fail) use ($kelasGuruList) {
                        $siswa = Siswa::find($value);
                        
                        if (!$siswa) {
                            $fail('Siswa tidak ditemukan.');
                            return;
                        }
                        
                        // Cek apakah siswa berada di salah satu kelas yang diajar guru
                        $siswaDiKelasGuru = $kelasGuruList->contains('Kelas_Id', $siswa->Kelas_Id);
                        
                        if (!$siswaDiKelasGuru) {
                            $fail('Siswa tersebut tidak berada di kelas Anda.');
                        }
                    }
                ]
            ]);
        }

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $updateData = [
            'Judul' => $request->Judul,
            'Isi' => $request->Isi,
            'Tipe' => strtolower($request->Tipe),
            'Tanggal' => $request->Tanggal
        ];

        if ($request->Tipe === 'perkelas') {
            $updateData['Kelas_Id'] = $request->Kelas_Id;
            $updateData['Siswa_Id'] = null;
        } 
        elseif ($request->Tipe === 'personal') {
            $updateData['Siswa_Id'] = $request->Siswa_Id;
            $siswa = Siswa::find($request->Siswa_Id);
            $updateData['Kelas_Id'] = $siswa->Kelas_Id;
        } 
        else { 
            $updateData['Kelas_Id'] = null;
            $updateData['Siswa_Id'] = null;
        }

        DB::beginTransaction();
        
        try {
            $pengumuman->update($updateData);
            
            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Pengumuman berhasil diupdate',
                'data' => $pengumuman->load(['guru', 'kelas', 'siswa'])
            ]);
            
        } catch (\Exception $e) {
            DB::rollBack();
            
            Log::error('Gagal update pengumuman: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Gagal update pengumuman: ' . $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $pengumuman = Pengumuman::where('Pengumuman_Id', $id)
            ->where('Guru_Id', $guruId)
            ->first();

        if (!$pengumuman) {
            return response()->json([
                'success' => false,
                'message' => 'Pengumuman tidak ditemukan'
            ], 404);
        }

        DB::beginTransaction();
        
        try {
            Notifikasi::where('Pengumuman_Id', $id)->delete();
            
            $pengumuman->delete();
            
            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Pengumuman berhasil dihapus beserta notifikasinya'
            ]);
            
        } catch (\Exception $e) {
            DB::rollBack();
            
            Log::error('Gagal hapus pengumuman: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus pengumuman: ' . $e->getMessage()
            ], 500);
        }
    }

    public function getDropdownData()
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        Log::info('Getting dropdown data for guru_id: ' . $guruId);
        
        // Cari semua kelas di mana guru mengajar
        $kelasGuru = Kelas::where('Guru_Utama_Id', $guruId)
                         ->orWhere('Guru_Pendamping_Id', $guruId)
                         ->get();
        
        Log::info('Found ' . $kelasGuru->count() . ' classes for this guru');
        
        $kelasData = [];
        $siswaData = [];
        
        if ($kelasGuru->isNotEmpty()) {
            $kelasData = $kelasGuru->map(function($kelas) use ($guruId) {
                return [
                    'Kelas_Id' => $kelas->Kelas_Id,
                    'Nama_Kelas' => $kelas->Nama_Kelas,
                    'peran' => $kelas->Guru_Utama_Id == $guruId ? 'Guru Utama' : 'Guru Pendamping'
                ];
            });
            
            $kelasIds = $kelasGuru->pluck('Kelas_Id')->toArray();
            
            $siswaData = Siswa::whereIn('Kelas_Id', $kelasIds)
                ->with('kelas')
                ->orderBy('Nama')
                ->get()
                ->map(function($siswa) {
                    return [
                        'Siswa_Id' => $siswa->Siswa_Id,
                        'Nama' => $siswa->Nama,
                        'Kelas_Nama' => $siswa->kelas ? $siswa->kelas->Nama_Kelas : '-'
                    ];
                });
                
            Log::info('Found ' . $siswaData->count() . ' students in these classes');
        }

        return response()->json([
            'success' => true,
            'data' => [
                'kelas' => $kelasData,
                'siswa' => $siswaData
            ]
        ]);
    }
}