<?php

namespace App\Http\Controllers;

use App\Services\ApiService;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    protected ApiService $api;

    public function __construct(ApiService $api)
    {
        $this->api = $api;
    }

    /**
     * Dashboard admin — manajemen pembelian & customer.
     */
    public function dashboard(Request $request)
    {
        $token = session('auth_token');
        $tab = $request->input('tab', 'orders');
        $statusFilter = $request->input('status', 'all');

        // Fetch orders
        $orderFilters = $statusFilter !== 'all' ? ['status' => $statusFilter] : [];
        $orderResult = $this->api->getOrders($token, $orderFilters);
        $orders = $orderResult['success'] ? $orderResult['data'] : [];

        // Fetch customers
        $customerResult = $this->api->getCustomers($token);
        $customers = $customerResult['success'] ? $customerResult['data'] : [];

        // Count pending orders for badge
        $pendingCount = count(array_filter($orders, fn($o) => $o['status'] === 'pending'));

        return view('admin.dashboard', compact('orders', 'customers', 'tab', 'statusFilter', 'pendingCount'));
    }

    /**
     * Update status pesanan (validasi pembayaran).
     */
    public function updateStatus(Request $request, string $orderId)
    {
        $token = session('auth_token');
        $result = $this->api->updateOrderStatus($token, $orderId, [
            'status' => $request->input('status'),
        ]);

        if (!$result['success']) {
            return back()->with('error', 'Gagal memperbarui status.');
        }

        return back()->with('success', 'Status pesanan berhasil diperbarui.');
    }

    /**
     * Toggle blokir/buka akses customer.
     */
    public function toggleBlock(string $username)
    {
        $token = session('auth_token');
        $result = $this->api->toggleBlock($token, $username);

        if (!$result['success']) {
            return back()->with('error', 'Gagal mengubah status akses.');
        }

        return back()->with('success', $result['data']['message'] ?? 'Status akses berhasil diubah.');
    }
}
