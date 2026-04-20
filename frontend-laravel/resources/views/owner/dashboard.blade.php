@extends('layouts.app')

@section('title', 'Laporan Eksekutif – Sinar Abadi')

@section('content')
<section class="section active">
    <div class="container">
        <h2 class="section-title">Laporan Eksekutif Direksi</h2>
        <div class="dashboard-layout">
            {{-- Sidebar --}}
            <aside>
                <div class="sidebar-card">
                    <div class="user-profile">
                        <div class="avatar" style="background:linear-gradient(135deg, #1e293b, #0f172a);">O</div>
                        <div>
                            <h4>{{ session('auth_name', 'Owner') }}</h4>
                            <p class="text-muted" style="font-size:12px;">Super Administrator</p>
                        </div>
                    </div>
                    <ul class="sidebar-menu">
                        <li class="{{ $tab === 'report' ? 'active' : '' }}">
                            <a href="{{ route('owner.dashboard', ['tab' => 'report']) }}" style="color:inherit; text-decoration:none; width:100%; display:block;">Ringkasan Finansial</a>
                        </li>
                        <li class="{{ $tab === 'stock' ? 'active' : '' }}">
                            <a href="{{ route('owner.dashboard', ['tab' => 'stock']) }}" style="color:inherit; text-decoration:none; width:100%; display:block;">Manajemen Stok Barang</a>
                        </li>
                        <li class="{{ $tab === 'shipping' ? 'active' : '' }}">
                            <a href="{{ route('owner.dashboard', ['tab' => 'shipping']) }}" style="color:inherit; text-decoration:none; width:100%; display:block;">Update Logistik / Resi</a>
                        </li>
                        <li class="{{ $tab === 'admin' ? 'active' : '' }}">
                            <a href="{{ route('owner.dashboard', ['tab' => 'admin']) }}" style="color:inherit; text-decoration:none; width:100%; display:block;">Kelola User Admin</a>
                        </li>
                    </ul>
                </div>
            </aside>

            {{-- Main Content --}}
            <div class="dashboard-content">

                @if($tab === 'report')
                {{-- Financial Report --}}
                <div class="stats-grid">
                    <div class="stat-card">
                        <span class="stat-title">Total Pendapatan</span>
                        <span class="stat-value" style="color:#059669;">Rp {{ number_format($totalRevenue, 0, ',', '.') }}</span>
                    </div>
                    <div class="stat-card">
                        <span class="stat-title">Total Pesanan</span>
                        <span class="stat-value">{{ $totalOrders }}</span>
                    </div>
                    <div class="stat-card">
                        <span class="stat-title">Menunggu Validasi</span>
                        <span class="stat-value" style="color:#d97706;">{{ $pendingOrders }}</span>
                    </div>
                    <div class="stat-card">
                        <span class="stat-title">Pesanan Sukses</span>
                        <span class="stat-value" style="color:#059669;">{{ $successOrders }}</span>
                    </div>
                </div>

                <div class="table-card">
                    <div class="table-header"><h3>Semua Pesanan</h3></div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead><tr><th>Ref ID</th><th>Pelanggan</th><th>Total</th><th>Status</th><th>Pengiriman</th></tr></thead>
                            <tbody>
                                @forelse($orders as $order)
                                <tr>
                                    <td><strong>{{ $order['id'] }}</strong><br><small class="text-muted">{{ $order['date'] }}</small></td>
                                    <td>{{ $order['customer'] ?? '-' }}</td>
                                    <td style="font-weight:700; color:#dc2626;">Rp {{ number_format($order['total'], 0, ',', '.') }}</td>
                                    <td><span class="status-pill {{ $order['status'] }}">{{ ucfirst($order['status']) }}</span></td>
                                    <td><span class="status-pill info">{{ $order['shippingStatus'] }}</span></td>
                                </tr>
                                @empty
                                <tr><td colspan="5" class="text-center text-muted" style="padding:40px;">Belum ada pesanan.</td></tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>

                @elseif($tab === 'stock')
                {{-- Stock Management --}}
                <div class="table-card">
                    <div class="table-header"><h3>Manajemen Stok Barang</h3></div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead><tr><th>ID</th><th>Nama Produk</th><th>Kategori</th><th>Stok</th><th>Terjual</th><th>Aksi Stok</th></tr></thead>
                            <tbody>
                                @foreach($products as $prod)
                                <tr>
                                    <td style="font-weight:700;">{{ $prod['id'] }}</td>
                                    <td>{{ $prod['name'] }}</td>
                                    <td><span class="text-muted">{{ $prod['category'] }}</span></td>
                                    <td>
                                        <span style="font-weight:800; color:{{ $prod['stock'] < 20 ? '#dc2626' : '#059669' }};">
                                            {{ $prod['stock'] }}
                                        </span>
                                    </td>
                                    <td>{{ $prod['sold'] }}</td>
                                    <td>
                                        <form method="POST" action="{{ route('owner.update-stock', $prod['id']) }}" class="d-flex gap-2 align-center">
                                            @csrf @method('PUT')
                                            <input type="number" name="amount" class="form-input" style="width:80px; padding:6px 8px; font-size:13px;" placeholder="+/-" required>
                                            <button type="submit" class="btn btn-outline" style="font-size:12px; padding:6px 12px;">Update</button>
                                        </form>
                                    </td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                </div>

                @elseif($tab === 'shipping')
                {{-- Shipping Management --}}
                <div class="table-card">
                    <div class="table-header"><h3>Update Logistik / Resi</h3></div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead><tr><th>Ref ID</th><th>Pelanggan</th><th>Metode Kirim</th><th>Status Saat Ini</th><th>Update Status</th></tr></thead>
                            <tbody>
                                @forelse($orders as $order)
                                @if($order['status'] === 'success')
                                <tr>
                                    <td><strong>{{ $order['id'] }}</strong></td>
                                    <td>{{ $order['customer'] ?? '-' }}</td>
                                    <td>{{ $order['shippingMethod'] }}</td>
                                    <td><span class="status-pill info">{{ $order['shippingStatus'] }}</span></td>
                                    <td>
                                        <form method="POST" action="{{ route('owner.update-shipping', $order['id']) }}" class="d-flex gap-2 align-center">
                                            @csrf @method('PUT')
                                            <select name="shippingStatus" class="form-input" style="width:200px; padding:6px 8px; font-size:13px;">
                                                <option value="Menunggu Validasi">Menunggu Validasi</option>
                                                <option value="Pembayaran Dikonfirmasi">Pembayaran Dikonfirmasi</option>
                                                <option value="Sedang Dikemas">Sedang Dikemas</option>
                                                <option value="Dalam Pengiriman">Dalam Pengiriman</option>
                                                <option value="Selesai">Selesai</option>
                                            </select>
                                            <button type="submit" class="btn btn-primary" style="font-size:12px; padding:6px 12px;">Update</button>
                                        </form>
                                    </td>
                                </tr>
                                @endif
                                @empty
                                <tr><td colspan="5" class="text-center text-muted" style="padding:40px;">Tidak ada pesanan untuk diperbarui.</td></tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>

                @elseif($tab === 'admin')
                {{-- Admin Management --}}
                <div class="table-card" style="margin-bottom:32px;">
                    <div class="table-header"><h3>Buat Admin Baru</h3></div>
                    <div style="padding:24px;">
                        <form method="POST" action="{{ route('owner.create-admin') }}" class="d-flex gap-4 align-center" style="flex-wrap:wrap;">
                            @csrf
                            <div class="form-group" style="margin-bottom:0; flex:1; min-width:150px;">
                                <input type="text" name="username" class="form-input" placeholder="Username" required>
                            </div>
                            <div class="form-group" style="margin-bottom:0; flex:1; min-width:150px;">
                                <input type="password" name="password" class="form-input" placeholder="Password" required>
                            </div>
                            <div class="form-group" style="margin-bottom:0; flex:1; min-width:150px;">
                                <input type="text" name="name" class="form-input" placeholder="Nama Lengkap" required>
                            </div>
                            <button type="submit" class="btn btn-primary">+ Buat Admin</button>
                        </form>
                    </div>
                </div>

                <div class="table-card">
                    <div class="table-header"><h3>Daftar Admin</h3></div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead><tr><th>Username</th><th>Nama</th><th>Aksi</th></tr></thead>
                            <tbody>
                                @forelse($admins as $admin)
                                <tr>
                                    <td style="font-weight:700;">{{ $admin['username'] }}</td>
                                    <td>{{ $admin['name'] }}</td>
                                    <td>
                                        <form method="POST" action="{{ route('owner.delete-admin', $admin['username']) }}" onsubmit="return confirm('Hapus admin {{ $admin['username'] }}?')">
                                            @csrf @method('DELETE')
                                            <button type="submit" class="btn btn-outline" style="font-size:12px; padding:6px 12px; color:#e11d48;">🗑️ Hapus</button>
                                        </form>
                                    </td>
                                </tr>
                                @empty
                                <tr><td colspan="3" class="text-center text-muted" style="padding:40px;">Tidak ada admin terdaftar.</td></tr>
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
