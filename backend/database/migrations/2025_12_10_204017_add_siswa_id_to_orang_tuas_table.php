<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::table('orang_tuas', function (Blueprint $table) {
            $table->unsignedBigInteger('Siswa_Id')->nullable()->after('Alamat');
            
            $table->foreign('Siswa_Id')
            ->references('Siswa_Id')
            ->on('siswa')
            ->onDelete('set null');
        });
    }


    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('orang_tuas', function (Blueprint $table) {
            //
        });
    }
};
