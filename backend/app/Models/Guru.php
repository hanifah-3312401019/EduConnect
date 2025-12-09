<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class Guru extends Authenticatable
{
    use HasApiTokens, HasFactory;

    protected $table = 'gurus';
    protected $primaryKey = 'Guru_Id';
    public $incrementing = true;       
    protected $keyType = 'int'; 

    protected $fillable = [
        'NIK',
        'Nama',
        'Email',
        'Kata_Sandi',
    ];

    protected $hidden = ['Kata_Sandi'];

    public function kelas()
    {
        return $this->hasOne(Kelas::class, 'Guru_Id', 'Guru_Id');
    }
}