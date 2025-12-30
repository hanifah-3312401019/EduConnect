<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Agenda;
use App\Models\Guru;
use App\Models\Kelas;
use App\Models\Ekstrakulikuler;
use Carbon\Carbon;

class AgendaSeeder extends Seeder
    {
        public function run(): void
        {
            // Cek apakah sudah ada data agenda
            if (Agenda::count() > 0) {
                $this->command->info('Data agenda sudah ada. Seeder dilewati.');
                return;
            }

            $gurus = Guru::all();
            $kelasList = Kelas::all();
            $ekskuls = Ekstrakulikuler::all();

            if ($gurus->isEmpty() || $kelasList->isEmpty()) {
                $this->command->info('Data guru atau kelas tidak ditemukan. Seeder tidak dijalankan.');
                return;
            }

            // ================================
            // 1. AGENDA SEKOLAH (UMUM) - FIXED
            // ================================
            $this->command->info('Membuat agenda sekolah...');
            
            // Ambil satu guru sebagai pembuat agenda sekolah (bisa guru mana saja)
            $guruUtama = $gurus->first();
            
            // Agenda sekolah (umum) - TIDAK TERIKAT KELAS
            Agenda::create([
                'Guru_Id' => $guruUtama->Guru_Id,
                'Kelas_Id' => null,  // ← INI HARUS NULL untuk sekolah
                'Ekstrakulikuler_Id' => null,
                'Judul' => 'Upacara Bendera Hari Senin',
                'Deskripsi' => 'Upacara bendera rutin setiap hari Senin untuk semua siswa',
                'Tanggal' => Carbon::now()->next(Carbon::MONDAY)->format('Y-m-d'),
                'Waktu_Mulai' => '07:00',
                'Waktu_Selesai' => '08:00',
                'Tipe' => 'sekolah',
            ]);

            Agenda::create([
                'Guru_Id' => $guruUtama->Guru_Id,
                'Kelas_Id' => null,  // ← INI HARUS NULL untuk sekolah
                'Ekstrakulikuler_Id' => null,
                'Judul' => 'Peringatan Hari Pendidikan Nasional',
                'Deskripsi' => 'Acara peringatan Hardiknas dengan berbagai kegiatan lomba',
                'Tanggal' => '2025-05-02',
                'Waktu_Mulai' => '08:00',
                'Waktu_Selesai' => '12:00',
                'Tipe' => 'sekolah',
            ]);

            Agenda::create([
                'Guru_Id' => $guruUtama->Guru_Id,
                'Kelas_Id' => null,  // ← INI HARUS NULL untuk sekolah
                'Ekstrakulikuler_Id' => null,
                'Judul' => 'Hari Kebersihan Sekolah',
                'Deskripsi' => 'Kegiatan gotong royong membersihkan lingkungan sekolah',
                'Tanggal' => Carbon::now()->addDays(7)->format('Y-m-d'),
                'Waktu_Mulai' => '09:00',
                'Waktu_Selesai' => '11:00',
                'Tipe' => 'sekolah',
            ]);

    
            // ================================
            // 3. AGENDA EKSTRAKULIKULER - FIXED
            // ================================
            $this->command->info('Membuat agenda ekstrakurikuler...');
            
            if ($ekskuls->isNotEmpty()) {
                // Setiap guru wali kelas bisa membuat agenda ekskul untuk kelas mereka
                foreach ($gurus as $guru) {

        $kelas = $guru->kelas();

        if (!$kelas) {
            continue;
        }

        foreach ($ekskuls->take(2) as $ekskul) {
            Agenda::create([
                'Guru_Id' => $guru->Guru_Id,
                'Kelas_Id' => $kelas->Kelas_Id,
                'Ekstrakulikuler_Id' => $ekskul->Ekstrakulikuler_Id,
                'Judul' => 'Latihan Rutin ' . $ekskul->Nama_Ekstrakulikuler,
                'Deskripsi' => 'Latihan rutin mingguan untuk ekstrakurikuler ' . $ekskul->Nama_Ekstrakulikuler,
                'Tanggal' => Carbon::now()->addDays(3)->format('Y-m-d'),
                'Waktu_Mulai' => '14:00',
                'Waktu_Selesai' => '16:00',
                'Tipe' => 'ekskul',
            ]);
        }
    }

            } else {
                $this->command->info('Tidak ada data ekstrakurikuler, agenda ekskul dilewati.');
            }

            $this->command->info('Seeder agenda selesai!');
            $this->command->info('Agenda Sekolah: Kelas_Id = null, Ekstrakulikuler_Id = null');
            $this->command->info('Agenda Perkelas: Kelas_Id = ada, Ekstrakulikuler_Id = null');
            $this->command->info('Agenda Ekskul: Kelas_Id = ada, Ekstrakulikuler_Id = ada');
        }
    }