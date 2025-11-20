<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Profil extends Model
{
    protected $table = 'profil';

    protected $fillable = ['name', 'ekskul', 'tgl_lahir', 'jenis_kelamin', 'agama', 'alamat'];

    public $timestamps = false;
}