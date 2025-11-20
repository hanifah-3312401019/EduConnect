<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Models\Guru;
use App\Models\OrangTua;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UniversalLoginController extends Controller
{
    public function login(Request $request)
    {
        $email = $request->Email;
        $password = $request->Kata_Sandi;

        // Cek Admin
        $admin = Admin::where('Email', $email)->first();
        if ($admin && Hash::check($password, $admin->Kata_Sandi)) {
            return response()->json([
                'role' => 'admin',
                'token' => $admin->createToken('admin-token')->plainTextToken,
                'profile' => $admin
            ]);
        }

        // Cek Guru
        $guru = Guru::where('Email', $email)->first();
        if ($guru && Hash::check($password, $guru->Kata_Sandi)) {
            return response()->json([
                'role' => 'guru',
                'token' => $guru->createToken('guru-token')->plainTextToken,
                'profile' => $guru
            ]);
        }

        // Cek Orang Tua
        $orangtua = OrangTua::where('Email', $email)->first();
        if ($orangtua && Hash::check($password, $orangtua->Kata_Sandi)) {
            return response()->json([
                'role' => 'orangtua',
                'token' => $orangtua->createToken('orangtua-token')->plainTextToken,
                'profile' => $orangtua
            ]);
        }

        return response()->json(['message' => 'Email atau kata sandi salah'], 401);
    }
}
