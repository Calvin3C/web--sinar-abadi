@extends('layouts.app')

@section('title', 'Katalog Lengkap – Sinar Abadi')

@section('content')
<section class="section active">
    <div class="container">
        <h2 class="section-title">Katalog Lengkap</h2>

        {{-- Toolbar: Search + Filter + Sort --}}
        <div class="toolbar">
            <div class="search-box">
                <svg viewBox="0 0 24 24" width="20" height="20" fill="#64748b"><path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>
                <form method="GET" action="{{ route('katalog') }}" id="catalog-form">
                    <input type="text" name="search" id="search-input"
                           placeholder="Cari nama produk, merek, atau tipe..."
                           value="{{ $filters['search'] ?? '' }}">
                    <input type="hidden" name="category" value="{{ $filters['category'] ?? 'all' }}" id="filter-cat-hidden">
                    <input type="hidden" name="sort" value="{{ $filters['sort'] ?? 'rekomendasi' }}" id="sort-hidden">
                </form>
            </div>
            <div class="d-flex gap-4 align-center">
                <select class="form-input" id="filter-cat" style="width:auto; padding:10px 16px;"
                        onchange="document.getElementById('filter-cat-hidden').value=this.value; document.getElementById('catalog-form').submit();">
                    <option value="all" {{ ($filters['category'] ?? 'all') === 'all' ? 'selected' : '' }}>Semua Kategori</option>
                    @foreach($categories as $cat)
                        <option value="{{ $cat }}" {{ ($filters['category'] ?? '') === $cat ? 'selected' : '' }}>{{ $cat }}</option>
                    @endforeach
                </select>
                <select class="form-input" id="sort-select" style="width:auto; padding:10px 16px;"
                        onchange="document.getElementById('sort-hidden').value=this.value; document.getElementById('catalog-form').submit();">
                    <option value="rekomendasi" {{ ($filters['sort'] ?? '') === 'rekomendasi' ? 'selected' : '' }}>Terlaris</option>
                    <option value="termurah" {{ ($filters['sort'] ?? '') === 'termurah' ? 'selected' : '' }}>Harga Termurah</option>
                    <option value="termahal" {{ ($filters['sort'] ?? '') === 'termahal' ? 'selected' : '' }}>Harga Termahal</option>
                    <option value="az" {{ ($filters['sort'] ?? '') === 'az' ? 'selected' : '' }}>A - Z</option>
                </select>
            </div>
        </div>

        {{-- Product Grid --}}
        @if(count($paginatedProducts) > 0)
            <div class="product-grid">
                @foreach($paginatedProducts as $product)
                    @include('components.product-card', ['product' => $product])
                @endforeach
            </div>
        @else
            <div class="text-center" style="padding: 60px 20px; color: #64748b;">
                <svg viewBox="0 0 24 24" width="80" height="80" fill="#cbd5e1"><path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>
                <h3 style="margin-top: 16px;">Produk Tidak Ditemukan</h3>
                <p>Coba ubah kata kunci pencarian atau filter kategori.</p>
            </div>
        @endif

        {{-- Pagination --}}
        @if($totalPages > 1)
            <div class="pagination">
                @for($i = 1; $i <= $totalPages; $i++)
                    <a href="{{ route('katalog', array_merge($filters, ['page' => $i])) }}"
                       class="page-btn {{ $i === $page ? 'active' : '' }}">{{ $i }}</a>
                @endfor
            </div>
        @endif

        <p class="text-muted text-center mt-4" style="font-size:13px;">
            Menampilkan {{ count($paginatedProducts) }} dari {{ $total }} produk
        </p>
    </div>
</section>
@endsection

@push('scripts')
<script>
    // Submit search on Enter
    document.getElementById('search-input').addEventListener('keydown', function(e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            document.getElementById('catalog-form').submit();
        }
    });
</script>
@endpush
