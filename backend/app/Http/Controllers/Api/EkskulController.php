<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Ekstrakulikuler;

class EkskulController extends Controller
{
    public function index()
    {
        return response()->json(Ekstrakulikuler::all());
    }
}
