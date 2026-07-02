<?php

namespace App\Http\Controllers;

use App\Services\ApiService;
use Illuminate\Http\Request;
use Inertia\Inertia;

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

        // Fetch orders
        $orderResult = $this->api->getOrders($token);
        $orders = $orderResult['success'] ? $orderResult['data'] : [];

        // Fetch customers
        $customerResult = $this->api->getCustomers($token);
        $customers = $customerResult['success'] ? $customerResult['data'] : [];

        // Fetch fleet status for Kurir Toko monitoring
        $fleetResult = $this->api->getFleetStatus($token);
        $fleet = $fleetResult['success'] ? $fleetResult['data'] : [];

        // Fetch delivery locations for reference
        $locationResult = $this->api->getDeliveryLocations();
        $deliveryLocations = $locationResult['success'] ? $locationResult['data'] : [];

        // Calculate stats
        $pendingOrders = count(array_filter($orders, fn($o) => strtolower($o['status'] ?? '') === 'pending'));
        $verifiedOrders = count(array_filter($orders, fn($o) => strtolower($o['status'] ?? '') === 'verified'));

        $profileResult = $this->api->getProfile($token);
        $profile = $profileResult['success'] ? $profileResult['data'] : null;

        return Inertia::render('Admin/Dashboard', [
            'orders' => $orders,
            'customers' => $customers,
            'fleet' => $fleet,
            'deliveryLocations' => $deliveryLocations,
            'username' => session('auth_username', 'Admin'),
            'profile' => $profile,
            'stats' => [
                'totalOrders' => count($orders),
                'pendingOrders' => $pendingOrders,
                'verifiedOrders' => $verifiedOrders,
                'totalCustomers' => count($customers),
            ],
        ]);
    }


    /**
     * Update status pengiriman (input resi / selesai / dll).
     */
    public function updateShipping(Request $request, string $orderId)
    {
        $token = session('auth_token');
        $status = $request->input('status', 'SHIPPING');

        $result = $this->api->updateOrderStatus($token, $orderId, [
            'status' => $status,
            'shippingCode' => $request->input('shippingCode', ''),
        ]);

        if (!$result['success']) {
            return back()->with('error', 'Gagal memperbarui status pengiriman.');
        }

        return back()->with('success', 'Status pengiriman berhasil diperbarui.');
    }

    /**
     * Update delivery status untuk pesanan Kurir Toko Sinar Abadi.
     */
    public function updateDeliveryStatus(Request $request, string $orderId)
    {
        $request->validate([
            'deliveryStatus' => 'required|string|in:Menunggu,Diproses,Dikirim,Selesai',
            'fleetVehicleId' => 'nullable|integer',
        ]);

        $token = session('auth_token');
        $data = [
            'deliveryStatus' => $request->input('deliveryStatus'),
        ];

        if ($request->input('fleetVehicleId')) {
            $data['fleetVehicleId'] = (int) $request->input('fleetVehicleId');
        }

        $result = $this->api->updateDeliveryStatus($token, $orderId, $data);

        if (!$result['success']) {
            $error = $result['data']['error'] ?? 'Gagal memperbarui status pengiriman.';
            return back()->with('error', $error);
        }

        return back()->with('success', 'Status pengiriman berhasil diperbarui.');
    }

    /**
     * Update admin profile.
     */
    public function updateProfile(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'username' => 'required|string',
            'email' => 'nullable|string',
            'phone' => 'nullable|string',
            'password' => 'nullable|string|min:5',
        ]);

        $data = [
            'name' => $request->input('name') ?? '',
            'username' => $request->input('username') ?? '',
            'email' => $request->input('email') ?? '',
            'phone' => $request->input('phone') ?? '',
            'password' => $request->input('password') ?? '',
        ];

        $token = session('auth_token');
        $result = $this->api->updateProfile($token, $data);

        if (!$result['success']) {
            \Illuminate\Support\Facades\Log::error('API Error Response:', $result);
            $error = $result['data']['error'] ?? 'Gagal memperbarui profil.';
            return back()->with('error', $error);
        }

        if ($request->input('username') !== session('auth_username')) {
            session(['auth_username' => $request->input('username')]);
        }

        return back()->with('success', 'Profil berhasil diperbarui.');
    }
}

