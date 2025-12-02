<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Siswa extends Model
{
    use HasFactory;

    protected $table = 'siswa';

    protected $primaryKey = 'Siswa_Id'; // wajib!

    protected $fillable = [
        'Nama',
        'OrangTua_Id',
        'Agama',
        'Tanggal_Lahir',
        'Alamat',
        'Jenis_Kelamin',
        'Ekstrakulikuler',
        'Kelas_Id'
    ];

    public function orangTua()
    {
        return $this->belongsTo(OrangTua::class, 'OrangTua_Id');
    }

    public function kelas()
    {
        return $this->belongsTo(Kelas::class, 'Kelas_Id');
    }
}
