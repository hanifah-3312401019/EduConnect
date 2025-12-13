<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('perizinan', function (Blueprint $table) {
            $table->id('Id_Perizinan');

            // Foreign key ke siswa
            $table->unsignedBigInteger('Siswa_Id');
            $table->foreign('Siswa_Id')
                  ->references('Siswa_Id')
                  ->on('siswa')
                  ->onDelete('cascade');

            // Foreign key ke orang tua (nama tabel harus sama dg migration siswa)
            $table->unsignedBigInteger('OrangTua_Id');
            $table->foreign('OrangTua_Id')
                  ->references('OrangTua_Id')
                  ->on('orang_tuas')
                  ->onDelete('cascade');

            $table->enum('Jenis', ['Sakit', 'Acara Keluarga', 'Lainnya'])->default('Sakit');
            $table->text('Keterangan');
            $table->string('Bukti')->nullable(); 
            $table->string('Nama_Berkas')->nullable(); 
            $table->dateTime('Tanggal_Pengajuan')->useCurrent();
            $table->date('Tanggal_Izin');
            $table->string('Status_Pembacaan')->default('Belum Dibaca');

            $table->timestamps();

            $table->index(['Siswa_Id', 'Tanggal_Izin']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('perizinan');
    }
};
