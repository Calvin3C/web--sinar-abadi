<?php

namespace App\Http\Controllers;

use App\Services\ApiService;
use Illuminate\Http\Request;
use Inertia\Inertia;

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
        $completedOrders = array_filter($orders, fn($o) => strtolower($o['status'] ?? '') === 'completed');
        
        $todayDate = date('Y-m-d');
        $totalRevenueKotor = 0;
        $totalRevenueBersih = 0;
        
        foreach ($completedOrders as $order) {
            $updatedAt = $order['updatedAt'] ?? ($order['updated_at'] ?? ($order['date'] ?? ''));
            $orderDate = substr($updatedAt, 0, 10);
            if ($orderDate === $todayDate) {
                $totalRevenueKotor += $order['total'] ?? 0;
                if (isset($order['items']) && is_array($order['items'])) {
                    foreach ($order['items'] as $item) {
                        $totalRevenueBersih += (($item['price'] ?? 0) * ($item['qty'] ?? 0));
                    }
                }
            }
        }
        
        $stockIssues = count(array_filter($products, fn($p) => ($p['stock'] ?? 0) <= 5));

        $profileResult = $this->api->getProfile($token);
        $profile = $profileResult['success'] ? $profileResult['data'] : null;

        $warehouseResult = $this->api->getWarehouses($token);
        $warehouses = $warehouseResult['success'] ? $warehouseResult['data'] : [];

        $inboundResult = $this->api->getInbounds($token);
        $inbounds = $inboundResult['success'] ? $inboundResult['data'] : [];

        $transferResult = $this->api->getStockTransfers($token);
        $stockTransfers = $transferResult['success'] ? $transferResult['data'] : [];

        return Inertia::render('Owner/Dashboard', [
            'products' => $products,
            'orders' => $orders,
            'admins' => $admins,
            'warehouses' => $warehouses,
            'inbounds' => $inbounds,
            'stockTransfers' => $stockTransfers,
            'username' => session('auth_username', 'Owner'),
            'profile' => $profile,
            'stats' => [
                'totalRevenueKotor' => $totalRevenueKotor,
                'totalRevenueBersih' => $totalRevenueBersih,
                'salesCount' => count($completedOrders),
                'stockIssuesCount' => $stockIssues,
                'totalAdmins' => count($admins),
            ],
        ]);
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
     * Update stok produk.
     */
    public function updateStock(Request $request, string $productId)
    {
        $request->validate([
            'amount' => 'required|integer',
            'warehouseId' => 'nullable|integer',
            'variantId' => 'nullable|integer',
        ]);
        $token = session('auth_token');

        $result = $this->api->updateStock(
            $token, 
            $productId, 
            $request->input('amount'),
            $request->input('warehouseId'),
            $request->input('variantId')
        );

        if (!$result['success']) {
            return back()->with('error', 'Gagal memperbarui stok.');
        }

        return back()->with('success', $result['data']['message'] ?? 'Stok berhasil diperbarui.');
    }

    /**
     * Transfer stok antar gudang.
     */
    public function transferStock(Request $request, string $productId)
    {
        $request->validate([
            'quantity' => 'required|integer|min:1',
            'fromWarehouseId' => 'required|integer',
            'toWarehouseId' => 'required|integer',
            'variantId' => 'nullable|integer',
        ]);

        $token = session('auth_token');

        $result = $this->api->transferStock(
            $token, 
            $productId, 
            [
                'fromWarehouseId' => (int) $request->input('fromWarehouseId'),
                'toWarehouseId' => (int) $request->input('toWarehouseId'),
                'quantity' => (int) $request->input('quantity'),
                'variantId' => $request->input('variantId') ? (int) $request->input('variantId') : null,
            ]
        );

        if (isset($result['error']) || (isset($result['success']) && $result['success'] === false)) {
            return back()->with('error', $result['error'] ?? $result['message'] ?? 'Gagal melakukan transfer stok.');
        }

        return back()->with('success', 'Transfer stok berhasil.');
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
            'email'    => 'nullable|email',
            'phone'    => 'nullable|string',
        ]);

        $token = session('auth_token');
        $result = $this->api->createAdmin($token, $request->only('username', 'password', 'name', 'email', 'phone'));

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

    /**
     * Update akun admin.
     */
    public function updateAdmin(Request $request, string $username)
    {
        $request->validate([
            'name' => 'nullable|string',
            'email' => 'nullable|string',
            'phone' => 'nullable|string',
            'password' => 'nullable|string|min:3',
        ]);

        $data = [
            'name' => $request->input('name') ?? '',
            'email' => $request->input('email') ?? '',
            'phone' => $request->input('phone') ?? '',
            'password' => $request->input('password') ?? '',
        ];

        $token = session('auth_token');
        $result = $this->api->updateAdmin($token, $username, $data);

        if (!$result['success']) {
            $error = $result['data']['error'] ?? 'Gagal memperbarui admin.';
            return back()->with('error', $error);
        }

        return back()->with('success', 'Akun admin berhasil diperbarui.');
    }

    /**
     * Tampilkan form tambah produk baru.
     */
    public function createProduct()
    {
        $token = session('auth_token');
        $productResult = $this->api->getProducts();
        $categories = collect($productResult['success'] ? $productResult['data'] : [])
            ->pluck('category')
            ->unique()
            ->values()
            ->all();

        $warehouseResult = $this->api->getWarehouses(session('auth_token'));
        $warehouses = $warehouseResult['success'] ? $warehouseResult['data'] : [];

        return Inertia::render('Owner/ProductForm', [
            'mode' => 'create',
            'product' => null,
            'categories' => $categories,
            'warehouses' => $warehouses,
            'username' => session('auth_username', 'Owner'),
        ]);
    }

    /**
     * Tampilkan form edit produk.
     */
    public function editProduct(string $productId)
    {
        $token = session('auth_token');
        $result = $this->api->getProductById($productId);

        if (!$result['success']) {
            return redirect()->route('owner.dashboard')->with('error', 'Produk tidak ditemukan.');
        }

        $productResult = $this->api->getProducts();
        $categories = collect($productResult['success'] ? $productResult['data'] : [])
            ->pluck('category')
            ->unique()
            ->values()
            ->all();

        $warehouseResult = $this->api->getWarehouses($token);
        $warehouses = $warehouseResult['success'] ? $warehouseResult['data'] : [];

        return Inertia::render('Owner/ProductForm', [
            'mode' => 'edit',
            'product' => $result['data'],
            'categories' => $categories,
            'warehouses' => $warehouses,
            'username' => session('auth_username', 'Owner'),
        ]);
    }

    /**
     * Simpan produk baru.
     */
    public function storeProduct(Request $request)
    {
        $request->validate([
            'id'         => 'required|string',
            'name'       => 'required|string',
            'category'   => 'required|string',
            'price'      => 'required|integer|min:0',
            'stock'      => 'required|integer|min:0',
            'brand'      => 'nullable|string',
            'weight'     => 'nullable|integer|min:0',
            'unit'       => 'nullable|string',
            'minPurchase'=> 'nullable|integer|min:1',
            'photo_main' => 'nullable|file|image|max:4096',
            'photo_1'    => 'nullable|file|image|max:4096',
            'photo_2'    => 'nullable|file|image|max:4096',
            'photo_3'    => 'nullable|file|image|max:4096',
            'photo_4'    => 'nullable|file|image|max:4096',
            'photo_5'    => 'nullable|file|image|max:4096',
        ]);

        // Handle photo uploads
        $imgUrl = '';
        if ($request->hasFile('photo_main')) {
            $path = $request->file('photo_main')->store('products', 'public');
            $imgUrl = asset('storage/' . $path);
        }

        // Store additional photos (for future use)
        $additionalPhotos = [];
        foreach (['photo_1', 'photo_2', 'photo_3', 'photo_4', 'photo_5'] as $photoField) {
            if ($request->hasFile($photoField)) {
                $path = $request->file($photoField)->store('products', 'public');
                $additionalPhotos[] = asset('storage/' . $path);
            }
        }

        $token = session('auth_token');
        $result = $this->api->createProduct($token, [
            'id'          => $request->input('id'),
            'name'        => $request->input('name'),
            'category'    => $request->input('category'),
            'brand'       => $request->input('brand', ''),
            'weight'      => (int) $request->input('weight', 0),
            'unit'        => $request->input('unit', ''),
            'minPurchase' => (int) $request->input('minPurchase', 1),
            'price'       => (int) $request->input('price'),
            'stock'       => (int) $request->input('stock'),
            'img'         => $imgUrl,
        ]);

        if (!$result['success']) {
            $error = $result['data']['error'] ?? 'Gagal menambahkan produk.';
            return back()->withErrors(['id' => $error]);
        }

        return redirect()->route('owner.dashboard')->with('success', 'Produk berhasil ditambahkan.');
    }

    /**
     * Update produk yang sudah ada.
     */
    public function updateProduct(Request $request, string $productId)
    {
        $request->validate([
            'name'       => 'required|string',
            'category'   => 'required|string',
            'price'      => 'required|integer|min:0',
            'stock'      => 'nullable|integer|min:0',
            'brand'      => 'nullable|string',
            'weight'     => 'nullable|integer|min:0',
            'unit'       => 'nullable|string',
            'minPurchase'=> 'nullable|integer|min:1',
            'photo_main' => 'nullable|file|image|max:4096',
            'photo_1'    => 'nullable|file|image|max:4096',
            'photo_2'    => 'nullable|file|image|max:4096',
            'photo_3'    => 'nullable|file|image|max:4096',
            'photo_4'    => 'nullable|file|image|max:4096',
            'photo_5'    => 'nullable|file|image|max:4096',
        ]);

        // Handle main photo upload
        $imgUrl = $request->input('img', '');
        if ($request->hasFile('photo_main')) {
            $path = $request->file('photo_main')->store('products', 'public');
            $imgUrl = asset('storage/' . $path);
        }

        // Store additional photos (for future use)
        foreach (['photo_1', 'photo_2', 'photo_3', 'photo_4', 'photo_5'] as $photoField) {
            if ($request->hasFile($photoField)) {
                $request->file($photoField)->store('products', 'public');
            }
        }

        $token = session('auth_token');
        $result = $this->api->updateProduct($token, $productId, [
            'name'        => $request->input('name'),
            'category'    => $request->input('category'),
            'brand'       => $request->input('brand', ''),
            'weight'      => (int) $request->input('weight', 0),
            'unit'        => $request->input('unit', ''),
            'minPurchase' => (int) $request->input('minPurchase', 1),
            'price'       => (int) $request->input('price'),
            'img'         => $imgUrl,
        ]);

        if (!$result['success']) {
            $error = $result['data']['error'] ?? 'Gagal memperbarui produk.';
            return back()->withErrors(['name' => $error]);
        }

        if ($request->has('stock')) {
            $newStock = (int) $request->input('stock');
            $currentProduct = $this->api->getProductById($productId);
            if ($currentProduct['success']) {
                $currentStock = $currentProduct['data']['stock'] ?? 0;
                $diff = $newStock - $currentStock;
                if ($diff !== 0) {
                    $this->api->updateStock($token, $productId, $diff);
                }
            }
        }

        return redirect()->route('owner.dashboard')->with('success', 'Produk berhasil diperbarui.');
    }

    /**
     * Create a new product variant.
     */
    public function createVariant(Request $request, string $productId)
    {
        $request->validate([
            'name'  => 'required|string|max:100',
            'price' => 'nullable|integer|min:0',
            'stock' => 'nullable|integer|min:0',
        ]);

        $token = session('auth_token');
        $result = $this->api->createVariant($token, $productId, [
            'name'  => $request->input('name'),
            'price' => (int) $request->input('price', 0),
            'stock' => (int) $request->input('stock', 0),
        ]);

        if (!$result['success']) {
            return back()->with('error', $result['data']['error'] ?? 'Gagal menambahkan varian.');
        }

        return back()->with('success', 'Varian berhasil ditambahkan.');
    }

    /**
     * Delete a product variant.
     */
    public function deleteVariant(string $productId, string $variantId)
    {
        $token = session('auth_token');
        $result = $this->api->deleteVariant($token, $productId, $variantId);

        if (!$result['success']) {
            return back()->with('error', $result['data']['error'] ?? 'Gagal menghapus varian.');
        }

        return back()->with('success', 'Varian berhasil dihapus.');
    }

    /**
     * Update owner profile.
     */
    public function updateProfile(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'username' => 'required|string',
            'email' => 'nullable|string',
            'phone' => 'nullable|string',
            'password' => 'nullable|string|min:3',
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

    public function storeWarehouse(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'description' => 'nullable|string',
        ]);
        $token = session('auth_token');
        $result = $this->api->createWarehouse($token, $request->all());

        if (!$result['success']) {
            return back()->with('error', $result['data']['message'] ?? 'Gagal membuat gudang.');
        }

        return back()->with('success', 'Gudang berhasil dibuat.');
    }

    public function updateWarehouse(Request $request, string $id)
    {
        $request->validate([
            'name' => 'required|string',
            'description' => 'nullable|string',
            'isActive' => 'required|boolean',
        ]);
        $token = session('auth_token');
        $result = $this->api->updateWarehouse($token, $id, $request->all());

        if (!$result['success']) {
            return back()->with('error', $result['data']['message'] ?? 'Gagal memperbarui gudang.');
        }

        return back()->with('success', 'Gudang berhasil diperbarui.');
    }

    public function storeInbound(Request $request)
    {
        $request->validate([
            'supplierName' => 'required|string',
            'expectedDate' => 'required|date',
            'items' => 'required|array',
        ]);
        
        $token = session('auth_token');
        
        $items = array_map(function($item) {
            if (isset($item['variantId']) && $item['variantId'] === '') {
                $item['variantId'] = null;
            } else if (isset($item['variantId'])) {
                $item['variantId'] = (int) $item['variantId'];
            }
            return $item;
        }, $request->input('items'));

        $data = [
            'supplierName' => $request->input('supplierName'),
            'expectedDate' => date('c', strtotime($request->input('expectedDate'))),
            'totalCost' => collect($items)->sum(fn($item) => ($item['qty'] ?? 0) * ($item['unitCost'] ?? 0)),
            'items' => $items,
        ];
        
        $result = $this->api->createInbound($token, $data);

        if (!$result['success']) {
            return back()->with('error', $result['data']['message'] ?? 'Gagal membuat inbound.');
        }

        return back()->with('success', 'Inbound berhasil dibuat.');
    }

    public function updateInboundStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|string|in:received,cancelled',
        ]);

        $token = session('auth_token');
        $result = $this->api->updateInboundStatus($token, $id, ['status' => $request->input('status')]);

        if (!$result['success']) {
            return back()->with('error', $result['data']['message'] ?? 'Gagal memperbarui status inbound.');
        }

        return back()->with('success', 'Status inbound berhasil diperbarui.');
    }
}
