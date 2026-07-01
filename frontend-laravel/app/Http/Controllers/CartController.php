<?php

namespace App\Http\Controllers;

use App\Services\ApiService;
use Illuminate\Http\Request;
use Inertia\Inertia;

class CartController extends Controller
{
    protected ApiService $api;

    public function __construct(ApiService $api)
    {
        $this->api = $api;
    }

    /**
     * Tampilkan halaman keranjang.
     */
    public function index()
    {
        $cart = session('cart', []);
        $cartItems = array_values($cart);
        
        $logistic = session('checkout_logistics', [
            'courier' => '',
            'address' => '',
            'cost' => 0,
            'totalWeight' => 0
        ]);

        return Inertia::render('Cart/Index', [
            'cartItems' => $cartItems,
            'logistic' => $logistic,
        ]);
    }

    /**
     * Tambah produk ke keranjang.
     */
    public function add(Request $request)
    {
        $request->validate([
            'id'      => 'required|string',
            'name'    => 'required|string',
            'price'   => 'required|numeric',
            'img'     => 'nullable|string',
            'weight'  => 'nullable|numeric',
            'length'  => 'nullable|numeric',
            'width'   => 'nullable|numeric',
            'height'  => 'nullable|numeric',
            'qty'     => 'nullable|numeric|min:1',
            'minPurchase' => 'nullable|numeric|min:1',
            'color'   => 'nullable|string',
            'variantId' => 'nullable|integer',
        ]);

        $cart = session('cart', []);
        $productId = $request->input('id');
        
        $requestedQty = (int) $request->input('qty', 1);
        $color = $request->input('color');
        $cartKey = $productId . ($color ? '_' . $color : '');

        if (isset($cart[$cartKey])) {
            // Check stock limit
            $newQty = $cart[$cartKey]['qty'] + $requestedQty;
            $stockLimit = (int) $request->input('stock', 999);
            if ($newQty > $stockLimit) {
                return back()->with('error', 'Stok produk tidak mencukupi.');
            }
            $cart[$cartKey]['qty'] = $newQty;
        } else {
            $cart[$cartKey] = [
                'cartKey' => $cartKey,
                'id'      => $productId,
                'name'    => $request->input('name'),
                'price'   => (int) $request->input('price'),
                'img'     => $request->input('img', ''),
                'weight'  => (int) $request->input('weight', 0),
                'length'  => (int) $request->input('length', 1),
                'width'   => (int) $request->input('width', 1),
                'height'  => (int) $request->input('height', 1),
                'stock'   => (int) $request->input('stock', 0),
                'qty'     => $requestedQty,
                'minPurchase' => (int) $request->input('minPurchase', 1),
                'color'   => $color,
                'variantId' => $request->input('variantId'),
            ];
        }

        session(['cart' => $cart]);

        // Recalculate shipping if logistics already set
        $this->recalculateLogistics();

        return back()->with('success', 'Produk ditambahkan ke keranjang.');
    }

    /**
     * Update quantity produk di keranjang.
     */
    public function update(Request $request)
    {
        $request->validate([
            'id'  => 'required|string',
            'qty' => 'required|integer|min:0',
        ]);

        $cart = session('cart', []);
        $productId = $request->input('id');
        $qty = (int) $request->input('qty');

        if ($qty <= 0) {
            unset($cart[$productId]);
        } elseif (isset($cart[$productId])) {
            $minPurchase = $cart[$productId]['minPurchase'] ?? 1;
            if ($qty < $minPurchase) {
                return back()->with('error', "Minimal pembelian adalah {$minPurchase}.");
            }
            // Check stock
            $stockLimit = $cart[$productId]['stock'];
            if ($qty > $stockLimit) {
                return back()->with('error', "Stok maksimal yang dapat dibeli adalah {$stockLimit}.");
            }
            $cart[$productId]['qty'] = $qty;
        }

        session(['cart' => $cart]);

        // Recalculate shipping if logistics already set
        $this->recalculateLogistics();

        return back()->with('success', 'Jumlah belanja berhasil diperbarui.');
    }

    /**
     * Hapus produk dari keranjang.
     */
    public function remove(string $productId)
    {
        $cart = session('cart', []);
        unset($cart[$productId]);
        session(['cart' => $cart]);

        // Recalculate shipping if logistics already set
        $this->recalculateLogistics();

        return back()->with('success', 'Produk dihapus dari keranjang.');
    }

