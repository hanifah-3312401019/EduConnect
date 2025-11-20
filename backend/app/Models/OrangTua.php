<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class OrangTua extends Authenticatable
{
    use HasApiTokens, HasFactory;

    protected $table = 'orang_tuas';

    protected $primaryKey = 'OrangTua_Id';

    protected $fillable = [
        'Nama',
        'Email',
        'Kata_Sandi',
        'No_Telepon',
        'Alamat',
    ];

    protected $hidden = ['Kata_Sandi'];
}