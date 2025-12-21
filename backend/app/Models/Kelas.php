<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Kelas extends Model
{
    use HasFactory;

    protected $table = 'kelas';
    protected $primaryKey = 'Kelas_Id';

    protected $fillable = [
        'Nama_Kelas',
        'Guru_Utama_Id',
        'Guru_Pendamping_Id',
        'Jumlah',
        'Tahun_Ajar'
    ];

    public function guruUtama()
    {
        return $this->belongsTo(Guru::class, 'Guru_Utama_Id');
    }

    public function guruPendamping()
    {
        return $this->belongsTo(Guru::class, 'Guru_Pendamping_Id');
    }

    public function siswa()
    {
        return $this->hasMany(Siswa::class, 'Kelas_Id');
    }

    public function pengumuman()
    {
        return $this->hasMany(Pengumuman::class, 'Kelas_Id');
    }

    public function jadwalPelajaran()
    {
        return $this->hasMany(JadwalPelajaran::class, 'Kelas_Id', 'Kelas_Id');
    }
}