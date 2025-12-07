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
                'Ekstrakulikuler_Id' => 1,
                'nama' => 'Basket',
                'biaya' => 50000,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'Ekstrakulikuler_Id' => 2,
                'nama' => 'Pramuka',
                'biaya' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}