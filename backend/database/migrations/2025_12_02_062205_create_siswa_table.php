<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
Schema::create('siswa', function (Blueprint $table) {
            $table->id('Siswa_Id');
            $table->string('Nama');
            $table->unsignedBigInteger('OrangTua_Id')->nullable();
            $table->string('Agama')->nullable();
            $table->date('Tanggal_Lahir')->nullable();
            $table->string('Alamat')->nullable();
            $table->enum('Jenis_Kelamin', ['L', 'P'])->nullable();
            $table->unsignedBigInteger('Ekstrakulikuler_Id')->nullable();
            $table->unsignedBigInteger('Kelas_Id')->nullable();

            // Relasi
            $table->foreign('OrangTua_Id')
                  ->references('OrangTua_Id')
                  ->on('orang_tuas')
                  ->onDelete('set null');

            $table->foreign('Kelas_Id')
                  ->references('Kelas_Id')
                  ->on('kelas')
                  ->onDelete('set null');
            
            $table->foreign('Ekstrakulikuler_Id')
                    ->references('Ekstrakulikuler_Id')
                    ->on('ekstrakulikuler')
                    ->onDelete('set null');

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('siswa');
    }
};
