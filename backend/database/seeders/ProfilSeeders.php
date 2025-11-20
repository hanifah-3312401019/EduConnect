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
        $orangTuaId = DB::table('orang_tua')->insertGetId([
            'nama_ortu' => 'Bapak Joko',
            'nohp' => '08123456789',
            'email' => 'joko@mail.com',
            'alamat_ortu' => 'Jl. Merdeka No.1',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Anak
        DB::table('anak')->insert([
            'orang_tua_id' => $orangTuaId,
            'nama' => 'Joko Junior',
            'ekskul' => 'Sepak Bola',
            'tgl_lahir' => '2012-05-10',
            'jenis_kelamin' => 'Laki-laki',
            'agama' => 'Islam',
            'alamat' => 'Jl. Merdeka No.1',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}