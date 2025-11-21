<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController; 
use App\Http\Controllers\ProfilController;
use App\Http\Controllers\Auth\UniversalLoginController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// LOGIN
Route::post('/login', [UniversalLoginController::class, 'login']);

// SEMUA ROUTE PROFIL
Route::get('/profil-new', [ProfilController::class, 'getProfil']);
Route::post('/profil/update-anak', [ProfilController::class, 'updateAnak']);
Route::post('/profil/update-ortu', [ProfilController::class, 'updateOrtu']);

Route::options('/{any}', function () {
    return response()->json([]);
})->where('any', '.*');