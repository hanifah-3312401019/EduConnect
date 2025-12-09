<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Siswa extends Model
{
    use HasFactory;

    protected $table = 'siswa';

    protected $primaryKey = 'Siswa_Id'; 

    protected $fillable = [
        'Nama',
        'OrangTua_Id',
        'Agama',
        'Tanggal_Lahir',
        'Alamat',
        'Jenis_Kelamin',
        'Ekstrakulikuler_Id',   
        'Kelas_Id',
    ];

    // Relasi ke orang tua
    public function orangTua()
    {
        return $this->belongsTo(OrangTua::class, 'OrangTua_Id', 'OrangTua_Id');
    }

    // Relasi ke kelas
    public function kelas()
    {
        return $this->belongsTo(Kelas::class, 'Kelas_Id', 'Kelas_Id');
    }

    // Relasi ke ekstrakulikuler
    public function ekstrakulikuler()
    {
        return $this->belongsTo(Ekstrakulikuler::class, 'Ekstrakulikuler_Id', 'Ekstrakulikuler_Id');
    }
}
