<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Anak extends Model
{
    use HasFactory;

    protected $table = 'siswa';
    protected $fillable = ['orangTua_id', 'nama', 'ekstrakulikuler', 'tanggal_lahir', 'jenis_kelamin', 'agama', 'alamat'];

    public function orangTua()
    {
        return $this->belongsTo(OrangTua::class, 'orang_tua_id');
    }
}