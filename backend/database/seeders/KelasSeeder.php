<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Kelas;
use App\Models\Guru;

class KelasSeeder extends Seeder
{
    public function run(): void
    {
        $guruUtama = Guru::first();
        $guruPendamping = Guru::skip(1)->first();

        if (!$guruUtama) {
            $this->command->error('Data guru tidak ditemukan. Pastikan GuruSeeder sudah dijalankan.');
            return;
        }

        $kelasData = [
            [
                'Kelas_Id' => 1,
                'Nama_Kelas' => 'Kelas 1A',
                'Guru_Utama_Id' => $guruUtama->Guru_Id,
                'Guru_Pendamping_Id' => $guruPendamping?->Guru_Id,
                'Jumlah' => 25,
                'Tahun_Ajar' => '2024/2025'
            ],
            [
                'Kelas_Id' => 2,
                'Nama_Kelas' => 'Kelas 2A',
                'Guru_Utama_Id' => null,
                'Guru_Pendamping_Id' => null,
                'Jumlah' => 28,
                'Tahun_Ajar' => '2024/2025'
            ]
        ];

        foreach ($kelasData as $data) {
            Kelas::create($data);
        }

        $this->command->info('KelasSeeder berhasil dijalankan.');
    }
}
