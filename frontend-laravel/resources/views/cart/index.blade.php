@extends('layouts.app')

@section('title', 'Keranjang Belanja – Sinar Abadi')

@section('content')
<section class="section active">
    <div class="container">
        <h2 class="section-title">Keranjang Belanja</h2>

        @if(count($cart) > 0)
        <div class="dashboard-layout" style="grid-template-columns: 1fr 380px;">
            {{-- Cart Items --}}
            <div>
                <div class="table-card">
                    <div class="table-header"><h3>{{ count($cart) }} Item dalam Keranjang</h3></div>
                    <div style="padding:24px;">
                        @foreach($cart as $item)
                        <div class="cart-item" id="cart-item-{{ $item['id'] }}">
                            <img src="{{ $item['img'] ?: 'https://placehold.co/80x80/e2e8f0/64748b?text=No+Img' }}"
                                 alt="{{ $item['name'] }}" class="cart-item-img">
                            <div class="cart-item-info">
                                <span class="cart-item-title">{{ $item['name'] }}</span>
                                <span class="cart-item-price">Rp {{ number_format($item['price'], 0, ',', '.') }}</span>
                                @if($item['isLarge'])
                                    <span class="cart-item-size">Barang Besar</span>
                                @endif
                                <div class="d-flex align-center gap-3" style="margin-top:8px;">
                                    <div class="qty-controls">
                                        <button class="qty-btn" onclick="updateQty('{{ $item['id'] }}', {{ $item['qty'] - 1 }})">−</button>
                                        <input type="text" class="qty-input" value="{{ $item['qty'] }}" readonly>
                                        <button class="qty-btn" onclick="updateQty('{{ $item['id'] }}', {{ $item['qty'] + 1 }})">+</button>
                                    </div>
                                    <button class="btn btn-ghost" style="color:#e11d48; font-size:13px;" onclick="removeItem('{{ $item['id'] }}')">Hapus</button>
                                </div>
                            </div>
                            <div style="text-align:right; font-weight:800; color:#dc2626; white-space:nowrap;">
                                Rp {{ number_format($item['price'] * $item['qty'], 0, ',', '.') }}
                            </div>
                        </div>
                        @endforeach
                    </div>
                </div>
            </div>

            {{-- Order Summary --}}
            <div>
                <div class="sidebar-card">
                    <h3 style="margin-bottom:24px;">Ringkasan Pesanan</h3>
                    <div class="summary-row"><span>Subtotal</span><span id="cart-subtotal">Rp {{ number_format($subtotal, 0, ',', '.') }}</span></div>
                    <div class="summary-row"><span>PPN (11%)</span><span id="cart-tax">Rp {{ number_format($tax, 0, ',', '.') }}</span></div>
                    <div class="summary-total"><span>Total</span><span id="cart-total">Rp {{ number_format($total, 0, ',', '.') }}</span></div>

                    {{-- Checkout Form --}}
                    <form method="POST" action="{{ route('cart.checkout') }}">
                        @csrf
                        <div class="form-group">
                            <label class="form-label">Nomor WhatsApp</label>
                            <input type="text" name="phone" class="form-input" placeholder="08123456789" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Alamat Pengiriman</label>
                            <textarea name="address" class="form-input" rows="2" placeholder="Alamat lengkap" required></textarea>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Metode Pengiriman</label>
                            <select name="shippingMethod" class="form-input" required>
                                <option value="">Pilih metode...</option>
                                <option value="Ambil di Toko">Ambil di Toko</option>
                                <option value="Kurir Toko Sinar Abadi">Kurir Toko Sinar Abadi</option>
                                <option value="Ekspedisi JNE">Ekspedisi JNE</option>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-primary w-100" style="font-size:16px; margin-top:16px;">
                            Buat Pesanan
                        </button>
                    </form>
                </div>
            </div>
        </div>
        @else
        <div class="text-center" style="padding:80px 20px;">
            <svg viewBox="0 0 24 24" width="80" height="80" fill="#cbd5e1"><path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/></svg>
            <h3 style="margin-top:16px;">Keranjang Kosong</h3>
            <p class="text-muted" style="margin-top:8px;">Belum ada produk di keranjang Anda.</p>
            <a href="{{ route('katalog') }}" class="btn btn-primary mt-6">Belanja Sekarang</a>
        </div>
        @endif
    </div>
</section>
@endsection

@push('scripts')
<script>
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    function updateQty(productId, newQty) {
        fetch('{{ route("cart.update") }}', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': csrfToken },
            body: JSON.stringify({ id: productId, qty: newQty })
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) location.reload();
        });
    }

    function removeItem(productId) {
        fetch('/cart/' + productId, {
            method: 'DELETE',
            headers: { 'X-CSRF-TOKEN': csrfToken }
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) location.reload();
        });
    }
</script>
@endpush
