<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import { ref, computed } from 'vue';
import { avianColors, avitexColors, emcoStandarColors, emcoGunungColors, emcoBintangColors, aquaproofColors, decolithColors, noDropColors } from '@/data/paintColors';

const props = defineProps({
    product: {
        type: Object,
        required: true,
    }
});

const page = usePage();
const auth = computed(() => page.props.auth);

const isSemen = props.product.category === 'Semen';
const isCat = props.product.category.toLowerCase().includes('cat');
const isBesi = props.product.category.toLowerCase().includes('besi') || props.product.name.toLowerCase().includes('besi beton');
const isKloset = props.product.category.toLowerCase().includes('kloset') || props.product.name.toLowerCase().includes('kloset');
const isKeramikGranite = props.product.category.toLowerCase().includes('keramik') || props.product.name.toLowerCase().includes('keramik') || props.product.category.toLowerCase().includes('granit') || props.product.name.toLowerCase().includes('granit');
const isPipa = props.product.category.toLowerCase().includes('pipa') || props.product.name.toLowerCase().includes('pipa');
const isBuahGroup = ['engsel', 'kuas', 'kunci pintu', 'lampu'].some(kw => props.product.category.toLowerCase().includes(kw) || props.product.name.toLowerCase().includes(kw));
const isPerkakas = props.product.category.toLowerCase().includes('perkakas');

let weightKg = 0;
const weightMatch = props.product.name.match(/(\d+(?:\.\d+)?)\s*kg/i);
if (weightMatch) {
    weightKg = parseFloat(weightMatch[1]);
}

let minPurchase = props.product.minPurchase || 1;
let unit = props.product.unit || '';

if (!props.product.unit) {
    unit = 'Pcs';
    if (isSemen) {
        minPurchase = 10;
        unit = 'Sak';
    } else if (isCat) {
        if (weightKg >= 1 && weightKg <= 5) {
            minPurchase = 1;
            unit = 'Galon';
        } else if (weightKg >= 20 && weightKg <= 25) {
            minPurchase = 1;
            unit = 'Pail';
        }
    } else if (isBesi) {
        minPurchase = 1;
        unit = 'Batang';
    } else if (isKloset) {
        minPurchase = 1;
        unit = 'Buah';
    } else if (isKeramikGranite) {
        minPurchase = 1;
        unit = 'Dus';
    } else if (isPipa) {
        minPurchase = 1;
        unit = 'Batang';
    } else if (isBuahGroup) {
        minPurchase = 1;
        unit = 'Buah';
    } else if (isPerkakas) {
        minPurchase = 1;
        unit = 'Unit';
    }
}

const quantity = ref(minPurchase);

const displayPrice = computed(() => {
    let base = props.product.price;
    if (props.product.variants && props.product.variants.length > 0) {
        const variant = props.product.variants.find(v => v.name === selectedColor.value);
        if (variant && variant.price > 0) {
            return variant.price;
        }
    }
    return base;
});

const subtotal = computed(() => {
    return displayPrice.value * quantity.value;
});

const decreaseQty = () => {
    if (quantity.value > minPurchase) quantity.value--;
};

const increaseQty = () => {
    if (quantity.value < props.product.stock) quantity.value++;
};

const formatPrice = (price) => {
    return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
    }).format(price).replace('Rp', 'Rp ');
};

const getVariantId = () => {
    if (props.product.variants && props.product.variants.length > 0) {
        const variant = props.product.variants.find(v => v.name === selectedColor.value);
        if (variant) return variant.id;
    }
    return null;
};

const handleAddToCart = () => {
    if (auth.value.role !== 'customer') {
        router.visit('/login');
        return;
    }
    
    router.post('/cart/add', {
        id: props.product.id,
        name: props.product.name,
        price: displayPrice.value,
        img: props.product.img || '',
        weight: props.product.weight || 0,
        length: props.product.length || 1,
        width: props.product.width || 1,
        height: props.product.height || 1,
        stock: props.product.stock,
        qty: quantity.value,
        minPurchase: minPurchase,
        color: selectedColor.value,
        variantId: getVariantId(),
    }, {
        preserveScroll: true
    });
};

const sharePage = () => {
    if (navigator.share) {
        navigator.share({
            title: props.product.name,
            url: window.location.href
        }).catch(console.error);
    } else {
        navigator.clipboard.writeText(window.location.href);
        alert('Tautan disalin ke clipboard!');
    }
};

const activeTab = ref('spesifikasi');

const getMerek = () => {
    if (props.product.brand) return props.product.brand;
    return props.product.name.split(' ')[0];
};

