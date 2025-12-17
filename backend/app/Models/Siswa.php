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
        'Jenis_Kelamin',
        'Tanggal_Lahir',
        'Alamat',
        'Agama',
        'Ekstrakulikuler_Id',
        'OrangTua_Id',
        'Kelas_Id',
    ];

    protected $casts = [
        'Tanggal_Lahir' => 'date',
    ];

    public function orangTua()
    {
        return $this->belongsTo(OrangTua::class, 'OrangTua_Id', 'OrangTua_Id');
    }

    public function kelas()
    {
        return $this->belongsTo(Kelas::class, 'Kelas_Id', 'Kelas_Id');
    }

    public function ekstrakulikuler()
    {
        return $this->belongsTo(Ekstrakulikuler::class, 'Ekstrakulikuler_Id', 'Ekstrakulikuler_Id');
    }

    public function perizinan()
    {
        return $this->hasMany(Perizinan::class, 'Siswa_Id', 'Siswa_Id');
    }

    public function pembayaran()
{
    return $this->hasMany(Pembayaran::class, 'Siswa_Id', 'Siswa_Id');
}
}