<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class OrangTuaSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('orang_tuas')->insert([
            [
                'Nama'        => 'Budi Santoso',
                'Email'       => 'orangtua@sekolah.com',
                'Kata_Sandi'  => bcrypt('password123'),
                'No_Telepon'  => '081234567890',
                'Alamat'      => 'Jl. Pendidikan No. 45',
                'created_at'  => now(),
                'updated_at'  => now(),
            ],
            [
                'Nama'        => 'Siti Aminah',
                'Email'       => 'siti@sekolah.com',
                'Kata_Sandi'  => bcrypt('password123'),
                'No_Telepon'  => '081987654321',
                'Alamat'      => 'Jl. Merdeka No. 12',
                'created_at'  => now(),
                'updated_at'  => now(),
            ],
        ]);
    }
}
