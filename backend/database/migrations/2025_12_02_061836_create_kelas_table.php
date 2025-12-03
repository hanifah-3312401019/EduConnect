<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('kelas', function (Blueprint $table) {
            $table->id('Kelas_Id');
            $table->string('Nama_Kelas');

            $table->unsignedBigInteger('Guru_Id');
            $table->foreign('Guru_Id')
                  ->references('Guru_Id')
                  ->on('gurus')
                  ->onDelete('cascade');

            $table->integer('Jumlah');      
            $table->string('Tahun_Ajar');   
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('kelas');
    }
};
