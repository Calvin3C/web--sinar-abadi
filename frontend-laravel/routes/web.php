<?php

use App\Http\Controllers\HomeController;
use App\Http\Controllers\CatalogController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\CustomerController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\OwnerController;
use Illuminate\Support\Facades\Route;

// =====================================================================
// PUBLIC ROUTES
// =====================================================================

Route::get('/', [HomeController::class, 'index'])->name('home');
Route::get('/katalog', [CatalogController::class, 'index'])->name('katalog');

// Auth
Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
Route::post('/login', [AuthController::class, 'login'])->name('login.process');
Route::post('/register', [AuthController::class, 'register'])->name('register.process');
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// =====================================================================
// CART (Customer, session-based + API checkout)
// =====================================================================
Route::middleware('auth.api:customer')->group(function () {
    Route::get('/cart', [CartController::class, 'index'])->name('cart.index');
    Route::post('/cart/add', [CartController::class, 'add'])->name('cart.add');
    Route::post('/cart/update', [CartController::class, 'update'])->name('cart.update');
    Route::delete('/cart/{productId}', [CartController::class, 'remove'])->name('cart.remove');
    
    // New Logistic & Payment Flow
    Route::post('/cart/set-logistics', [CartController::class, 'setLogistics'])->name('cart.setLogistics');
    Route::get('/cart/payment', [CartController::class, 'paymentPage'])->name('cart.payment');
    Route::post('/checkout', [CartController::class, 'checkout'])->name('cart.checkout');
});

// =====================================================================
// CUSTOMER DASHBOARD
// =====================================================================
Route::middleware('auth.api:customer')->prefix('customer')->name('customer.')->group(function () {
    Route::get('/dashboard', [CustomerController::class, 'dashboard'])->name('dashboard');
    Route::post('/orders/{id}/proof', [CustomerController::class, 'uploadProof'])->name('upload-proof');
    Route::get('/tracking', [CustomerController::class, 'trackOrder'])->name('tracking');
});

// =====================================================================
// ADMIN DASHBOARD
// =====================================================================
Route::middleware('auth.api:admin')->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [AdminController::class, 'dashboard'])->name('dashboard');
    Route::put('/orders/{id}/status', [AdminController::class, 'updateStatus'])->name('update-status');
    Route::put('/users/{username}/block', [AdminController::class, 'toggleBlock'])->name('toggle-block');
});

// =====================================================================
// OWNER DASHBOARD
// =====================================================================
Route::middleware('auth.api:owner')->prefix('owner')->name('owner.')->group(function () {
    Route::get('/dashboard', [OwnerController::class, 'dashboard'])->name('dashboard');
    Route::put('/products/{id}/stock', [OwnerController::class, 'updateStock'])->name('update-stock');
    Route::put('/orders/{id}/shipping', [OwnerController::class, 'updateShipping'])->name('update-shipping');
    Route::post('/admins', [OwnerController::class, 'createAdmin'])->name('create-admin');
    Route::delete('/admins/{username}', [OwnerController::class, 'deleteAdmin'])->name('delete-admin');
});
