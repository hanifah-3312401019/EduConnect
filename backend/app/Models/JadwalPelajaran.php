<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class JadwalPelajaran extends Model
{
    use HasFactory;

    protected $table = 'jadwal_pelajaran';
    protected $primaryKey = 'Jadwal_Id';
    
    protected $fillable = [
        'Kelas_Id',
        'Hari',
        'Jam_Mulai',
        'Jam_Selesai',
        'Mata_Pelajaran'
    ];

    protected $casts = [
        'Jam_Mulai' => 'string',
        'Jam_Selesai' => 'string',
    ];

    public function kelas()
    {
        return $this->belongsTo(Kelas::class, 'Kelas_Id', 'Kelas_Id');
    }

    // Scope untuk mengurutkan berdasarkan hari
    public function scopeUrutHari($query)
    {
        return $query->orderByRaw("FIELD(Hari, 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat')")
                     ->orderBy('Jam_Mulai');
    }
}
