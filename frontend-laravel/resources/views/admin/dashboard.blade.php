@extends('layouts.app')

@section('title', 'Panel Admin – Sinar Abadi')

@section('content')
<section class="section active">
    <div class="container">
        <h2 class="section-title">Modul Operasional Admin</h2>
        <div class="dashboard-layout">
            {{-- Sidebar --}}
            <aside>
                <div class="sidebar-card">
                    <div class="user-profile">
                        <div class="avatar" style="background:var(--color-accent);">A</div>
                        <div>
                            <h4>{{ session('auth_name', 'Admin') }}</h4>
                            <p class="text-muted" style="font-size:12px;">Divisi Keuangan & Verifikasi</p>
                        </div>
                    </div>
                    <ul class="sidebar-menu">
                        <li class="{{ $tab === 'orders' ? 'active' : '' }}">
                            <a href="{{ route('admin.dashboard', ['tab' => 'orders']) }}" style="color:inherit; text-decoration:none; display:flex; justify-content:space-between; width:100%;">
                                Manajemen Pembelian
                                @if($pendingCount > 0)<span class="badge">{{ $pendingCount }}</span>@endif
                            </a>
                        </li>
                        <li class="{{ $tab === 'customers' ? 'active' : '' }}">
                            <a href="{{ route('admin.dashboard', ['tab' => 'customers']) }}" style="color:inherit; text-decoration:none; width:100%; display:block;">
                                Manajemen Customer
                            </a>
                        </li>
                    </ul>
                </div>
            </aside>

            {{-- Main Content --}}
            <div class="dashboard-content">
                @if($tab === 'orders')
                <div class="table-card">
                    <div class="table-header">
                        <h3>Data Pembelian & Validasi Bukti</h3>
                        <form method="GET" action="{{ route('admin.dashboard') }}">
                            <input type="hidden" name="tab" value="orders">
                            <select name="status" class="form-input" style="width:200px; padding:8px;" onchange="this.form.submit()">
                                <option value="all" {{ $statusFilter === 'all' ? 'selected' : '' }}>Semua Status</option>
                                <option value="pending" {{ $statusFilter === 'pending' ? 'selected' : '' }}>Perlu Validasi</option>
                                <option value="success" {{ $statusFilter === 'success' ? 'selected' : '' }}>Lunas</option>
                                <option value="refund" {{ $statusFilter === 'refund' ? 'selected' : '' }}>Di-refund</option>
                                <option value="cancelled" {{ $statusFilter === 'cancelled' ? 'selected' : '' }}>Dibatalkan</option>
                            </select>
                        </form>
                    </div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Ref ID</th>
                                    <th>Pelanggan</th>
                                    <th>Tagihan Final</th>
                                    <th>Status</th>
                                    <th>Bukti</th>
                                    <th>Aksi</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($orders as $order)
                                <tr>
                                    <td>
                                        <strong>{{ $order['id'] }}</strong><br>
                                        <small class="text-muted">{{ $order['date'] }}</small>
                                    </td>
                                    <td>{{ $order['customer'] ?? '-' }}</td>
                                    <td style="font-weight:700; color:#dc2626;">Rp {{ number_format($order['total'], 0, ',', '.') }}</td>
                                    <td><span class="status-pill {{ $order['status'] }}">{{ ucfirst($order['status']) }}</span></td>
                                    <td>
                                        @if($order['proofUploaded'])
                                            <span class="status-pill success">✅ Ada</span>
                                        @else
                                            <span class="status-pill pending">⏳ Belum</span>
                                        @endif
                                    </td>
                                    <td>
                                        @if($order['status'] === 'pending')
                                        <div class="d-flex gap-2">
                                            <form method="POST" action="{{ route('admin.update-status', $order['id']) }}">
                                                @csrf @method('PUT')
                                                <input type="hidden" name="status" value="success">
                                                <button type="submit" class="btn btn-primary" style="font-size:12px; padding:6px 12px;">✅ Validasi</button>
                                            </form>
                                            <form method="POST" action="{{ route('admin.update-status', $order['id']) }}">
                                                @csrf @method('PUT')
                                                <input type="hidden" name="status" value="cancelled">
                                                <button type="submit" class="btn btn-outline" style="font-size:12px; padding:6px 12px; color:#e11d48;">❌ Tolak</button>
                                            </form>
                                        </div>
                                        @else
                                            <span class="text-muted" style="font-size:12px;">Sudah diproses</span>
                                        @endif
                                    </td>
                                </tr>
                                @empty
                                <tr><td colspan="6" class="text-center text-muted" style="padding:40px;">Tidak ada data pesanan.</td></tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>

                @elseif($tab === 'customers')
                <div class="table-card">
                    <div class="table-header"><h3>Data Customer & Blokir Akses</h3></div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr><th>Username</th><th>Nama Lengkap</th><th>Status Akses</th><th>Aksi</th></tr>
                            </thead>
                            <tbody>
                                @forelse($customers as $cust)
                                <tr>
                                    <td style="font-weight:700;">{{ $cust['username'] }}</td>
                                    <td>{{ $cust['name'] }}</td>
                                    <td>
                                        @if($cust['isBlocked'])
                                            <span class="status-pill cancelled">🚫 Diblokir</span>
                                        @else
                                            <span class="status-pill success">✅ Aktif</span>
                                        @endif
                                    </td>
                                    <td>
                                        <form method="POST" action="{{ route('admin.toggle-block', $cust['username']) }}">
                                            @csrf @method('PUT')
                                            <button type="submit" class="btn {{ $cust['isBlocked'] ? 'btn-primary' : 'btn-outline' }}" style="font-size:12px; padding:6px 12px;">
                                                {{ $cust['isBlocked'] ? '🔓 Buka Akses' : '🔒 Blokir' }}
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                                @empty
                                <tr><td colspan="4" class="text-center text-muted" style="padding:40px;">Tidak ada customer terdaftar.</td></tr>
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