    /**
     * Simpan data logistik ke session.
     */
    public function setLogistics(Request $request)
    {
        $request->validate([
            'courier' => 'required|string',
            'address' => 'required|string',
        ]);

        $cart = session('cart', []);
        $totalQty = collect($cart)->sum('qty');

        // Simple shipping rates calculation
        $baseRate = 15000;
        if ($request->input('courier') === 'JNE') {
            $baseRate = 20000;
        } else if ($request->input('courier') === 'Pos Indonesia') {
            $baseRate = 12000;
        }

        $cost = $baseRate + ($totalQty * 4000);

        // Mock total weight (each item approx 2kg, large items 15kg)
        $weight = 0;
        foreach ($cart as $item) {
            $weight += $item['qty'] * ($item['weight'] > 0 ? $item['weight'] / 1000 : 2);
        }

        session([
            'checkout_logistics' => [
                'courier' => $request->input('courier'),
                'address' => $request->input('address'),
                'phone' => '0812-3456-7890', // Default phone fallback
                'cost' => $cost,
                'totalWeight' => $weight,
            ]
        ]);

        return back()->with('success', 'Kurir & alamat pengiriman berhasil disimpan.');
    }

    /**
     * Tampilkan halaman pembayaran setelah logistik diisi.
     */
    public function paymentPage()
    {
        $cart = session('cart', []);
        if (empty($cart)) return redirect()->route('cart.index')->with('error', 'Keranjang kosong.');

        $logistic = session('checkout_logistics');
        if (!$logistic || empty($logistic['address'])) {
            $logistic = [
                'courier' => 'J&T',
                'address' => '',
                'phone' => '',
                'cost' => 0,
                'totalWeight' => collect($cart)->sum(fn($i) => $i['qty'] * ($i['weight'] > 0 ? $i['weight'] / 1000 : 2)),
            ];
        }

        $bankAccounts = [
            [
                'name' => 'BCA',
                'number' => '1240345109',
                'owner' => 'Duvaltina Prihatini'
            ],
        ];

        return Inertia::render('Cart/Payment', [
            'cartItems' => array_values($cart),
            'logistic' => $logistic,
            'bankAccounts' => $bankAccounts,
            'user' => session('auth_user', []),
        ]);
    }

    /**
     * Proses checkout — kirim order ke Go backend.
     * Supports two flows:
     * 1. Midtrans Online: No proof required, returns snapToken for Snap popup
     * 2. Transfer Bank Manual: Proof upload required, redirect to dashboard
     */
    public function checkout(Request $request)
    {
        $paymentType = $request->input('payment_type', 'manual'); // 'midtrans' or 'manual'

        // Validation rules differ by payment type
        $rules = [
            'address' => 'required|string',
            'phone' => 'required|string',
            'courier' => 'required|string',
            'biteship_area_id' => 'nullable|string',
            'shipping_cost' => 'nullable|numeric',
            'courier_code' => 'nullable|string',
            'courier_service_code' => 'nullable|string',
            'delivery_location_id' => 'nullable|integer',
            'payment_type' => 'required|string',
        ];

        if ($paymentType === 'manual') {
            $rules['bank'] = 'required|string';
            $rules['proof'] = 'required|file|image|max:4096';
        }

        $request->validate($rules);

        $proofPath = null;
        if ($paymentType === 'manual' && $request->hasFile('proof')) {
            $proofPath = $request->file('proof')->store('proofs', 'public');
        }

        $logistic = [
            'address' => $request->input('address'),
            'phone' => $request->input('phone'),
            'courier' => $request->input('courier'),
        ];

        $cart = session('cart', []);
        if (empty($cart)) {
            if (str_starts_with($paymentType, 'midtrans')) {
                return response()->json(['error' => 'Keranjang kosong.'], 400);
            }
            return redirect()->route('cart.index')->with('error', 'Keranjang kosong.');
        }

        $items = [];
        foreach ($cart as $item) {
            $items[] = [
                'productId' => $item['id'],
                'name'      => $item['name'],
                'qty'       => $item['qty'],
                'price'     => $item['price'],
                'weight'    => $item['weight'] ?? 0,
                'length'    => $item['length'] ?? 1,
                'width'     => $item['width'] ?? 1,
                'height'    => $item['height'] ?? 1,
                'color'     => $item['color'] ?? '',
            ];
            if (isset($item['variantId']) && $item['variantId']) {
                $items[count($items) - 1]['variantId'] = $item['variantId'];
            }
        }

        $subtotal = collect($cart)->sum(fn($item) => $item['price'] * $item['qty']);
        $tax = floor($subtotal * 0.11);
        $totalProduct = $subtotal + $tax;

        // Determine payment method label for backend
        $paymentMethod = str_starts_with($paymentType, 'midtrans')
            ? $paymentType
            : 'Transfer Bank ' . $request->input('bank', 'BCA');

        $orderPayload = [
            'phone'              => $logistic['phone'],
            'address'            => $logistic['address'],
            'shippingMethod'     => $logistic['courier'],
            'paymentMethod'      => $paymentMethod,
            'biteshipAreaId'     => $request->input('biteship_area_id', ''),
            'shippingCost'       => (int) $request->input('shipping_cost', 0),
            'courierCode'        => $request->input('courier_code', ''),
            'courierServiceCode' => $request->input('courier_service_code', ''),
            'items'              => $items,
            'total'              => $totalProduct,
        ];

        // Add delivery location ID for Kurir Toko Sinar Abadi
        if ($request->input('delivery_location_id')) {
            $orderPayload['deliveryLocationId'] = (int) $request->input('delivery_location_id');
        }

        $result = $this->api->createOrder(session('auth_token'), $orderPayload);

        if (!$result['success']) {
            $error = $result['data']['error'] ?? 'Gagal membuat pesanan.';
            if (str_starts_with($paymentType, 'midtrans')) {
                return response()->json(['error' => $error], 422);
            }
            return back()->withErrors(['bank' => $error]);
        }

        $orderId = $result['data']['id'] ?? null;

        // === MIDTRANS FLOW ===
        if (str_starts_with($paymentType, 'midtrans')) {
            $snapToken = $result['data']['snapToken'] ?? null;

            if (!$snapToken) {
                return response()->json([
                    'error' => 'Gagal mendapatkan token pembayaran dari Midtrans.',
                    'orderId' => $orderId,
                ], 500);
            }

            // Don't clear cart yet — only after payment is confirmed
            // Cart will be cleared after Snap popup success callback

            return response()->json([
                'success' => true,
                'orderId' => $orderId,
                'snapToken' => $snapToken,
            ]);
        }

        // === TRANSFER BANK MANUAL FLOW ===
        if ($orderId && $proofPath) {
            $proofUrl = asset('storage/' . $proofPath);
            $this->api->uploadProof(session('auth_token'), $orderId, $proofUrl);
        }

        // Clear session after successful checkout
        session()->forget(['cart', 'checkout_logistics']);

        return redirect()->route('customer.dashboard')->with('success', 'Pesanan berhasil dibuat! Bukti pembayaran Anda sedang diverifikasi.');
    }

