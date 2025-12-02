<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController; 
use App\Http\Controllers\ProfilController;
use App\Http\Controllers\Auth\UniversalLoginController;
use App\Http\Controllers\Api\AdminController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// LOGIN
Route::post('/login', [UniversalLoginController::class, 'login']);
Route::post('/logout', [UniversalLoginController::class, 'logout']);

// SEMUA ROUTE PROFIL
Route::get('/profil-new', [ProfilController::class, 'getProfil']);
Route::post('/profil/update-anak', [ProfilController::class, 'updateAnak']);
Route::post('/profil/update-ortu', [ProfilController::class, 'updateOrtu']);

// ADMIN WEBSITE
Route::get('/admin/profile', [AdminController::class, 'getProfile']);

// ADMIN - Tambah Orang Tua
Route::post('/admin/orangtua/create', [AdminController::class, 'createOrangTua']);

// ADMIN - Ambil Semua Orang Tua
Route::get('/admin/orangtua/list', [AdminController::class, 'getAllOrangTua']);


Route::options('/{any}', function () {
    return response()->json([]);
})->where('any', '.*');
