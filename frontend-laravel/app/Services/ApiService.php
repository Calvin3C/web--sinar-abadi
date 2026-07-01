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

    public function register(string $username, string $password, string $role, string $name = '', string $phone = '', string $email = ''): array
    {
        $response = Http::timeout(10)->post("{$this->baseUrl}/register", [
            'username' => $username,
            'password' => $password,
            'role'     => $role,
            'name'     => $name,
            'phone'    => $phone,
            'email'    => $email,
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
    public function updateStock(string $token, string $productId, int $amount, ?int $warehouseId = null, ?int $variantId = null): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->put("{$this->baseUrl}/products/{$productId}/stock", [
                'amount' => $amount,
                'warehouseId' => $warehouseId,
                'variantId' => $variantId,
            ]);

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    /**
     * Update product details (admin/owner).
     */
    public function updateProduct(string $token, string $productId, array $data): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->put("{$this->baseUrl}/products/{$productId}", $data);

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    /**
     * Get a single product by ID.
     */
    public function getProductById(string $productId): array
    {
        $response = Http::timeout(10)
            ->get("{$this->baseUrl}/products/{$productId}");

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    /**
     * Create a new product variant (owner only).
     */
    public function createVariant(string $token, string $productId, array $data): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->post("{$this->baseUrl}/products/{$productId}/variants", $data);

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    /**
     * Delete a product variant (owner only).
     */
    public function deleteVariant(string $token, string $productId, string $variantId): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->delete("{$this->baseUrl}/products/{$productId}/variants/{$variantId}");

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
     * Complete order (customer).
     */
    public function completeOrder(string $token, string $orderId): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->put("{$this->baseUrl}/orders/{$orderId}/complete");

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    /**
     * Mengubah status pesanan menjadi proof_uploaded = true dan menyimpan URL
     */
    public function uploadProof(string $token, string $orderId, string $proofUrl = null): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->put("{$this->baseUrl}/orders/{$orderId}/proof", [
                'proofUploaded' => true,
                'proofUrl'      => $proofUrl,
            ]);

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    /**
     * Get live tracking for an order
     */
    public function getTracking(string $token, string $orderId): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->get("{$this->baseUrl}/biteship/tracking/{$orderId}");

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    // =====================================================================
    // USERS
    // =====================================================================

    /**
     * Get user profile.
     */
    public function getProfile(string $token): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->get("{$this->baseUrl}/users/profile");

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    /**
     * Update user profile.
     */
    public function updateProfile(string $token, array $data): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->put("{$this->baseUrl}/users/profile", $data);

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

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
     * Update an admin (owner).
     */
    public function updateAdmin(string $token, string $username, array $data): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->put("{$this->baseUrl}/users/admins/{$username}", $data);

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

    // =====================================================================
    // WAREHOUSES & INBOUNDS
    // =====================================================================

    public function getWarehouses(string $token): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->get("{$this->baseUrl}/warehouses");

        return [
            'success' => $response->successful(),
            'data'    => $response->json()['data'] ?? [],
        ];
    }

    public function createWarehouse(string $token, array $data): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->post("{$this->baseUrl}/warehouses", $data);

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    public function updateWarehouse(string $token, string $id, array $data): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->put("{$this->baseUrl}/warehouses/{$id}", $data);

        return $response->json() ?? ['success' => false, 'message' => 'API error'];
    }

    public function getStockTransfers(string $token): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->get("{$this->baseUrl}/stock-transfers");

        return $response->json() ?? ['success' => false, 'message' => 'API error'];
    }

    public function transferStock(string $token, string $productId, array $data): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->post("{$this->baseUrl}/products/{$productId}/transfer", $data);

        return $response->json() ?? ['success' => false, 'message' => 'API error'];
    }

    public function getInbounds(string $token): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->get("{$this->baseUrl}/inbounds");

        return [
            'success' => $response->successful(),
            'data'    => $response->json()['data'] ?? [],
        ];
    }

    public function createInbound(string $token, array $data): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->post("{$this->baseUrl}/inbounds", $data);

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    public function updateInboundStatus(string $token, string $id, array $data): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->put("{$this->baseUrl}/inbounds/{$id}/status", $data);

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }

    // =====================================================================
    // DELIVERY (Kurir Toko Sinar Abadi)
    // =====================================================================

    /**
     * Get delivery locations served by Kurir Toko Sinar Abadi.
     */
    public function getDeliveryLocations(): array
    {
        $response = Http::timeout(10)
            ->get("{$this->baseUrl}/delivery/locations");

        return [
            'success' => $response->successful(),
            'data'    => $response->json() ?? [],
        ];
    }

    /**
     * Get fleet vehicle status (admin/owner).
     */
    public function getFleetStatus(string $token): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->get("{$this->baseUrl}/delivery/fleet");

        return [
            'success' => $response->successful(),
            'data'    => $response->json() ?? [],
        ];
    }

    /**
     * Update delivery status for a Kurir Toko order (admin/owner).
     */
    public function updateDeliveryStatus(string $token, string $orderId, array $data): array
    {
        $response = Http::timeout(10)
            ->withToken($token)
            ->put("{$this->baseUrl}/delivery/{$orderId}/status", $data);

        return [
            'success' => $response->successful(),
            'data'    => $response->json(),
        ];
    }
}

