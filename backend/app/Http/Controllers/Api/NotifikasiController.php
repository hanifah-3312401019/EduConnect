<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notifikasi;
use App\Models\OrangTua;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;

class NotifikasiController extends Controller
{
    // Get semua notifikasi untuk orangtua yang login
    public function getNotificationsForOrtu(Request $request)
    {
        try {
            $user = Auth::user();
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 401);
            }

            $orangtua = $user;
            
            if (!$orangtua instanceof OrangTua) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak terdaftar sebagai orangtua'
                ], 403);
            }

            $notifications = Notifikasi::with(['agenda', 'pengumuman'])
                ->where('OrangTua_Id', $orangtua->OrangTua_Id)
                ->orderBy('created_at', 'desc')
                ->get()
                ->map(function($notif) {
                    $data = $notif->toArray();
                    
                    // Tambahkan info tipe dari relasi
                    if ($notif->agenda) {
                        $data['tipe'] = $notif->agenda->Tipe ?? null;
                        $data['target_id'] = $notif->agenda->Agenda_Id ?? null;
                    } else if ($notif->pengumuman) {
                        $data['tipe'] = $notif->pengumuman->Tipe ?? null;
                        $data['target_id'] = $notif->pengumuman->Pengumuman_Id ?? null;
                    } else {
                        $data['tipe'] = null;
                        $data['target_id'] = null;
                    }
                    
                    $data['created_at_formatted'] = $notif->created_at->format('Y-m-d H:i:s');
                    $data['created_at_human'] = $notif->created_at->diffForHumans();
                    
                    return $data;
                });

            $unreadCount = Notifikasi::where('OrangTua_Id', $orangtua->OrangTua_Id)
                ->where('dibaca', false)
                ->count();

            return response()->json([
                'success' => true,
                'data' => [
                    'notifications' => $notifications,
                    'unread_count' => $unreadCount,
                    'total' => $notifications->count(),
                    'orangtua_info' => [
                        'id' => $orangtua->OrangTua_Id,
                        'nama' => $orangtua->Nama,
                        'email' => $orangtua->Email
                    ]
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Error get notifications for ortu: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    public function markAsRead(Request $request, $id)
    {
        try {
            $user = Auth::user();
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 401);
            }

            $orangtua = $user;
            
            if (!$orangtua instanceof OrangTua) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak terdaftar sebagai orangtua'
                ], 403);
            }

            $notifikasi = Notifikasi::find($id);
            
            if (!$notifikasi) {
                return response()->json([
                    'success' => false,
                    'message' => 'Notifikasi tidak ditemukan'
                ], 404);
            }

            if ($notifikasi->OrangTua_Id != $orangtua->OrangTua_Id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Akses ditolak. Notifikasi ini bukan milik Anda.'
                ], 403);
            }

            $notifikasi->update(['dibaca' => true]);

            return response()->json([
                'success' => true,
                'message' => 'Notifikasi ditandai sebagai dibaca',
                'data' => $notifikasi->fresh()
            ]);

        } catch (\Exception $e) {
            Log::error('Error mark as read: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    // Tandai semua notifikasi sebagai dibaca
    public function markAllAsRead(Request $request)
    {
        try {
            $user = Auth::user();
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 401);
            }

            $orangtua = $user;
            
            if (!$orangtua instanceof OrangTua) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak terdaftar sebagai orangtua'
                ], 403);
            }

            $updated = Notifikasi::where('OrangTua_Id', $orangtua->OrangTua_Id)
                ->where('dibaca', false)
                ->update(['dibaca' => true]);

            return response()->json([
                'success' => true,
                'message' => $updated . ' notifikasi ditandai sebagai dibaca'
            ]);

        } catch (\Exception $e) {
            Log::error('Error mark all as read: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    // Get jumlah notifikasi belum dibaca (untuk badge)
    public function getUnreadCount(Request $request)
    {
        try {
            $user = Auth::user();
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 401);
            }

            $orangtua = $user;
            
            if (!$orangtua instanceof OrangTua) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak terdaftar sebagai orangtua'
                ], 403);
            }

            $unreadCount = Notifikasi::where('OrangTua_Id', $orangtua->OrangTua_Id)
                ->where('dibaca', false)
                ->count();

            return response()->json([
                'success' => true,
                'data' => [
                    'unread_count' => $unreadCount,
                    'orangtua_id' => $orangtua->OrangTua_Id
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Error get unread count: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    // API untuk delete notifikasi
    public function deleteNotification($id)
    {
        try {
            $user = Auth::user();
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 401);
            }

            $orangtua = $user;
            
            if (!$orangtua instanceof OrangTua) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak terdaftar sebagai orangtua'
                ], 403);
            }

            $notifikasi = Notifikasi::where('Notifikasi_Id', $id)
                ->where('OrangTua_Id', $orangtua->OrangTua_Id)
                ->first();

            if (!$notifikasi) {
                return response()->json([
                    'success' => false,
                    'message' => 'Notifikasi tidak ditemukan'
                ], 404);
            }

            $notifikasi->delete();

            return response()->json([
                'success' => true,
                'message' => 'Notifikasi berhasil dihapus'
            ]);

        } catch (\Exception $e) {
            Log::error('Error delete notification: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    public function clearAllNotifications(Request $request)
    {
        try {
            $user = Auth::user();
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 401);
            }

            $orangtua = $user;
            
            if (!$orangtua instanceof OrangTua) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak terdaftar sebagai orangtua'
                ], 403);
            }

            $deleted = Notifikasi::where('OrangTua_Id', $orangtua->OrangTua_Id)
                ->delete();

            return response()->json([
                'success' => true,
                'message' => $deleted . ' notifikasi berhasil dihapus'
            ]);

        } catch (\Exception $e) {
            Log::error('Error clear all notifications: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }
}