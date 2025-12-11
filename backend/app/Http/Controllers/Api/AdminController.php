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
    // FUNGSI ORANG TUA
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

    // FUNGSI GURU 
    public function createGuru(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'NIK' => 'required|string|unique:gurus,NIK|max:20',
            'Nama' => 'required|string|max:255',
            'Email' => 'required|email|unique:gurus,Email',
            'Kelas_Id' => 'nullable|exists:kelas,Kelas_Id'
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
        $guru = Guru::create([
            'NIK' => $request->NIK,
            'Nama' => $request->Nama,
            'Email' => $request->Email,
            'Kata_Sandi' => bcrypt($plainPassword),
        ]);

        // Update kelas jika ada Kelas_Id
        if ($request->has('Kelas_Id') && $request->Kelas_Id) {
            Kelas::where('Kelas_Id', $request->Kelas_Id)
                 ->update(['Guru_Id' => $guru->Guru_Id]);
        }

        // Kirim password ke email
        Mail::to($request->Email)
            ->send(new GuruPasswordMail($request->Nama, $request->Email, $plainPassword));

        // Return ke frontend (admin)
        return response()->json([
            'success' => true,
            'message' => 'Akun guru berhasil dibuat & password telah dikirim ke email',
            'data' => [
                'guru' => $guru,
                'password_generated' => $plainPassword
            ]
        ]);
    }

    public function getAllGuru()
    {
        try {
            // Ambil semua guru
            $gurus = Guru::select('Guru_Id', 'NIK', 'Nama', 'Email', 'created_at', 'updated_at')
                        ->get();

            // Ambil data kelas untuk mapping
            $kelasData = Kelas::select('Kelas_Id', 'Nama_Kelas', 'Guru_Id')
                            ->whereNotNull('Guru_Id')
                            ->get()
                            ->keyBy('Guru_Id');

            // Format data
            $data = $gurus->map(function($guru) use ($kelasData) {
                $kelas = $kelasData->get($guru->Guru_Id);
                
                return [
                    'Guru_Id' => $guru->Guru_Id,
                    'NIK' => $guru->NIK,
                    'Nama' => $guru->Nama,
                    'Email' => $guru->Email,
                    'Kelas' => $kelas ? $kelas->Nama_Kelas : null,
                    'Kelas_Id' => $kelas ? $kelas->Kelas_Id : null,
                    'created_at' => $guru->created_at,
                    'updated_at' => $guru->updated_at
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $data
            ]);
            
        } catch (\Exception $e) {
            \Log::error('Error in getAllGuru: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan pada server'
            ], 500);
        }
    }

    public function getGuruDetail($id)
    {
        try {
            $guru = Guru::select('Guru_Id', 'NIK', 'Nama', 'Email', 'created_at', 'updated_at')
                       ->find($id);

            if (!$guru) {
                return response()->json([
                    'success' => false,
                    'message' => 'Guru tidak ditemukan'
                ], 404);
            }

            // Cek apakah guru punya kelas
            $kelas = Kelas::select('Kelas_Id', 'Nama_Kelas')
                         ->where('Guru_Id', $id)
                         ->first();

            return response()->json([
                'success' => true,
                'data' => [
                    'Guru_Id' => $guru->Guru_Id,
                    'NIK' => $guru->NIK,
                    'Nama' => $guru->Nama,
                    'Email' => $guru->Email,
                    'Kelas' => $kelas ? $kelas->Nama_Kelas : null,
                    'Kelas_Id' => $kelas ? $kelas->Kelas_Id : null,
                    'created_at' => $guru->created_at,
                    'updated_at' => $guru->updated_at
                ]
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    public function updateGuru(Request $request, $id)
    {
        $guru = Guru::find($id);

        if (!$guru) {
            return response()->json([
                'success' => false,
                'message' => 'Guru tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'Nama' => 'required|string|max:255',
            'Email' => 'required|email|unique:gurus,Email,' . $id . ',Guru_Id',
            'Kelas_Id' => 'nullable|exists:kelas,Kelas_Id'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()
            ], 422);
        }

        // Update data guru
        $guru->update([
            'Nama' => $request->Nama,
            'Email' => $request->Email,
        ]);

        // Update kelas jika ada Kelas_Id
        if ($request->has('Kelas_Id')) {
            // Hapus relasi kelas lama
            Kelas::where('Guru_Id', $id)->update(['Guru_Id' => null]);
            
            // Update kelas baru (jika bukan kosong)
            if ($request->Kelas_Id) {
                Kelas::where('Kelas_Id', $request->Kelas_Id)->update(['Guru_Id' => $id]);
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Data guru berhasil diperbarui',
            'data' => $guru
        ]);
    }

    public function deleteGuru($id)
    {
        $guru = Guru::find($id);

        if (!$guru) {
            return response()->json([
                'success' => false,
                'message' => 'Guru tidak ditemukan'
            ], 404);
        }

        // Cek apakah guru memiliki kelas
        $kelas = Kelas::where('Guru_Id', $id)->first();
        if ($kelas) {
            return response()->json([
                'success' => false,
                'message' => 'Guru masih memiliki kelas. Harap ubah wali kelas terlebih dahulu.'
            ], 400);
        }

        // Hapus guru
        $guru->delete();

        return response()->json([
            'success' => true,
            'message' => 'Data guru berhasil dihapus'
        ]);
    }

    public function getKelasListForGuru()
    {
        try {
            $kelas = Kelas::select('Kelas_Id', 'Nama_Kelas', 'Guru_Id')
                        ->with(['guru' => function($query) {
                            $query->select('Guru_Id', 'Nama');
                        }])
                        ->get();

            return response()->json([
                'success' => true,
                'data' => $kelas
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    // FUNGSI PROFIL & STATISTIK
    public function getProfile(Request $request)
    {
        $admin = $request->user();
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
    }
}