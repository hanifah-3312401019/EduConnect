<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Agenda extends Model
{
    use HasFactory;

    protected $table = 'agenda';
    protected $primaryKey = 'Agenda_Id';

    protected $fillable = [
        'Guru_Id',
        'Kelas_Id',
        'Ekstrakulikuler_Id',
        'Tanggal',
        'Waktu_Mulai',
        'Waktu_Selesai',
        'Judul',
        'Deskripsi',
        'Tipe',
    ];

    protected $casts = [
        'Tanggal' => 'date',
        'Waktu_Mulai' => 'string',
        'Waktu_Selesai' => 'string',
    ];

    // relasi
    public function guru()
    {
        return $this->belongsTo(Guru::class, 'Guru_Id', 'Guru_Id');
    }

    public function kelas()
    {
        return $this->belongsTo(Kelas::class, 'Kelas_Id', 'Kelas_Id');
    }

    public function ekstrakulikuler()
    {
        return $this->belongsTo(Ekstrakulikuler::class, 'Ekstrakulikuler_Id', 'Ekstrakulikuler_Id');
    }

    // accessor: tampilkan rentang waktu "HH:MM - HH:MM"
    public function getWaktuDisplayAttribute()
    {
        $start = $this->Waktu_Mulai ? substr($this->Waktu_Mulai, 0, 5) : '';
        $end   = $this->Waktu_Selesai ? substr($this->Waktu_Selesai, 0, 5) : '';
        return trim($start . ($start && $end ? ' - ' : '') . $end);
    }

    // Scopes berdasarkan tipe
    public function scopeSekolah($query)
    {
        return $query->where('Tipe', 'sekolah');
    }

    public function scopePerkelas($query)
    {
        return $query->where('Tipe', 'perkelas');
    }

    public function scopeEkskul($query)
    {
        return $query->where('Tipe', 'ekskul');
    }

    // Helper untuk label tipe
    public function getTipeLabelAttribute()
    {
        $labels = [
            'sekolah' => 'Sekolah (Umum)',
            'perkelas' => 'Per Kelas',
            'ekskul' => 'Ekstrakurikuler'
        ];
        return $labels[$this->Tipe] ?? $this->Tipe;
    }
}