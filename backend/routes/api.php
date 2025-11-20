<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController; 
use App\Http\Controllers\Auth\UniversalLoginController;

// LOGIN
Route::post('/login', [UniversalLoginController::class, 'login']);




