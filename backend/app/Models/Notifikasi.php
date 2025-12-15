<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notifikasi extends Model
{
    use HasFactory;

    protected $table = 'notifikasi';
    protected $primaryKey = 'Notifikasi_Id';
    public $timestamps = true;

    protected $fillable = [
        'OrangTua_Id', 
        'Judul',
        'Pesan',
        'Jenis',
        'Agenda_Id',
        'Pengumuman_Id',
        'dibaca',
    ];

    protected $casts = [
        'dibaca' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relationship dengan OrangTua 
    public function orangTua()
    {
        return $this->belongsTo(OrangTua::class, 'OrangTua_Id', 'OrangTua_Id'); 
    }

    // Relationship dengan Agenda
    public function agenda()
    {
        return $this->belongsTo(Agenda::class, 'Agenda_Id', 'Agenda_Id');
    }

    // Relationship dengan Pengumuman
    public function pengumuman()
    {
        return $this->belongsTo(Pengumuman::class, 'Pengumuman_Id', 'Pengumuman_Id');
    }

    // Scope untuk notifikasi belum dibaca
    public function scopeUnread($query)
    {
        return $query->where('dibaca', false);
    }

    // Scope untuk notifikasi berdasarkan jenis
    public function scopeByJenis($query, $jenis)
    {
        return $query->where('Jenis', $jenis);
    }

    // Accessor untuk status
    public function getStatusAttribute()
    {
        return $this->dibaca ? 'Dibaca' : 'Belum Dibaca';
    }

    // Accessor untuk warna status
    public function getStatusColorAttribute()
    {
        return $this->dibaca ? 'success' : 'warning';
    }
}