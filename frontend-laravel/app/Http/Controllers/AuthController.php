<?php

namespace App\Http\Controllers;

use App\Services\ApiService;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    protected ApiService $api;

    public function __construct(ApiService $api)
    {
        $this->api = $api;
    }

    /**
     * Tampilkan halaman login/register.
     */
    public function showLogin()
    {
        if (session('auth_token')) {
            return $this->redirectByRole(session('auth_role'));
        }
        return view('auth.login');
    }

    /**
     * Proses login via Go API.
     */
    public function login(Request $request)
    {
        $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
            'role'     => 'required|in:customer,admin,owner',
        ]);

        $result = $this->api->login(
            $request->input('username'),
            $request->input('password'),
            $request->input('role')
        );

        if (!$result['success']) {
            $error = $result['data']['error'] ?? 'Login gagal. Periksa kembali kredensial Anda.';
            return back()->withInput()->with('error', $error);
        }

        $data = $result['data'];

        // Store JWT token and user info in session
        session([
            'auth_token'    => $data['token'],
            'auth_user'     => $data['user'],
            'auth_role'     => $data['user']['role'],
            'auth_username' => $data['user']['username'],
            'auth_name'     => $data['user']['name'],
            'auth_user_id'  => $data['user']['id'],
        ]);

        return $this->redirectByRole($data['user']['role']);
    }

    /**
     * Proses registrasi customer baru.
     */
    public function register(Request $request)
    {
        $request->validate([
            'username' => 'required|string|min:3',
            'password' => 'required|string|min:3',
            'name'     => 'required|string|min:2',
        ]);

        $result = $this->api->register(
            $request->input('username'),
            $request->input('password'),
            $request->input('name')
        );

        if (!$result['success']) {
            $error = $result['data']['error'] ?? 'Registrasi gagal.';
            return back()->withInput()->with('error', $error)->with('mode', 'register');
        }

        return redirect()->route('login')->with('success', 'Akun berhasil terdaftar! Silakan login.');
    }

    /**
     * Logout — hapus session.
     */
    public function logout()
    {
        session()->forget([
            'auth_token', 'auth_user', 'auth_role',
            'auth_username', 'auth_name', 'auth_user_id',
            'cart',
        ]);

        return redirect()->route('home')->with('success', 'Anda telah keluar.');
    }

    /**
     * Redirect user ke dashboard sesuai role.
     */
    private function redirectByRole(?string $role)
    {
        return match ($role) {
            'customer' => redirect()->route('customer.dashboard'),
            'admin'    => redirect()->route('admin.dashboard'),
            'owner'    => redirect()->route('owner.dashboard'),
            default    => redirect()->route('home'),
        };
    }
}
