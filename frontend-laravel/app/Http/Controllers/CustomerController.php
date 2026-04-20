<?php

namespace App\Http\Controllers;

use App\Services\ApiService;
use Illuminate\Http\Request;

class CustomerController extends Controller
{
    protected ApiService $api;

    public function __construct(ApiService $api)
    {
        $this->api = $api;
    }

    /**
     * Dashboard pelanggan — pesanan aktif, riwayat, tracking.
     */
    public function dashboard(Request $request)
    {
        $token = session('auth_token');
        $result = $this->api->getOrders($token);
        $orders = $result['success'] ? $result['data'] : [];

        // Separate active and completed orders
        $activeOrders = array_filter($orders, fn($o) => in_array($o['status'], ['pending']));
        $historyOrders = array_filter($orders, fn($o) => in_array($o['status'], ['success', 'refund', 'cancelled']));

        $tab = $request->input('tab', 'active');

        return view('customer.dashboard', compact('activeOrders', 'historyOrders', 'tab'));
    }

    /**
     * Upload bukti pembayaran.
     */
    public function uploadProof(string $orderId)
    {
        $token = session('auth_token');
        $result = $this->api->uploadProof($token, $orderId);

        if (!$result['success']) {
            return back()->with('error', 'Gagal mengunggah bukti pembayaran.');
        }

        return back()->with('success', 'Bukti pembayaran berhasil diunggah.');
    }

    /**
     * Lacak pesanan berdasarkan ID.
     */
    public function trackOrder(Request $request)
    {
        $token = session('auth_token');
        $orderId = $request->input('order_id');
        $order = null;

        if ($orderId) {
            $result = $this->api->getOrderById($token, $orderId);
            if ($result['success']) {
                $order = $result['data'];
            }
        }

        return view('customer.tracking', compact('order', 'orderId'));
    }
}
