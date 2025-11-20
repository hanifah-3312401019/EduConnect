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

    protected $fillable = [
        'NIK',
        'Nama',
        'Email',
        'Kata_Sandi',
    ];

    protected $hidden = ['Kata_Sandi'];
}