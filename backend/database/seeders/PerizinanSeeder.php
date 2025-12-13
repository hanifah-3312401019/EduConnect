<?php
// database/seeders/PerizinanSeeder.php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Perizinan;
use App\Models\Siswa;
use App\Models\OrangTua;

class PerizinanSeeder extends Seeder
{
    public function run(): void
    {
        // Ambil beberapa siswa dan orang tua
        $siswa = Siswa::take(5)->get();
        $orangTua = OrangTua::take(5)->get();

        $jenisIzin = ['Sakit', 'Acara Keluarga', 'Lainnya'];
        $alasan = [
            'Demam tinggi',
            'Batuk pilek',
            'Acara keluarga di luar kota',
            'Keperluan mendadak',
            'Konsultasi dokter'
        ];

        foreach ($siswa as $index => $s) {
            if (isset($orangTua[$index])) {
                Perizinan::create([
                    'Siswa_Id' => $s->id_siswa,
                    'OrangTua_Id' => $orangTua[$index]->id_orang_tua,
                    'Jenis' => $jenisIzin[array_rand($jenisIzin)],
                    'Keterangan' => $alasan[array_rand($alasan)],
                    'Bukti' => null, // bisa diisi path gambar dummy jika ada
                    'Nama_Berkas' => 'bukti_izin_' . ($index + 1) . '.jpg',
                    'Tanggal_Izin' => now()->addDays($index)->format('Y-m-d'),
                    'Status_Pembacaan' => 'Belum Dibaca'
                ]);
            }
        }
    }
}