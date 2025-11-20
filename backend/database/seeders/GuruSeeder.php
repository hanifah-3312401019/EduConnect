<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Guru;
use Illuminate\Support\Facades\Hash;

class GuruSeeder extends Seeder
{
    public function run(): void
    {
        Guru::create([
            'NIK' => '987654321000',
            'Nama' => 'Guru Utama',
            'Email' => 'guru@sekolah.com',
            'Kata_Sandi' => Hash::make('guru123'),
        ]);
    }
}