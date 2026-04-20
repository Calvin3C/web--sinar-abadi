<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Middleware to check if user is authenticated (has JWT token in session)
 * and optionally checks for specific role(s).
 *
 * Usage in routes:
 *   ->middleware('auth.api')            — any authenticated user
 *   ->middleware('auth.api:customer')   — customer only
 *   ->middleware('auth.api:admin,owner') — admin or owner
 */
class CheckApiAuth
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        // Check if token exists in session
        if (!session('auth_token')) {
            if ($request->expectsJson()) {
                return response()->json(['error' => 'Silakan login terlebih dahulu.'], 401);
            }
            return redirect()->route('login')->with('error', 'Silakan login terlebih dahulu.');
        }

        // Check role if specified
        if (!empty($roles)) {
            $userRole = session('auth_role');
            if (!in_array($userRole, $roles)) {
                if ($request->expectsJson()) {
                    return response()->json(['error' => 'Akses ditolak.'], 403);
                }
                abort(403, 'Akses ditolak. Anda tidak memiliki hak akses ke halaman ini.');
            }
        }

        return $next($request);
    }
}
