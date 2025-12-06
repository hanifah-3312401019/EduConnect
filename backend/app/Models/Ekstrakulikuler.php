<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Ekstrakulikuler extends Model
{
    use HasFactory;

    protected $table = 'ekstrakulikuler';
    protected $primaryKey = 'Ekstrakulikuler_Id';

    protected $fillable = [
        'nama',
        'biaya',
    ];

    // Relasi: Satu Ekskul punya banyak siswa
    public function siswa()
    {
        return $this->hasMany(Siswa::class, 'Ekstrakulikuler_Id', 'Ekstrakulikuler_Id');
    }
}