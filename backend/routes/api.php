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

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// LOGIN
Route::post('/login', [UniversalLoginController::class, 'login']);
Route::post('/logout', [UniversalLoginController::class, 'logout']);

// SEMUA ROUTE PROFIL
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/profil-new', [ProfilController::class, 'getProfil']);
    Route::post('/profil/update-anak', [ProfilController::class, 'updateAnak']);
    Route::post('/profil/update-ortu', [ProfilController::class, 'updateOrtu']);
});

Route::get('/ekstrakulikuler', [EkskulController::class, 'index']);

// ADMIN WEBSITE
Route::get('/admin/profile', [AdminController::class, 'getProfile']);

// ADMIN - Tambah Orang Tua
Route::post('/admin/orangtua/create', [AdminController::class, 'createOrangTua']);

// ADMIN - Ambil Semua Orang Tua
Route::get('/admin/orangtua/list', [AdminController::class, 'getAllOrangTua']);

// ROUTE PENGUMUMAN GURU
Route::get('/guru/pengumuman', [PengumumanGuruController::class, 'index']);
Route::post('/guru/pengumuman', [PengumumanGuruController::class, 'store']);
Route::put('/guru/pengumuman/{id}', [PengumumanGuruController::class, 'update']);
Route::delete('/guru/pengumuman/{id}', [PengumumanGuruController::class, 'destroy']);
Route::get('/guru/pengumuman/dropdown-data', [PengumumanGuruController::class, 'getDropdownData']);
Route::get('/guru/kelas-saya', [PengumumanGuruController::class, 'getKelasSaya'])->middleware('auth:sanctum');
Route::get('/guru/siswa-kelas-saya', [PengumumanGuruController::class, 'getSiswaKelasSaya'])->middleware('auth:sanctum');

// ROUTE PENGUMUMAN ORTU
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/orangtua/pengumuman/{kategori?}', [PengumumanOrtuController::class, 'showByKategori']);
});

// ROUTE AGENDA GURU
Route::prefix('guru')->group(function () {
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

Route::options('/{any}', function () {
    return response()->json([]);
})->where('any', '.*');
