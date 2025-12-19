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
            
            $gurus = Guru::select('Guru_Id', 'NIK', 'Nama', 'Email', 'created_at', 'updated_at')
                        ->orderBy('Nama', 'asc')
                        ->get();
            
            \Log::info('Found ' . $gurus->count() . ' gurus');
            
            foreach ($gurus as $guru) {
                \Log::info('Guru: ID=' . $guru->Guru_Id . ', Nama=' . $guru->Nama . ', NIK=' . $guru->NIK);
            }
            
            $formattedGurus = $gurus->map(function($guru) {
                return [
                    'Guru_Id' => $guru->Guru_Id,
                    'NIK' => $guru->NIK,
                    'Nama' => $guru->Nama,
                    'Email' => $guru->Email,
                    'kelas_nama' => null,
                    'kelas_id' => null,
                    'peran' => null,
                    'status' => 'Data Guru',
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
            
            return response()->json([
                'success' => true,
                'data' => [
                    'Guru_Id' => $guru->Guru_Id,
                    'NIK' => $guru->NIK,
                    'Nama' => $guru->Nama,
                    'Email' => $guru->Email,
                    'kelas_nama' => null,
                    'kelas_id' => null,
                    'peran' => null,
                    'status' => 'Data Guru',
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

    //  DELETE
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
}