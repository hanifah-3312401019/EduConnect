<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\UserController; 
use App\Http\Controllers\Api\ProfilController;
use App\Http\Controllers\Api\EkskulController;
use App\Http\Controllers\Auth\UniversalLoginController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\PengumumanGuruController;
use App\Http\Controllers\Api\PengumumanOrtuController;
use App\Http\Controllers\Api\PembayaranController;
use App\Http\Controllers\Api\AgendaGuruController;
use App\Http\Controllers\Api\AgendaOrtuController;
use App\Http\Controllers\Api\PerizinanOrtuController;
use App\Http\Controllers\Api\PerizinanGuruController;
use App\Http\Controllers\Api\NotifikasiController;
use App\Http\Controllers\Api\JadwalPelajaranController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// LOGIN
Route::post('/login', [UniversalLoginController::class, 'login']);
Route::post('/logout', [UniversalLoginController::class, 'logout'])->middleware('auth:sanctum');

// SEMUA ROUTE PROFIL
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/profil-new', [ProfilController::class, 'getProfil']);
    Route::post('/profil/update-anak', [ProfilController::class, 'updateAnak']);
    Route::post('/profil/update-ortu', [ProfilController::class, 'updateOrtu']);
});

Route::get('/ekstrakulikuler', [EkskulController::class, 'index']);

// ROUTE PEMBAYARAN ORANG TUA
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/orangtua/pembayaran', [PembayaranController::class, 'pembayaranOrangtua']);
});

// ADMIN WEBSITE
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/admin/profile', [AdminController::class, 'getProfile']);
    
    // ADMIN - Orang Tua
    Route::post('/admin/orangtua/create', [AdminController::class, 'createOrangTua']);
    Route::get('/admin/orangtua/list', [AdminController::class, 'getAllOrangTua']);
    Route::put('/admin/orangtua/update/{id}', [AdminController::class, 'updateOrangTua']);
    Route::delete('/admin/orangtua/delete/{id}', [AdminController::class, 'deleteOrangTua']);

    // Admin - Siswa
    Route::get('/admin/siswa', [AdminController::class, 'getAllSiswa']);
    Route::get('/admin/siswa/{id}', [AdminController::class, 'getSiswaDetail']);
    Route::post('/admin/siswa', [AdminController::class, 'createSiswa']);
    Route::put('/admin/siswa/{id}', [AdminController::class, 'updateSiswa']);
    Route::delete('/admin/siswa/{id}', [AdminController::class, 'deleteSiswa']); 
    Route::delete('/admin/siswa/{id}/force', [AdminController::class, 'forceDeleteSiswa']); // Force delete

    // ADMIN - Pembayaran
    Route::get('admin/pembayaran', [PembayaranController::class, 'index']);
    Route::post('admin/pembayaran', [PembayaranController::class, 'store']);
    Route::get('admin/pembayaran/{id}', [PembayaranController::class, 'show']);
    Route::put('admin/pembayaran/{id}', [PembayaranController::class, 'update']);
    Route::delete('admin/pembayaran/{id}', [PembayaranController::class, 'destroy']);

    // ADMIN - Guru
    Route::post('/admin/guru/create', [AdminController::class, 'createGuru']);
    Route::get('/admin/guru/list', [AdminController::class, 'getAllGuru']);
    Route::get('/admin/guru/detail/{id}', [AdminController::class, 'getGuruDetail']);
    Route::put('/admin/guru/update/{id}', [AdminController::class, 'updateGuru']);
    Route::delete('/admin/guru/delete/{id}', [AdminController::class, 'deleteGuru']);

    // ADMIN - Kelas
    Route::get('/admin/kelas/list', [AdminController::class, 'getAllKelas']);
    Route::post('/admin/kelas/create', [AdminController::class, 'createKelas']);
    Route::put('/admin/kelas/update/{id}', [AdminController::class, 'updateKelas']);
    Route::delete('/admin/kelas/delete/{id}', [AdminController::class, 'deleteKelas']);
    Route::get('/admin/guru/{id}/kelas', [AdminController::class, 'getGuruKelas']);
    
    // Get kelas list untuk dropdown
    Route::get('/admin/guru/kelas-list', [AdminController::class, 'getKelasListForGuru']);
    
    // Penugasan guru ke kelas (opsional, bisa digunakan untuk UI khusus)
    Route::post('/admin/guru/assign-kelas', [AdminController::class, 'assignGuruToKelas']);
    Route::post('/admin/guru/remove-kelas', [AdminController::class, 'removeGuruFromKelas']);
});