const getWeight = () => {
    if (props.product.weight > 0) {
        const kg = props.product.weight / 1000;
        const gramStr = new Intl.NumberFormat('id-ID').format(props.product.weight);
        const kgStr = new Intl.NumberFormat('id-ID', {maximumFractionDigits: 2}).format(kg);
        return `${gramStr} Gram / ${kgStr} Kg`;
    }
    if (weightKg > 0) {
        const gramStr = new Intl.NumberFormat('id-ID').format(weightKg * 1000);
        return `${gramStr} Gram / ${weightKg} Kg`;
    }
    return '2.000 Gram / 2 Kg';
};

const getWaLink = () => {
    const text = `Halo CS Sinar Abadi, saya mau bertanya tentang produk ${props.product.name}`;
    return `https://wa.me/6281945122202?text=${encodeURIComponent(text)}`;
};

const currentColors = computed(() => {
    if (props.product.variants && props.product.variants.length > 0) {
        return props.product.variants.map(v => v.name);
    }
    const name = props.product.name.toLowerCase();
    if (name.includes('avian')) return avianColors;
    if (name.includes('avitex')) return avitexColors;
    if (name.includes('emco')) {
        if (name.includes('bintang')) return emcoBintangColors;
        if (name.includes('gunung')) return emcoGunungColors;
        return emcoStandarColors;
    }
    if (name.includes('aquaproof')) return aquaproofColors;
    if (name.includes('decolith')) return decolithColors;
    if (name.includes('no drop')) return noDropColors;
    return [];
});

const getColorCategory = (colorName) => {
    const c = colorName.toLowerCase();
    // Merah/Pink
    if (c.includes('red') || c.includes('merah') || c.includes('pink') || c.includes('peach')
        || c.includes('salmon') || c.includes('ballerina') || c.includes('blush') || c.includes('barbecue')
        || c.includes('cherry') || c.includes('passion') || c.includes('fiesta') || c.includes('orchid')
        || c.includes('terakota') || c.includes('terrakota') || c.includes('delima') || c.includes('markisa')
        || c.includes('balado') || c.includes('dendeng') || c.includes('rendang') || c.includes('sambal')
        || c.includes('brinjal') || c.includes('oxide') || c.includes('star') || c.includes('maroon')
        || c.includes('vermillion') || c.includes('sunrise') || c.includes('chile')) return 'Merah/Pink';
    // Biru
    if (c.includes('blue') || c.includes('cyan') || c.includes('teal') || c.includes('navy')
        || c.includes('biru') || c.includes('mediterranean') || c.includes('malibu')
        || c.includes('bubble gum') || c.includes('tumpeng')) return 'Biru';
    // Hijau
    if (c.includes('green') || c.includes('mint') || c.includes('olive')
        || c.includes('hijau') || c.includes('wasabi') || c.includes('lumut')
        || c.includes('lontong') || c.includes('sambel ijo') || c.includes('jungle')
        || c.includes('emerald') || c.includes('pandan') || c.includes('laurel')
        || c.includes('madagascar') || c.includes('peace')) return 'Hijau';
    // Kuning/Krem
    if (c.includes('yellow') || c.includes('cream') || c.includes('beige') || c.includes('ivory')
        || c.includes('kuning') || c.includes('lemon') || c.includes('golden')
        || c.includes('nugget') || c.includes('ocker') || c.includes('buttermilk')
        || c.includes('gulai') || c.includes('kentang') || c.includes('opor')
        || c.includes('sunny') || c.includes('banana') || c.includes('champagne')
        || c.includes('sun flower') || c.includes('sunshine')) return 'Kuning/Krem';
    // Oranye
    if (c.includes('orange') || c.includes('sunkist') || c.includes('pumpkin')
        || c.includes('carrot') || c.includes('flame') || c.includes('tangerine')
        || c.includes('apricot') || c.includes('sunset') || c.includes('fiesta')) return 'Oranye';
    // Cokelat
    if (c.includes('brown') || c.includes('coklat') || c.includes('mocca')
        || c.includes('mocha') || c.includes('sahara') || c.includes('cendana')
        || c.includes('borobudur') || c.includes('monas') || c.includes('buckskin')
        || c.includes('safari') || c.includes('suede') || c.includes('leather')
        || c.includes('saddle') || c.includes('cinnamon') || c.includes('mahogany')
        || c.includes('caramel') || c.includes('honey') || c.includes('copra')
        || c.includes('semur') || c.includes('tongkol') || c.includes('teri')
        || c.includes('santan') || c.includes('pepes')) return 'Cokelat';
    // Monokrom
    if (c.includes('grey') || c.includes('putih') || c.includes('hitam') || c.includes('silver')
        || c.includes('black') || c.includes('white') || c.includes('abu')
        || c.includes('cement') || c.includes('platinum') || c.includes('rawon')
        || c.includes('transparan') || c.includes('smoke') || c.includes('grafit')
        || c.includes('midnight') || c.includes('dover') || c.includes('dove')) return 'Monokrom';
    // Ungu
    if (c.includes('purple') || c.includes('lilac') || c.includes('violet')
        || c.includes('violetta') || c.includes('grape') || c.includes('powder violet')) return 'Ungu';
    return 'Lainnya';
};

