<?php

namespace App\Http\Controllers;

use App\Services\ApiService;
use Illuminate\Http\Request;

class OwnerController extends Controller
{
    protected ApiService $api;

    public function __construct(ApiService $api)
    {
        $this->api = $api;
    }

    /**
     * Dashboard owner — laporan, stok, logistik, admin management.
     */
    public function dashboard(Request $request)
    {
        $token = session('auth_token');
        $tab = $request->input('tab', 'report');

        // Fetch all orders for reports
        $orderResult = $this->api->getOrders($token);
        $orders = $orderResult['success'] ? $orderResult['data'] : [];

        // Fetch all products for stock management
        $productResult = $this->api->getProducts();
        $products = $productResult['success'] ? $productResult['data'] : [];

        // Fetch admins
        $adminResult = $this->api->getAdmins($token);
        $admins = $adminResult['success'] ? $adminResult['data'] : [];

        // Calculate stats
        $totalRevenue = collect($orders)->where('status', 'success')->sum('total');
        $totalOrders = count($orders);
        $pendingOrders = count(array_filter($orders, fn($o) => $o['status'] === 'pending'));
        $successOrders = count(array_filter($orders, fn($o) => $o['status'] === 'success'));

        return view('owner.dashboard', compact(
            'orders', 'products', 'admins', 'tab',
            'totalRevenue', 'totalOrders', 'pendingOrders', 'successOrders'
        ));
    }

    /**
     * Update stok produk.
     */
    public function updateStock(Request $request, string $productId)
    {
        $request->validate(['amount' => 'required|integer']);
        $token = session('auth_token');

        $result = $this->api->updateStock($token, $productId, $request->input('amount'));

        if (!$result['success']) {
            return back()->with('error', 'Gagal memperbarui stok.');
        }

        return back()->with('success', $result['data']['message'] ?? 'Stok berhasil diperbarui.');
    }

    /**
     * Update status pengiriman.
     */
    public function updateShipping(Request $request, string $orderId)
    {
        $token = session('auth_token');
        $result = $this->api->updateOrderStatus($token, $orderId, [
            'shippingStatus' => $request->input('shippingStatus'),
        ]);

        if (!$result['success']) {
            return back()->with('error', 'Gagal memperbarui status pengiriman.');
        }

        return back()->with('success', 'Status pengiriman berhasil diperbarui.');
    }

    /**
     * Buat akun admin baru.
     */
    public function createAdmin(Request $request)
    {
        $request->validate([
            'username' => 'required|string|min:3',
            'password' => 'required|string|min:3',
            'name'     => 'required|string|min:2',
        ]);

        $token = session('auth_token');
        $result = $this->api->createAdmin($token, $request->only('username', 'password', 'name'));

        if (!$result['success']) {
            $error = $result['data']['error'] ?? 'Gagal membuat akun admin.';
            return back()->with('error', $error);
        }

        return back()->with('success', 'Akun admin berhasil dibuat.');
    }

    /**
     * Hapus akun admin.
     */
    public function deleteAdmin(string $username)
    {
        $token = session('auth_token');
        $result = $this->api->deleteAdmin($token, $username);

        if (!$result['success']) {
            return back()->with('error', 'Gagal menghapus admin.');
        }

        return back()->with('success', 'Akun admin berhasil dihapus.');
    }
}
