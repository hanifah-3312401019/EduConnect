<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
       public function up(): void
    {
        Schema::create('ekstrakulikuler', function (Blueprint $table) {
            $table->id('Ekstrakulikuler_Id');
            $table->string('nama');
            $table->integer('biaya')->default(0);
            $table->timestamps();
        });
    }
    public function down(): void
    {
         Schema::dropIfExists('ekstrakulikuler');
    }
};
