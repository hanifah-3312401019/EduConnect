<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

// app/Models/Pembayaran.php
class Pembayaran extends Model
{
    protected $table = 'pembayaran';
    protected $primaryKey = 'Pembayaran_Id';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'Siswa_Id',
        'Ekstrakulikuler_Id',
        'Bulan',
        'Tahun_Ajaran',
        'Biaya_SPP',
        'Biaya_Catering',
        'Total_Bayar'
    ];

    public function siswa()
    {
        return $this->belongsTo(Siswa::class, 'Siswa_Id', 'Siswa_Id');
    }

    public function ekstrakulikuler()
    {
        return $this->belongsTo(Ekstrakulikuler::class, 'Ekstrakulikuler_Id', 'Ekstrakulikuler_Id');
    }
}

