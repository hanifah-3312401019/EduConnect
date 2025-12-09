<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Agenda;
use App\Models\Guru;
use App\Models\Kelas;
use App\Models\Ekstrakulikuler;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AgendaGuruController extends Controller
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

        $guru = Guru::find($guruId);
        if (!$guru) {
            return response()->json([
                'success' => false,
                'message' => 'Guru tidak ditemukan'
            ], 404);
        }

        return $guruId;
    }

    // Get semua agenda guru dengan filter tipe
    public function index(Request $request)
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $query = Agenda::where('Guru_Id', $guruId)
            ->with(['guru', 'kelas', 'ekstrakulikuler'])
            ->orderBy('Tanggal', 'desc')
            ->orderBy('Waktu_Mulai', 'desc');

        // Filter by tipe jika ada
        if ($request->has('tipe') && $request->tipe) {
            $query->where('Tipe', $request->tipe);
        }

        $agenda = $query->get();

        return response()->json([
            'success' => true,
            'data' => $agenda
        ]);
    }

    // Buat agenda baru
    public function store(Request $request)
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $validator = Validator::make($request->all(), [
            'Judul' => 'required|string|max:255',
            'Deskripsi' => 'required|string',
            'Tanggal' => 'required|date',
            'Waktu_Mulai' => 'required|date_format:H:i',
            'Waktu_Selesai' => 'required|date_format:H:i',
            'Tipe' => 'required|in:sekolah,perkelas,ekskul',
            'Ekstrakulikuler_Id' => 'nullable|required_if:Tipe,ekskul|exists:ekstrakulikuler,Ekstrakulikuler_Id',
        ], [
            'Waktu_Mulai.date_format' => 'Format waktu harus HH:MM (contoh: 08:00)',
            'Waktu_Selesai.date_format' => 'Format waktu harus HH:MM (contoh: 10:00)',
            'Ekstrakulikuler_Id.required_if' => 'Pilih ekstrakurikuler untuk agenda ekskul',
        ]);

        // Validasi tambahan
        $validator->after(function ($validator) use ($request, $guruId) {
            // Validasi waktu selesai > waktu mulai
            if ($request->Waktu_Mulai && $request->Waktu_Selesai) {
                if (strtotime($request->Waktu_Selesai) <= strtotime($request->Waktu_Mulai)) {
                    $validator->errors()->add('Waktu_Selesai', 'Waktu selesai harus setelah waktu mulai.');
                }
            }
        });

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        // Prepare data berdasarkan tipe
        $data = [
            'Guru_Id' => $guruId,
            'Judul' => $request->Judul,
            'Deskripsi' => $request->Deskripsi,
            'Tanggal' => $request->Tanggal,
            'Waktu_Mulai' => $request->Waktu_Mulai,
            'Waktu_Selesai' => $request->Waktu_Selesai,
            'Tipe' => $request->Tipe,
        ];

        // Handle berdasarkan tipe
        switch ($request->Tipe) {
            case 'sekolah':
                // Untuk sekolah: Kelas_Id NULL
                $data['Kelas_Id'] = null;
                $data['Ekstrakulikuler_Id'] = null;
                break;
                
            case 'perkelas':
                // Untuk perkelas: pakai kelas guru jika ada, jika tidak error
                $kelasGuru = Kelas::where('Guru_Id', $guruId)->first();
                if (!$kelasGuru) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Anda belum memiliki kelas. Tidak dapat membuat agenda kelas.'
                    ], 400);
                }
                $data['Kelas_Id'] = $kelasGuru->Kelas_Id;
                $data['Ekstrakulikuler_Id'] = null;
                break;
                
            case 'ekskul':
                // Untuk ekskul: pakai kelas guru jika ada, jika tidak error
                $kelasGuru = Kelas::where('Guru_Id', $guruId)->first();
                if (!$kelasGuru) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Anda belum memiliki kelas. Tidak dapat membuat agenda ekskul.'
                    ], 400);
                }
                $data['Kelas_Id'] = $kelasGuru->Kelas_Id;
                $data['Ekstrakulikuler_Id'] = $request->Ekstrakulikuler_Id;
                break;
        }

        $agenda = Agenda::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Agenda berhasil dibuat',
            'data' => $agenda->load(['guru', 'kelas', 'ekstrakulikuler'])
        ], 201);
    }

    // Update agenda
    public function update(Request $request, $id)
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $agenda = Agenda::where('Agenda_Id', $id)
            ->where('Guru_Id', $guruId)
            ->first();

        if (!$agenda) {
            return response()->json([
                'success' => false,
                'message' => 'Agenda tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'Judul' => 'required|string|max:255',
            'Deskripsi' => 'required|string',
            'Tanggal' => 'required|date',
            'Waktu_Mulai' => 'required|date_format:H:i',
            'Waktu_Selesai' => 'required|date_format:H:i',
            'Tipe' => 'required|in:sekolah,perkelas,ekskul',
            'Ekstrakulikuler_Id' => 'nullable|required_if:Tipe,ekskul|exists:ekstrakulikuler,Ekstrakulikuler_Id',
        ], [
            'Waktu_Mulai.date_format' => 'Format waktu harus HH:MM (contoh: 08:00)',
            'Waktu_Selesai.date_format' => 'Format waktu harus HH:MM (contoh: 10:00)',
            'Ekstrakulikuler_Id.required_if' => 'Pilih ekstrakurikuler untuk agenda ekskul',
        ]);

        $validator->after(function ($validator) use ($request, $guruId) {
            // Validasi waktu selesai > waktu mulai
            if ($request->Waktu_Mulai && $request->Waktu_Selesai) {
                if (strtotime($request->Waktu_Selesai) <= strtotime($request->Waktu_Mulai)) {
                    $validator->errors()->add('Waktu_Selesai', 'Waktu selesai harus setelah waktu mulai.');
                }
            }
        });

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        // Prepare data berdasarkan tipe
        $data = [
            'Judul' => $request->Judul,
            'Deskripsi' => $request->Deskripsi,
            'Tanggal' => $request->Tanggal,
            'Waktu_Mulai' => $request->Waktu_Mulai,
            'Waktu_Selesai' => $request->Waktu_Selesai,
            'Tipe' => $request->Tipe,
        ];

        // Handle berdasarkan tipe
        switch ($request->Tipe) {
            case 'sekolah':
                // Untuk sekolah: Kelas_Id NULL
                $data['Kelas_Id'] = null;
                $data['Ekstrakulikuler_Id'] = null;
                break;
                
            case 'perkelas':
                // Untuk perkelas: pakai kelas guru jika ada, jika tidak error
                $kelasGuru = Kelas::where('Guru_Id', $guruId)->first();
                if (!$kelasGuru) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Anda belum memiliki kelas. Tidak dapat mengubah agenda menjadi tipe kelas.'
                    ], 400);
                }
                $data['Kelas_Id'] = $kelasGuru->Kelas_Id;
                $data['Ekstrakulikuler_Id'] = null;
                break;
                
            case 'ekskul':
                // Untuk ekskul: pakai kelas guru jika ada, jika tidak error
                $kelasGuru = Kelas::where('Guru_Id', $guruId)->first();
                if (!$kelasGuru) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Anda belum memiliki kelas. Tidak dapat mengubah agenda menjadi tipe ekskul.'
                    ], 400);
                }
                $data['Kelas_Id'] = $kelasGuru->Kelas_Id;
                $data['Ekstrakulikuler_Id'] = $request->Ekstrakulikuler_Id;
                break;
        }

        $agenda->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Agenda berhasil diupdate',
            'data' => $agenda->load(['guru', 'kelas', 'ekstrakulikuler'])
        ]);
    }

    // Hapus agenda
    public function destroy($id)
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        $agenda = Agenda::where('Agenda_Id', $id)
            ->where('Guru_Id', $guruId)
            ->first();

        if (!$agenda) {
            return response()->json([
                'success' => false,
                'message' => 'Agenda tidak ditemukan'
            ], 404);
        }

        $agenda->delete();

        return response()->json([
            'success' => true,
            'message' => 'Agenda berhasil dihapus'
        ]);
    }

    // Get dropdown data (kelas, ekskul)
    public function getDropdownData()
    {
        $guruId = $this->getGuruId();
        
        if ($guruId instanceof \Illuminate\Http\JsonResponse) {
            return $guruId;
        }

        // Ambil kelas guru (1 guru = 1 kelas)
        $kelasGuru = Kelas::where('Guru_Id', $guruId)->first();
        
        // Ambil SEMUA ekskul di sekolah (untuk dropdown ekskul)
        $semuaEkskul = Ekstrakulikuler::orderBy('nama')->get();

        return response()->json([
            'success' => true,
            'data' => [
                // Kelas guru (bisa null jika guru belum punya kelas)
                'kelas_guru' => $kelasGuru ? [
                    'Kelas_Id' => $kelasGuru->Kelas_Id,
                    'nama_kelas' => $kelasGuru->Nama_Kelas
                ] : null,

                // Semua ekskul sekolah (untuk dropdown ekskul)
                'ekstrakulikuler' => $semuaEkskul->map(function($ekskul) {
                    return [
                        'Ekstrakulikuler_Id' => $ekskul->Ekstrakulikuler_Id,
                        'nama' => $ekskul->nama // sesuai field di database
                    ];
                })->toArray()
            ]
        ]);
    }
}