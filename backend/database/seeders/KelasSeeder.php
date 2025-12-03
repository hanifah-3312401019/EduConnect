<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Kelas;
use App\Models\Guru;

class KelasSeeder extends Seeder
{
    public function run(): void
    {
        $guru = Guru::first();

        if (!$guru) {
            $this->command->error('Guru tidak ditemukan! Pastikan GuruSeeder sudah dijalankan.');
            return;
        }

        $kelasData = [
            [
                'Kelas_Id' => 1, // Explicitly set ID
                'Nama_Kelas' => 'Kelas 1A',
                'Guru_Id' => $guru->Guru_Id,
                'Jumlah' => 25,
                'Tahun_Ajar' => '2024/2025'
            ],
            [
                'Kelas_Id' => 2, // Explicitly set ID
                'Nama_Kelas' => 'Kelas 2A',
                'Guru_Id' => $guru->Guru_Id,
                'Jumlah' => 28,
                'Tahun_Ajar' => '2024/2025'
            ]
        ];

        foreach ($kelasData as $data) {
            Kelas::create($data);
        }

        $this->command->info('Kelas seeder berhasil dijalankan!');
    }
}