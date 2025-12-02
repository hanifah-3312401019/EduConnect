<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\OrangTua;
use App\Models\Admin;
use App\Models\Anak;
use App\Models\Guru;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Mail;
use App\Mail\OrangTuaPasswordMail;

class AdminController extends Controller
{
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

        // Generate password otomatis
        $plainPassword = substr(str_shuffle('ABCDEFGHJKLMNPQRSTUVWXYZ123456789'), 0, 8);

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
        $data = OrangTua::select('OrangTua_Id', 'Nama', 'Email', 'No_Telepon', 'Alamat')->get();

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

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
