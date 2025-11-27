<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\OrangTua;
use App\Models\Siswa;
use Illuminate\Support\Facades\Validator;

class ProfilController extends Controller
{
    // Ambil profil lengkap (orang tua + anak)
    public function getProfil()
    {
        try {
            $orangTua = OrangTua::first(); 
            
            if (!$orangTua) {
                return response()->json(['error' => 'Data orang tua tidak ditemukan'], 404);
            }

            $anak = Siswa::where('OrangTua_Id', $orangTua->OrangTua_Id)->first();

            return response()->json([
                // Data orang tua
                "Nama" => $orangTua->Nama,
                "No_Telepon" => $orangTua->No_Telepon,
                "Email" => $orangTua->Email,
                "Alamat" => $orangTua->Alamat,

                // Data anak (key sesuai Flutter)
                "nama_anak"     => $anak ? $anak->Nama : '-',
                "ekskul"        => $anak ? $anak->Ekstrakulikuler : '-',
                "tgl_lahir"     => $anak ? $anak->Tanggal_Lahir : '-',
                "jenis_kelamin" => $anak ? $anak->Jenis_Kelamin : '-',
                "agama"         => $anak ? $anak->Agama : '-',
                "alamat_anak"   => $anak ? $anak->Alamat : '-',
                "kelas_id"      => $anak ? $anak->Kelas_Id : '-',
            ]);

        } catch (\Exception $e) {
            return response()->json(['error' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // Update data orang tua
    public function updateOrtu(Request $request)
    {
        try {
            $orangTua = OrangTua::first();
            if (!$orangTua) {
                return response()->json(['error' => 'Data orang tua tidak ditemukan'], 404);
            }

            $validator = Validator::make($request->all(), [
                'Nama'        => 'required|string',
                'No_Telepon'  => 'nullable|string',
                'Email'       => 'nullable|email',
                'Alamat'      => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return response()->json(['errors' => $validator->errors()], 422);
            }

            $orangTua->update([
                'Nama'       => $request->Nama,
                'No_Telepon' => $request->No_Telepon,
                'Email'      => $request->Email,
                'Alamat'     => $request->Alamat,
            ]);

            return response()->json([
                'message' => 'Profil Orang Tua berhasil diperbarui',
                'data' => $orangTua
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['error' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // Update data anak (key sesuai Flutter)
    public function updateAnak(Request $request)
    {
        try {
            $orangTua = OrangTua::first();
            if (!$orangTua) {
                return response()->json(['error' => 'Profil orang tua tidak ditemukan'], 404);
            }

            $validator = Validator::make($request->all(), [
                'nama_anak'  => 'required|string',
                'ekskul'     => 'nullable|string',
                'tgl_lahir'  => 'nullable|date',
                'jenis_kelamin' => 'nullable|string|in:L,P',
                'agama'      => 'nullable|string',
                'alamat_anak'=> 'nullable|string',
                'kelas_id'   => 'nullable|integer',
            ]);

            if ($validator->fails()) {
                return response()->json(['errors' => $validator->errors()], 422);
            }

            $anakData = [
                'Nama'           => $request->nama_anak,
                'Ekstrakulikuler'=> $request->ekskul,
                'Tanggal_Lahir'  => $request->tgl_lahir,
                'Jenis_Kelamin'  => $request->jenis_kelamin,
                'Agama'          => $request->agama,
                'Alamat'         => $request->alamat_anak,
                'Kelas_Id'       => $request->kelas_id ?? 1,
                'OrangTua_Id'    => $orangTua->OrangTua_Id,
            ];

            $anak = Siswa::where('OrangTua_Id', $orangTua->OrangTua_Id)->first();

            if (!$anak) {
                $anak = Siswa::create($anakData);
                $message = 'Data anak berhasil dibuat';
            } else {
                $anak->update($anakData);
                $message = 'Data anak berhasil diperbarui';
            }

            return response()->json([
                'message' => $message,
                'data' => $anak
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['error' => 'Server error: ' . $e->getMessage()], 500);
        }
    }
}