// ADMIN - Jadwal Pelajaran
Route::middleware('auth:sanctum')->group(function () {
    // CRUD Jadwal Pelajaran
    Route::get('/admin/jadwal/list', [JadwalPelajaranController::class, 'getAllJadwal']);
    Route::get('/admin/jadwal/kelas/{kelas_id}', [JadwalPelajaranController::class, 'getJadwalByKelas']);
    Route::post('/admin/jadwal/create', [JadwalPelajaranController::class, 'createJadwal']);
    Route::put('/admin/jadwal/update/{id}', [JadwalPelajaranController::class, 'updateJadwal']);
    Route::delete('/admin/jadwal/delete/{id}', [JadwalPelajaranController::class, 'deleteJadwal']);
    
    // Daftar mata pelajaran dropdown
    Route::get('/admin/mata-pelajaran/list', [JadwalPelajaranController::class, 'getMataPelajaranList']);
});

// ORANG TUA - Jadwal Pelajaran
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/orangtua/jadwal-pelajaran', [JadwalPelajaranController::class, 'getJadwalForOrangTua']);
});

// ADMIN DASHBOARD STATS
Route::middleware('auth:sanctum')->get('/admin/dashboard/stats', [AdminController::class, 'dashboardStats']);

// ROUTE PENGUMUMAN GURU
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/guru/pengumuman', [PengumumanGuruController::class, 'index']);
    Route::post('/guru/pengumuman', [PengumumanGuruController::class, 'store']);
    Route::put('/guru/pengumuman/{id}', [PengumumanGuruController::class, 'update']);
    Route::delete('/guru/pengumuman/{id}', [PengumumanGuruController::class, 'destroy']);
    Route::get('/guru/pengumuman/dropdown-data', [PengumumanGuruController::class, 'getDropdownData']);
    Route::get('/guru/kelas-saya', [PengumumanGuruController::class, 'getKelasSaya']);
    Route::get('/guru/siswa-kelas-saya', [PengumumanGuruController::class, 'getSiswaKelasSaya']);
});

// ROUTE PENGUMUMAN ORTU
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/orangtua/pengumuman/{kategori?}', [PengumumanOrtuController::class, 'showByKategori']);
});

// ROUTE AGENDA GURU
Route::middleware('auth:sanctum')->prefix('guru')->group(function () {
    Route::get('/agenda', [AgendaGuruController::class, 'index']);
    Route::post('/agenda', [AgendaGuruController::class, 'store']);
    Route::put('/agenda/{id}', [AgendaGuruController::class, 'update']);
    Route::delete('/agenda/{id}', [AgendaGuruController::class, 'destroy']);
    Route::get('/agenda/dropdown-data', [AgendaGuruController::class, 'getDropdownData']);
});

// ROUTE AGENDA ORANG TUA
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/orangtua/agenda/{kategori?}', [AgendaOrtuController::class, 'index']);
});

// Notifikasi orangtua
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/orangtua/notifikasi', [NotifikasiController::class, 'getNotificationsForOrtu']);
    Route::get('/orangtua/notifikasi/unread-count', [NotifikasiController::class, 'getUnreadCount']);
    Route::post('/notifikasi/{id}/read', [NotifikasiController::class, 'markAsRead']);
    Route::post('/notifikasi/mark-all-read', [NotifikasiController::class, 'markAllAsRead']);
    Route::delete('/notifikasi/{id}', [NotifikasiController::class, 'deleteNotification']);
    Route::delete('/notifikasi/clear-all', [NotifikasiController::class, 'clearAllNotifications']);
});

// ROUTE PERIZINAN ORANG TUA & GURU
Route::middleware('auth:sanctum')->group(function () {
    // Orang Tua
    Route::prefix('orangtua')->group(function () {
        Route::get('/perizinan/anak', [PerizinanOrtuController::class, 'getAnak']);
        Route::get('/perizinan', [PerizinanOrtuController::class, 'index']);
        Route::post('/perizinan', [PerizinanOrtuController::class, 'store']);
    });

    // Guru
    Route::middleware('auth:sanctum')->prefix('guru')->group(function () {
    Route::get('/perizinan', [PerizinanGuruController::class, 'index']);
});
});

// Handle OPTIONS request untuk CORS
Route::options('/{any}', function () {
    return response()->json([]);
})->where('any', '.*');