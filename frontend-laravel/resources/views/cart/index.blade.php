@extends('layouts.app')

@section('title', 'Keranjang Belanja – Sinar Abadi')

@section('content')
    <section class="section active relative">
        <div class="container">
            <h2 class="section-title">Keranjang Belanja</h2>

            @if(count($cart) > 0)
                <div class="dashboard-layout" style="grid-template-columns: 1fr 380px;">
                    {{-- Cart Items --}}
                    <div>
                        <div class="table-card">
                            <div class="table-header">
                                <h3>{{ count($cart) }} Item dalam Keranjang</h3>
                            </div>
                            <div style="padding:24px;">
                                @foreach($cart as $item)
                                    <div class="cart-item" id="cart-item-{{ $item['id'] }}">
                                        <img src="{{ $item['img'] ?: 'https://placehold.co/80x80/e2e8f0/64748b?text=No+Img' }}"
                                            alt="{{ $item['name'] }}" class="cart-item-img">
                                        <div class="cart-item-info">
                                            <span class="cart-item-title">{{ $item['name'] }}</span>
                                            <span class="cart-item-price">Rp {{ number_format($item['price'], 0, ',', '.') }}</span>
                                            @if($item['isLarge'])
                                                <span class="cart-item-size" data-category="hardware">Hardware / Plumbing</span>
                                            @else
                                                <span class="cart-item-size text-muted" data-category="umum">Kategori Umum</span>
                                            @endif
                                            <div class="d-flex align-center gap-3" style="margin-top:8px;">
                                                <div class="qty-controls">
                                                    <button type="button" class="qty-btn"
                                                        onclick="updateQty('{{ $item['id'] }}', {{ $item['qty'] - 1 }})">−</button>
                                                    <input type="text" class="qty-input" value="{{ $item['qty'] }}" readonly>
                                                    <button type="button" class="qty-btn"
                                                        onclick="updateQty('{{ $item['id'] }}', {{ $item['qty'] + 1 }})">+</button>
                                                </div>
                                                <button type="button" class="btn btn-ghost" style="color:#e11d48; font-size:13px;"
                                                    onclick="removeItem('{{ $item['id'] }}')">Hapus</button>
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

                    {{-- Checkout Sidebar --}}
                    <div>
                        <div class="sidebar-card">
                            <h3 style="margin-bottom:24px;">Ringkasan Pesanan</h3>
                            <div class="summary-row"><span>Subtotal</span><span id="cart-subtotal">Rp
                                    {{ number_format($subtotal, 0, ',', '.') }}</span></div>
                            <div class="summary-row"><span>PPN (11%)</span><span id="cart-tax">Rp
                                    {{ number_format($tax, 0, ',', '.') }}</span></div>
                            <div class="summary-total"><span>Total Produk</span><span id="cart-total">Rp
                                    {{ number_format($total, 0, ',', '.') }}</span></div>

                            <button type="button" onclick="openModal()" class="btn btn-primary w-100"
                                style="font-size:16px; margin-top:16px;">
                                Checkout & Atur Logistik
                            </button>
                        </div>
                    </div>
                </div>
            @else
                <div class="text-center" style="padding:80px 20px;">
                    <svg viewBox="0 0 24 24" width="80" height="80" fill="#cbd5e1" style="margin:0 auto;">
                        <path
                            d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z" />
                    </svg>
                    <h3 style="margin-top:16px;">Keranjang Kosong</h3>
                    <p class="text-muted" style="margin-top:8px;">Belum ada produk di keranjang Anda.</p>
                    <a href="{{ route('katalog') }}" class="btn btn-primary"
                        style="margin-top:24px; display:inline-block;">Belanja Sekarang</a>
                </div>
            @endif

            {{-- Logistics Modal (Vanilla JS implementation since Alpine/React isn't guaranteed full setup in blade) --}}
            <div id="logisticsModal" class="modal-overlay"
                style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.5); z-index:999; align-items:center; justify-content:center;">
                <div class="modal-content"
                    style="background:#fff; border-radius:12px; width:100%; max-width:500px; padding:24px; box-shadow:0 20px 25px -5px rgba(0,0,0,0.1);">
                    <div
                        style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px; border-bottom:1px solid #e2e8f0; padding-bottom:16px;">
                        <h2 style="font-size:1.25rem; font-weight:700;">Detail Pengiriman & Logistik</h2>
                        <button type="button" onclick="closeModal()"
                            style="background:none; border:none; cursor:pointer; font-size:1.5rem; color:#94a3b8;">&times;</button>
                    </div>

                    <form id="logisticsForm" method="POST" action="{{ route('cart.setLogistics') }}"
                        onsubmit="return prepareAddress()">
                        @csrf
                        <input type="hidden" name="address" id="finalAddress" value="">

                        <div class="form-group mb-4">
                            <label class="form-label font-bold">Nomor WhatsApp (Aktif) <span
                                    style="color:red">*</span></label>
                            <input type="text" name="phone" class="form-input" placeholder="Contoh: 08123456789" required
                                style="width:100%; padding:10px; border-radius:6px; border:1px solid #cbd5e1;">
                            <small style="color:#64748b; margin-top:4px; display:block;">Diperlukan untuk notifikasi
                                resi.</small>
                        </div>

                        <div class="form-group mb-4">
                            <label class="form-label font-bold" style="margin-bottom:8px; display:block;">Pilih Metode
                                Pengiriman <span style="color:red">*</span></label>

                            <label class="shipping-option"
                                style="display:block; border:1px solid #e2e8f0; border-radius:8px; padding:12px; margin-bottom:8px; cursor:pointer;"
                                onchange="toggleAddressForm()">
                                <input type="radio" name="shippingMethod" value="Ambil di Toko" required>
                                <span style="font-weight:600; margin-left:8px;">Ambil di Toko</span>
                                <div style="font-size:0.8rem; color:#64748b; margin-left:24px; margin-top:4px;">Bebas biaya.
                                    Ambil langsung di toko Sinar Abadi.</div>
                            </label>

                            <label class="shipping-option" id="kurirTokoCard"
                                style="display:block; border:1px solid #e2e8f0; border-radius:8px; padding:12px; margin-bottom:8px; cursor:pointer;"
                                onchange="toggleAddressForm()">
                                <input type="radio" name="shippingMethod" id="kurirTokoRadio" value="Kurir Toko Sinar Abadi"
                                    required>
                                <span style="font-weight:600; margin-left:8px;">Kurir Toko Sinar Abadi</span>
                                <div style="font-size:0.8rem; color:#64748b; margin-left:24px; margin-top:4px;">Khusus area
                                    Malang. Bebas ukuran/berat barang.</div>
                            </label>

                            <label class="shipping-option" id="jneCard"
                                style="display:block; border:1px solid #e2e8f0; border-radius:8px; padding:12px; margin-bottom:8px; cursor:pointer;"
                                onchange="toggleAddressForm()">
                                <input type="radio" name="shippingMethod" id="jneRadio" value="Ekspedisi JNE" required>
                                <span style="font-weight:600; margin-left:8px;">Ekspedisi JNE</span>
                                <div style="font-size:0.8rem; color:#64748b; margin-left:24px; margin-top:4px;">Luar kota.
                                    Berlaku hanya untuk barang kecil (Hardware/Plumbing).</div>
                            </label>
                        </div>

                        <!-- Formulir Detail Pengiriman (Ditampilkan khusus pengiriman kurir/ekspedisi) -->
                        <div id="detailedAddressForm"
                            style="display:none; padding-top:16px; border-top:1px solid #e2e8f0; margin-top:16px;">
                            <h3 style="font-size:1.1rem; font-weight:700; margin-bottom:16px; color:#1e293b;">Detail
                                Pengiriman</h3>

                            <div style="display:flex; gap:12px; margin-bottom:12px;">
                                <div style="flex:1;">
                                    <label class="form-label font-bold" style="font-size:0.85rem;">Nama Depan <span
                                            style="color:red">*</span></label>
                                    <input type="text" id="dt_fname" class="form-input dt-req" placeholder="Misal: Calvin"
                                        style="width:100%; padding:10px; border-radius:6px; border:1px solid #cbd5e1;">
                                </div>
                                <div style="flex:1;">
                                    <label class="form-label font-bold" style="font-size:0.85rem;">Nama Belakang <span
                                            style="color:red">*</span></label>
                                    <input type="text" id="dt_lname" class="form-input dt-req" placeholder="Misal: Sucipto"
                                        style="width:100%; padding:10px; border-radius:6px; border:1px solid #cbd5e1;">
                                </div>
                            </div>

                            <div class="form-group mb-4">
                                <label class="form-label font-bold" style="font-size:0.85rem;">Alamat Lengkap <span
                                        style="color:red">*</span></label>
                                <textarea id="dt_address" class="form-input dt-req" rows="2"
                                    placeholder="Nama Jalan, Gedung, No. Rumah"
                                    style="width:100%; padding:10px; border-radius:6px; border:1px solid #cbd5e1;"></textarea>
                            </div>

                            <div class="form-group mb-4">
                                <input type="text" id="dt_landmark" class="form-input"
                                    placeholder="Detail Patokan (Opsional)"
                                    style="width:100%; padding:10px; border-radius:6px; border:1px solid #cbd5e1;">
                            </div>

                            <div style="display:flex; gap:12px; margin-bottom:12px;">
                                <div style="flex:1;">
                                    <label class="form-label font-bold" style="font-size:0.85rem;">Negara <span
                                            style="color:red">*</span></label>
                                    <select id="dt_country" class="form-input dt-req"
                                        style="width:100%; padding:10px; border-radius:6px; border:1px solid #cbd5e1;">
                                        <option value="Indonesia">Indonesia</option>
                                    </select>
                                </div>
                                <div style="flex:1;">
                                    <label class="form-label font-bold" style="font-size:0.85rem;">Provinsi <span
                                            style="color:red">*</span></label>
                                    <select id="dt_province" class="form-input dt-req"
                                        style="width:100%; padding:10px; border-radius:6px; border:1px solid #cbd5e1;">
                                        <option value="">Silakan pilih...</option>
                                        <option value="Jawa Timur">Jawa Timur</option>
                                        <option value="Jawa Tengah">Jawa Tengah</option>
                                        <option value="Jawa Barat">Jawa Barat</option>
                                        <option value="DKI Jakarta">DKI Jakarta</option>
                                    </select>
                                </div>
                            </div>

                            <div style="display:flex; gap:12px; margin-bottom:12px;">
                                <div style="flex:1;">
                                    <label class="form-label font-bold" style="font-size:0.85rem;">Kota/Kab <span
                                            style="color:red">*</span></label>
                                    <select id="dt_city" class="form-input dt-req"
                                        style="width:100%; padding:10px; border-radius:6px; border:1px solid #cbd5e1;">
                                        <option value="">Silakan pilih kota.</option>
                                        <option value="Kota Malang">Kota Malang</option>
                                        <option value="Kabupaten Malang">Kabupaten Malang</option>
                                        <option value="Surabaya">Surabaya</option>
                                        <option value="Jakarta">Jakarta</option>
                                    </select>
                                </div>
                                <div style="flex:1;">
                                    <label class="form-label font-bold" style="font-size:0.85rem;">Kecamatan <span
                                            style="color:red">*</span></label>
                                    <input type="text" id="dt_district" class="form-input dt-req"
                                        placeholder="Pilih kecamatan."
                                        style="width:100%; padding:10px; border-radius:6px; border:1px solid #cbd5e1;">
                                </div>
                            </div>

                            <div class="form-group mb-4">
                                <label class="form-label font-bold" style="font-size:0.85rem;">Postal Code <span
                                        style="color:red">*</span></label>
                                <input type="text" id="dt_postal" class="form-input dt-req" placeholder=""
                                    style="width:100%; padding:10px; border-radius:6px; border:1px solid #cbd5e1;">
                            </div>
                        </div>

                        <div
                            style="display:flex; justify-content:flex-end; gap:12px; margin-top:24px; padding-top:16px; border-top:1px solid #e2e8f0;">
                            <button type="button" onclick="closeModal()" class="btn"
                                style="background:#f1f5f9; color:#475569;">Batal</button>
                            <button type="submit" class="btn btn-primary"
                                style="background:#ef4444; border-color:#ef4444;">Lanjut ke Pembayaran</button>
                        </div>
                    </form>
                </div>
            </div>

        </div>
    </section>
@endsection

@push('scripts')
    <script>
        const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

        // Cart Updates
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

        // Modal Logic
        const modal = document.getElementById('logisticsModal');

        // Check if cart has hardware/plumbing (we simulated this with `isLarge` mapped to data-category)
        const hasHardware = document.querySelector('[data-category="hardware"]') !== null;

        function openModal() {
            modal.style.display = 'flex';
            evaluateConditions();
        }

        function closeModal() {
            modal.style.display = 'none';
        }

        function evaluateConditions() {
            // Logic for JNE (must have hardware/plumbing)
            const jneCard = document.getElementById('jneCard');
            const jneRadio = document.getElementById('jneRadio');
            if (!hasHardware) {
                jneCard.style.opacity = '0.5';
                jneRadio.disabled = true;
                if (jneRadio.checked) jneRadio.checked = false;
            } else {
                jneCard.style.opacity = '1';
                jneRadio.disabled = false;
            }
        }

        function toggleAddressForm() {
            const method = document.querySelector('input[name="shippingMethod"]:checked')?.value;
            const detailedForm = document.getElementById('detailedAddressForm');
            const reqFields = document.querySelectorAll('.dt-req');

            // Modal reset height when toggling form
            if (method === "Ambil di Toko") {
                detailedForm.style.display = 'none';
                reqFields.forEach(el => el.removeAttribute('required'));
            } else {
                detailedForm.style.display = 'block';
                reqFields.forEach(el => el.setAttribute('required', 'required'));
            }
        }

        function prepareAddress() {
            const method = document.querySelector('input[name="shippingMethod"]:checked')?.value;
            if (!method) return false;

            if (method === "Ambil di Toko") {
                document.getElementById('finalAddress').value = "Ambil Di Toko Sinar Abadi Dampit, Malang (+62 8123388670)";
                return true;
            }

            const fname = document.getElementById('dt_fname').value;
            const lname = document.getElementById('dt_lname').value;
            const address = document.getElementById('dt_address').value;
            const landmark = document.getElementById('dt_landmark').value;
            const province = document.getElementById('dt_province').value;
            const city = document.getElementById('dt_city').value;
            const district = document.getElementById('dt_district').value;
            const postal = document.getElementById('dt_postal').value;

            // Validation for Kurir Toko Sinar Abadi strictly
            if (method === "Kurir Toko Sinar Abadi") {
                if (!city.toLowerCase().includes('malang')) {
                    alert("Pengiriman Kurir Toko hanya diizinkan untuk area/Kota Malang. Silahkan ubah Kota/Kabupaten Anda.");
                    return false;
                }
            }

            // Combine into logical address string
            const fullAdr = `${fname} ${lname}, ${address} ${landmark ? '(Patokan: ' + landmark + ')' : ''}, Kec. ${district}, ${city}, ${province}, Indonesia ${postal}`;
            document.getElementById('finalAddress').value = fullAdr;

            return true;
        }
    </script>
@endpush