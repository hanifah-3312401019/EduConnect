<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class Admin extends Authenticatable
{
    use HasApiTokens, HasFactory;

    protected $table = 'admins';
    protected $primaryKey = 'Admin_Id';

    protected $fillable = [
        'Nama',
        'NIK',
        'Email',
        'Kata_Sandi',
    ];

    protected $hidden = ['Kata_Sandi'];
}