<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\OrangTua;
use App\Models\Siswa;
use App\Models\Ekstrakulikuler;
use Illuminate\Support\Facades\Validator;

class ProfilController extends Controller
{
    public function getProfil()
    {
        $orangTua = OrangTua::first();
        if (!$orangTua) {
            return response()->json(['error' => 'Data orang tua tidak ditemukan'], 404);
        }

        // Ambil siswa dan nama ekskul
        $anak = Siswa::with('ekstrakulikuler')
                ->where('OrangTua_Id', $orangTua->OrangTua_Id)
                ->first();

        return response()->json([
            "Nama"        => $orangTua->Nama,
            "No_Telepon"  => $orangTua->No_Telepon,
            "Email"       => $orangTua->Email,
            "Alamat"      => $orangTua->Alamat,

            "nama_anak"      => $anak->Nama ?? null,
            "agama"          => $anak->Agama ?? null,
            "tgl_lahir"      => $anak->Tanggal_Lahir ?? null,
            "jenis_kelamin"  => $anak->Jenis_Kelamin ?? null,
            "alamat_anak"    => $anak->Alamat ?? null,

            // ambil nama ekskul
            "ekskul_id"      => $anak->Ekstrakulikuler_Id ?? null,
            "ekskul_nama"    => $anak->ekstrakulikuler->nama ?? null,
            "ekskul_biaya"   => $anak->ekstrakulikuler->biaya ?? null,

            "kelas"          => $anak->Kelas_Id ?? null,
        ]);
    }


    public function updateOrtu(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Nama'        => 'required|string',
            'No_Telepon'  => 'nullable|string',
            'Email'       => 'nullable|email',
            'Alamat'      => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $orangTua = OrangTua::first();
        if (!$orangTua) {
            return response()->json(['error' => 'Profil orang tua tidak ditemukan'], 404);
        }

        $orangTua->update([
            'Nama'        => $request->Nama,
            'No_Telepon'  => $request->No_Telepon,
            'Email'       => $request->Email,
            'Alamat'      => $request->Alamat,
        ]);

        return response()->json(['message' => 'Profil Orang Tua berhasil diperbarui'], 200);
    }


    public function updateAnak(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nama_anak'     => 'required|string',
            'agama'         => 'nullable|string',
            'tgl_lahir'     => 'nullable|date',
            'jenis_kelamin' => 'nullable|string',
            'alamat_anak'   => 'nullable|string',
            'ekskul_id'     => 'nullable|integer|exists:ekstrakulikuler,Ekstrakulikuler_Id',
            'kelas'         => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $orangTua = OrangTua::first();
        if (!$orangTua) {
            return response()->json(['error' => 'Profil orang tua tidak ditemukan'], 404);
        }

        $anak = Siswa::where('OrangTua_Id', $orangTua->OrangTua_Id)->first();

        if (!$anak) {
            $anak = Siswa::create([
                'OrangTua_Id' => $orangTua->OrangTua_Id
            ]);
        }

        $anak->update([
            'Nama'                 => $request->nama_anak,
            'Agama'                => $request->agama,
            'Tanggal_Lahir'        => $request->tgl_lahir,
            'Jenis_Kelamin'        => $request->jenis_kelamin,
            'Alamat'               => $request->alamat_anak,
            'Ekstrakulikuler_Id'   => $request->ekskul_id,
            'Kelas_Id'             => $request->kelas,
        ]);

        return response()->json(['message' => 'Profil Anak berhasil diperbarui'], 200);
    }
}