    /**
     * Helper to update logistics calculations dynamically if cart contents change.
     */
    private function recalculateLogistics()
    {
        $logistic = session('checkout_logistics');
        if ($logistic && $logistic['address']) {
            $cart = session('cart', []);
            $totalQty = collect($cart)->sum('qty');

            $baseRate = 15000;
            if ($logistic['courier'] === 'JNE') {
                $baseRate = 20000;
            } else if ($logistic['courier'] === 'Pos Indonesia') {
                $baseRate = 12000;
            }

            $cost = $baseRate + ($totalQty * 4000);

            $weight = 0;
            foreach ($cart as $item) {
                $weight += $item['qty'] * ($item['weight'] > 0 ? $item['weight'] / 1000 : 2);
            }

            $logistic['cost'] = $cost;
            $logistic['totalWeight'] = $weight;

            session(['checkout_logistics' => $logistic]);
        }
    }

    /**
     * Clear cart after successful Midtrans payment.
     * Called via AJAX from Snap popup success callback.
     */
    public function clearCart()
    {
        session()->forget(['cart', 'checkout_logistics']);
        return response()->json(['success' => true]);
    }

    /**
     * Cancel a Midtrans order when the user closes the Snap popup.
     * This restores stock and allows the user to retry with a different payment method.
     */
    public function cancelMidtransOrder(Request $request)
    {
        $orderId = $request->input('orderId');
        if (!$orderId) {
            return response()->json(['error' => 'Order ID is required.'], 400);
        }

        $token = session('auth_token');
        if (!$token) {
            return response()->json(['error' => 'Unauthorized.'], 401);
        }

        // Call Go backend customer cancel endpoint
        $baseUrl = rtrim(config('services.go_api.url', 'http://localhost:8080/api'), '/');
        $response = \Illuminate\Support\Facades\Http::timeout(10)
            ->withToken($token)
            ->put("{$baseUrl}/orders/{$orderId}/cancel");

        if ($response->successful()) {
            return response()->json(['success' => true, 'message' => 'Pesanan dibatalkan.']);
        }

        return response()->json([
            'error' => $response->json('error') ?? 'Gagal membatalkan pesanan.',
        ], 422);
    }
}
