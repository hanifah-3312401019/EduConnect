<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pengumuman;
use App\Models\Guru;
use App\Models\Kelas;
use App\Models\Siswa;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class PengumumanGuruController extends Controller
{
    // Helper method untuk mendapatkan Guru_Id dari header
    private function getGuruId()
    {
        $guruId = request()->header('Guru_Id');
        
        if (!$guruId) {
            return response()->json([
                'success' => false,
                'message' => 'Guru_ID header diperlukan'
            ], 400);
        }

        // Validasi guru exists
        $guru = Guru::find($guruId);
        if (!$guru) {
            return response()->json([
                'success' => false,
                'message' => 'Guru tidak ditemukan'
            ], 404);
        }

        return $guruId;
    }

    public function getKelasSaya()
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $kelas = Kelas::where('Guru_Id', $guruId)->get();

        if ($kelas->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki kelas'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $kelas
        ]);
    }

    public function getSiswaKelasSaya()
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $kelas = Kelas::where('Guru_Id', $guruId)->get();

        if ($kelas->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki kelas'
            ], 404);
        }

        $kelasIds = $kelas->pluck('Kelas_Id')->toArray();

        $siswa = Siswa::whereIn('Kelas_Id', $kelasIds)
            ->orderBy('Nama')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $siswa
        ]);
    }

    public function index(Request $request)
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $pengumuman = Pengumuman::where('Guru_Id', $guruId)
            ->with(['guru', 'kelas', 'siswa'])
            ->orderBy('Tanggal', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $pengumuman
        ]);
    }

    public function store(Request $request)
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $kelasGuruList = Kelas::where('Guru_Id', $guruId)->get();
        
        $validator = Validator::make($request->all(), [
            'Judul' => 'required|string|max:255',
            'Isi' => 'required|string',
            'Tipe' => ['required', Rule::in(['umum', 'perkelas', 'personal'])],
            'Tanggal' => 'required|date'
        ], [
            'Tipe.in' => 'Tipe harus berupa: umum, perkelas, atau personal',
        ]);

        if ($request->Tipe === 'perkelas') {
            // Validasi: hanya jika guru punya kelas
            if ($kelasGuruList->isEmpty()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Anda tidak memiliki kelas untuk membuat pengumuman perkelas'
                ], 422);
            }
            
            $validator->addRules([
                'Kelas_Id' => [
                    'required',
                    'exists:kelas,Kelas_Id',
                    function ($attribute, $value, $fail) use ($kelasGuruList) {
                        // Validasi bahwa kelas tersebut dimiliki guru
                        $kelasMilikGuru = $kelasGuruList->contains('Kelas_Id', $value);
                        
                        if (!$kelasMilikGuru) {
                            $fail('Kelas tersebut tidak dimiliki oleh Anda.');
                        }
                    }
                ]
            ]);
            
        } elseif ($request->Tipe === 'personal') {
            // Validasi: hanya jika guru punya kelas
            if ($kelasGuruList->isEmpty()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Anda tidak memiliki kelas untuk membuat pengumuman personal'
                ], 422);
            }
            
            $validator->addRules([
                'Siswa_Id' => [
                    'required',
                    'exists:siswa,Siswa_Id',
                    function ($attribute, $value, $fail) use ($kelasGuruList) {
                        // Validasi bahwa siswa tersebut berada di kelas guru
                        $siswa = Siswa::find($value);
                        
                        if (!$siswa) {
                            $fail('Siswa tidak ditemukan.');
                            return;
                        }
                        
                        $kelasMilikGuru = $kelasGuruList->contains('Kelas_Id', $siswa->Kelas_Id);
                        
                        if (!$kelasMilikGuru) {
                            $fail('Siswa tersebut tidak berada di kelas Anda.');
                        }
                    }
                ]
            ]);
        }

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = [
            'Guru_Id' => $guruId,
            'Judul' => $request->Judul,
            'Isi' => $request->Isi,
            'Tipe' => strtolower($request->Tipe),
            'Tanggal' => $request->Tanggal
        ];

        if ($request->Tipe === 'perkelas') {
            $data['Kelas_Id'] = $request->Kelas_Id;
            $data['Siswa_Id'] = null;
        } 
        elseif ($request->Tipe === 'personal') {
            $data['Siswa_Id'] = $request->Siswa_Id;
            // Ambil kelas_id dari siswa
            $siswa = Siswa::find($request->Siswa_Id);
            $data['Kelas_Id'] = $siswa->Kelas_Id;
        } 
        else { // Tipe umum
            $data['Kelas_Id'] = null;
            $data['Siswa_Id'] = null;
        }

        $pengumuman = Pengumuman::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Pengumuman berhasil dibuat',
            'data' => $pengumuman->load(['guru', 'kelas', 'siswa'])
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $pengumuman = Pengumuman::where('Pengumuman_Id', $id)
            ->where('Guru_Id', $guruId)
            ->first();

        if (!$pengumuman) {
            return response()->json([
                'success' => false,
                'message' => 'Pengumuman tidak ditemukan'
            ], 404);
        }

        $kelasGuruList = Kelas::where('Guru_Id', $guruId)->get();

        $validator = Validator::make($request->all(), [
            'Judul' => 'required|string|max:255',
            'Isi' => 'required|string',
            'Tipe' => ['required', Rule::in(['umum', 'perkelas', 'personal'])],
            'Tanggal' => 'required|date'
        ]);

        if ($request->Tipe === 'perkelas') {
            if ($kelasGuruList->isEmpty()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Anda tidak memiliki kelas untuk mengupdate pengumuman perkelas'
                ], 422);
            }
            
            $validator->addRules([
                'Kelas_Id' => [
                    'required',
                    'exists:kelas,Kelas_Id',
                    function ($attribute, $value, $fail) use ($kelasGuruList) {
                        $kelasMilikGuru = $kelasGuruList->contains('Kelas_Id', $value);
                        
                        if (!$kelasMilikGuru) {
                            $fail('Kelas tersebut tidak dimiliki oleh Anda.');
                        }
                    }
                ]
            ]);
            
        } elseif ($request->Tipe === 'personal') {
            if ($kelasGuruList->isEmpty()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Anda tidak memiliki kelas untuk mengupdate pengumuman personal'
                ], 422);
            }
            
            $validator->addRules([
                'Siswa_Id' => [
                    'required',
                    'exists:siswa,Siswa_Id',
                    function ($attribute, $value, $fail) use ($kelasGuruList) {
                        $siswa = Siswa::find($value);
                        
                        if (!$siswa) {
                            $fail('Siswa tidak ditemukan.');
                            return;
                        }
                        
                        $kelasMilikGuru = $kelasGuruList->contains('Kelas_Id', $siswa->Kelas_Id);
                        
                        if (!$kelasMilikGuru) {
                            $fail('Siswa tersebut tidak berada di kelas Anda.');
                        }
                    }
                ]
            ]);
        }

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $updateData = [
            'Judul' => $request->Judul,
            'Isi' => $request->Isi,
            'Tipe' => strtolower($request->Tipe),
            'Tanggal' => $request->Tanggal
        ];

        if ($request->Tipe === 'perkelas') {
            $updateData['Kelas_Id'] = $request->Kelas_Id;
            $updateData['Siswa_Id'] = null;
        } 
        elseif ($request->Tipe === 'personal') {
            $updateData['Siswa_Id'] = $request->Siswa_Id;
            $siswa = Siswa::find($request->Siswa_Id);
            $updateData['Kelas_Id'] = $siswa->Kelas_Id;
        } 
        else { 
            $updateData['Kelas_Id'] = null;
            $updateData['Siswa_Id'] = null;
        }

        $pengumuman->update($updateData);

        return response()->json([
            'success' => true,
            'message' => 'Pengumuman berhasil diupdate',
            'data' => $pengumuman->load(['guru', 'kelas', 'siswa'])
        ]);
    }

    public function destroy($id)
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $pengumuman = Pengumuman::where('Pengumuman_Id', $id)
            ->where('Guru_Id', $guruId)
            ->first();

        if (!$pengumuman) {
            return response()->json([
                'success' => false,
                'message' => 'Pengumuman tidak ditemukan'
            ], 404);
        }

        $pengumuman->delete();

        return response()->json([
            'success' => true,
            'message' => 'Pengumuman berhasil dihapus'
        ]);
    }

    public function getDropdownData()
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $kelasGuru = Kelas::where('Guru_Id', $guruId)->get();
        
        $kelasData = [];
        $siswaData = [];
        
        if ($kelasGuru->isNotEmpty()) {
            $kelasData = $kelasGuru;
            
            $kelasIds = $kelasGuru->pluck('Kelas_Id')->toArray();
            
            $siswaData = Siswa::whereIn('Kelas_Id', $kelasIds)
                ->orderBy('Nama')
                ->get();
        }

        return response()->json([
            'success' => true,
            'data' => [
                'kelas' => $kelasData,
                'siswa' => $siswaData
            ]
        ]);
    }
}