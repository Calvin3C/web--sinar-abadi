@extends('layouts.app')

@section('title', 'Masuk – Sinar Abadi')

@section('content')
<section class="section active">
    <div class="container">
        <div class="auth-container">
            <div class="auth-header">
                <h2 id="auth-title">{{ session('mode') === 'register' ? 'Registrasi Customer' : 'Autentikasi Sistem' }}</h2>
                <p style="color:#cbd5e1; font-size:14px;">Portal Manajemen Sinar Abadi Terintegrasi</p>
            </div>

            <div class="auth-body">
                {{-- Role Tabs (Login Mode) --}}
                <div id="login-section">
                    <div class="role-tabs" id="auth-role-selector">
                        <div class="role-tab active" data-role="customer" onclick="switchRole('customer', this)">Customer</div>
                        <div class="role-tab" data-role="admin" onclick="switchRole('admin', this)">Admin</div>
                        <div class="role-tab" data-role="owner" onclick="switchRole('owner', this)">Owner</div>
                    </div>

                    <form method="POST" action="{{ route('login.process') }}" id="login-form">
                        @csrf
                        <input type="hidden" name="role" id="login-role" value="customer">

                        <div class="form-group">
                            <label class="form-label">Username</label>
                            <input type="text" name="username" class="form-input" placeholder="Masukkan username" value="{{ old('username') }}" required>
                        </div>

                        <div class="form-group mb-8">
                            <label class="form-label">Kata Sandi</label>
                            <input type="password" name="password" class="form-input" placeholder="••••••••" required>
                        </div>

                        <div class="dummy-data-box">
                            <b>Kredensial Akses Database:</b><br><br>
                            Pelanggan: user <code>budi</code> | pass <code>123</code><br>
                            Sistem Admin: user <code>admin</code> | pass <code>admin123</code><br>
                            Direksi/Owner: user <code>owner</code> | pass <code>owner123</code>
                        </div>

                        <button type="submit" class="btn btn-primary w-100" style="font-size:16px;">
                            Masuk Sebagai <span id="lbl-btn-role">Customer</span>
                        </button>
                    </form>

                    <div class="text-center mt-8 text-muted" style="font-size:14px;">
                        Pelanggan baru? <a href="javascript:void(0)" onclick="toggleAuthMode()">Buat Akun Customer</a>
                    </div>
                </div>

                {{-- Register Section --}}
                <div id="register-section" style="display:none;">
                    <form method="POST" action="{{ route('register.process') }}">
                        @csrf
                        <div class="form-group">
                            <label class="form-label">Nama Lengkap</label>
                            <input type="text" name="name" class="form-input" placeholder="Masukkan nama lengkap" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Username</label>
                            <input type="text" name="username" class="form-input" placeholder="Buat username unik" required>
                        </div>

                        <div class="form-group mb-8">
                            <label class="form-label">Kata Sandi</label>
                            <input type="password" name="password" class="form-input" placeholder="Min. 3 karakter" required>
                        </div>

                        <button type="submit" class="btn btn-primary w-100" style="font-size:16px;">Daftar Sekarang</button>
                    </form>

                    <div class="text-center mt-8 text-muted" style="font-size:14px;">
                        Sudah punya akun? <a href="javascript:void(0)" onclick="toggleAuthMode()">Masuk di sini</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
@endsection

@push('scripts')
<script>
    function switchRole(role, el) {
        document.querySelectorAll('.role-tab').forEach(t => t.classList.remove('active'));
        el.classList.add('active');
        document.getElementById('login-role').value = role;
        document.getElementById('lbl-btn-role').textContent =
            role === 'customer' ? 'Customer' : role === 'admin' ? 'Admin' : 'Owner';
    }

    function toggleAuthMode() {
        const loginSection = document.getElementById('login-section');
        const registerSection = document.getElementById('register-section');
        const title = document.getElementById('auth-title');

        if (loginSection.style.display === 'none') {
            loginSection.style.display = '';
            registerSection.style.display = 'none';
            title.textContent = 'Autentikasi Sistem';
        } else {
            loginSection.style.display = 'none';
            registerSection.style.display = '';
            title.textContent = 'Registrasi Customer';
        }
    }

    @if(session('mode') === 'register')
        toggleAuthMode();
    @endif
</script>
@endpush
