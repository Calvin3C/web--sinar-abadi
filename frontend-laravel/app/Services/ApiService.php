<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * ApiService handles all HTTP communication with the Go backend API.
 * All product, order, and user data is managed by the Go backend.
 * Laravel acts purely as a frontend that renders Blade templates.
 */
class ApiService
{
    protected string $baseUrl;

    public function __construct()
    {
        $this->baseUrl = rtrim(config('services.go_api.url', 'http://localhost:8080/api'), '/');
    }

    // =====================================================================
    // AUTH
    // =====================================================================

    /**
     * Login via Go backend. Returns token + user info.
     */
    public function login(string $username, string $password, string $role): array
    {
        $response = Http::timeout(10)->post("{$this->baseUrl}/login", [
            'username' => $username,
            'password' => $password,
            'role'     => $role,
        ]);

        return [
            'success' => $response->successful(),
            'status'  => $response->status(),
            'data'    => $response->json(),
        ];
    }

    /**
     * Register a new customer account.
     */
    public function register(string $username, string $password, string $name): array
    {
        $response = Http::timeout(10)->post("{$this->baseUrl}/register", [
            'username' => $username,
            'password' => $password,
            'name'     => $name,
        ]);

        return [
            'success' => $response->successful(),
            'status'  => $response->status(),
            'data'    => $response->json(),
        ];
    }

    // =====================================================================
    // PRODUCTS
    // =====================================================================

    /**
     * Get products with optional filters.
     */
    public function getProducts(array $filters = []): array
    {
        $response = Http::timeout(10)->get("{$this->baseUrl}/products", $filters);

        return [
            'success' => $response->successful(),
            'data'    => $response->json() ?? [],
        ];
    }

    /**
     * Create a new product (admin/owner).
     */
    public function createProduct(string $token, array $data): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->post("{$this->baseUrl}/products", $data);

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    /**
     * Update product stock (owner only).
     */
    public function updateStock(string $token, string $productId, int $amount): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->put("{$this->baseUrl}/products/{$productId}/stock", [
                'amount' => $amount,
            ]);

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    // =====================================================================
    // ORDERS
    // =====================================================================

    /**
     * Create a new order (customer checkout).
     */
    public function createOrder(string $token, array $data): array
    {
        $response = Http::timeout(15)
            ->withToken($token)
            ->post("{$this->baseUrl}/orders", $data);

        return [
            'success' => $response->successful(),
            'status'  => $response->status(),
            'data'    => $response->json(),
        ];
    }

    /**
     * Get orders (role-based filtering on backend).
     */
    public function getOrders(string $token, array $filters = []): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->get("{$this->baseUrl}/orders", $filters);

        return [
            'success' => $response->successful(),
            'data'    => $response->json() ?? [],
        ];
    }

    /**
     * Get a single order by ID.
     */
    public function getOrderById(string $token, string $orderId): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->get("{$this->baseUrl}/orders/{$orderId}");

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    /**
     * Update order status (admin/owner).
     */
    public function updateOrderStatus(string $token, string $orderId, array $data): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->put("{$this->baseUrl}/orders/{$orderId}/status", $data);

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    /**
     * Mark proof as uploaded (customer).
     */
    public function uploadProof(string $token, string $orderId): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->put("{$this->baseUrl}/orders/{$orderId}/proof", [
                'proofUploaded' => true,
            ]);

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    // =====================================================================
    // USERS
    // =====================================================================

    /**
     * Get all customers (admin/owner).
     */
    public function getCustomers(string $token): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->get("{$this->baseUrl}/users");

        return [
            'success' => $response->successful(),
            'data'    => $response->json() ?? [],
        ];
    }

    /**
     * Toggle block status for a customer (admin).
     */
    public function toggleBlock(string $token, string $username): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->put("{$this->baseUrl}/users/{$username}/block");

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    /**
     * Get all admins (owner).
     */
    public function getAdmins(string $token): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->get("{$this->baseUrl}/users/admins");

        return [
            'success' => $response->successful(),
            'data'    => $response->json() ?? [],
        ];
    }

    /**
     * Create a new admin (owner).
     */
    public function createAdmin(string $token, array $data): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->post("{$this->baseUrl}/users/admins", $data);

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    /**
     * Delete an admin (owner).
     */
    public function deleteAdmin(string $token, string $username): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->delete("{$this->baseUrl}/users/admins/{$username}");

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }
}
