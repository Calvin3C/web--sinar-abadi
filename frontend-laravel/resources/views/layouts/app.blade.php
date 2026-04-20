<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Sinar Abadi – Material Bangunan Modern')</title>
    <meta name="description" content="@yield('description', 'Sinar Abadi menyediakan material bangunan berkualitas untuk konstruksi residensial dan industri. Jaminan keaslian merek dan pengiriman tepat waktu.')">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    @vite(['resources/css/app.css', 'resources/js/app.js'])

    @stack('styles')
</head>
<body>
    {{-- Toast Notifications --}}
    <div class="toast-container" id="toast-container">
        @if(session('success'))
        <div class="toast success" id="flash-toast">
            <svg class="toast-icon" viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
            <div>
                <div class="toast-title">Berhasil</div>
                <div class="toast-msg">{{ session('success') }}</div>
            </div>
        </div>
        @endif
        @if(session('error'))
        <div class="toast warning" id="flash-toast">
            <svg class="toast-icon" viewBox="0 0 24 24"><path d="M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z"/></svg>
            <div>
                <div class="toast-title">Gagal</div>
                <div class="toast-msg">{{ session('error') }}</div>
            </div>
        </div>
        @endif
    </div>

    {{-- Header & Navigation --}}
    <header class="header">
        <div class="container header-inner">
            <a href="{{ route('home') }}" class="logo">
                <svg viewBox="0 0 24 24"><path d="M12 2L2 22h20L12 2zm0 3.8l6.1 12.2H5.9L12 5.8z"/></svg>
                SINAR<span>ABADI</span>
            </a>

            <nav class="nav-menu" id="main-nav">
                <a href="{{ route('home') }}" class="nav-link {{ request()->routeIs('home') ? 'active' : '' }}">Beranda</a>
                <a href="{{ route('katalog') }}" class="nav-link {{ request()->routeIs('katalog') ? 'active' : '' }}">Semua Katalog</a>

                @if(!session('auth_token'))
                    <a href="{{ route('login') }}" class="nav-link {{ request()->routeIs('login') ? 'active' : '' }}">Masuk / Daftar</a>
                @else
                    @if(session('auth_role') === 'customer')
                        <a href="{{ route('customer.dashboard') }}" class="nav-link {{ request()->routeIs('customer.*') ? 'active' : '' }}">Dashboard Saya</a>
                        <a href="{{ route('cart.index') }}" class="cart-trigger">
                            <svg viewBox="0 0 24 24" width="20" height="20"><path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z" fill="currentColor"/></svg>
                            Keranjang
                            <span class="cart-badge" id="cart-counter">{{ collect(session('cart', []))->sum('qty') }}</span>
                        </a>
                    @elseif(session('auth_role') === 'admin')
                        <a href="{{ route('admin.dashboard') }}" class="nav-link {{ request()->routeIs('admin.*') ? 'active' : '' }}">Panel Admin</a>
                    @elseif(session('auth_role') === 'owner')
                        <a href="{{ route('owner.dashboard') }}" class="nav-link {{ request()->routeIs('owner.*') ? 'active' : '' }}">Laporan Owner</a>
                    @endif

                    <form action="{{ route('logout') }}" method="POST" style="display:inline;">
                        @csrf
                        <button type="submit" class="btn btn-outline" style="padding:8px 16px; margin-left:8px;">
                            Keluar ({{ session('auth_username') }})
                        </button>
                    </form>
                @endif
            </nav>
        </div>
    </header>

    {{-- Main Content --}}
    <main>
        @yield('content')
    </main>

    {{-- Footer --}}
    <footer class="footer">
        <div class="container">
            <div class="footer-grid">
                <div class="footer-brand">
                    <div class="logo">
                        <svg viewBox="0 0 24 24" width="32" height="32" fill="#dc2626"><path d="M12 2L2 22h20L12 2zm0 3.8l6.1 12.2H5.9L12 5.8z"/></svg>
                        SINAR<span>ABADI</span>
                    </div>
                    <p>Toko material bangunan terlengkap di Dampit, Malang. Melayani penjualan material berkualitas tinggi untuk kebutuhan konstruksi Anda.</p>
                </div>
                <div>
                    <h4>Navigasi</h4>
                    <ul class="footer-links">
                        <li><a href="{{ route('home') }}">Beranda</a></li>
                        <li><a href="{{ route('katalog') }}">Katalog Produk</a></li>
                        <li><a href="{{ route('login') }}">Masuk / Daftar</a></li>
                    </ul>
                </div>
                <div>
                    <h4>Kategori</h4>
                    <ul class="footer-links">
                        <li><a href="{{ route('katalog', ['category' => 'Semen']) }}">Semen</a></li>
                        <li><a href="{{ route('katalog', ['category' => 'Plumbing']) }}">Plumbing</a></li>
                        <li><a href="{{ route('katalog', ['category' => 'Cat Tembok']) }}">Cat Tembok</a></li>
                        <li><a href="{{ route('katalog', ['category' => 'Tools']) }}">Tools</a></li>
                    </ul>
                </div>
                <div>
                    <h4>Hubungi Kami</h4>
                    <div class="contact-item">
                        <svg viewBox="0 0 24 24" width="20" height="20" fill="#dc2626"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg>
                        <span>Jl. Raya Dampit, Kab. Malang, Jawa Timur</span>
                    </div>
                    <div class="contact-item">
                        <svg viewBox="0 0 24 24" width="20" height="20" fill="#dc2626"><path d="M20.01 15.38c-1.23 0-2.42-.2-3.53-.56-.35-.12-.74-.03-1.01.24l-1.57 1.97c-2.83-1.35-5.48-3.9-6.89-6.83l1.95-1.66c.27-.28.35-.67.24-1.02-.37-1.11-.56-2.3-.56-3.53 0-.54-.45-.99-.99-.99H4.19C3.65 3 3 3.24 3 3.99 3 13.28 10.73 21 20.01 21c.71 0 .99-.63.99-1.18v-3.45c0-.54-.45-.99-.99-.99z"/></svg>
                        <span>+62 812-3456-7890</span>
                    </div>
                </div>
            </div>
            <div class="footer-bottom">
                &copy; {{ date('Y') }} Sinar Abadi. All rights reserved. | Built with Laravel & Go
            </div>
        </div>
    </footer>

    <script>
        // Auto-dismiss flash toasts
        document.addEventListener('DOMContentLoaded', function() {
            const toast = document.getElementById('flash-toast');
            if (toast) {
                setTimeout(() => {
                    toast.style.animation = 'fadeOut 0.5s forwards';
                    setTimeout(() => toast.remove(), 500);
                }, 4000);
            }
        });
    </script>

    @stack('scripts')
</body>
</html>
