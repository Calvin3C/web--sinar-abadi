{{-- Product Card Component --}}
<div class="product-card">
    <div class="product-image-wrap">
        @if($product['stock'] <= 0)
            <span class="product-badge">Habis</span>
        @endif
        @if($product['isLarge'] ?? false)
            <span class="size-badge">Barang Besar</span>
        @endif
        <img src="{{ $product['img'] ?? 'https://placehold.co/400x300/e2e8f0/64748b?text=No+Image' }}"
             alt="{{ $product['name'] }}"
             class="product-image"
             loading="lazy">
    </div>
    <div class="product-content">
        <span class="product-cat-label">{{ $product['category'] }}</span>
        <h4 class="product-title">{{ $product['name'] }}</h4>
        <div class="product-stats">
            <span>{{ $product['sold'] ?? 0 }} terjual</span>
            <span>•</span>
            <span>Stok: {{ $product['stock'] ?? 0 }}</span>
        </div>
        <div class="product-price">Rp {{ number_format($product['price'], 0, ',', '.') }}</div>

        @if(($product['stock'] ?? 0) > 0)
            @if(session('auth_role') === 'customer')
                <button class="btn btn-primary w-100 btn-add-cart"
                        onclick="addToCart(this)"
                        data-id="{{ $product['id'] }}"
                        data-name="{{ $product['name'] }}"
                        data-price="{{ $product['price'] }}"
                        data-img="{{ $product['img'] ?? '' }}"
                        data-islarge="{{ ($product['isLarge'] ?? false) ? '1' : '0' }}"
                        data-stock="{{ $product['stock'] }}">
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="white"><path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/></svg>
                    Tambah ke Keranjang
                </button>
            @else
                <a href="{{ route('login') }}" class="btn btn-outline w-100" style="border-color:var(--color-primary); color:var(--color-primary);">
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/></svg>
                    Login untuk Beli
                </a>
            @endif
        @else
            <button class="btn w-100" disabled style="background:#e2e8f0; color:#94a3b8; cursor:not-allowed;">
                Stok Habis
            </button>
        @endif
    </div>
</div>
