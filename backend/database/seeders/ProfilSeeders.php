<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\OrangTua;
use App\Models\Anak;
use Illuminate\Support\Facades\DB;

class ProfilSeeder extends Seeder
{
    public function run(): void
    {
        // Orang tua
        $orangTuaId = DB::table('orang_tuas')->insertGetId([
                'Nama'        => 'Budi Santoso',
                'Email'       => 'orangtua@sekolah.com',
                'Kata_Sandi'  => bcrypt('password123'),
                'No_Telepon'  => '081234567890',
                'Alamat'      => 'Jl. Pendidikan No. 45',
                'created_at'  => now(),
                'updated_at'  => now(),
        ]);

        // Anak
        DB::table('anak')->insert([
                'orang_tua_id' => $orangTuaId, // sesuai id dari tabel orang_tua
                'nama_anak' => 'Andi Santoso',
                'ekskul' => 'Basket',
                'tgl_lahir' => '2009-05-21',
                'jenis_kelamin' => 'Laki-laki',
                'agama' => 'Islam',
                'alamat_anak' => 'Jl. Merdeka No.12',
                'created_at' => now(),
                'updated_at' => now(),
        ]);
    }
}