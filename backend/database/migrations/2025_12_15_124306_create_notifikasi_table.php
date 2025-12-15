<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
{
    Schema::create('notifikasi', function (Blueprint $table) {
        $table->id('Notifikasi_Id');
        
        $table->unsignedBigInteger('OrangTua_Id');  
        
        $table->string('Judul', 255);
        $table->text('Pesan');
        $table->enum('Jenis', ['agenda', 'pengumuman', 'lainnya']);
        $table->unsignedBigInteger('Agenda_Id')->nullable();
        $table->unsignedBigInteger('Pengumuman_Id')->nullable();
        $table->boolean('dibaca')->default(false);
        $table->timestamps();

        $table->foreign('OrangTua_Id')  
              ->references('OrangTua_Id')
              ->on('orang_tuas')
              ->onDelete('cascade');
              
        $table->foreign('Agenda_Id')
              ->references('Agenda_Id')
              ->on('agenda')
              ->onDelete('cascade');
              
        $table->foreign('Pengumuman_Id')
              ->references('Pengumuman_Id')
              ->on('pengumuman')
              ->onDelete('cascade');
    });
}

    public function down(): void
    {
        Schema::dropIfExists('notifikasi');
    }
};