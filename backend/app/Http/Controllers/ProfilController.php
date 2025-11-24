<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\OrangTua;
use App\Models\Anak;
use Illuminate\Support\Facades\Validator;

class ProfilController extends Controller
{
public function getProfil()
{
    try {
        $orangTua = OrangTua::first(); 
        
        if (!$orangTua) {
            return response()->json(['error' => 'Data orang tua tidak ditemukan'], 404);
        }

        $anak = Anak::where('OrangTua_Id', $orangTua->OrangTua_Id)->first();

        return response()->json([
            "Nama" => $orangTua->Nama,
            "No_Telepon" => $orangTua->No_Telepon,
            "Email" => $orangTua->Email,
            "Alamat" => $orangTua->Alamat,
            "nama_anak" => $anak ? $anak->nama : '-',
            "ekskul" => $anak ? $anak->ekskul : '-',
            "tgl_lahir" => $anak ? $anak->tgl_lahir : '-',
            "jenis_kelamin" => $anak ? $anak->jenis_kelamin : '-',
            "agama" => $anak ? $anak->agama : '-',
            "alamat_anak" => $anak ? $anak->alamat : '-',
        ]);

    } catch (\Exception $e) {
        return response()->json(['error' => 'Server error: ' . $e->getMessage()], 500);
    }
}

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
            'Nama'        => $request->Nama,
            'No_Telepon'  => $request->No_Telepon,
            'Email'       => $request->Email,
            'Alamat'      => $request->Alamat,
        ]);

        return response()->json([
            'message' => 'Profil Orang Tua berhasil diperbarui',
            'data' => $orangTua
        ], 200);

    } catch (\Exception $e) {
        return response()->json(['error' => 'Server error: ' . $e->getMessage()], 500);
    }
}

    public function updateAnak(Request $request)
{
    try {
        $orangTua = OrangTua::first();
        
        if (!$orangTua) {
            return response()->json(['error' => 'Profil orang tua tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'nama_anak' => 'required|string',
            'ekskul' => 'nullable|string',
            'tgl_lahir' => 'nullable|date',
            'jenis_kelamin' => 'nullable|string|in:Laki-laki,Perempuan',
            'agama' => 'nullable|string|in:Islam,Kristen,Katolik,Hindu,Buddha',
            'alamat_anak' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Cari atau buat data anak
        $anak = Anak::where('OrangTua_Id', $orangTua->OrangTua_Id)->first();
        
        if (!$anak) {
            $anak = Anak::create([
                'OrangTua_Id' => $orangTua->OrangTua_Id,
                'nama' => $request->nama_anak,
                'ekskul' => $request->ekskul,
                'tgl_lahir' => $request->tgl_lahir,
                'jenis_kelamin' => $request->jenis_kelamin,
                'agama' => $request->agama,
                'alamat' => $request->alamat_anak,
            ]);
            $message = 'Data anak berhasil dibuat';
        } else {
            $anak->update([
                'nama' => $request->nama_anak,
                'ekskul' => $request->ekskul,
                'tgl_lahir' => $request->tgl_lahir,
                'jenis_kelamin' => $request->jenis_kelamin,
                'agama' => $request->agama,
                'alamat' => $request->alamat_anak,
            ]);
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