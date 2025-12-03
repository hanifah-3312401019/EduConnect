<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Pengumuman;
use App\Models\Guru;
use App\Models\Kelas;
use App\Models\Siswa;

class PengumumanSeeder extends Seeder
{
    public function run(): void
    {
        // PENGUMUMAN UMUM
        $gurus = Guru::all();
        foreach ($gurus as $guru) {
            Pengumuman::create([
                'Guru_Id'   => $guru->Guru_Id,
                'Judul'     => 'Libur Semester',
                'Isi'       => 'Sekolah libur mulai tanggal 20 Juni.',
                'Tanggal'   => now(),
                'Tipe'      => 'umum',
            ]);
        }

        // PENGUMUMAN PERKELAS
        $kelasList = Kelas::all();
        foreach ($kelasList as $kelas) {
            Pengumuman::create([
                'Guru_Id'   => $kelas->Guru_Id,      
                'Kelas_Id'  => $kelas->Kelas_Id,
                'Judul'     => 'Ujian Semester',
                'Isi'       => 'Ujian dimulai tanggal 1 Juli.',
                'Tanggal'   => now(),
                'Tipe'      => 'perkelas',
            ]);
        }

        // PENGUMUMAN PERSONAL
        $siswaList = Siswa::with('kelas')->get();
        foreach ($siswaList as $siswa) {
            Pengumuman::create([
                'Guru_Id'   => $siswa->kelas->Guru_Id, 
                'Kelas_Id'  => $siswa->Kelas_Id,
                'Siswa_Id'  => $siswa->Siswa_Id,
                'Judul'     => 'Konsultasi Pribadi',
                'Isi'       => 'Harap hadir konsultasi akademik.',
                'Tanggal'   => now(),
                'Tipe'      => 'personal',
            ]);
        }

        $this->command->info('Pengumuman otomatis berhasil dibuat!');
    }
}