const colorCategories = computed(() => {
    if (currentColors.value.length === 0) return [];
    const categories = new Set();
    currentColors.value.forEach(c => categories.add(getColorCategory(c)));
    return ['Semua', ...Array.from(categories)].sort();
});

const selectedColorCategory = ref('Semua');

const filteredColors = computed(() => {
    if (selectedColorCategory.value === 'Semua') return currentColors.value;
    return currentColors.value.filter(c => getColorCategory(c) === selectedColorCategory.value);
});

const selectedColor = ref(currentColors.value.length > 0 ? currentColors.value[0] : null);
</script>

<template>
    <Head :title="product.name" />
    <AppLayout>
        <div class="container" style="padding-top: 40px; padding-bottom: 80px;">
            <div class="breadcrumb">
                <Link href="/">Beranda</Link> &gt; 
                <Link href="/katalog">Katalog</Link> &gt; 
                <Link :href="`/katalog?category=${encodeURIComponent(product.category)}`">{{ product.category }}</Link> &gt; 
                <span>{{ product.name }}</span>
            </div>

            <div class="detail-grid">
                <!-- Kiri: Gambar -->
                <div class="detail-left card">
                    <img :src="product.img || 'https://placehold.co/400x300/e2e8f0/64748b?text=No+Image'" :alt="product.name" class="main-image">
                    

                </div>

                <!-- Tengah: Info -->
                <div class="detail-mid card">
                    <h1 class="product-title">{{ product.name }}</h1>
                    <div class="product-price">{{ formatPrice(displayPrice) }}</div>
                    
                    <div class="badges">
                        <span class="badge" v-if="product.stock <= 10">Stok Terbatas</span>

                    </div>

                    <!-- Pilihan Warna -->
                    <div v-if="currentColors.length > 0" class="color-selection" style="margin-bottom: 24px;">
                        <template v-if="!isKloset">
                            <div style="font-weight: 600; color: #0f172a; margin-bottom: 12px; font-size: 14px;">Kategori Warna:</div>
                            <div style="display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 16px;">
                                <button
                                    v-for="cat in colorCategories"
                                    :key="cat"
                                    @click="selectedColorCategory = cat"
                                    :style="{
                                        padding: '6px 12px',
                                        fontSize: '12px',
                                        fontWeight: '600',
                                        borderRadius: '20px',
                                        border: selectedColorCategory === cat ? '1px solid #e11d48' : '1px solid #cbd5e1',
                                        background: selectedColorCategory === cat ? '#e11d48' : '#f8fafc',
                                        color: selectedColorCategory === cat ? 'white' : '#475569',
                                        cursor: 'pointer',
                                        transition: 'all 0.2s',
                                    }"
                                >
                                    {{ cat }}
                                </button>
                            </div>
                        </template>

                        <div style="font-weight: 600; color: #0f172a; margin-bottom: 12px; font-size: 15px;">Warna: <span style="font-weight: 500; color: #334155;">{{ selectedColor }}</span></div>
                        <div style="display: flex; flex-wrap: wrap; gap: 8px;">
                            <button 
                                v-for="color in filteredColors" 
                                :key="color"
                                @click="selectedColor = color"
                                :style="{
                                    padding: '8px 12px',
                                    fontSize: '13px',
                                    fontWeight: '500',
                                    borderRadius: '6px',
                                    border: selectedColor === color ? '2px solid #0f766e' : '1px solid #cbd5e1',
                                    background: selectedColor === color ? '#f0fdfa' : 'white',
                                    color: selectedColor === color ? '#0f766e' : '#475569',
                                    cursor: 'pointer',
                                    transition: 'all 0.2s',
                                }"
                            >
                                {{ color }}
                            </button>
                        </div>
                    </div>

                    <div class="tabs">
                        <div class="tab" :class="{ active: activeTab === 'spesifikasi' }" @click="activeTab = 'spesifikasi'">Spesifikasi Produk</div>
                        <div class="tab" :class="{ active: activeTab === 'deskripsi' }" @click="activeTab = 'deskripsi'">Deskripsi Produk</div>
                    </div>

                    <div class="tab-content" v-if="activeTab === 'spesifikasi'">
                        <div class="spec-row">
                            <div class="spec-label">Satuan</div>
                            <div class="spec-value">{{ unit }}</div>
                        </div>
                        <div class="spec-row">
                            <div class="spec-label">Pembelian minimal</div>
                            <div class="spec-value">{{ minPurchase }} {{ unit }}</div>
                        </div>
                        <div class="spec-row">
                            <div class="spec-label">Berat</div>
                            <div class="spec-value">{{ getWeight() }}</div>
                        </div>
                        <div class="spec-row" v-if="product.length && product.length > 1">
                            <div class="spec-label">Dimensi (P×L×T)</div>
                            <div class="spec-value">{{ product.length }} × {{ product.width }} × {{ product.height }} cm</div>
                        </div>
                        <div class="spec-row">
                            <div class="spec-label">Merek</div>
                            <div class="spec-value" style="color: var(--color-primary); font-weight: 600;">{{ getMerek() }}</div>
                        </div>
                        <div class="spec-row">
                            <div class="spec-label">Sub kategori</div>
                            <div class="spec-value" style="color: var(--color-primary); font-weight: 600;">{{ product.category }}</div>
                        </div>
                    </div>

                    <div class="tab-content" v-if="activeTab === 'deskripsi'">
                        <p>Produk material bangunan Sinar Abadi. Jaminan kualitas terbaik dan orisinal untuk kebutuhan konstruksi Anda.</p>
                        <p v-if="isSemen">Perhatian: Pembelian minimal untuk produk Semen adalah {{ minPurchase }} sak.</p>
                    </div>
                </div>

                <!-- Kanan: Keranjang -->
                <div class="detail-right">
                    <div class="promo-box mb-4">
                        <div style="font-weight: 600; color: #0f172a;">Potensi Harga Terbaik</div>
                        <div style="font-size: 13px; color: #475569;">Beli lebih banyak, hemat ongkir!</div>
                    </div>

                    <div class="card">
                        <h3 style="font-size: 18px; margin-bottom: 8px;">Subtotal</h3>
                        <div class="subtotal-price">{{ formatPrice(subtotal) }}</div>

                        <div style="margin-top: 20px; margin-bottom: 8px; font-weight: 500; font-size: 14px; color: #334155;">Atur Jumlah Pembelian</div>
                        
                        <div class="qty-control">
                            <button class="qty-btn" @click="decreaseQty" :disabled="quantity <= minPurchase">-</button>
                            <input type="number" class="qty-input" v-model.number="quantity" :min="minPurchase" :max="product.stock" readonly>
                            <span style="padding-right: 8px; color: #475569; font-weight: 500;">x {{ unit }}</span>
                            <button class="qty-btn" @click="increaseQty" :disabled="quantity >= product.stock">+</button>
                        </div>
                        
                        <div v-if="product.stock <= 0" class="text-danger mt-2" style="font-size: 14px; font-weight: 600;">
                            Stok Habis
                        </div>
                        <div v-else-if="product.stock < quantity" class="text-danger mt-2" style="font-size: 14px;">
                            Sisa stok: {{ product.stock }}
                        </div>

                        <button 
                            class="btn btn-outline w-100 mt-4 mb-4" 
                            style="border-color: #cbd5e1; color: #0f172a; padding: 12px;" 
                            @click="handleAddToCart"
                            :disabled="product.stock < minPurchase"
                        >
                            <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor" style="vertical-align: middle; margin-right: 8px;">
                                <path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/>
                            </svg>
                            Masukkan Keranjang
                        </button>

                        <div class="delivery-estimate">
                            <strong>Estimasi Pengiriman</strong><br>
                            Malang: <span style="font-weight: 600;">2-7 hari kerja</span>
                        </div>

                        <a :href="getWaLink()" target="_blank" class="btn w-100 mt-4" style="background: #f1f5f9; color: #334155; border: 1px solid #e2e8f0; font-size: 14px; display: block; text-align: center; text-decoration: none;">
                            <svg viewBox="0 0 24 24" width="16" height="16" fill="#25D366" style="vertical-align: middle; margin-right: 6px;">
                                <path d="M12.01 2.01A10 10 0 0 0 2 12c0 1.93.55 3.73 1.52 5.25L2 22l4.88-1.52A9.95 9.95 0 0 0 12.01 22c5.52 0 10-4.48 10-10s-4.48-10-10-10zm0 18.33c-1.63 0-3.18-.42-4.52-1.22l-.32-.19-3.36 1.05.89-3.27-.21-.34A8.29 8.29 0 0 1 3.68 12c0-4.6 3.74-8.34 8.33-8.34s8.33 3.74 8.33 8.34-3.74 8.34-8.33 8.34zm4.57-6.23c-.25-.13-1.49-.74-1.72-.82-.23-.09-.4-.13-.57.13-.17.25-.65.82-.79.99-.15.17-.29.19-.54.06-1.07-.54-2.02-1.39-2.73-2.39-.2-.29.04-.37.26-.78.07-.13.11-.22.17-.35.13-.25.06-.48-.06-.74-.13-.25-.57-1.38-.78-1.89-.21-.5-.41-.43-.57-.44h-.49c-.21 0-.54.08-.82.39s-1.09 1.07-1.09 2.6c0 1.54 1.12 3.02 1.27 3.23.15.21 2.2 3.36 5.33 4.71 1.9.82 2.65.88 3.55.74.96-.15 2.12-.87 2.42-1.71.3-.84.3-1.56.21-1.71-.09-.15-.32-.23-.57-.36z"/>
                            </svg>
                            Hubungi Sinar Abadi
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </AppLayout>
</template>

