<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Perizinan;
use App\Models\Siswa;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class PerizinanOrtuController extends Controller
{
    public function store(Request $request)
    {
        try {
            $user = Auth::user();
            
            // Ambil OrangTua_Id (bisa dari property atau primary key)
            $orangTuaId = $user->OrangTua_Id ?? $user->getKey();

            $validator = Validator::make($request->all(), [
                'Siswa_Id' => 'required|exists:siswa,Siswa_Id',
                'Jenis' => 'required|in:Sakit,Acara Keluarga,Lainnya',
                'Keterangan' => 'required|string|min:10',
                'Tanggal_Izin' => 'required|date|after_or_equal:today',
                'Bukti' => 'required|file|mimes:jpg,jpeg,png,pdf|max:102040'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false, 
                    'message' => 'Validasi gagal',
                    'errors' => $validator->errors()
                ], 422);
            }

            $siswa = Siswa::where('Siswa_Id', $request->Siswa_Id)
                          ->where('OrangTua_Id', $orangTuaId)
                          ->first();

            if (!$siswa) {
                return response()->json([
                    'success' => false, 
                    'message' => 'Siswa tidak ditemukan atau bukan anak Anda.'
                ], 404);
            }

            $file = $request->file('Bukti');
            $originalName = $file->getClientOriginalName();
            $extension = $file->getClientOriginalExtension();
            $safeName = preg_replace('/[^A-Za-z0-9\-\_\.]/', '_', pathinfo($originalName, PATHINFO_FILENAME));
            $fileName = time() . '_' . uniqid() . '_' . $safeName . '.' . $extension;
            
            $path = $file->storeAs('bukti_perizinan', $fileName, 'public');

            $perizinan = Perizinan::create([
                'Siswa_Id' => $request->Siswa_Id,
                'OrangTua_Id' => $orangTuaId,
                'Jenis' => $request->Jenis,
                'Keterangan' => trim($request->Keterangan),
                'Tanggal_Izin' => $request->Tanggal_Izin,
                'Bukti' => $path,
                'Nama_Berkas' => $originalName,
                'Tanggal_Pengajuan' => now(),
                'Status_Pembacaan' => 'Belum Dibaca'
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Perizinan berhasil dikirim!',
                'data' => [
                    'Id_Perizinan' => $perizinan->Id_Perizinan,
                    'Jenis' => $perizinan->Jenis,
                    'Keterangan' => $perizinan->Keterangan,
                    'Tanggal_Izin' => $perizinan->Tanggal_Izin->format('d/m/Y'),
                    'Tanggal_Pengajuan' => $perizinan->Tanggal_Pengajuan->format('d/m/Y H:i'),
                    'Nama_Berkas' => $perizinan->Nama_Berkas,
                    'Bukti_URL' => asset('storage/' . $perizinan->Bukti),
                    'Status_Pembacaan' => $perizinan->Status_Pembacaan
                ]
            ], 201);

        } catch (\Exception $e) {
            if (isset($path) && Storage::disk('public')->exists($path)) {
                Storage::disk('public')->delete($path);
            }
            
            Log::error('Error perizinan: ' . $e->getMessage());
            
            return response()->json([
                'success' => false, 
                'message' => 'Gagal mengirim perizinan',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error'
            ], 500);
        }
    }

    public function getAnak()
    {
        try {
            $user = Auth::user();
            
            // Ambil OrangTua_Id (bisa dari property atau primary key)
            $orangTuaId = $user->OrangTua_Id ?? $user->getKey();

            Log::info('=== GET ANAK DEBUG ===');
            Log::info('Model: ' . get_class($user));
            Log::info('OrangTua_Id: ' . $orangTuaId);
            Log::info('Primary Key: ' . $user->getKey());

            $anak = Siswa::with(['kelas', 'ekstrakulikuler'])
                        ->where('OrangTua_Id', $orangTuaId)
                        ->get();

            Log::info('Jumlah anak: ' . $anak->count());

            if ($anak->isEmpty()) {
                $totalSiswa = Siswa::count();
                
                // Lihat semua OrangTua_Id yang ada
                $allOrangTuaIds = Siswa::select('OrangTua_Id')->distinct()->pluck('OrangTua_Id');
                Log::info('OrangTua_Id yang ada: ' . $allOrangTuaIds->implode(', '));
                
                return response()->json([
                    'success' => true,
                    'message' => 'Belum ada data anak',
                    'data' => [],
                    'debug' => [
                        'your_orangtua_id' => $orangTuaId,
                        'total_siswa' => $totalSiswa,
                        'orangtua_ids_in_db' => $allOrangTuaIds->toArray(),
                        'hint' => 'Jalankan: UPDATE siswa SET OrangTua_Id = ' . $orangTuaId . ' WHERE Siswa_Id = 1'
                    ]
                ]);
            }

            return response()->json([
                'success' => true,
                'data' => $anak->map(function ($item) {
                    return [
                        'Siswa_Id' => $item->Siswa_Id,
                        'Nama' => $item->Nama,
                        'Jenis_Kelamin' => $item->Jenis_Kelamin,
                        'Tanggal_Lahir' => $item->Tanggal_Lahir ? $item->Tanggal_Lahir->format('d/m/Y') : null,
                        'Alamat' => $item->Alamat,
                        'Agama' => $item->Agama,
                        'Ekstrakurikuler' => $item->ekstrakulikuler ? $item->ekstrakulikuler->Nama : null,
                        'Kelas' => $item->kelas ? $item->kelas->Nama_Kelas : '-'
                    ];
                })
            ]);
        } catch (\Exception $e) {
            Log::error('Error getAnak: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
                'trace' => config('app.debug') ? $e->getTraceAsString() : null
            ], 500);
        }
    }

    public function index()
    {
        try {
            $user = Auth::user();
            
            // Ambil OrangTua_Id
            $orangTuaId = $user->OrangTua_Id ?? $user->getKey();

            $perizinan = Perizinan::with(['siswa.kelas'])
                ->where('OrangTua_Id', $orangTuaId)
                ->orderBy('Tanggal_Pengajuan', 'DESC')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $perizinan->map(function ($item) {
                    return [
                        'Id_Perizinan' => $item->Id_Perizinan,
                        'Jenis' => $item->Jenis,
                        'Keterangan' => $item->Keterangan,
                        'Bukti' => $item->Bukti ? asset('storage/' . $item->Bukti) : null,
                        'Nama_Berkas' => $item->Nama_Berkas,
                        'Tanggal_Pengajuan' => $item->Tanggal_Pengajuan->format('d/m/Y H:i'),
                        'Tanggal_Izin' => $item->Tanggal_Izin->format('d/m/Y'),
                        'Status_Pembacaan' => $item->Status_Pembacaan,
                        'Nama_Siswa' => $item->siswa ? $item->siswa->Nama : '-',
                        'Kelas' => $item->siswa && $item->siswa->kelas ? $item->siswa->kelas->Nama_Kelas : '-'
                    ];
                })
            ]);
        } catch (\Exception $e) {
            Log::error('Error index perizinan: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data perizinan'
            ], 500);
        }
    }
}