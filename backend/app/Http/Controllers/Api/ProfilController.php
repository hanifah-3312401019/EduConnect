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
    $orangTua = OrangTua::first(); // pastikan ada datanya
    $anak = Anak::where('orang_tua_id', $orangTua->id)->first();

    return response()->json([
            "Nama"        => $orangTua->Nama,
            "No_Telepon"  => $orangTua->No_Telepon,
            "Email"       => $orangTua->Email,
            "Alamat"      => $orangTua->Alamat,
            "nama_anak" => $anak->nama,
            "ekskul" => $anak->ekskul,
            "tgl_lahir" => $anak->tgl_lahir,
            "jenis_kelamin" => $anak->jenis_kelamin,
            "agama" => $anak->agama,
            "alamat_anak" => $anak->alamat,
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
        return response()->json(['error' => 'Profil tidak ditemukan'], 404);
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
        'nama_anak' => 'required|string',
        'ekskul' => 'nullable|string',
        'tgl_lahir' => 'nullable|date',
        'jenis_kelamin' => 'nullable|string',
        'agama' => 'nullable|string',
        'alamat_anak' => 'nullable|string',
    ]);

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 422);
    }

    $orangTua = OrangTua::with('anak')->first();
    if (!$orangTua) {
        return response()->json(['error' => 'Profil tidak ditemukan'], 404);
    }

    $anak = $orangTua->anak;
    if (!$anak) {
        $anak = $orangTua->anak()->create([]);
    }

   $anak->update([
    'nama' => $request->nama_anak,
    'ekskul' => $request->ekskul,
    'tgl_lahir' => $request->tgl_lahir,
    'jenis_kelamin' => $request->jenis_kelamin,
    'agama' => $request->agama,
    'alamat' => $request->alamat_anak,
]);

    return response()->json(['message' => 'Profil Anak berhasil diperbarui'], 200);
}
}