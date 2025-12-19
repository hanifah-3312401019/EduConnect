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
        Schema::table('kelas', function (Blueprint $table) {
        // relasi lama
        $table->dropForeign(['Guru_Id']);
        $table->dropColumn('Guru_Id');

        // relasi baru
        $table->unsignedBigInteger('Guru_Utama_Id')->nullable()->after('Nama_Kelas');
        $table->unsignedBigInteger('Guru_Pendamping_Id')->nullable()->after('Guru_Utama_Id');

        $table->foreign('Guru_Utama_Id')
              ->references('Guru_Id')->on('gurus')
              ->onDelete('set null');

        $table->foreign('Guru_Pendamping_Id')
              ->references('Guru_Id')->on('gurus')
              ->onDelete('set null');
    });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('kelas', function (Blueprint $table) {
        $table->dropForeign(['Guru_Utama_Id']);
        $table->dropForeign(['Guru_Pendamping_Id']);
        $table->dropColumn(['Guru_Utama_Id', 'Guru_Pendamping_Id']);

        $table->unsignedBigInteger('Guru_Id');
    });
    }
};
