<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
{
    Schema::table('siswa', function (Blueprint $table) {
        if (!Schema::hasColumn('siswa', 'ekstrakulikuler')) {
            $table->string('ekstrakulikuler')->nullable();
        }
    });
}
    public function down(): void
    {
        Schema::table('siswa', function (Blueprint $table) {
            //
        });
    }
};
