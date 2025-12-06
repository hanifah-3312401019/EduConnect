<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SiswaSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('siswa')->insert([
            [
                'Nama'            => 'Andi Santoso',
                'OrangTua_Id'     => 1,
                'Agama'           => 'Islam',
                'Tanggal_Lahir'   => '2009-05-21',
                'Alamat'          => 'Jl. Merdeka No.12',
                'Jenis_Kelamin'   => 'L',     // WAJIB 'L' atau 'P'
                'Ekstrakulikuler_Id' => 'Basket',
                'Kelas_Id'        => 1,  
                'created_at'      => now(),
                'updated_at'      => now(),
            ],
        ]);
    }
}
