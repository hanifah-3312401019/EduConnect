<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pengumuman extends Model
{
    use HasFactory;

    protected $table = 'pengumuman';
    protected $primaryKey = 'Pengumuman_Id';

    protected $fillable = [
        'Guru_Id',
        'Kelas_Id', 
        'Siswa_Id',
        'Judul',
        'Isi',
        'Tanggal',
        'Tipe'
    ];

    public function guru()
    {
        return $this->belongsTo(Guru::class, 'Guru_Id', 'Guru_Id');
    }

    public function kelas()
    {
        return $this->belongsTo(Kelas::class, 'Kelas_Id', 'Kelas_Id');
    }

    public function siswa()
    {
        return $this->belongsTo(Siswa::class, 'Siswa_Id', 'Siswa_Id');
    }
}