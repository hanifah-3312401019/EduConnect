<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrangTua extends Model
{
    use HasFactory;

    protected $table = 'orang_tuas'; // sesuai nama tabel di phpMyAdmin
    protected $primaryKey = 'OrangTua_Id'; // primary key kamu beda

    protected $fillable = [
        'Nama',
        'Email',
        'Kata_Sandi',
        'No_Telepon',
        'Alamat',
    ];

    public function anak()
    {
        return $this->hasOne(Anak::class, 'orang_tua_id');
    }
}
