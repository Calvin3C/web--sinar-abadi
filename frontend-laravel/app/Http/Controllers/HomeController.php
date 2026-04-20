<?php

namespace App\Http\Controllers;

use App\Services\ApiService;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    protected ApiService $api;

    public function __construct(ApiService $api)
    {
        $this->api = $api;
    }

    /**
     * Halaman Beranda — Hero + Kategori + Best Sellers
     */
    public function index()
    {
        // Fetch best-selling products (sorted by popularity)
        $result = $this->api->getProducts(['sort' => 'rekomendasi']);
        $products = $result['success'] ? $result['data'] : [];

        // Take top 8 for best-sellers display
        $bestSellers = array_slice($products, 0, 8);

        // Extract unique categories
        $categories = collect($products)->pluck('category')->unique()->values()->all();

        return view('home', compact('bestSellers', 'categories'));
    }
}
