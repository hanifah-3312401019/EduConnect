<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Models\Guru;
use App\Models\OrangTua;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

class UniversalLoginController extends Controller
{
    public function login(Request $request)
    {
        // Handle CORS preflight
        if ($request->isMethod('OPTIONS')) {
            return response()->json(['status' => 'OK']);
        }

        // Pastikan hanya POST
        if (!$request->isMethod('POST')) {
            return response()->json([
                'success' => false,
                'message' => 'Method not allowed'
            ], 405);
        }

        $email = $request->Email;
        $password = $request->Kata_Sandi;

        Log::info('Login attempt', ['email' => $email]);

        // Cek Orang Tua
        $orangtua = OrangTua::where('Email', $email)->first();
        if ($orangtua && Hash::check($password, $orangtua->Kata_Sandi)) {
            $orangtua->tokens()->delete();
            $token = $orangtua->createToken('orangtua-token')->plainTextToken;
            
            Log::info('Orangtua login SUCCESS', ['email' => $email]);
            
            return response()->json([
                'success' => true,
                'role' => 'orangtua',
                'token' => $token,
                'profile' => $orangtua
            ]);
        }

        // Cek Admin
        $admin = Admin::where('Email', $email)->first();
        if ($admin && Hash::check($password, $admin->Kata_Sandi)) {
            $admin->tokens()->delete();
            $token = $admin->createToken('admin-token')->plainTextToken;
            
            return response()->json([
                'success' => true,
                'role' => 'admin',
                'token' => $token,
                'profile' => $admin
            ]);
        }

        // Cek Guru
        $guru = Guru::where('Email', $email)->first();
        if ($guru && Hash::check($password, $guru->Kata_Sandi)) {
            $guru->tokens()->delete();
            $token = $guru->createToken('guru-token')->plainTextToken;
            
            return response()->json([
                'success' => true,
                'role' => 'guru', 
                'token' => $token,
                'profile' => $guru
            ]);
        }

        Log::warning('Login FAILED', ['email' => $email]);
        
        return response()->json([
            'success' => false,
            'message' => 'Email atau kata sandi salah'
        ], 401);
    }
}
