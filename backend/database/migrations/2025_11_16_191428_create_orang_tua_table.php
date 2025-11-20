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
    Schema::create('orang_tua', function (Blueprint $table) {
        $table->id();
        $table->string('nama_ortu');
        $table->string('nohp');
        $table->string('email')->nullable();
        $table->text('alamat_ortu')->nullable();
        $table->timestamps();
    });
}

public function down(): void
{
    Schema::dropIfExists('orang_tua');
}
};