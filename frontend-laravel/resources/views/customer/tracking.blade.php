@extends('layouts.app')

@section('title', 'Lacak Pesanan – Sinar Abadi')

@section('content')
<section class="section active">
    <div class="container">
        <h2 class="section-title">🔍 Lacak Pesanan Real-Time</h2>

        <div class="tracking-search-wrap" style="max-width:600px; margin:0 auto 48px;">
            <p class="text-muted mb-6" style="font-size:14px;">Masukkan nomor referensi pesanan Anda untuk melacak status pengiriman secara langsung.</p>
            <form method="GET" action="{{ route('customer.tracking') }}" class="tracking-search-box">
                <input type="text" name="order_id" placeholder="Masukkan Nomor Pesanan (misal: ORD-260401-081)" value="{{ $orderId ?? '' }}">
                <button class="btn btn-primary" type="submit">Lacak</button>
            </form>
        </div>

        @if(isset($orderId) && $orderId)
            @if($order)
            <div class="tracking-result" style="max-width:800px; margin:0 auto;">
                <div class="tracking-card">
                    <div class="tracking-card-header">
                        <h3>DETAIL PESANAN</h3>
                        <div class="tracking-order-id">{{ $order['id'] }}</div>
                        <div class="tracking-meta">
                            <span>📅 {{ $order['date'] }}</span>
                            <span>📦 {{ $order['shippingMethod'] }}</span>
                            <span>
                                <span class="live-dot"></span>
                                {{ $order['shippingStatus'] }}
                            </span>
                        </div>
                    </div>

                    {{-- Timeline --}}
                    @php
                        $steps = ['Menunggu Validasi', 'Pembayaran Dikonfirmasi', 'Sedang Dikemas', 'Dalam Pengiriman', 'Selesai'];
                        $currentIndex = array_search($order['shippingStatus'], $steps);
                        if ($currentIndex === false) $currentIndex = 0;
                        $progressWidth = $currentIndex > 0 ? (($currentIndex / (count($steps) - 1)) * 100) : 0;
                    @endphp
                    <div class="tracking-timeline">
                        <div class="timeline-steps">
                            <div class="timeline-progress" style="width:{{ $progressWidth }}%;"></div>
                            @foreach($steps as $index => $step)
                            <div class="timeline-step {{ $index < $currentIndex ? 'completed' : ($index === $currentIndex ? 'active' : '') }}">
                                <div class="step-circle">
                                    @if($index < $currentIndex)
                                    <svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                                    @else
                                    <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
                                    @endif
                                </div>
                                <span class="step-label">{{ $step }}</span>
                            </div>
                            @endforeach
                        </div>
                    </div>

                    {{-- Details --}}
                    <div class="tracking-details">
                        <div class="tracking-details-grid">
                            <div class="tracking-detail-item">
                                <label>Status Bayar</label>
                                <span class="status-pill {{ $order['status'] }}">{{ ucfirst($order['status']) }}</span>
                            </div>
                            <div class="tracking-detail-item">
                                <label>Telepon</label>
                                <span>{{ $order['phone'] }}</span>
                            </div>
                            <div class="tracking-detail-item">
                                <label>Alamat</label>
                                <span>{{ $order['address'] }}</span>
                            </div>
                            <div class="tracking-detail-item">
                                <label>Total</label>
                                <span style="color:#dc2626; font-size:18px;">Rp {{ number_format($order['total'], 0, ',', '.') }}</span>
                            </div>
                        </div>
                    </div>

                    {{-- Items --}}
                    <div class="tracking-items-list">
                        <h4>Item Pesanan</h4>
                        @foreach($order['items'] ?? [] as $item)
                        <div class="tracking-item-row">
                            <span class="tracking-item-name">{{ $item['name'] }}</span>
                            <span class="tracking-item-qty">× {{ $item['qty'] }}</span>
                            <span class="tracking-item-price">Rp {{ number_format($item['price'] * $item['qty'], 0, ',', '.') }}</span>
                        </div>
                        @endforeach
                    </div>
                </div>
            </div>
            @else
            <div class="tracking-not-found" style="text-align:center; padding:60px 20px; max-width:500px; margin:0 auto;">
                <svg viewBox="0 0 24 24" width="80" height="80" fill="#cbd5e1"><path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>
                <h3 style="margin-top:16px;">Pesanan Tidak Ditemukan</h3>
                <p class="text-muted">ID pesanan "<strong>{{ $orderId }}</strong>" tidak ditemukan. Pastikan nomor pesanan sudah benar.</p>
            </div>
            @endif
        @endif
    </div>
</section>
@endsection
