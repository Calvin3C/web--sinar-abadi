<?php

namespace App\Http\Middleware;

use Illuminate\Http\Request;
use Inertia\Middleware;

class HandleInertiaRequests extends Middleware
{
    /**
     * The root template that is loaded on the first page visit.
     *
     * @var string
     */
    protected $rootView = 'app';

    /**
     * Determine the current asset version.
     */
    public function version(Request $request): ?string
    {
        return parent::version($request);
    }

    /**
     * Define the assets that are shared by default.
     *
     * @return array<string, mixed>
     */
    public function share(Request $request): array
    {
        $cart = session('cart', []);
        $cartCount = collect($cart)->count();

        return array_merge(parent::share($request), [
            'auth' => [
                'user' => session('auth_user'),
                'token' => session('auth_token'),
                'role' => session('auth_role'),
                'username' => session('auth_username'),
                'name' => session('auth_name'),
                'id' => session('auth_user_id'),
            ],
            'cartCount' => $cartCount,
            'flash' => [
                'success' => fn () => $request->session()->get('success'),
                'error' => fn () => $request->session()->get('error'),
            ],
            'currentRouteName' => $request->route() ? $request->route()->getName() : null,
            'currentRouteParams' => $request->route() ? $request->route()->parameters() : [],
        ]);
    }
}
