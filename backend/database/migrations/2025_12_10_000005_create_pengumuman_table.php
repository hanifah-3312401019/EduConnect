<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pengumuman', function (Blueprint $table) {
            $table->id('Pengumuman_Id');
            
            $table->unsignedBigInteger('Guru_Id');
            $table->foreign('Guru_Id')
                  ->references('Guru_Id')
                  ->on('gurus')
                  ->onDelete('cascade');
            
            $table->unsignedBigInteger('Kelas_Id')->nullable();
            $table->foreign('Kelas_Id')
                  ->references('Kelas_Id')
                  ->on('kelas')
                  ->onDelete('cascade');
            
            $table->unsignedBigInteger('Siswa_Id')->nullable();
            $table->foreign('Siswa_Id')
                  ->references('Siswa_Id')
                  ->on('siswa')
                  ->onDelete('cascade');
                  
            $table->string('Judul');
            $table->text('Isi');
            $table->dateTime('Tanggal');
            $table->enum('Tipe', ['umum', 'perkelas', 'personal']);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pengumuman');
    }
};