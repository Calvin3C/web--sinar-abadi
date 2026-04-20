@extends('layouts.app')

@section('title', 'Sinar Abadi – Material Bangunan Modern')

@section('content')
<section class="section active" id="home">
    <div class="container">
        {{-- Hero Banner --}}
        <div class="hero">
            <div class="hero-decoration"></div>
            <div class="hero-content">
                <h1>Membangun Masa Depan Dengan Material Terbaik</h1>
                <p>Sinar Abadi menyediakan kebutuhan konstruksi berskala industri maupun residensial. Jaminan keaslian merek dan pengiriman tepat waktu di seluruh Jawa Timur.</p>
                <div class="d-flex gap-4">
                    <a href="{{ route('katalog') }}" class="btn btn-primary" style="font-size:16px; padding:16px 32px;">Jelajahi Katalog</a>
                    <a href="#cat-section" class="btn btn-outline" style="border-color:rgba(255,255,255,0.3); color:white; font-size:16px; padding:16px 32px;">Kategori</a>
                </div>
            </div>
        </div>

        {{-- Kategori Material --}}
        <div id="cat-section" style="padding-top:20px;">
            <div class="text-center"><h3 class="section-title">Kategori Material</h3></div>
            <div class="category-grid">
                @php
                    $categoryIcons = [
                        'Semen' => '<path d="M4 10v6h16v-6H4zm14 4H6v-2h12v2zm-6-8h4V4h-4v2zM6 4h4v2H6V4zm-2 2h2V4H4v2z"/>',
                        'Plumbing' => '<path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/>',
                        'Cat Tembok' => '<path d="M7 14c-1.66 0-3 1.34-3 3 0 1.31-1.16 2-2 2 .92 1.22 2.49 2 4 2 2.21 0 4-1.79 4-4 0-1.66-1.34-3-3-3zm13.71-9.37l-1.34-1.34a1.99 1.99 0 0 0-2.83 0L2 17.83V22h4.17l14.54-14.54c.78-.78.78-2.05 0-2.83z"/>',
                        'Cat Kayu' => '<path d="M7 14c-1.66 0-3 1.34-3 3 0 1.31-1.16 2-2 2 .92 1.22 2.49 2 4 2 2.21 0 4-1.79 4-4 0-1.66-1.34-3-3-3zm13.71-9.37l-1.34-1.34a1.99 1.99 0 0 0-2.83 0L2 17.83V22h4.17l14.54-14.54c.78-.78.78-2.05 0-2.83z"/>',
                        'Besi Beton' => '<path d="M4 10v6h16v-6H4zm14 4H6v-2h12v2z"/>',
                        'Kloset' => '<path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/>',
                        'Tools' => '<path d="M22.7 19l-9.1-9.1c.9-2.3.4-5-1.5-6.9-2-2-5-2.4-7.4-1.3L9 6 6 9 1.6 4.7C.5 7.1.9 10.1 2.9 12.1c1.9 1.9 4.6 2.4 6.9 1.5l9.1 9.1c.4.4 1 .4 1.4 0l2.3-2.3c.5-.4.5-1.1.1-1.4z"/>',
                        'Electrical' => '<path d="M9 21c0 .55.45 1 1 1h4c.55 0 1-.45 1-1v-1H9v1zm3-19C8.14 2 5 5.14 5 9c0 2.38 1.19 4.47 3 5.74V17c0 .55.45 1 1 1h6c.55 0 1-.45 1-1v-2.26c1.81-1.27 3-3.36 3-5.74 0-3.86-3.14-7-7-7z"/>',
                        'Kuas Cat' => '<path d="M7 14c-1.66 0-3 1.34-3 3 0 1.31-1.16 2-2 2 .92 1.22 2.49 2 4 2 2.21 0 4-1.79 4-4 0-1.66-1.34-3-3-3z"/>',
                        'Kunci Pintu' => '<path d="M21 11h-4v-1h4v-2h-4V7h4V5h-6v14h6v-2h-4v-1h4v-2h-4v-1h4v-2z"/>',
                        'Engsel' => '<path d="M21 11h-4v-1h4v-2h-4V7h4V5h-6v14h6v-2h-4v-1h4v-2h-4v-1h4v-2z"/>',
                        'Keramik & Granite' => '<path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>',
                    ];
                @endphp
                @foreach($categories as $cat)
                <a href="{{ route('katalog', ['category' => $cat]) }}" class="category-card">
                    <div class="category-icon">
                        <svg viewBox="0 0 24 24" width="32" height="32" fill="#0f172a">{!! $categoryIcons[$cat] ?? '<path d="M12 2L2 22h20L12 2z"/>' !!}</svg>
                    </div>
                    <span class="category-name">{{ $cat }}</span>
                </a>
                @endforeach
            </div>
        </div>

        {{-- Produk Paling Laku --}}
        <div class="mt-8">
            <div class="d-flex align-center justify-between mb-8">
                <h3 class="section-title" style="margin-bottom:0;">Produk Paling Laku</h3>
                <a href="{{ route('katalog') }}" class="btn btn-ghost">Lihat Semua →</a>
            </div>
            <div class="product-grid">
                @foreach($bestSellers as $product)
                    @include('components.product-card', ['product' => $product])
                @endforeach
            </div>
        </div>
    </div>
</section>
@endsection
