<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class EkstrakulikulerSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('ekstrakulikuler')->insert([
            [
                'nama' => 'Basket',
                'biaya' => 50000,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nama' => 'Pramuka',
                'biaya' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}