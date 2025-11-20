<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AnakSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('anak')->insert([
            [
                'orang_tua_id' => 1, // sesuai id dari tabel orang_tua
                'nama_anak' => 'Andi Santoso',
                'ekskul' => 'Basket',
                'tgl_lahir' => '2009-05-21',
                'jenis_kelamin' => 'Laki-laki',
                'agama' => 'Islam',
                'alamat_anak' => 'Jl. Merdeka No.12',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'orang_tua_id' => 2,
                'nama_anak' => 'Ani Aminah',
                'ekskul' => 'Piano',
                'tgl_lahir' => '2010-08-15',
                'jenis_kelamin' => 'Perempuan',
                'agama' => 'Kristen',
                'alamat_anak' => 'Jl. Sudirman No.45',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}