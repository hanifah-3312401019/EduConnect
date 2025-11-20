<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\OrangTua;
use Illuminate\Support\Facades\Hash;

class OrangTuaSeeder extends Seeder
{
    public function run(): void
    {
        OrangTua::create([
            'Nama' => 'Budi Santoso',
            'Email' => 'orangtua@sekolah.com',
            'Kata_Sandi' => Hash::make('ortu123'),
            'No_Telepon' => '081234567890',
            'Alamat' => 'Jl. Pendidikan No. 45',
        ]);
    }
}