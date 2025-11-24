<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Anak extends Model
{
    use HasFactory;

    protected $table = 'anak';
    protected $fillable = ['orang_tua_id', 'nama', 'ekskul', 'tgl_lahir', 'jenis_kelamin', 'agama', 'alamat'];

    public function orangTua()
    {
        return $this->belongsTo(OrangTua::class, 'orang_tua_id');
    }
}