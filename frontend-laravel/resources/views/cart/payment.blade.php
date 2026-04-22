@extends('layouts.app')

@section('title', 'Pembayaran – Sinar Abadi')

@section('content')
    <div style="background-color: #f8fafc; min-height: calc(100vh - 64px); padding: 40px 20px;">
        <div class="container" style="max-width: 1000px;">

            <div
                style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #e2e8f0; padding-bottom:16px; margin-bottom:32px;">
                <div style="font-size:1.5rem; font-weight:800; color:#dc2626;">
                    SINAR ABADI <span style="color:#cbd5e1; margin:0 12px; font-weight:400;">|</span> <span
                        style="color:#059669; font-size:1rem;">✔ PEMBAYARAN AMAN</span>
                </div>
            </div>

            <div class="dashboard-layout" style="grid-template-columns: 1fr 380px; gap: 32px; align-items: start;">

                {{-- Left: Payment Methods --}}
                <div style="background:#fff; border-radius:12px; padding:32px; box-shadow:0 1px 3px rgba(0,0,0,0.1);">
                    <h2
                        style="font-size:1.25rem; font-weight:700; color:#1e293b; border-bottom:1px solid #e2e8f0; padding-bottom:16px; margin-bottom:24px;">
                        METODE PEMBAYARAN</h2>
                    <p style="color:#64748b; margin-bottom:24px;">Silahkan pilih metode pembayaran yang Anda inginkan:</p>

                    <form method="POST" action="{{ route('cart.checkout') }}" id="paymentForm">
                        @csrf

                        <label
                            style="display:flex; align-items:center; border:1px solid #e2e8f0; border-radius:8px; padding:20px; cursor:pointer; margin-bottom:16px; transition:all 0.2s;"
                            onchange="highlight(this)">
                            <input type="radio" name="paymentMethod" value="Virtual Account" required
                                style="width:20px; height:20px; accent-color:#2563eb; margin-right:16px;">
                            <span style="font-weight:700; color:#1e293b;">Virtual Account (Transfer Bank)</span>
                        </label>

                        <label
                            style="display:flex; align-items:center; border:1px solid #e2e8f0; border-radius:8px; padding:20px; cursor:pointer; margin-bottom:16px; transition:all 0.2s;"
                            onchange="highlight(this)">
                            <input type="radio" name="paymentMethod" value="Credit Card" required
                                style="width:20px; height:20px; accent-color:#2563eb; margin-right:16px;">
                            <span style="font-weight:700; color:#1e293b;">Credit Card - Full Payment</span>
                        </label>

                        <div
                            style="margin-top:32px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; padding:20px; font-size:0.9rem; color:#475569;">
                            <strong style="display:block; color:#1e293b; margin-bottom:8px; font-size:1rem;">Sinar Abadi
                                (Pusat)</strong>
                            <p style="margin:0;">Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit,</p>
                            <p style="margin:0;">Kabupaten Malang, Jawa Timur 65181 • +62 8123388670</p>
                        </div>

                        <div style="margin-top:32px;">
                            <button type="submit" class="btn btn-primary"
                                style="background:#111827; border-color:#111827; width:100%; font-size:1rem; padding:16px; font-weight:700;">BAYAR
                                SEKARANG</button>
                        </div>
                    </form>
                </div>

                {{-- Right: Summaries --}}
                <div style="display:flex; flex-direction:column; gap:24px;">

                    {{-- Pricing --}}
                    <div style="background:#fff; border-radius:12px; padding:24px; box-shadow:0 1px 3px rgba(0,0,0,0.1);">
                        <h3
                            style="font-size:1.1rem; font-weight:700; border-bottom:1px solid #e2e8f0; padding-bottom:12px; margin-bottom:16px;">
                            Ringkasan Pembelian</h3>
                        <div
                            style="display:flex; justify-content:space-between; margin-bottom:12px; color:#64748b; font-size:0.95rem;">
                            <span>Subtotal Produk</span>
                            <span style="font-weight:600; color:#1e293b;">Rp
                                {{ number_format($subtotal, 0, ',', '.') }}</span>
                        </div>
                        <div
                            style="display:flex; justify-content:space-between; margin-bottom:12px; color:#64748b; font-size:0.95rem;">
                            <span>PPN (11%)</span>
                            <span style="font-weight:600; color:#1e293b;">Rp {{ number_format($tax, 0, ',', '.') }}</span>
                        </div>
                        <div
                            style="display:flex; justify-content:space-between; margin-bottom:16px; color:#64748b; font-size:0.95rem;">
                            <span>Ongkos Kirim</span>
                            <span
                                style="font-weight:600; color:#1e293b;">{{ $shippingCost == 0 ? 'Gratis' : 'Rp ' . number_format($shippingCost, 0, ',', '.') }}</span>
                        </div>
                        <div
                            style="display:flex; justify-content:space-between; border-top:1px solid #e2e8f0; padding-top:16px; font-size:1.1rem;">
                            <span style="font-weight:700;">Grand Total</span>
                            <span style="font-weight:800; color:#dc2626; font-size:1.25rem;">Rp
                                {{ number_format($grandTotal, 0, ',', '.') }}</span>
                        </div>
                    </div>

                    {{-- Products --}}
                    <div style="background:#fff; border-radius:12px; padding:24px; box-shadow:0 1px 3px rgba(0,0,0,0.1);">
                        <h3
                            style="font-size:1.1rem; font-weight:700; border-bottom:1px solid #e2e8f0; padding-bottom:12px; margin-bottom:16px;">
                            Ringkasan Produk</h3>
                        <div style="max-height:220px; overflow-y:auto; padding-right:8px;">
                            @foreach($cart as $item)
                                <div style="display:flex; gap:16px; margin-bottom:16px;">
                                    <div style="width:60px; height:60px; background:#f1f5f9; border-radius:6px; flex-shrink:0;">
                                    </div>
                                    <div>
                                        <div style="font-size:0.9rem; font-weight:600; color:#1e293b; line-height:1.3;">
                                            {{ $item['name'] }}</div>
                                        <div style="font-size:0.8rem; color:#64748b; margin-top:4px;">{{ $item['qty'] }} x Rp
                                            {{ number_format($item['price'], 0, ',', '.') }}</div>
                                    </div>
                                </div>
                            @endforeach
                        </div>
                    </div>

                    {{-- Logistics info --}}
                    <div style="background:#fff; border-radius:12px; padding:24px; box-shadow:0 1px 3px rgba(0,0,0,0.1);">
                        <div
                            style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #e2e8f0; padding-bottom:12px; margin-bottom:16px;">
                            <h3 style="font-size:1.1rem; font-weight:700;">Info Pengiriman</h3>
                            <a href="{{ route('cart.index') }}"
                                style="color:#ef4444; font-size:0.85rem; font-weight:600; text-decoration:none;">Ubah</a>
                        </div>
                        <p style="font-size:0.95rem; font-weight:600; color:#1e293b; margin-bottom:4px;">
                            {{ $logistics['shippingMethod'] }}</p>
                        <p style="font-size:0.85rem; color:#64748b; line-height:1.5;">Tujuan:
                            {{ $logistics['address'] }}<br>WA: {{ $logistics['phone'] }}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        function highlight(label) {
            document.querySelectorAll('form label').forEach(l => {
                l.style.borderColor = '#e2e8f0';
                l.style.backgroundColor = 'transparent';
                l.style.boxShadow = 'none';
            });
            label.style.borderColor = '#3b82f6';
            label.style.backgroundColor = '#eff6ff';
            label.style.boxShadow = '0 0 0 1px #3b82f6';
        }

        // pre-highlight on load if checked
        document.querySelectorAll('input[type="radio"]').forEach(radio => {
            if (radio.checked) highlight(radio.closest('label'));
        });
    </script>
@endpush