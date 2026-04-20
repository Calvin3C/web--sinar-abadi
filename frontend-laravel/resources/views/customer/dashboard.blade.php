@extends('layouts.app')

@section('title', 'Dashboard Pelanggan – Sinar Abadi')

@section('content')
<section class="section active">
    <div class="container">
        <h2 class="section-title">Portal Pelanggan</h2>
        <div class="dashboard-layout">
            {{-- Sidebar --}}
            <aside>
                <div class="sidebar-card">
                    <div class="user-profile">
                        <div class="avatar">{{ strtoupper(substr(session('auth_name', 'U'), 0, 1)) }}</div>
                        <div>
                            <h4>{{ session('auth_name', 'User') }}</h4>
                            <p class="text-muted" style="font-size:12px;">Akun Reguler</p>
                        </div>
                    </div>
                    <ul class="sidebar-menu">
                        <li class="{{ $tab === 'active' ? 'active' : '' }}">
                            <a href="{{ route('customer.dashboard', ['tab' => 'active']) }}" style="color:inherit; text-decoration:none; display:flex; justify-content:space-between; width:100%;">
                                Pesanan & Pengiriman
                                <span class="badge">{{ count($activeOrders) }}</span>
                            </a>
                        </li>
                        <li class="{{ $tab === 'history' ? 'active' : '' }}">
                            <a href="{{ route('customer.dashboard', ['tab' => 'history']) }}" style="color:inherit; text-decoration:none; width:100%; display:block;">
                                Riwayat Selesai
                            </a>
                        </li>
                        <li class="{{ $tab === 'tracking' ? 'active' : '' }}">
                            <a href="{{ route('customer.tracking') }}" style="color:inherit; text-decoration:none; width:100%; display:block;">
                                🔍 Lacak Pesanan
                            </a>
                        </li>
                        <li>
                            <a href="{{ route('cart.index') }}" style="color:inherit; text-decoration:none; display:flex; justify-content:space-between; width:100%;">
                                🛒 Keranjang Belanja
                                <span class="badge">{{ collect(session('cart', []))->sum('qty') }}</span>
                            </a>
                        </li>
                    </ul>
                </div>
            </aside>

            {{-- Main Content --}}
            <div class="dashboard-content">
                @if($tab === 'active')
                {{-- Active Orders --}}
                <div class="table-card">
                    <div class="table-header"><h3>Menunggu Tindakan / Sedang Diproses</h3></div>
                    <div style="padding:24px;">
                        @forelse($activeOrders as $order)
                        <div class="order-card">
                            <div class="order-header">
                                <div>
                                    <h4 style="font-size:16px; margin-bottom:4px;">{{ $order['id'] }}</h4>
                                    <p class="text-muted" style="font-size:13px;">{{ $order['date'] }} • {{ $order['shippingMethod'] }}</p>
                                </div>
                                <div style="text-align:right;">
                                    <span class="status-pill {{ $order['status'] }}">{{ ucfirst($order['status']) }}</span>
                                    <p style="font-size:18px; font-weight:800; color:#dc2626; margin-top:8px;">
                                        Rp {{ number_format($order['total'], 0, ',', '.') }}
                                    </p>
                                </div>
                            </div>

                            {{-- Order Items --}}
                            <table class="order-items-table">
                                @foreach($order['items'] ?? [] as $item)
                                <tr>
                                    <td style="font-weight:600;">{{ $item['name'] }}</td>
                                    <td class="text-muted text-right">{{ $item['qty'] }} × Rp {{ number_format($item['price'], 0, ',', '.') }}</td>
                                </tr>
                                @endforeach
                            </table>

                            {{-- Actions --}}
                            <div class="d-flex gap-3" style="margin-top:16px;">
                                @if(!$order['proofUploaded'])
                                <form method="POST" action="{{ route('customer.upload-proof', $order['id']) }}">
                                    @csrf
                                    <button type="submit" class="btn btn-primary" style="font-size:13px; padding:10px 20px;">
                                        📤 Upload Bukti Bayar
                                    </button>
                                </form>
                                @else
                                <span class="status-pill success">✅ Bukti Terunggah</span>
                                @endif

                                <span class="status-pill info">📦 {{ $order['shippingStatus'] }}</span>
                            </div>
                        </div>
                        @empty
                        <div class="text-center text-muted" style="padding:40px;">
                            <p>Tidak ada pesanan aktif saat ini.</p>
                            <a href="{{ route('katalog') }}" class="btn btn-primary mt-4">Belanja Sekarang</a>
                        </div>
                        @endforelse
                    </div>
                </div>

                @elseif($tab === 'history')
                {{-- Order History --}}
                <div class="table-card">
                    <div class="table-header"><h3>Faktur Pembelian Selesai</h3></div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr><th>Tanggal</th><th>Ref ID</th><th>Total Pembayaran</th><th>Status</th></tr>
                            </thead>
                            <tbody>
                                @forelse($historyOrders as $order)
                                <tr>
                                    <td>{{ $order['date'] }}</td>
                                    <td style="font-weight:700;">{{ $order['id'] }}</td>
                                    <td style="font-weight:700; color:#dc2626;">Rp {{ number_format($order['total'], 0, ',', '.') }}</td>
                                    <td><span class="status-pill {{ $order['status'] }}">{{ ucfirst($order['status']) }}</span></td>
                                </tr>
                                @empty
                                <tr><td colspan="4" class="text-center text-muted" style="padding:40px;">Belum ada riwayat pesanan.</td></tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>
                @endif
            </div>
        </div>
    </div>
</section>
@endsection
