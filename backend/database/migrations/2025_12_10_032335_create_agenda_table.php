<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('agenda', function (Blueprint $table) {
            $table->id('Agenda_Id');

            // FK Guru
            $table->unsignedBigInteger('Guru_Id');
            $table->foreign('Guru_Id')
                  ->references('Guru_Id')
                  ->on('gurus')
                  ->onDelete('cascade');

            // FK Kelas (NULLABLE untuk tipe "sekolah")
            $table->unsignedBigInteger('Kelas_Id')->nullable(); // <-- UBAH INI: nullable()
            $table->foreign('Kelas_Id')
                  ->references('Kelas_Id')
                  ->on('kelas')
                  ->onDelete('cascade');

            // FK Ekskul (hanya untuk tipe ekskul)
            $table->unsignedBigInteger('Ekstrakulikuler_Id')->nullable();
            $table->foreign('Ekstrakulikuler_Id')
                  ->references('Ekstrakulikuler_Id')
                  ->on('ekstrakulikuler')
                  ->onDelete('set null');

            $table->date('Tanggal');
            $table->time('Waktu_Mulai');
            $table->time('Waktu_Selesai');

            $table->string('Judul');
            $table->text('Deskripsi');

            // tipe agenda: sekolah, perkelas, ekskul
            $table->enum('Tipe', ['sekolah', 'perkelas', 'ekskul']);

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('agenda');
    }
};