<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Perizinan extends Model
{
    use HasFactory;

    protected $table = 'perizinan';
    protected $primaryKey = 'Id_Perizinan';

    protected $fillable = [
        'Siswa_Id',
        'OrangTua_Id',
        'Jenis',
        'Keterangan',
        'Bukti',
        'Nama_Berkas',
        'Tanggal_Pengajuan',
        'Tanggal_Izin',
        'Status_Pembacaan',
    ];

    protected $casts = [
        'Tanggal_Pengajuan' => 'datetime',
        'Tanggal_Izin' => 'date',
    ];

    public function siswa()
    {
        return $this->belongsTo(Siswa::class, 'Siswa_Id', 'Siswa_Id');
    }

    public function orangTua()
    {
        return $this->belongsTo(OrangTua::class, 'OrangTua_Id', 'OrangTua_Id');
    }
}