<style scoped>
.breadcrumb {
    font-size: 14px;
    color: #64748b;
    margin-bottom: 24px;
}
.breadcrumb a {
    color: var(--color-primary);
    text-decoration: none;
}
.breadcrumb a:hover {
    text-decoration: underline;
}

.detail-grid {
    display: grid;
    grid-template-columns: 300px 1fr 320px;
    gap: 24px;
    align-items: start;
}

@media (max-width: 992px) {
    .detail-grid {
        grid-template-columns: 1fr;
    }
}

.card {
    background: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    border: 1px solid #e2e8f0;
}

.main-image {
    width: 100%;
    height: auto;
    object-fit: contain;
    border-radius: 8px;
}

.product-title {
    font-size: 24px;
    font-weight: 700;
    color: #0f172a;
    margin-bottom: 8px;
    line-height: 1.3;
}

.product-price {
    font-size: 32px;
    font-weight: 800;
    color: var(--color-primary);
    margin-bottom: 16px;
}

.badges {
    display: flex;
    gap: 8px;
    margin-bottom: 32px;
}

.badge {
    background: #fef3c7;
    color: #d97706;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 600;
}

.badge-outline {
    border: 1px solid #10b981;
    color: #10b981;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 600;
}

.tabs {
    display: flex;
    border-bottom: 2px solid #e2e8f0;
    margin-bottom: 20px;
}

