<?php

namespace App\Http\Controllers;

use App\Services\ApiService;
use Illuminate\Http\Request;

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
        $subtotal = collect($cart)->sum(fn($item) => $item['price'] * $item['qty']);
        $tax = round($subtotal * 0.11);
        $total = $subtotal + $tax;

        return view('cart.index', compact('cart', 'subtotal', 'tax', 'total'));
    }

    /**
     * Tambah produk ke keranjang (AJAX).
     */
    public function add(Request $request)
    {
        $request->validate([
            'id'    => 'required|string',
            'name'  => 'required|string',
            'price' => 'required|numeric',
            'img'   => 'nullable|string',
            'stock' => 'nullable|numeric',
        ]);

        $cart = session('cart', []);
        $productId = $request->input('id');
        $isLarge = in_array($request->input('isLarge'), ['1', 'true', true, 1], true)
                || $request->input('isLarge') === true;

        if (isset($cart[$productId])) {
            $cart[$productId]['qty'] += 1;
        } else {
            $cart[$productId] = [
                'id'      => $productId,
                'name'    => $request->input('name'),
                'price'   => (int) $request->input('price'),
                'img'     => $request->input('img', ''),
                'isLarge' => $isLarge,
                'stock'   => (int) $request->input('stock', 0),
                'qty'     => 1,
            ];
        }

        session(['cart' => $cart]);

        return response()->json([
            'success'   => true,
            'message'   => 'Produk ditambahkan ke keranjang',
            'cartCount' => collect($cart)->sum('qty'),
        ]);
    }

    /**
     * Update quantity produk di keranjang (AJAX).
     */
    public function update(Request $request)
    {
        $request->validate([
            'id'  => 'required|string',
            'qty' => 'required|integer|min:0',
        ]);

        $cart = session('cart', []);
        $productId = $request->input('id');
        $qty = $request->input('qty');

        if ($qty <= 0) {
            unset($cart[$productId]);
        } elseif (isset($cart[$productId])) {
            $cart[$productId]['qty'] = $qty;
        }

        session(['cart' => $cart]);

        $subtotal = collect($cart)->sum(fn($item) => $item['price'] * $item['qty']);
        $tax = round($subtotal * 0.11);

        return response()->json([
            'success'   => true,
            'cartCount' => collect($cart)->sum('qty'),
            'subtotal'  => $subtotal,
            'tax'       => $tax,
            'total'     => $subtotal + $tax,
        ]);
    }

    /**
     * Hapus produk dari keranjang (AJAX).
     */
    public function remove(string $productId)
    {
        $cart = session('cart', []);
        unset($cart[$productId]);
        session(['cart' => $cart]);

        return response()->json([
            'success'   => true,
            'cartCount' => collect($cart)->sum('qty'),
        ]);
    }

    /**
     * Proses checkout — kirim order ke Go backend.
     */
    public function checkout(Request $request)
    {
        $request->validate([
            'phone'          => 'required|string',
            'address'        => 'required|string',
            'shippingMethod' => 'required|string',
        ]);

        $cart = session('cart', []);
        if (empty($cart)) {
            return back()->with('error', 'Keranjang kosong.');
        }

        $items = [];
        foreach ($cart as $item) {
            $items[] = [
                'productId' => $item['id'],
                'name'      => $item['name'],
                'qty'       => $item['qty'],
                'price'     => $item['price'],
            ];
        }

        $subtotal = collect($cart)->sum(fn($item) => $item['price'] * $item['qty']);
        $tax = round($subtotal * 0.11);
        $total = $subtotal + $tax;

        $result = $this->api->createOrder(session('auth_token'), [
            'phone'          => $request->input('phone'),
            'address'        => $request->input('address'),
            'shippingMethod' => $request->input('shippingMethod'),
            'items'          => $items,
            'total'          => $total,
        ]);

        if (!$result['success']) {
            $error = $result['data']['error'] ?? 'Gagal membuat pesanan.';
            return back()->with('error', $error);
        }

        // Clear cart after successful checkout
        session()->forget('cart');

        return redirect()->route('customer.dashboard')->with('success', 'Pesanan berhasil dibuat! ID: ' . ($result['data']['id'] ?? ''));
    }
}
