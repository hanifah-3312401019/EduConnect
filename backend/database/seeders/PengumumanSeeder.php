<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Pengumuman;
use App\Models\Guru;
use App\Models\Kelas;

class PengumumanSeeder extends Seeder
{
    public function run(): void
    {
        $guru = Guru::first();
        $kelas = Kelas::first();

        if (!$guru || !$kelas) {
            $this->command->error(
                'Seeder Pengumuman gagal: data Guru atau Kelas belum tersedia.'
            );
            return;
        }

        Pengumuman::create([
            'Guru_Id'   => $guru->Guru_Id,
            'Kelas_Id'  => $kelas->Kelas_Id,
            'Judul'     => 'Ujian Semester',
            'Isi'       => 'Ujian dimulai tanggal 1 Juli.',
            'Tanggal'   => now(),
            'Tipe'      => 'perkelas',
        ]);

        $this->command->info('PengumumanSeeder berhasil dijalankan.');
    }
}
