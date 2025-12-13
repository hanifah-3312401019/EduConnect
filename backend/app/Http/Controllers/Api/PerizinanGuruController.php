<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Perizinan;
use App\Models\Guru;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PerizinanGuruController extends Controller
{
    public function index(Request $request)
    {
        $user = Auth::user();
        
        if ($user->role !== 'guru') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        $guru = Guru::with('kelas')->find($user->id_guru);
        
        if (!$guru || !$guru->kelas) {
            return response()->json(['success' => false, 'message' => 'Belum ada kelas.'], 404);
        }

        $kelasIds = $guru->kelas->pluck('Kelas_Id');

        $perizinan = Perizinan::with(['siswa' => function($query) use ($kelasIds) {
                $query->whereIn('Kelas_Id', $kelasIds)->with(['kelas', 'orangTua']);
            }])
            ->whereHas('siswa', function($query) use ($kelasIds) {
                $query->whereIn('Kelas_Id', $kelasIds);
            })
            ->orderBy('Tanggal_Pengajuan', 'DESC')
            ->get();

        // Update status pembacaan
        $perizinan->where('Status_Pembacaan', 'Belum Dibaca')->each(function ($item) {
            $item->update(['Status_Pembacaan' => 'Sudah Dibaca']);
        });

        return response()->json([
            'success' => true,
            'data' => $perizinan->map(function ($item) {
                $siswa = $item->siswa;
                $orangTua = $siswa ? $siswa->orangTua : null;
                
                return [
                    'Id_Perizinan' => $item->Id_Perizinan,
                    'Jenis' => $item->Jenis,
                    'Keterangan' => $item->Keterangan,
                    'Bukti' => $item->Bukti ? asset('storage/' . $item->Bukti) : null,
                    'Nama_Berkas' => $item->Nama_Berkas,
                    'Tanggal_Pengajuan' => $item->Tanggal_Pengajuan->format('d/m/Y H:i'),
                    'Tanggal_Izin' => $item->Tanggal_Izin->format('d/m/Y'),
                    'Status_Pembacaan' => $item->Status_Pembacaan,
                    'Siswa_Id' => $item->Siswa_Id,
                    
                    // Data Siswa sesuai atribut yang Anda berikan
                    'Nama_Siswa' => $siswa ? $siswa->Nama : '-',
                    'Jenis_Kelamin_Siswa' => $siswa ? $siswa->Jenis_Kelamin : '-',
                    'Tanggal_Lahir_Siswa' => $siswa && $siswa->Tanggal_Lahir ? $siswa->Tanggal_Lahir->format('d/m/Y') : '-',
                    'Alamat_Siswa' => $siswa ? $siswa->Alamat : '-',
                    'Agama_Siswa' => $siswa ? $siswa->Agama : '-',
                    'Ekstrakurikuler_Siswa' => $siswa && $siswa->ekstrakulikuler ? $siswa->ekstrakulikuler->Nama : '-',
                    
                    // Data Kelas
                    'Kelas' => $siswa && $siswa->kelas ? $siswa->kelas->Nama_Kelas : '-',
                    
                    // Data Orang Tua
                    'Nama_OrangTua' => $orangTua ? $orangTua->Nama : '-',
                    'Email_OrangTua' => $orangTua ? $orangTua->Email : '-',
                    'No_Telepon_OrangTua' => $orangTua ? $orangTua->No_Telepon : '-',
                    'Alamat_OrangTua' => $orangTua ? $orangTua->Alamat : '-'
                ];
            })
        ]);
    }
}