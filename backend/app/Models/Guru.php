<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class Guru extends Authenticatable
{
    use HasApiTokens, HasFactory;

    protected $table = 'gurus';
    protected $primaryKey = 'Guru_Id';
    public $incrementing = true;       
    protected $keyType = 'int'; 

    protected $fillable = [
        'NIK',
        'Nama',
        'Email',
        'Kata_Sandi',
    ];

    protected $hidden = ['Kata_Sandi'];

    // Cari kelas di mana guru ini mengajar (baik sebagai utama atau pendamping)
    public function kelas()
    {
        return Kelas::where('Guru_Utama_Id', $this->Guru_Id)
                   ->orWhere('Guru_Pendamping_Id', $this->Guru_Id)
                   ->first();
    }

    // Helper untuk mengetahui peran dan kelas
    public function getInfoKelas()
    {
        $kelas = $this->kelas();
        
        if (!$kelas) {
            return [
                'status' => 'Belum Bertugas',
                'kelas_nama' => null,
                'kelas_id' => null,
                'peran' => null
            ];
        }
        
        $peran = $kelas->Guru_Utama_Id == $this->Guru_Id ? 'Guru Utama' : 'Guru Pendamping';
        
        return [
            'status' => 'Aktif',
            'kelas_nama' => $kelas->Nama_Kelas,
            'kelas_id' => $kelas->Kelas_Id,
            'peran' => $peran
        ];
    }
}