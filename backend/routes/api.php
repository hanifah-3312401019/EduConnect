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
use App\Http\Controllers\Api\AgendaGuruController;
use App\Http\Controllers\Api\AgendaOrtuController;
use App\Http\Controllers\Api\PerizinanOrtuController;
use App\Http\Controllers\Api\PerizinanGuruController;
use App\Http\Controllers\Api\NotifikasiController;

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

// ADMIN WEBSITE
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/admin/profile', [AdminController::class, 'getProfile']);
    
    // ADMIN - Orang Tua
    Route::post('/admin/orangtua/create', [AdminController::class, 'createOrangTua']);
    Route::get('/admin/orangtua/list', [AdminController::class, 'getAllOrangTua']);
    Route::put('/admin/orangtua/update/{id}', [AdminController::class, 'updateOrangTua']);
    Route::delete('/admin/orangtua/delete/{id}', [AdminController::class, 'deleteOrangTua']);
});

// ADMIN - Guru
Route::post('/admin/guru/create', [AdminController::class, 'createGuru']);
Route::get('/admin/guru/list', [AdminController::class, 'getAllGuru']);
Route::get('/admin/guru/detail/{id}', [AdminController::class, 'getGuruDetail']);
Route::put('/admin/guru/update/{id}', [AdminController::class, 'updateGuru']);
Route::delete('/admin/guru/delete/{id}', [AdminController::class, 'deleteGuru']);
Route::get('/admin/guru/kelas-list', [AdminController::class, 'getKelasListForGuru']);

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
    Route::prefix('guru')->group(function () {
        Route::get('/perizinan', [PerizinanGuruController::class, 'index']);
    });
});

// Handle OPTIONS request untuk CORS
Route::options('/{any}', function () {
    return response()->json([]);
})->where('any', '.*');