.tab {
    padding: 12px 24px;
    font-weight: 600;
    color: #64748b;
    cursor: pointer;
    border-bottom: 2px solid transparent;
    margin-bottom: -2px;
    transition: all 0.2s;
}

.tab:hover {
    color: #0f172a;
}

.tab.active {
    color: var(--color-primary);
    border-bottom-color: var(--color-primary);
}

.tab-content {
    font-size: 14px;
    line-height: 1.6;
    color: #334155;
}

.spec-row {
    display: flex;
    padding: 12px 0;
    border-bottom: 1px dashed #e2e8f0;
}

.spec-label {
    width: 200px;
    color: #64748b;
    font-weight: 500;
}

.spec-value {
    flex: 1;
    color: #0f172a;
}

.promo-box {
    background: #e0f2fe;
    border: 1px solid #bae6fd;
    border-radius: 8px;
    padding: 16px;
}

.subtotal-price {
    font-size: 24px;
    font-weight: 800;
    color: var(--color-primary);
}

.qty-control {
    display: flex;
    align-items: center;
    border: 1px solid #cbd5e1;
    border-radius: 6px;
    padding: 4px;
    background: #fff;
}

.qty-btn {
    width: 36px;
    height: 36px;
    background: transparent;
    border: none;
    font-size: 20px;
    color: #475569;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
}

.qty-btn:disabled {
    opacity: 0.3;
    cursor: not-allowed;
}

.qty-input {
    flex: 1;
    text-align: center;
    border: none;
    font-weight: 600;
    color: #0f172a;
    width: 60px;
}

.qty-input:focus {
    outline: none;
}

.delivery-estimate {
    font-size: 13px;
    color: #475569;
    padding-top: 16px;
    border-top: 1px dashed #e2e8f0;
    line-height: 1.5;
}
</style>
