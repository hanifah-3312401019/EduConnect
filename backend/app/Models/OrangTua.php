<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class OrangTua extends Model
{
    use HasApiTokens, HasFactory;

    protected $table = 'orang_tuas'; // nama tabel di phpMyAdmin
    protected $primaryKey = 'OrangTua_Id'; // primary key beda

    protected $fillable = [
        'Nama',
        'Email',
        'Kata_Sandi',
        'No_Telepon',
        'Alamat',
    ];

    public function anak()
    {
        return $this->hasOne(Anak::class, 'OrangTua_Id');
    }
}
