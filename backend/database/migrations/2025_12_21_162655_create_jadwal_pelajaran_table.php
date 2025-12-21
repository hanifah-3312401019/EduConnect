<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('jadwal_pelajaran', function (Blueprint $table) {
            $table->id('Jadwal_Id');
            $table->foreignId('Kelas_Id')->constrained('kelas', 'Kelas_Id')->onDelete('cascade');
            $table->enum('Hari', ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat']);
            $table->time('Jam_Mulai');
            $table->time('Jam_Selesai');
            $table->string('Mata_Pelajaran', 100);
            $table->timestamps();
            
            // Unique constraint mencegah jadwal bentrok
            $table->unique(['Kelas_Id', 'Hari', 'Jam_Mulai'], 'jadwal_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('jadwal_pelajaran');
    }
};
