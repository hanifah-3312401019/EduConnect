<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ProfilSeeder extends Seeder
{
    public function run(): void
    {
        // Insert Orang Tua
        $orangTuaId = DB::table('orang_tuas')->insertGetId([
            'Nama'        => 'Budi Santoso',
            'Email'       => 'orangtua@sekolah.com',
            'Kata_Sandi'  => bcrypt('password123'),
            'No_Telepon'  => '081234567890',
            'Alamat'      => 'Jl. Pendidikan No. 45',
            'created_at'  => now(),
            'updated_at'  => now(),
        ]);

        // Insert Siswa
        DB::table('siswa')->insert([
            'OrangTua_Id'     => $orangTuaId,
            'Nama'            => 'Andi Santoso',
            'Ekstrakulikuler' => 'Basket',
            'Tanggal_Lahir'   => '2009-05-21',
            'Jenis_Kelamin'   => 'L',
            'Agama'           => 'Islam',
            'Alamat'          => 'Jl. Merdeka No.12',
            'Kelas_Id'        => 1,

            'created_at'      => now(),
            'updated_at'      => now(),
        ]);
    }
}
