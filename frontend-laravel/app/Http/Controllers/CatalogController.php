<?php

namespace App\Http\Controllers;

use App\Services\ApiService;
use Illuminate\Http\Request;

class CatalogController extends Controller
{
    protected ApiService $api;

    public function __construct(ApiService $api)
    {
        $this->api = $api;
    }

    /**
     * Halaman Katalog Lengkap — dengan search, filter, dan sorting.
     */
    public function index(Request $request)
    {
        $filters = array_filter([
            'search'   => $request->input('search'),
            'category' => $request->input('category', 'all'),
            'sort'     => $request->input('sort', 'rekomendasi'),
        ]);

        $result = $this->api->getProducts($filters);
        $products = $result['success'] ? $result['data'] : [];

        // Extract unique categories for the filter dropdown
        $allResult = $this->api->getProducts();
        $allProducts = $allResult['success'] ? $allResult['data'] : [];
        $categories = collect($allProducts)->pluck('category')->unique()->sort()->values()->all();

        // Simple server-side pagination
        $page = max(1, (int) $request->input('page', 1));
        $perPage = 12;
        $total = count($products);
        $totalPages = max(1, ceil($total / $perPage));
        $page = min($page, $totalPages);
        $paginatedProducts = array_slice($products, ($page - 1) * $perPage, $perPage);

        return view('katalog', compact(
            'paginatedProducts',
            'categories',
            'page',
            'totalPages',
            'total',
            'filters'
        ));
    }
}
