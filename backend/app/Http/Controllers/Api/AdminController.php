<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\OrangTua;
use App\Models\Admin;
use App\Models\Siswa;
use App\Models\Guru;
use App\Models\Kelas;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\DB;
use App\Mail\OrangTuaPasswordMail;
use App\Mail\GuruPasswordMail;

class AdminController extends Controller
{
    //  FUNGSI ORANG TUA
    public function createOrangTua(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Nama' => 'required|string|max:255',
            'Email' => 'required|email|unique:orang_tuas,Email',
            'No_Telepon' => 'required',
            'Alamat' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()
            ], 422);
        }

        // Generate password berdasarkan nama + angka
        $namaBersih = preg_replace('/[^a-zA-Z]/', '', $request->Nama);
        $namaSingkat = strtolower(substr($namaBersih, 0, 4));
        $angka = rand(1000, 9999);
        $plainPassword = $namaSingkat . $angka;

        // Simpan ke DB (hash)
        $orangTua = OrangTua::create([
            'Nama' => $request->Nama,
            'Email' => $request->Email,
            'Kata_Sandi' => bcrypt($plainPassword),
            'No_Telepon' => $request->No_Telepon,
            'Alamat' => $request->Alamat,
        ]);

        // Kirim password ke email
        Mail::to($request->Email)
            ->send(new OrangTuaPasswordMail($request->Nama, $request->Email, $plainPassword));

        // Return ke frontend (admin)
        return response()->json([
            'success' => true,
            'message' => 'Akun orang tua berhasil dibuat & password telah dikirim ke email',
            'data' => [
                'orangtua' => $orangTua
            ]
        ]);
    }

    public function getAllOrangTua()
    {
        $ortu = OrangTua::with(['siswa.kelas'])->get();

        return response()->json([
            'success' => true,
            'data' => $ortu->map(function ($o) {
                return [
                    'OrangTua_Id' => $o->OrangTua_Id,
                    'Nama' => $o->Nama,
                    'Email' => $o->Email,
                    'No_Telepon' => $o->No_Telepon,
                    'Alamat' => $o->Alamat,
                    'Anak' => $o->siswa->Nama ?? '-',
                    'Kelas' => $o->siswa->kelas->Nama_Kelas ?? '-',
                ];
            })
        ]);
    }

    public function getOrangTuaDetail($id)
    {
        $ortu = OrangTua::with(['siswa.kelas'])->find($id);

        if (!$ortu) {
            return response()->json([
                'success' => false,
                'message' => 'Orang tua tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'OrangTua_Id' => $ortu->OrangTua_Id,
                'Nama' => $ortu->Nama,
                'Email' => $ortu->Email,
                'No_Telepon' => $ortu->No_Telepon,
                'Alamat' => $ortu->Alamat,
                'Anak' => $ortu->siswa->Nama ?? '-',
                'Kelas' => $ortu->siswa->kelas->Nama_Kelas ?? '-',
            ]
        ]);
    }

    public function updateOrangTua(Request $request, $id)
    {
        $ortu = OrangTua::find($id);

        if (!$ortu) {
            return response()->json([
                'success' => false,
                'message' => 'Orang tua tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'Nama' => 'required|string|max:255',
            'Email' => 'required|email|unique:orang_tuas,Email,' . $id . ',OrangTua_Id',
            'No_Telepon' => 'required',
            'Alamat' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()
            ], 422);
        }

        $ortu->update([
            'Nama' => $request->Nama,
            'Email' => $request->Email,
            'No_Telepon' => $request->No_Telepon,
            'Alamat' => $request->Alamat,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Data orang tua berhasil diperbarui',
            'data' => $ortu
        ]);
    }

    public function deleteOrangTua($id)
    {
        $ortu = OrangTua::find($id);

        if (!$ortu) {
            return response()->json([
                'success' => false,
                'message' => 'Orang tua tidak ditemukan'
            ], 404);
        }

        // Jika punya anak, tidak boleh langsung hapus
        if ($ortu->siswa()->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Orang tua masih memiliki data anak. Hapus / ubah data anak terlebih dahulu.'
            ], 400);
        }

        $ortu->delete();

        return response()->json([
            'success' => true,
            'message' => 'Data orang tua berhasil dihapus'
        ]);
    }

    //  DATA GURU 
    public function createGuru(Request $request)
    {
        \Log::info('Create Guru Request: ', $request->all());
        
        $validator = Validator::make($request->all(), [
            'NIK' => 'required|string|unique:gurus,NIK|max:20',
            'Nama' => 'required|string|max:255',
            'Email' => 'required|email|unique:gurus,Email',
        ]);

        if ($validator->fails()) {
            \Log::error('Validation failed: ', $validator->errors()->toArray());
            return response()->json([
                'success' => false,
                'message' => $validator->errors()
            ], 422);
        }

        // Generate password otomatis
        $namaBersih = preg_replace('/[^a-zA-Z]/', '', $request->Nama);
        $namaSingkat = strtolower(substr($namaBersih, 0, 4));
        $angka = rand(1000, 9999);
        $plainPassword = $namaSingkat . $angka;

        \Log::info('Generated password for ' . $request->Nama . ': ' . $plainPassword);

        // Simpan guru ke database
        try {
            $guru = Guru::create([
                'NIK' => $request->NIK,
                'Nama' => $request->Nama,
                'Email' => $request->Email,
                'Kata_Sandi' => bcrypt($plainPassword),
            ]);

            \Log::info('Guru created successfully: ID ' . $guru->Guru_Id);
        } catch (\Exception $e) {
            \Log::error('Error saving guru: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan data guru: ' . $e->getMessage()
            ], 500);
        }

        try {
            Mail::to($request->Email)
                ->send(new GuruPasswordMail($request->Nama, $request->Email, $plainPassword));
            \Log::info('Email sent to: ' . $request->Email);
        } catch (\Exception $e) {
            \Log::error('Error sending email: ' . $e->getMessage());
        }

        return response()->json([
            'success' => true,
            'message' => 'Akun guru berhasil dibuat. Password telah dikirim ke email.',
            'data' => [
                'Guru_Id' => $guru->Guru_Id,
                'NIK' => $guru->NIK,
                'Nama' => $guru->Nama,
                'Email' => $guru->Email,
                'created_at' => $guru->created_at
            ]
        ]);
    }

    public function getAllGuru()
    {
        \Log::info('=== GET ALL GURU STARTED ===');
        
        try {
            $totalGuru = Guru::count();
            \Log::info('Total guru in database: ' . $totalGuru);
            
            // Ambil semua guru dengan informasi kelas
            $gurus = Guru::select('Guru_Id', 'NIK', 'Nama', 'Email', 'created_at', 'updated_at')
                        ->orderBy('Nama', 'asc')
                        ->get();
            
            \Log::info('Found ' . $gurus->count() . ' gurus');
            
            // Format data guru dengan informasi kelas
            $formattedGurus = $gurus->map(function($guru) {
                // Dapatkan informasi kelas dari model Guru
                $infoKelas = $guru->getInfoKelas();
                
                return [
                    'Guru_Id' => $guru->Guru_Id,
                    'NIK' => $guru->NIK,
                    'Nama' => $guru->Nama,
                    'Email' => $guru->Email,
                    'kelas_nama' => $infoKelas['kelas_nama'],
                    'kelas_id' => $infoKelas['kelas_id'],
                    'peran' => $infoKelas['peran'],
                    'status' => $infoKelas['status'],
                    'created_at' => $guru->created_at->format('Y-m-d H:i:s'),
                    'updated_at' => $guru->updated_at->format('Y-m-d H:i:s')
                ];
            });

            \Log::info('=== GET ALL GURU COMPLETED ===');
            
            return response()->json([
                'success' => true,
                'message' => 'Data guru berhasil diambil',
                'count' => $formattedGurus->count(),
                'data' => $formattedGurus
            ]);
            
        } catch (\Exception $e) {
            \Log::error('Error in getAllGuru: ' . $e->getMessage());
            \Log::error('Stack trace: ' . $e->getTraceAsString());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan pada server: ' . $e->getMessage()
            ], 500);
        }
    }

    public function getGuruDetail($id)
    {
        \Log::info('Get Guru Detail for ID: ' . $id);
        
        try {
            $guru = Guru::select('Guru_Id', 'NIK', 'Nama', 'Email', 'created_at', 'updated_at')
                       ->find($id);

            if (!$guru) {
                \Log::warning('Guru not found: ID ' . $id);
                return response()->json([
                    'success' => false,
                    'message' => 'Guru tidak ditemukan'
                ], 404);
            }

            \Log::info('Found guru: ' . $guru->Nama);
            
            // Dapatkan informasi kelas dari model Guru
            $infoKelas = $guru->getInfoKelas();
            
            return response()->json([
                'success' => true,
                'data' => [
                    'Guru_Id' => $guru->Guru_Id,
                    'NIK' => $guru->NIK,
                    'Nama' => $guru->Nama,
                    'Email' => $guru->Email,
                    'kelas_nama' => $infoKelas['kelas_nama'],
                    'kelas_id' => $infoKelas['kelas_id'],
                    'peran' => $infoKelas['peran'],
                    'status' => $infoKelas['status'],
                    'created_at' => $guru->created_at->format('Y-m-d H:i:s'),
                    'updated_at' => $guru->updated_at->format('Y-m-d H:i:s')
                ]
            ]);
            
        } catch (\Exception $e) {
            \Log::error('Error in getGuruDetail: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    public function updateGuru(Request $request, $id)
    {
        \Log::info('Update Guru Request for ID ' . $id . ': ', $request->all());
        
        $guru = Guru::find($id);

        if (!$guru) {
            \Log::warning('Guru not found for update: ID ' . $id);
            return response()->json([
                'success' => false,
                'message' => 'Guru tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'Nama' => 'required|string|max:255',
            'Email' => 'required|email|unique:gurus,Email,' . $id . ',Guru_Id',
        ]);

        if ($validator->fails()) {
            \Log::error('Validation failed: ', $validator->errors()->toArray());
            return response()->json([
                'success' => false,
                'message' => $validator->errors()
            ], 422);
        }

        try {
            $guru->update([
                'Nama' => $request->Nama,
                'Email' => $request->Email,
            ]);
            
            \Log::info('Guru updated successfully: ID ' . $id);

            return response()->json([
                'success' => true,
                'message' => 'Data guru berhasil diperbarui',
                'data' => $guru
            ]);
        } catch (\Exception $e) {
            \Log::error('Error updating guru: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui data: ' . $e->getMessage()
            ], 500);
        }
    }

    //  DELETE GURU
    public function deleteGuru($id)
    {
        \Log::info('Delete Guru Request for ID: ' . $id);
        
        $guru = Guru::find($id);

        if (!$guru) {
            \Log::warning('Guru not found for delete: ID ' . $id);
            return response()->json([
                'success' => false,
                'message' => 'Guru tidak ditemukan'
            ], 404);
        }

        // Cek apakah guru sedang ditugaskan di kelas (sebagai guru utama atau pendamping)
        $isAssigned = Kelas::where('Guru_Utama_Id', $id)
                          ->orWhere('Guru_Pendamping_Id', $id)
                          ->exists();
        
        if ($isAssigned) {
            \Log::warning('Cannot delete guru: Guru is assigned to a class');
            return response()->json([
                'success' => false,
                'message' => 'Guru tidak dapat dihapus karena sedang ditugaskan di kelas. Hapus/ubah penugasan kelas terlebih dahulu.'
            ], 400);
        }

        try {
            $guruData = [
                'id' => $guru->Guru_Id,
                'nama' => $guru->Nama,
                'email' => $guru->Email
            ];
            
            $guru->delete();
            
            \Log::info('Guru deleted: ', $guruData);

            return response()->json([
                'success' => true,
                'message' => 'Data guru berhasil dihapus'
            ]);
        } catch (\Exception $e) {
            \Log::error('Error deleting guru: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus data: ' . $e->getMessage()
            ], 500);
        }
    }

    public function getKelasListForGuru()
    {
        try {
            if (!\Schema::hasTable('kelas')) {
                return response()->json([
                    'success' => true,
                    'message' => 'Tabel kelas tidak tersedia',
                    'data' => []
                ]);
            }
            
            $kelas = Kelas::select('Kelas_Id', 'Nama_Kelas')
                        ->orderBy('Nama_Kelas', 'asc')
                        ->get()
                        ->map(function($kelas) {
                            return [
                                'Kelas_Id' => $kelas->Kelas_Id,
                                'Nama_Kelas' => $kelas->Nama_Kelas,
                                'note' => 'Penugasan guru diatur di halaman Data Kelas'
                            ];
                        });

            return response()->json([
                'success' => true,
                'data' => $kelas
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => true,
                'message' => 'Info kelas tidak tersedia',
                'data' => []
            ]);
        }
    }

    // FUNGSI UNTUK MENDAPATKAN KELAS BERDASARKAN GURU
    public function getGuruKelas($guruId)
    {
        \Log::info('Get Kelas for Guru ID: ' . $guruId);
        
        try {
            $guru = Guru::find($guruId);
            
            if (!$guru) {
                return response()->json([
                    'success' => false,
                    'message' => 'Guru tidak ditemukan'
                ], 404);
            }
            
            // Cari kelas di mana guru mengajar (baik sebagai utama atau pendamping)
            $kelas = Kelas::where('Guru_Utama_Id', $guruId)
                        ->orWhere('Guru_Pendamping_Id', $guruId)
                        ->get();
            
            $formattedKelas = $kelas->map(function($k) use ($guruId) {
                return [
                    'Kelas_Id' => $k->Kelas_Id,
                    'Nama_Kelas' => $k->Nama_Kelas,
                    'Tahun_Ajar' => $k->Tahun_Ajar,
                    'Peran' => $k->Guru_Utama_Id == $guruId ? 'Guru Utama' : 'Guru Pendamping',
                    'Jumlah_Siswa' => $k->siswa->count() ?? 0
                ];
            });
            
            return response()->json([
                'success' => true,
                'message' => 'Data kelas guru berhasil diambil',
                'count' => $formattedKelas->count(),
                'data' => $formattedKelas
            ]);
            
        } catch (\Exception $e) {
            \Log::error('Error in getGuruKelas: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    // FUNGSI UNTUK MENUGASKAN GURU KE KELAS
    public function assignGuruToKelas(Request $request)
    {
        \Log::info('Assign Guru to Kelas Request: ', $request->all());
        
        $validator = Validator::make($request->all(), [
            'guru_id' => 'required|exists:gurus,Guru_Id',
            'kelas_id' => 'required|exists:kelas,Kelas_Id',
            'peran' => 'required|in:utama,pendamping'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()
            ], 422);
        }

        try {
            $kelas = Kelas::find($request->kelas_id);
            
            // Cek apakah guru sudah ditugaskan di kelas lain
            $alreadyAssigned = Kelas::where('Guru_Utama_Id', $request->guru_id)
                                  ->orWhere('Guru_Pendamping_Id', $request->guru_id)
                                  ->exists();
            
            if ($alreadyAssigned) {
                return response()->json([
                    'success' => false,
                    'message' => 'Guru sudah ditugaskan di kelas lain'
                ], 400);
            }
            
            // Update kelas berdasarkan peran
            if ($request->peran == 'utama') {
                $kelas->Guru_Utama_Id = $request->guru_id;
            } else {
                $kelas->Guru_Pendamping_Id = $request->guru_id;
            }
            
            $kelas->save();
            
            \Log::info('Guru assigned to kelas successfully');
            
            return response()->json([
                'success' => true,
                'message' => 'Guru berhasil ditugaskan ke kelas',
                'data' => $kelas
            ]);
            
        } catch (\Exception $e) {
            \Log::error('Error assigning guru to kelas: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal menugaskan guru: ' . $e->getMessage()
            ], 500);
        }
    }

    //  FUNGSI MENGHAPUS GURU DARI KELAS
    public function removeGuruFromKelas(Request $request)
    {
        \Log::info('Remove Guru from Kelas Request: ', $request->all());
        
        $validator = Validator::make($request->all(), [
            'guru_id' => 'required|exists:gurus,Guru_Id',
            'kelas_id' => 'required|exists:kelas,Kelas_Id',
            'peran' => 'required|in:utama,pendamping'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()
            ], 422);
        }

        try {
            $kelas = Kelas::find($request->kelas_id);
            
            if (!$kelas) {
                return response()->json([
                    'success' => false,
                    'message' => 'Kelas tidak ditemukan'
                ], 404);
            }
            
            // Cek apakah guru benar-benar ditugaskan di kelas tersebut dengan peran yang sesuai
            if ($request->peran == 'utama') {
                if ($kelas->Guru_Utama_Id != $request->guru_id) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Guru tidak ditugaskan sebagai guru utama di kelas ini'
                    ], 400);
                }
                $kelas->Guru_Utama_Id = null;
            } else {
                if ($kelas->Guru_Pendamping_Id != $request->guru_id) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Guru tidak ditugaskan sebagai guru pendamping di kelas ini'
                    ], 400);
                }
                $kelas->Guru_Pendamping_Id = null;
            }
            
            $kelas->save();
            
            \Log::info('Guru removed from kelas successfully');
            
            return response()->json([
                'success' => true,
                'message' => 'Guru berhasil dihapus dari penugasan kelas',
                'data' => [
                    'kelas_id' => $kelas->Kelas_Id,
                    'nama_kelas' => $kelas->Nama_Kelas,
                    'guru_id' => $request->guru_id,
                    'peran' => $request->peran
                ]
            ]);
            
        } catch (\Exception $e) {
            \Log::error('Error removing guru from kelas: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus guru dari kelas: ' . $e->getMessage()
            ], 500);
        }
    }
    
    public function getGuruKelasOverview()
    {
        try {
            // Ambil semua guru yang sudah ditugaskan
            $gurusWithKelas = Guru::whereHas('kelasUtama')
                            ->orWhereHas('kelasPendamping')
                            ->with(['kelasUtama', 'kelasPendamping'])
                            ->get()
                            ->map(function($guru) {
                                $infoKelas = $guru->getInfoKelas();
                                
                                return [
                                    'guru_id' => $guru->Guru_Id,
                                    'nama' => $guru->Nama,
                                    'peran' => $infoKelas['peran'] ?? null,
                                    'kelas_nama' => $infoKelas['kelas_nama'] ?? null,
                                    'status' => $infoKelas['status'] ?? 'Belum Bertugas'
                                ];
                            })
                            ->where('kelas_nama', '!=', null)
                            ->values();

            return response()->json([
                'success' => true,
                'message' => 'Data guru yang mengajar berhasil diambil',
                'count' => $gurusWithKelas->count(),
                'data' => $gurusWithKelas
            ]);
            
        } catch (\Exception $e) {
            \Log::error('Error in getGuruKelasOverview: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    // FUNGSI PROFIL & STATISTIK 
    public function getProfile(Request $request)
    {
        $admin = $request->user();
        
        if (!$admin) {
            return response()->json([
                'success' => false,
                'message' => 'Admin tidak ditemukan'
            ], 404);
        }
        
        return response()->json([
            'success' => true,
            'data' => [
                'Admin_Id' => $admin->id,
                'Nama' => $admin->nama,
                'Email' => $admin->email,
                'created_at' => $admin->created_at,
                'updated_at' => $admin->updated_at
            ]
        ]);
    }

    public function getStatistics(Request $request)
    {
        try {
            $totalSiswa = Siswa::count();
            $totalGuru = Guru::count();
            $totalOrangTua = OrangTua::count();
            $totalKelas = Kelas::count();

            return response()->json([
                'success' => true,
                'data' => [
                    'total_siswa' => $totalSiswa,
                    'total_guru' => $totalGuru,
                    'total_orang_tua' => $totalOrangTua,
                    'total_kelas' => $totalKelas,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error getting statistics: ' . $e->getMessage()
            ], 500);
        }
    }

    //  FUNGSI DATA KELAS
    public function getAllKelas()
    {
        $kelas = Kelas::with(['guruUtama', 'guruPendamping', 'siswa'])
        ->orderBy('Nama_Kelas', 'asc')
        ->get();
        
        return response()->json([
            'success' => true,
            'data' => $kelas->map(function ($k) {
                return [
                    'Kelas_Id' => $k->Kelas_Id,
                    'Nama_Kelas' => $k->Nama_Kelas,
                    'Tahun_Ajar' => $k->Tahun_Ajar,
                    'Jumlah' => $k->Jumlah,
                    'Guru_Utama' => $k->guruUtama->Nama ?? '-',
                    'Guru_Pendamping' => $k->guruPendamping->Nama ?? '-',
                    'Siswa' => $k->siswa->pluck('Nama'),
                    'Jumlah_Siswa' => $k->siswa->count(),
                ];
           })
       ]);
    }

    // FUNGSI TAMBAH KELAS
    public function createKelas(Request $request)
    {
        $request->validate([
            'Nama_Kelas' => 'required',
            'Tahun_Ajar' => 'required',
            'Guru_Utama_Id' => 'nullable|exists:gurus,Guru_Id',
            'Guru_Pendamping_Id' => 'nullable|exists:gurus,Guru_Id',
        ]);
        $kelas = Kelas::create([
            'Nama_Kelas' => $request->Nama_Kelas,
            'Tahun_Ajar' => $request->Tahun_Ajar,
            'Guru_Utama_Id' => $request->Guru_Utama_Id,
            'Guru_Pendamping_Id' => $request->Guru_Pendamping_Id,
            'Jumlah' => 0,
        ]);
        
        return response()->json([
            'success' => true,
            'message' => 'Kelas berhasil ditambahkan',
            'data' => $kelas
        ]);
    }

    // FUNGSI UPDATE KELAS
    public function updateKelas(Request $request, $id)
    {
        $kelas = Kelas::findOrFail($id);

        $kelas->update($request->only([
            'Nama_Kelas',
            'Tahun_Ajar',
            'Guru_Utama_Id',
            'Guru_Pendamping_Id'
        ]));
        
        return response()->json([
            'success' => true,
            'message' => 'Data kelas berhasil diperbarui'
        ]);
    }

    // FUNGSI HAPUS KELAS
    public function deleteKelas($id)
    {
        $kelas = Kelas::findOrFail($id);
        
        if ($kelas->siswa()->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Kelas masih memiliki siswa'
            ], 400);
        }
        
        $kelas->delete();
        
        return response()->json([
            'success' => true,
            'message' => 'Kelas berhasil dihapus'
        ]);
    }

    // ==================== FUNGSI DATA SISWA ====================
public function getAllSiswa()
{
    try {
        // Ambil semua siswa dengan relasi
        $siswa = Siswa::with(['orangTua', 'kelas', 'ekstrakulikuler'])
            ->orderBy('Nama', 'asc')
            ->get();

        $formattedSiswa = $siswa->map(function ($s) {
            return [
                'Siswa_Id' => $s->Siswa_Id,
                'Nama' => $s->Nama,
                'Jenis_Kelamin' => $s->Jenis_Kelamin,
                'Tanggal_Lahir' => $s->Tanggal_Lahir,
                'Alamat' => $s->Alamat,
                'Agama' => $s->Agama,
                'Ekstrakulikuler_Id' => $s->Ekstrakulikuler_Id,
                'OrangTua_Id' => $s->OrangTua_Id,
                'Kelas_Id' => $s->Kelas_Id,
                'nama_ortu' => $s->orangTua->Nama ?? 'Orang Tua',
                'nama_kelas' => $s->kelas->Nama_Kelas ?? 'Kelas',
                'nama_ekskul' => $s->ekstrakulikuler->nama ?? '',
                'created_at' => $s->created_at,
                'updated_at' => $s->updated_at,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $formattedSiswa
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Error: ' . $e->getMessage()
        ], 500);
    }
}

public function getSiswaDetail($id)
{
    try {
        $siswa = Siswa::with(['orangTua', 'kelas', 'ekstrakulikuler'])->find($id);

        if (!$siswa) {
            return response()->json([
                'success' => false,
                'message' => 'Siswa tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'Siswa_Id' => $siswa->Siswa_Id,
                'Nama' => $siswa->Nama,
                'Jenis_Kelamin' => $siswa->Jenis_Kelamin,
                'Tanggal_Lahir' => $siswa->Tanggal_Lahir,
                'Alamat' => $siswa->Alamat,
                'Agama' => $siswa->Agama,
                'Ekstrakulikuler_Id' => $siswa->Ekstrakulikuler_Id,
                'OrangTua_Id' => $siswa->OrangTua_Id,
                'Kelas_Id' => $siswa->Kelas_Id,
                'nama_ortu' => $siswa->orangTua->Nama ?? 'Orang Tua',
                'nama_kelas' => $siswa->kelas->Nama_Kelas ?? 'Kelas',
                'nama_ekskul' => $siswa->ekstrakulikuler->nama ?? '',
            ]
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Error: ' . $e->getMessage()
        ], 500);
    }
}

public function createSiswa(Request $request)
{
    \Log::info('Create Siswa Request: ', $request->all());

    $validator = Validator::make($request->all(), [
        'Nama' => 'required|string|max:255',
        'Jenis_Kelamin' => 'required|in:L,P',
        'Tanggal_Lahir' => 'required|date_format:Y-m-d',
        'Alamat' => 'required|string',
        'Agama' => 'required|string',
        'OrangTua_Id' => 'required|exists:orang_tuas,OrangTua_Id',
        'Kelas_Id' => 'required|exists:kelas,Kelas_Id',
        'Ekstrakulikuler_Id' => 'nullable|exists:ekstrakulikuler,Ekstrakulikuler_Id',
    ]);

    if ($validator->fails()) {
        return response()->json([
            'success' => false,
            'message' => $validator->errors()
        ], 422);
    }

    try {
        $siswa = Siswa::create([
            'Nama' => $request->Nama,
            'Jenis_Kelamin' => $request->Jenis_Kelamin,
            'Tanggal_Lahir' => $request->Tanggal_Lahir,
            'Alamat' => $request->Alamat,
            'Agama' => $request->Agama,
            'OrangTua_Id' => $request->OrangTua_Id,
            'Kelas_Id' => $request->Kelas_Id,
            'Ekstrakulikuler_Id' => $request->Ekstrakulikuler_Id,
        ]);

        \Log::info('Siswa created: ID ' . $siswa->Siswa_Id);

        return response()->json([
            'success' => true,
            'message' => 'Data siswa berhasil ditambahkan',
            'data' => $siswa
        ]);
    } catch (\Exception $e) {
        \Log::error('Error create siswa: ' . $e->getMessage());
        return response()->json([
            'success' => false,
            'message' => 'Gagal menambahkan data siswa: ' . $e->getMessage()
        ], 500);
    }
}

public function updateSiswa(Request $request, $id)
{
    \Log::info('Update Siswa Request ID ' . $id . ': ', $request->all());

    $siswa = Siswa::find($id);

    if (!$siswa) {
        return response()->json([
            'success' => false,
            'message' => 'Siswa tidak ditemukan'
        ], 404);
    }

    $validator = Validator::make($request->all(), [
        'Nama' => 'required|string|max:255',
        'Jenis_Kelamin' => 'required|in:L,P',
        'Tanggal_Lahir' => 'required|date_format:Y-m-d',
        'Alamat' => 'required|string',
        'Agama' => 'required|string',
        'OrangTua_Id' => 'required|exists:orang_tuas,OrangTua_Id',
        'Kelas_Id' => 'required|exists:kelas,Kelas_Id',
        'Ekstrakulikuler_Id' => 'nullable|exists:ekstrakulikuler,Ekstrakulikuler_Id',
    ]);

    if ($validator->fails()) {
        return response()->json([
            'success' => false,
            'message' => $validator->errors()
        ], 422);
    }

    try {
        $siswa->update([
            'Nama' => $request->Nama,
            'Jenis_Kelamin' => $request->Jenis_Kelamin,
            'Tanggal_Lahir' => $request->Tanggal_Lahir,
            'Alamat' => $request->Alamat,
            'Agama' => $request->Agama,
            'OrangTua_Id' => $request->OrangTua_Id,
            'Kelas_Id' => $request->Kelas_Id,
            'Ekstrakulikuler_Id' => $request->Ekstrakulikuler_Id,
        ]);

        \Log::info('Siswa updated: ID ' . $id);

        return response()->json([
            'success' => true,
            'message' => 'Data siswa berhasil diperbarui',
            'data' => $siswa
        ]);
    } catch (\Exception $e) {
        \Log::error('Error update siswa: ' . $e->getMessage());
        return response()->json([
            'success' => false,
            'message' => 'Gagal memperbarui data siswa: ' . $e->getMessage()
        ], 500);
    }
}

public function deleteSiswa($id)
{
    \Log::info('=== DELETE SISWA REQUEST START ===');
    \Log::info('Siswa ID: ' . $id);

    try {
        DB::beginTransaction();
        $siswa = Siswa::find($id);

        if (!$siswa) {
            \Log::warning('Siswa not found: ID ' . $id);
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Siswa tidak ditemukan'
            ], 404);
        }

        \Log::info('Siswa found: ' . $siswa->Nama);
        
        // Hapus pembayaran jika tabelnya ada
        if (\Schema::hasTable('pembayaran')) {
            $pembayaranCount = $siswa->pembayaran()->count();
            \Log::info('Pembayaran count: ' . $pembayaranCount);
            
            if ($pembayaranCount > 0) {
                $siswa->pembayaran()->delete();
                \Log::info('Deleted pembayaran records');
            }
        }
        
        $siswaData = [
            'id' => $siswa->Siswa_Id,
            'nama' => $siswa->Nama,
        ];
        
        // Hapus siswa
        $siswa->delete();
        
        DB::commit();
        
        \Log::info('=== DELETE SUCCESS ===');
        \Log::info('Siswa berhasil dihapus');
        
        return response()->json([
            'success' => true,
            'message' => 'Data siswa berhasil dihapus',
            'deleted_data' => $siswaData
        ]);
        
    } catch (\Exception $e) {
        DB::rollBack();
        
        \Log::error('=== DELETE ERROR ===');
        \Log::error('Error message: ' . $e->getMessage());
        \Log::error('Stack trace: ' . $e->getTraceAsString());
        
        return response()->json([
            'success' => false,
            'message' => 'Gagal menghapus data siswa: ' . $e->getMessage(),
        ], 500);
    }
}

public function forceDeleteSiswa($id)
{
    \Log::info('=== FORCE DELETE SISWA REQUEST ===');
    \Log::info('Siswa ID: ' . $id);

    try {
        DB::beginTransaction();
        
        $siswa = Siswa::find($id);

        if (!$siswa) {
            return response()->json([
                'success' => false,
                'message' => 'Siswa tidak ditemukan'
            ], 404);
        }

        // Hanya hapus pembayaran jika tabel ada
        if (\Schema::hasTable('pembayaran')) {
            $siswa->pembayaran()->delete();
        }
        
        // TIDAK ADA PERIZINAN
        
        $siswaData = [
            'id' => $siswa->Siswa_Id,
            'nama' => $siswa->Nama,
        ];
        
        $siswa->delete();
        
        DB::commit();
        
        return response()->json([
            'success' => true,
            'message' => 'Data siswa berhasil dihapus',
            'deleted_data' => $siswaData
        ]);
        
    } catch (\Exception $e) {
        DB::rollBack();
        
        return response()->json([
            'success' => false,
            'message' => 'Gagal menghapus: ' . $e->getMessage(),
        ], 500);
    }
}

    // FUNGSI DASHBOARD STATS
    public function dashboardStats()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'total_siswa' => \App\Models\Siswa::count(),
                'total_guru' => \App\Models\Guru::count(),
                'total_orangtua' => \App\Models\OrangTua::count(),
                'total_kelas' => \App\Models\Kelas::count(),
                ]
            ]);
        }
}