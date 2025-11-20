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
    Schema::create('anak', function (Blueprint $table) {
        $table->id();
        $table->foreignId('orang_tua_id')->constrained('orang_tua')->onDelete('cascade');
        $table->string('nama');
        $table->string('ekskul')->nullable();
        $table->date('tgl_lahir')->nullable();
        $table->string('jenis_kelamin')->nullable();
        $table->string('agama')->nullable();
        $table->text('alamat')->nullable();
        $table->timestamps();
    });
}

public function down(): void
{
    Schema::dropIfExists('anak');
}
};